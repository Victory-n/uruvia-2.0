import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:uruvia/offline/connectivity_service.dart';
import 'package:uruvia/offline/inventory_repository.dart';
import 'package:uruvia/offline/database_helper.dart';
import 'package:uruvia/screens/tasks/task_model.dart';
import 'package:uruvia/screens/tasks/tasks_repository.dart';
import 'package:uruvia/services/notification_service.dart';
import 'package:uruvia/screens/inventory/add_inventory_page.dart';
import 'package:uruvia/screens/inventory/inventory_detailed_page.dart';
import '../../constants/colors.dart';
import '../../widgets/custom_column_heading_text.dart';
import '../../widgets/custom_text.dart';
import 'package:uruvia/classes/custom_snackbar.dart';

class InventoryMainPage extends StatefulWidget {
  const InventoryMainPage({super.key});

  @override
  State<InventoryMainPage> createState() => _InventoryMainPageState();
}

class _InventoryMainPageState extends State<InventoryMainPage> {
  List<Map<String, dynamic>> _items = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadItems();

    // Listen to connection changes to automatically refresh cache/status
    ConnectivityService.instance.isConnected.addListener(_onConnectionChanged);
  }

  @override
  void dispose() {
    ConnectivityService.instance.isConnected.removeListener(
      _onConnectionChanged,
    );
    super.dispose();
  }

  void _onConnectionChanged() {
    if (mounted) {
      _loadItems();
    }
  }

  Future<void> _loadItems() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      final items = await InventoryRepository.instance.getInventoryItems();
      if (mounted) {
        setState(() {
          _items = items;
          _isLoading = false;
        });
        _checkLowStockItems(items);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        CustomSnackbar.showFailed(context, 'Error loading inventory: $e');
      }
    }
  }

  Future<void> _checkLowStockItems(List<Map<String, dynamic>> items) async {
    final dbHelper = DatabaseHelper.instance;
    final autoCreate = await dbHelper.getSetting(
      'setting_auto_task_low_stock',
      defaultValue: true,
    );

    for (var item in items) {
      final int stock = item['stock'] as int? ?? 0;
      final int threshold = item['threshold'] as int? ?? 0;
      if (stock <= threshold) {
        final itemId = item['id'] as String? ?? '';
        final itemName = item['name'] as String? ?? 'Item';
        final sku = item['sku'] as String? ?? '';

        if (autoCreate) {
          // Auto create task
          final task = Task(
            id: 'low_stock_$itemId',
            title: "Reorder: $itemName",
            description:
                "Stock is low: $stock items remaining (Threshold: $threshold). SKU: $sku",
            dueDate: DateTime.now().add(const Duration(days: 2)),
            type: 'inventory',
            relatedItemId: itemId,
            createdAt: DateTime.now(),
          );
          await TasksRepository.instance.addTask(task);
        } else {
          // Check if a task is already pending
          final existingTasks = await TasksRepository.instance.getTasks();
          final hasPending = existingTasks.any(
            (t) =>
                t.relatedItemId == itemId &&
                !t.isCompleted &&
                t.type == 'inventory',
          );
          if (!hasPending) {
            // Show instant notification
            await NotificationService.instance.showInstantNotification(
              "Low Stock Alert: $itemName",
              "Stock is low: $stock remaining. Tap to create reorder task.",
            );
            // Show in-app dialog (only one at a time)
            if (mounted) {
              _showLowStockDialog(itemId, itemName, stock, threshold, sku);
              break;
            }
          }
        }
      }
    }
  }

  void _showLowStockDialog(
    String itemId,
    String itemName,
    int stock,
    int threshold,
    String sku,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        title: Row(
          children: [
            const Icon(
              CupertinoIcons.exclamationmark_triangle_fill,
              color: Colors.orange,
              size: 24.0,
            ),
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
          text:
              "$itemName (SKU: $sku) is low on stock ($stock remaining, threshold is $threshold). Would you like to set a reorder task?",
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
                description:
                    "Stock is low: $stock items remaining (Threshold: $threshold). SKU: $sku",
                dueDate: DateTime.now().add(const Duration(days: 2)),
                type: 'inventory',
                relatedItemId: itemId,
                createdAt: DateTime.now(),
              );
              await TasksRepository.instance.addTask(task);
              CustomSnackbar.showSuccess(
                context,
                "Reorder task created for $itemName",
              );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddInventoryPage()),
          );
          if (result == true) {
            _loadItems();
          }
        },
        backgroundColor: ConstantColor.blueBackground,
        child: Icon(
          Platform.isAndroid ? Icons.add : CupertinoIcons.add,
          color: Colors.white,
        ),
      ),
      appBar: AppBar(
        elevation: 1.0,
        backgroundColor: Colors.white,
        leading: Navigator.canPop(context)
            ? null
            : IconButton(
                icon: const Icon(
                  CupertinoIcons.bars,
                  color: ConstantColor.headingTextPrimary,
                ),
                onPressed: () => Scaffold.maybeOf(context)?.openDrawer(),
              ),
        centerTitle: true,
        title: interText(
          text: "Inventory",
          colors: Colors.black,
          fontWeight: FontWeight.bold,
          size: 20.0,
          textAlign: TextAlign.center,
          softWrap: true,
        ),
        automaticallyImplyLeading: true,
        actions: [
          ValueListenableBuilder<bool>(
            valueListenable: ConnectivityService.instance.isConnected,
            builder: (context, isOnline, _) {
              if (isOnline) {
                return IconButton(
                  onPressed: _loadItems,
                  icon: Platform.isAndroid
                      ? const Icon(
                          Icons.cloud_done_outlined,
                          color: ConstantColor.paragraphTextPrimary,
                        )
                      : const Icon(
                          CupertinoIcons.cloud_upload,
                          color: ConstantColor.paragraphTextPrimary,
                        ),
                );
              } else {
                return const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      Icon(Icons.cloud_off, color: Colors.red, size: 20.0),
                      SizedBox(width: 4.0),
                      Text(
                        "Offline",
                        style: TextStyle(
                          fontFamily: "Inter",
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 14.0,
                        ),
                      ),
                    ],
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadItems,
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _items.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 16.0,
                  ),
                  itemCount: _items.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 16.0,
                        ),
                        child: columnText(
                          headingText: interText(
                            text: "Inventory Management",
                            colors: Colors.black,
                            fontWeight: FontWeight.w600,
                            size: 24.0,
                            textAlign: TextAlign.center,
                            softWrap: true,
                          ),
                          subtext: googleSansText(
                            text: "track and manage your product stock levels.",
                            colors: ConstantColor.paragraphTextPrimary,
                            fontWeight: FontWeight.normal,
                            size: 14.0,
                            textAlign: TextAlign.center,
                            softWrap: true,
                          ),
                        ),
                      );
                    }

                    final item = _items[index - 1];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: _buildProductCard(item),
                    );
                  },
                ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.15),
        Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.inventory_2_outlined,
                  size: 64,
                  color: ConstantColor.paragraphTextSecondary,
                ),
                const SizedBox(height: 16.0),
                googleSansText(
                  text: "No inventory items found.",
                  colors: ConstantColor.paragraphTextPrimary,
                  fontWeight: FontWeight.bold,
                  size: 18.0,
                ),
                const SizedBox(height: 8.0),
                googleSansText(
                  text: "Tap the + button to add products offline or online.",
                  colors: ConstantColor.paragraphTextSecondary,
                  fontWeight: FontWeight.normal,
                  size: 14.0,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProductCard(Map<String, dynamic> item) {
    final int stock = item['stock'] as int;
    final int threshold = item['threshold'] as int;
    final bool isCritical = stock <= threshold;

    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => InventoryDetailedPage(product: item),
          ),
        );
        if (result == true) {
          _loadItems();
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color: Colors.white,
          border: isCritical
              ? Border.all(color: Colors.red, width: 1.0)
              : Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image (Local Asset)
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                image: DecorationImage(
                  image: AssetImage(
                    item['image_url'] ?? "assets/img/inventory/inventory-1.png",
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 12.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                googleSansText(
                  text: item['name'] ?? "Unknown Product",
                  colors: ConstantColor.paragraphTextPrimary,
                  fontWeight: FontWeight.bold,
                  size: 16.0,
                ),
                const SizedBox(height: 2),
                googleSansText(
                  text: "SKU: ${item['sku'] ?? 'N/A'}",
                  colors: ConstantColor.paragraphTextSecondary,
                  fontWeight: FontWeight.w600,
                  size: 13.0,
                ),
              ],
            ),
            const SizedBox(height: 12.0),
            const Divider(color: Color(0xFFE8ECF4)),
            const SizedBox(height: 8.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    googleSansText(
                      text: "Current Stock",
                      colors: ConstantColor.paragraphTextSecondary,
                      fontWeight: FontWeight.bold,
                      size: 13.0,
                    ),
                    const SizedBox(height: 2),
                    googleSansText(
                      text: "$stock",
                      colors: ConstantColor.paragraphTextPrimary,
                      fontWeight: FontWeight.bold,
                      size: 15.0,
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    googleSansText(
                      text: "Threshold: $threshold",
                      colors: ConstantColor.paragraphTextSecondary,
                      fontWeight: FontWeight.bold,
                      size: 13.0,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 4.0,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5.0),
                        color: isCritical
                            ? Colors.red.shade50
                            : Colors.green.shade50,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isCritical
                                ? (Platform.isAndroid
                                      ? Icons.warning_amber
                                      : CupertinoIcons.exclamationmark_triangle)
                                : (Platform.isAndroid
                                      ? Icons.check_circle_outline
                                      : CupertinoIcons.check_mark_circled),
                            color: isCritical ? Colors.red : Colors.green,
                            size: 14.0,
                          ),
                          const SizedBox(width: 4.0),
                          googleSansText(
                            text: isCritical ? "Critical" : "Healthy",
                            colors: isCritical ? Colors.red : Colors.green,
                            fontWeight: FontWeight.bold,
                            size: 11.0,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
