import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../theme/business/business_theme.dart';
import '../../../widgets/app_text.dart';
import '../models/inventory_item.dart';
import '../services/inventory_service.dart';
import '../widgets/inventory_image_picker.dart';

class AddEditInventoryScreen extends StatefulWidget {
  final InventoryItem? itemToEdit;

  const AddEditInventoryScreen({
    super.key,
    this.itemToEdit,
  });

  @override
  State<AddEditInventoryScreen> createState() => _AddEditInventoryScreenState();
}

class _AddEditInventoryScreenState extends State<AddEditInventoryScreen> {
  final _formKey = GlobalKey<FormState>();

  String? _imagePath;
  late final TextEditingController _nameController;
  late final TextEditingController _categoryController;
  late final TextEditingController _skuController;
  late final TextEditingController _unitController;
  late final TextEditingController _quantityController;
  late final TextEditingController _costPriceController;
  late final TextEditingController _sellingPriceController;
  late final TextEditingController _thresholdController;

  late bool _lowStockAlert;
  bool _isSaving = false;

  bool get _isEditing => widget.itemToEdit != null;

  @override
  void initState() {
    super.initState();
    final item = widget.itemToEdit;
    _imagePath = item?.imagePath;
    _nameController = TextEditingController(text: item?.itemName ?? '');
    _categoryController = TextEditingController(text: item?.category ?? 'General');
    _skuController = TextEditingController(text: item?.sku ?? '');
    _unitController = TextEditingController(text: item?.unit ?? 'units');
    _quantityController = TextEditingController(
      text: item != null ? item.quantity.toString() : '0',
    );
    _costPriceController = TextEditingController(
      text: item != null && item.costPrice > 0 ? item.costPrice.toStringAsFixed(0) : '',
    );
    _sellingPriceController = TextEditingController(
      text: item != null && item.sellingPrice > 0 ? item.sellingPrice.toStringAsFixed(0) : '',
    );
    _thresholdController = TextEditingController(
      text: item != null ? item.lowStockThreshold.toString() : '5',
    );
    _lowStockAlert = item?.lowStockAlert ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _skuController.dispose();
    _unitController.dispose();
    _quantityController.dispose();
    _costPriceController.dispose();
    _sellingPriceController.dispose();
    _thresholdController.dispose();
    super.dispose();
  }

  Future<void> _saveItem() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final id = widget.itemToEdit?.id ??
          'inv_${DateTime.now().millisecondsSinceEpoch}_${_nameController.text.trim().hashCode.abs()}';

