import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:uruvia/constants/colors.dart';
import 'package:uruvia/offline/inventory_repository.dart';
import 'package:uruvia/widgets/custom_text.dart';

class AddInventoryPage extends StatefulWidget {
  const AddInventoryPage({super.key});

  @override
  State<AddInventoryPage> createState() => _AddInventoryPageState();
}

class _AddInventoryPageState extends State<AddInventoryPage> {
  final _formKey = GlobalKey<FormState>();
  
  final _nameController = TextEditingController();
  final _skuController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  final _thresholdController = TextEditingController();
  final _supplierController = TextEditingController();
  bool _lowStockAlert = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _skuController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _thresholdController.dispose();
    _supplierController.dispose();
    super.dispose();
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final id = DateTime.now().microsecondsSinceEpoch.toString();
    final name = _nameController.text.trim();
    final sku = _skuController.text.trim();
    final retailPrice = double.tryParse(_priceController.text) ?? 0.0;
    final stock = int.tryParse(_stockController.text) ?? 0;
    final threshold = int.tryParse(_thresholdController.text) ?? 10;
    final supplier = _supplierController.text.trim();

    final newItem = {
      'id': id,
      'name': name,
      'sku': sku,
      'stock': stock,
      'threshold': threshold,
      'image_url': 'assets/img/inventory/inventory-1.png',
      'retail_price': retailPrice,
      'supplier': supplier.isEmpty ? 'Generic Supplier' : supplier,
      'low_stock_alert': _lowStockAlert,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    };

    try {
      await InventoryRepository.instance.addInventoryItem(newItem);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Product added successfully! Syncing in progress...'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding product: $e'),
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
    return Scaffold(
      backgroundColor: ConstantColor.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: interText(
          text: "Add New Product",
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product Name
                      _buildLabel("Product Name"),
                      TextFormField(
                        controller: _nameController,
                        decoration: _buildInputDecoration("e.g. Smart Watch Series 5"),
                        validator: (value) => value == null || value.trim().isEmpty ? "Name is required" : null,
                      ),
                      const SizedBox(height: 16),

                      // SKU Code
                      _buildLabel("SKU Code"),
                      TextFormField(
                        controller: _skuController,
                        decoration: _buildInputDecoration("e.g. SW-S5-BLK"),
                        validator: (value) => value == null || value.trim().isEmpty ? "SKU is required" : null,
                      ),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel("Current Stock"),
                                TextFormField(
                                  controller: _stockController,
                                  keyboardType: TextInputType.number,
                                  decoration: _buildInputDecoration("e.g. 52"),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) return "Required";
                                    if (int.tryParse(value) == null) return "Must be number";
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel("Min. Threshold"),
                                TextFormField(
                                  controller: _thresholdController,
                                  keyboardType: TextInputType.number,
                                  decoration: _buildInputDecoration("e.g. 10"),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) return "Required";
                                    if (int.tryParse(value) == null) return "Must be number";
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Price
                      _buildLabel("Retail Price (₦)"),
                      TextFormField(
                        controller: _priceController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: _buildInputDecoration("e.g. 45000"),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) return "Price is required";
                          if (double.tryParse(value) == null) return "Must be valid price";
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Supplier
                      _buildLabel("Supplier"),
                      TextFormField(
                        controller: _supplierController,
                        decoration: _buildInputDecoration("e.g. Apex Tech Ltd"),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Alerts section
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          googleSansText(
                            text: "Low Stock Alert",
                            colors: ConstantColor.paragraphTextPrimary,
                            fontWeight: FontWeight.bold,
                            size: 15.0,
                          ),
                          const SizedBox(height: 4),
                          googleSansText(
                            text: "Notify when stock drops below threshold",
                            colors: ConstantColor.paragraphTextSecondary,
                            fontWeight: FontWeight.normal,
                            size: 12.0,
                          ),
                        ],
                      ),
                      Switch.adaptive(
                        value: _lowStockAlert,
                        onChanged: (val) {
                          setState(() {
                            _lowStockAlert = val;
                          });
                        },
                        activeColor: Colors.white,
                        activeTrackColor: ConstantColor.blueBackground,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Save button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveProduct,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ConstantColor.blueBackground,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Platform.isAndroid ? Icons.save : CupertinoIcons.floppy_disk,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 8),
                              googleSansText(
                                text: "Save Product",
                                colors: Colors.white,
                                fontWeight: FontWeight.bold,
                                size: 16.0,
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String labelText) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: googleSansText(
        text: labelText,
        colors: ConstantColor.paragraphTextPrimary,
        fontWeight: FontWeight.bold,
        size: 13.0,
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        fontFamily: "WorkSans",
        color: ConstantColor.paragraphTextSecondary,
        fontSize: 14.0,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      filled: true,
      fillColor: Colors.grey.shade50,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: ConstantColor.blueBackground, width: 1.5),
      ),
    );
  }
}
