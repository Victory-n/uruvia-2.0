import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../theme/business/business_theme.dart';
import '../../../widgets/app_text.dart';
import '../models/inventory_item.dart';

class StockDeductionSheet extends StatefulWidget {
  final InventoryItem item;
  final Future<void> Function(int quantityToDeduct, String? referenceId, String? note) onConfirm;

  const StockDeductionSheet({
    super.key,
    required this.item,
    required this.onConfirm,
  });

  @override
  State<StockDeductionSheet> createState() => _StockDeductionSheetState();
}

class _StockDeductionSheetState extends State<StockDeductionSheet> {
  final TextEditingController _quantityController = TextEditingController(text: '1');
  final TextEditingController _referenceController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _quantityController.dispose();
    _referenceController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  int get _enteredQuantity => int.tryParse(_quantityController.text.trim()) ?? 0;
  int get _resultingQuantity => widget.item.quantity - _enteredQuantity;

  Future<void> _submit() async {
    final qty = _enteredQuantity;
    if (qty <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid quantity to deduct.')),
      );
      return;
    }

    if (qty > widget.item.quantity) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Cannot deduct $qty ${widget.item.unit}. Only ${widget.item.quantity} available in stock!',
          ),
          backgroundColor: BusinessTheme.danger,
        ),
      );
      return;
    }

    final ref = _referenceController.text.trim();
    final note = _noteController.text.trim();

    setState(() => _isLoading = true);

    try {
      await widget.onConfirm(
        qty,
        ref.isNotEmpty ? ref : null,
        note.isNotEmpty ? note : null,
      );
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to record sale: $e')),
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
    final bool isExceedingStock = _enteredQuantity > widget.item.quantity;
    final bool willTriggerLowStock =
        !isExceedingStock && _resultingQuantity <= widget.item.lowStockThreshold;

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
                      color: BusinessTheme.charcoal.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: const FaIcon(
                      FontAwesomeIcons.tag,
                      size: 16,
                      color: BusinessTheme.charcoal,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const AppText.subtitle(
                        'Record Sale / Deduct Stock',
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

          // Current Stock & Dynamic Result Preview Box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: BusinessTheme.backgroundLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isExceedingStock
                    ? BusinessTheme.danger
                    : willTriggerLowStock
                        ? const Color(0xFFF59E0B)
                        : Colors.transparent,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AppText.paragraph(
                      'Current Stock:',
                      style: TextStyle(fontSize: 11, color: BusinessTheme.textMuted),
                    ),
                    const SizedBox(height: 2),
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
                const FaIcon(
                  FontAwesomeIcons.arrowRight,
                  size: 14,
                  color: BusinessTheme.textMuted,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const AppText.paragraph(
                      'Resulting Stock:',
                      style: TextStyle(fontSize: 11, color: BusinessTheme.textMuted),
                    ),
                    const SizedBox(height: 2),
                    AppText.subtitle(
                      isExceedingStock ? 'Deficit!' : '$_resultingQuantity ${widget.item.unit}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isExceedingStock
                            ? BusinessTheme.danger
                            : willTriggerLowStock
                                ? const Color(0xFFD97706)
                                : BusinessTheme.success,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          if (willTriggerLowStock && !isExceedingStock) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const FaIcon(
                  FontAwesomeIcons.triangleExclamation,
                  size: 12,
                  color: Color(0xFFD97706),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: AppText.paragraph(
                    'Warning: Stock will fall below threshold (${widget.item.lowStockThreshold} ${widget.item.unit}) and trigger low stock alert.',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFFB45309),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),

          // Quantity to Deduct Input
          const AppText.paragraph(
            'Quantity Sold / Subtracted',
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
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              suffixText: widget.item.unit,
              hintText: 'e.g. 3',
              filled: true,
              fillColor: BusinessTheme.backgroundLight,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Invoice / Sale Reference (e.g. INV-104)
          const AppText.paragraph(
            'Invoice / Receipt Reference (Optional)',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: BusinessTheme.charcoal,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _referenceController,
            decoration: InputDecoration(
              hintText: 'e.g. INV-2026-0042',
              filled: true,
              fillColor: BusinessTheme.backgroundLight,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Customer / Notes
          const AppText.paragraph(
            'Customer or Sale Note (Optional)',
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
              hintText: 'e.g. Paid in full via transfer',
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
              onPressed: _isLoading || isExceedingStock ? null : _submit,
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
                        FaIcon(FontAwesomeIcons.circleMinus, size: 14),
                        SizedBox(width: 8),
                        AppText.button(
                          'Confirm Stock Deduction',
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