      final item = InventoryItem(
        id: id,
        itemName: _nameController.text.trim(),
        category: _categoryController.text.trim().isEmpty ? 'General' : _categoryController.text.trim(),
        sku: _skuController.text.trim(),
        unit: _unitController.text.trim().isEmpty ? 'units' : _unitController.text.trim(),
        quantity: int.tryParse(_quantityController.text.trim()) ?? 0,
        costPrice: double.tryParse(_costPriceController.text.trim()) ?? 0.0,
        sellingPrice: double.tryParse(_sellingPriceController.text.trim()) ?? 0.0,
        lowStockAlert: _lowStockAlert,
        lowStockThreshold: int.tryParse(_thresholdController.text.trim()) ?? 5,
        imagePath: _imagePath,
        createdAt: widget.itemToEdit?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (_isEditing) {
        await InventoryService.instance.updateItem(item);
      } else {
        await InventoryService.instance.addItem(item);
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving item: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BusinessTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const FaIcon(
            FontAwesomeIcons.arrowLeft,
            color: BusinessTheme.charcoal,
            size: 18,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: AppText.subtitle(
          _isEditing ? 'Edit Inventory Item' : 'New Inventory Item',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: BusinessTheme.charcoal,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Photo Upload Section
              InventoryImagePicker(
                imagePath: _imagePath,
                onImageSelected: (path) => setState(() => _imagePath = path),
              ),
              const SizedBox(height: 20),

              // Section 1: Item Basic Info
              _buildSectionHeader('Product Details', FontAwesomeIcons.box),
              const SizedBox(height: 12),
              _buildTextField(
                label: 'Item Name *',
                controller: _nameController,
                hintText: 'e.g. Toyota Corolla 2022 / Wireless Mouse',
                validator: (val) =>
                    val == null || val.trim().isEmpty ? 'Item name is required' : null,
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      label: 'Category',
                      controller: _categoryController,
                      hintText: 'e.g. Vehicles / Electronics',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField(
                      label: 'SKU / Barcode',
                      controller: _skuController,
                      hintText: 'e.g. TOY-042',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Section 2: Stock & Inventory Quantity
              _buildSectionHeader('Stock & Quantities', FontAwesomeIcons.cubes),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: _buildTextField(
                      label: 'Current Quantity *',
                      controller: _quantityController,
                      keyboardType: TextInputType.number,
                      hintText: '0',
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) return 'Required';
                        if (int.tryParse(val.trim()) == null) return 'Enter number';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField(
                      label: 'Unit of Measure',
                      controller: _unitController,
                      hintText: 'units, pcs, cars',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Section 3: Pricing & Margins
              _buildSectionHeader('Pricing (NGN ₦)', FontAwesomeIcons.moneyBillWave),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      label: 'Cost Price (₦)',
                      controller: _costPriceController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      prefixText: '₦ ',
                      hintText: '0.00',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField(
                      label: 'Selling Price (₦) *',
                      controller: _sellingPriceController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      prefixText: '₦ ',
                      hintText: '0.00',
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) return 'Required';
                        if (double.tryParse(val.trim()) == null) return 'Enter valid price';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Section 4: Low Stock Alert Settings
              _buildSectionHeader('Low Stock Alert Settings', FontAwesomeIcons.bell),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: BusinessTheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              AppText.subtitle(
                                'Enable Low Stock Alert',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: BusinessTheme.charcoal,
                                ),
                              ),
                              SizedBox(height: 4),
                              AppText.paragraph(
                                'Receive notifications when stock hits or drops below the reorder point',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: BusinessTheme.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch.adaptive(
                          value: _lowStockAlert,
                          activeTrackColor: BusinessTheme.primaryAmber,
                          onChanged: (val) => setState(() => _lowStockAlert = val),
                        ),
                      ],
                    ),
                    if (_lowStockAlert) ...[
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                AppText.paragraph(
                                  'Alert Threshold (Units)',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: BusinessTheme.charcoal,
                                  ),
                                ),
                                SizedBox(height: 2),
                                AppText.paragraph(
                                  'Notify me when stock reaches this number',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: BusinessTheme.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: 80,
                            child: TextField(
                              controller: _thresholdController,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: BusinessTheme.backgroundLight,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveItem,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: BusinessTheme.charcoal,
                    foregroundColor: BusinessTheme.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: BusinessTheme.white,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const FaIcon(FontAwesomeIcons.check, size: 16),
                            const SizedBox(width: 8),
                            AppText.button(
                              _isEditing ? 'Update Item' : 'Add to Inventory',
                              style: const TextStyle(
                                color: BusinessTheme.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, dynamic icon) {
    return Row(
      children: [
        FaIcon(icon, size: 14, color: BusinessTheme.primaryAmber),
        const SizedBox(width: 8),
        AppText.subtitle(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: BusinessTheme.charcoal,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    String? hintText,
    String? prefixText,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText.paragraph(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: BusinessTheme.charcoal,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          style: const TextStyle(fontSize: 14, color: BusinessTheme.charcoal),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(fontSize: 13, color: BusinessTheme.textMuted),
            prefixText: prefixText,
            filled: true,
            fillColor: BusinessTheme.surface,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: BusinessTheme.primaryAmber, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: BusinessTheme.danger),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: BusinessTheme.danger, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
