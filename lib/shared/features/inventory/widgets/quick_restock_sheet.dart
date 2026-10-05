import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../theme/business/business_theme.dart';
import '../../../widgets/app_text.dart';
import '../models/inventory_item.dart';

class QuickRestockSheet extends StatefulWidget {
  final InventoryItem item;
  final Future<void> Function(int quantityToAdd, double? newCostPrice, String? note) onConfirm;

  const QuickRestockSheet({
    super.key,
    required this.item,
    required this.onConfirm,
  });

  @override
  State<QuickRestockSheet> createState() => _QuickRestockSheetState();
}

class _QuickRestockSheetState extends State<QuickRestockSheet> {
  final TextEditingController _quantityController = TextEditingController(text: '10');
  final TextEditingController _costPriceController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.item.costPrice > 0) {
      _costPriceController.text = widget.item.costPrice.toStringAsFixed(0);
    }
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _costPriceController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _setPreset(int amount) {
    setState(() {
      _quantityController.text = amount.toString();
    });
  }

  Future<void> _submit() async {
    final qty = int.tryParse(_quantityController.text.trim()) ?? 0;
    if (qty <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid quantity greater than zero.')),
      );
      return;
    }

    final newCost = double.tryParse(_costPriceController.text.trim());
    final note = _noteController.text.trim();

    setState(() => _isLoading = true);

    try {
      await widget.onConfirm(qty, newCost, note.isNotEmpty ? note : null);
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to restock: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: BusinessTheme.primaryAmber.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const FaIcon(
                      FontAwesomeIcons.boxesPacking,
                      size: 16,
                      color: BusinessTheme.primaryAmber,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const AppText.subtitle(
                        'Restock Inventory',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: BusinessTheme.charcoal,
                        ),
                      ),
                      AppText.paragraph(
                        widget.item.itemName,
                        style: const TextStyle(
                          fontSize: 12,
                          color: BusinessTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              IconButton(
                icon: const FaIcon(
                  FontAwesomeIcons.xmark,
                  size: 16,
                  color: BusinessTheme.textMuted,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Current Stock Info Box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: BusinessTheme.backgroundLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const AppText.paragraph(
                  'Current Stock on Hand:',
                  style: TextStyle(fontSize: 12, color: BusinessTheme.textMuted),
                ),
                AppText.subtitle(
                  '${widget.item.quantity} ${widget.item.unit}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: BusinessTheme.charcoal,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Quantity to Add Input
          const AppText.paragraph(
            'Quantity to Add',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: BusinessTheme.charcoal,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _quantityController,
            keyboardType: TextInputType.number,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            decoration: InputDecoration(
              suffixText: widget.item.unit,
              hintText: 'e.g. 20',
              filled: true,
              fillColor: BusinessTheme.backgroundLight,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Quick Presets
          Row(
            children: [5, 10, 25, 50, 100].map((preset) {
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: GestureDetector(
                  onTap: () => _setPreset(preset),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: BusinessTheme.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: AppText.paragraph(
                      '+$preset',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: BusinessTheme.charcoal,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Optional Cost Price update
          const AppText.paragraph(
            'Purchase Cost per Unit (₦) (Optional)',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: BusinessTheme.charcoal,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _costPriceController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              prefixText: '₦ ',
              hintText: '0.00',
              filled: true,
              fillColor: BusinessTheme.backgroundLight,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Optional Note
          const AppText.paragraph(
            'Restock Note (Optional)',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: BusinessTheme.charcoal,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _noteController,
            decoration: InputDecoration(
              hintText: 'e.g. Received shipment from supplier',
              filled: true,
              fillColor: BusinessTheme.backgroundLight,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Confirm Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: BusinessTheme.charcoal,
                foregroundColor: BusinessTheme.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: BusinessTheme.white,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        FaIcon(FontAwesomeIcons.plus, size: 14),
                        SizedBox(width: 8),
                        AppText.button(
                          'Confirm Restock',
                          style: TextStyle(
                            color: BusinessTheme.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
