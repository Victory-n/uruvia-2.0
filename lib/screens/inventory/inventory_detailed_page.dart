import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:uruvia/constants/colors.dart';
import 'package:uruvia/offline/inventory_repository.dart';
import 'package:uruvia/widgets/custom_text.dart';
import 'package:uruvia/offline/database_helper.dart';
import 'package:uruvia/screens/tasks/task_model.dart';
import 'package:uruvia/screens/tasks/tasks_repository.dart';
import 'package:uruvia/services/notification_service.dart';

class InventoryDetailedPage extends StatefulWidget {
  final Map<String, dynamic> product;

  const InventoryDetailedPage({super.key, required this.product});

  @override
  State<InventoryDetailedPage> createState() => _InventoryDetailedPageState();
}

class _InventoryDetailedPageState extends State<InventoryDetailedPage> {
  late int _stock;
  late bool _lowStockAlert;
  late TextEditingController _thresholdController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _stock = widget.product['stock'] as int;
    _lowStockAlert = widget.product['low_stock_alert'] == true;
    _thresholdController = TextEditingController(text: (widget.product['threshold'] ?? 10).toString());
  }

  @override
  void dispose() {
    _thresholdController.dispose();
    super.dispose();
  }

  void _incrementStock() {
    setState(() {
      _stock++;
    });
  }

  void _decrementStock() {
    if (_stock > 0) {
      setState(() {
        _stock--;
      });
    }
  }

  Future<void> _updateProduct() async {
    setState(() {
      _isLoading = true;
    });

    final threshold = int.tryParse(_thresholdController.text) ?? 10;
    
    final updates = {
      'stock': _stock,
      'threshold': threshold,
      'low_stock_alert': _lowStockAlert,
    };

    try {
      await InventoryRepository.instance.updateInventoryItem(widget.product['id'] as String, updates);
      
      final itemId = widget.product['id'] as String? ?? '';
      final itemName = widget.product['name'] as String? ?? 'Item';
      final sku = widget.product['sku'] as String? ?? '';

      if (_stock <= threshold) {
        final autoCreate = await DatabaseHelper.instance.getSetting('setting_auto_task_low_stock', defaultValue: true);
        if (autoCreate) {
          final task = Task(
            id: 'low_stock_$itemId',
            title: "Reorder: $itemName",
            description: "Stock is low: $_stock items remaining (Threshold: $threshold). SKU: $sku",
            dueDate: DateTime.now().add(const Duration(days: 2)),
            type: 'inventory',
            relatedItemId: itemId,
            createdAt: DateTime.now(),
          );
          await TasksRepository.instance.addTask(task);
        } else {
          final existingTasks = await TasksRepository.instance.getTasks();
          final hasPending = existingTasks.any((t) => t.relatedItemId == itemId && !t.isCompleted && t.type == 'inventory');
          if (!hasPending && mounted) {
            await _showLowStockPromptDialog(itemId, itemName, _stock, threshold, sku);
          }
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Product updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating product: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _showLowStockPromptDialog(String itemId, String itemName, int stock, int threshold, String sku) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        title: Row(
          children: [
            const Icon(CupertinoIcons.exclamationmark_triangle_fill, color: Colors.orange, size: 24.0),
            const SizedBox(width: 8.0),
            googleSansText(
              text: "Low Stock Alert",
              colors: ConstantColor.headingTextPrimary,
              fontWeight: FontWeight.bold,
              size: 18.0,
            ),
          ],
        ),
        content: googleSansText(
          text: "$itemName (SKU: $sku) is low on stock ($stock remaining, threshold is $threshold). Would you like to set a reorder task?",
          colors: ConstantColor.paragraphTextPrimary,
          fontWeight: FontWeight.normal,
          size: 14.5,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: googleSansText(
              text: "Ignore",
              colors: ConstantColor.paragraphTextSecondary,
              fontWeight: FontWeight.bold,
              size: 14.0,
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final task = Task(
                id: 'low_stock_$itemId',
                title: "Reorder: $itemName",
                description: "Stock is low: $stock items remaining (Threshold: $threshold). SKU: $sku",
                dueDate: DateTime.now().add(const Duration(days: 2)),
                type: 'inventory',
                relatedItemId: itemId,
                createdAt: DateTime.now(),
              );
              await TasksRepository.instance.addTask(task);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ConstantColor.blueBackground,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              elevation: 0.0,
            ),
            child: googleSansText(
              text: "Set Task",
              colors: Colors.white,
              fontWeight: FontWeight.bold,
              size: 14.0,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteProduct() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text('Are you sure you want to delete "${widget.product['name']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await InventoryRepository.instance.deleteInventoryItem(widget.product['id'] as String);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Product deleted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting product: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final retailPrice = widget.product['retail_price'] ?? 0.0;
    final supplier = widget.product['supplier'] ?? 'Generic Supplier';

    return Scaffold(
      backgroundColor: ConstantColor.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: interText(
          text: "Product Details",
          colors: Colors.black,
          fontWeight: FontWeight.bold,
          size: 18.0,
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Platform.isAndroid ? Icons.arrow_back : CupertinoIcons.back,
            color: Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
                  child: Column(
                    children: [
                      // Product Image Header Card
                      Hero(
                        tag: 'hero-image-${widget.product['id']}',
                        child: Container(
                          height: 260,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            image: DecorationImage(
                              image: AssetImage(widget.product['image_url'] ?? "assets/img/inventory/inventory-1.png"),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16.0),

                      // Product Info Card
                      Container(
                        padding: const EdgeInsets.all(20.0),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10.0),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            googleSansText(
                              text: widget.product['name'] ?? 'Product Information',
                              colors: ConstantColor.paragraphTextPrimary,
                              fontWeight: FontWeight.bold,
                              size: 17.0,
                            ),
                            const SizedBox(height: 4),
                            Divider(color: Colors.grey.shade100),
                            const SizedBox(height: 8),
                            
                            // SKU
                            googleSansText(text: "SKU Code", colors: ConstantColor.paragraphTextSecondary, fontWeight: FontWeight.bold, size: 11.0),
                            const SizedBox(height: 4),
                            googleSansText(text: widget.product['sku'] ?? 'N/A', colors: ConstantColor.paragraphTextPrimary, fontWeight: FontWeight.bold, size: 15.0),
                            const SizedBox(height: 16),
                            
                            // Retail Price
                            googleSansText(text: "Retail Price", colors: ConstantColor.paragraphTextSecondary, fontWeight: FontWeight.bold, size: 11.0),
                            const SizedBox(height: 4),
                            googleSansText(text: "₦${retailPrice.toStringAsFixed(2)}", colors: ConstantColor.paragraphTextPrimary, fontWeight: FontWeight.bold, size: 15.0),
                            const SizedBox(height: 16),
                            
                            // Supplier
                            googleSansText(text: "Supplier", colors: ConstantColor.paragraphTextSecondary, fontWeight: FontWeight.bold, size: 11.0),
                            const SizedBox(height: 4),
                            googleSansText(text: supplier, colors: ConstantColor.paragraphTextPrimary, fontWeight: FontWeight.bold, size: 15.0),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16.0),

                      // Stock adjustment card
                      Container(
                        padding: const EdgeInsets.all(20.0),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          color: const Color(0xFF131B2E), // Dark theme for stock control
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    googleSansText(text: "Current Stock", colors: Colors.white, fontWeight: FontWeight.bold, size: 16.0),
                                    const SizedBox(height: 2),
                                    googleSansText(text: "Adjust quantities below", colors: Colors.grey.shade400, fontWeight: FontWeight.normal, size: 12.0),
                                  ],
                                ),
                                Icon(
                                  Platform.isAndroid ? Icons.inventory_outlined : CupertinoIcons.archivebox,
                                  color: Colors.green,
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                googleSansText(text: "$_stock", colors: Colors.white, fontWeight: FontWeight.bold, size: 44.0),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: Row(
                                    children: [
                                      IconButton(
                                        onPressed: _decrementStock,
                                        icon: Icon(
                                          Platform.isAndroid ? Icons.remove_rounded : CupertinoIcons.minus,
                                          color: ConstantColor.blueBackground,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 24,
                                        child: VerticalDivider(
                                          color: Colors.grey,
                                          thickness: 1.2,
                                          width: 8,
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: _incrementStock,
                                        icon: Icon(
                                          Platform.isAndroid ? Icons.add : CupertinoIcons.add,
                                          color: ConstantColor.blueBackground,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16.0),

                      // Alerts card
                      Container(
                        padding: const EdgeInsets.all(20.0),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10.0),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Platform.isAndroid ? Icons.notifications_none : CupertinoIcons.bell,
                                  color: ConstantColor.paragraphTextPrimary,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                googleSansText(text: "Inventory Alert", colors: ConstantColor.paragraphTextPrimary, fontWeight: FontWeight.bold, size: 15.0),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Divider(color: Colors.grey.shade100),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    googleSansText(text: "Low Stock Warning", colors: ConstantColor.paragraphTextPrimary, fontWeight: FontWeight.bold, size: 14.0),
                                    const SizedBox(height: 2),
                                    googleSansText(text: "Notify when quantity drops below:", colors: ConstantColor.paragraphTextSecondary, fontWeight: FontWeight.normal, size: 12.0),
                                  ],
                                ),
                                Switch.adaptive(
                                  value: _lowStockAlert,
                                  onChanged: (bool value) {
                                    setState(() {
                                      _lowStockAlert = value;
                                    });
                                  },
                                  activeColor: Colors.white,
                                  activeTrackColor: ConstantColor.blueBackground,
                                ),
                              ],
                            ),
                            const SizedBox(height: 12.0),
                            Row(
                              children: [
                                Container(
                                  width: 80,
                                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(8.0),
                                    border: Border.all(color: Colors.grey.shade200),
                                  ),
                                  child: TextField(
                                    controller: _thresholdController,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      isDense: true,
                                    ),
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                googleSansText(text: "Units", colors: ConstantColor.paragraphTextPrimary, fontWeight: FontWeight.bold, size: 14.0),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24.0),

                      // Actions Card
                      Container(
                        padding: const EdgeInsets.all(20.0),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10.0),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            googleSansText(text: "ACTIONS", colors: ConstantColor.paragraphTextPrimary, fontWeight: FontWeight.bold, size: 13.0),
                            const SizedBox(height: 12),
                            
                            // Update Button
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: _updateProduct,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: ConstantColor.blueBackground,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                                  elevation: 0,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Platform.isAndroid ? Icons.check_circle_outline : CupertinoIcons.check_mark_circled,
                                      color: Colors.white,
                                      size: 18.0,
                                    ),
                                    const SizedBox(width: 8),
                                    googleSansText(text: "Update Product", colors: Colors.white, fontWeight: FontWeight.w700, size: 15.0),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            
                            // Delete Button
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: _deleteProduct,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFFDAD6),
                                  foregroundColor: Colors.red,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                                  side: const BorderSide(color: Colors.red),
                                  elevation: 0,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Platform.isAndroid ? Icons.delete_outlined : CupertinoIcons.delete,
                                      color: Colors.red,
                                      size: 18.0,
                                    ),
                                    const SizedBox(width: 8),
                                    googleSansText(text: "Delete Product", colors: Colors.red, fontWeight: FontWeight.w700, size: 15.0),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
