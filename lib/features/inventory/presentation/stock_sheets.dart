import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_palette.dart';
import '../../../app/theme/tokens.dart';
import '../../../core/errors/friendly_error.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_sheet.dart';
import '../../../core/widgets/app_text_field.dart';
import '../application/inventory_controller.dart';
import '../domain/inventory_models.dart';

/// The three stock actions on a product. Each returns true when something changed.
Future<bool?> showRestockSheet(BuildContext context, Product product) => showAppSheet<bool>(
      context,
      title: 'Restock ${product.name}',
      builder: (_) => _QtyForm(product: product, mode: _Mode.restock),
    );

Future<bool?> showAdjustSheet(BuildContext context, Product product) => showAppSheet<bool>(
      context,
      title: 'Adjust stock',
      builder: (_) => _QtyForm(product: product, mode: _Mode.adjust),
    );

Future<bool?> showReserveSheet(BuildContext context, Product product) => showAppSheet<bool>(
      context,
      title: 'Reserve stock',
      builder: (_) => _QtyForm(product: product, mode: _Mode.reserve),
    );

enum _Mode { restock, adjust, reserve }

class _QtyForm extends ConsumerStatefulWidget {
  const _QtyForm({required this.product, required this.mode});
  final Product product;
  final _Mode mode;

  @override
  ConsumerState<_QtyForm> createState() => _QtyFormState();
}

class _QtyFormState extends ConsumerState<_QtyForm> {
  final _qty = TextEditingController();
  final _note = TextEditingController();
  String _reason = 'damaged'; // damaged, lost, count
  bool _add = false; // only used for count corrections
  String? _qtyError;
  String? _error;
  bool _saving = false;

  @override
  void dispose() {
    _qty.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final qty = int.tryParse(_qty.text.trim());
    if (qty == null || qty <= 0) {
      setState(() => _qtyError = 'Enter a whole number greater than zero.');
      return;
    }
    if (widget.mode == _Mode.reserve && qty > widget.product.qtyAvailable) {
      setState(() => _qtyError = 'Only ${widget.product.qtyAvailable} available.');
      return;
    }
    setState(() {
      _qtyError = null;
      _error = null;
      _saving = true;
    });
    final actions = ref.read(inventoryActionsProvider);
    final id = widget.product.id;
    try {
      switch (widget.mode) {
        case _Mode.restock:
          await actions.restock(id, qty, _note.text);
        case _Mode.reserve:
          await actions.reserve(id, qty, _note.text);
        case _Mode.adjust:
          final delta = (_reason == 'count' && _add) ? qty : -qty;
          await actions.adjust(id, delta, _reason, _note.text);
      }
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = friendlyError(e);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = widget.product;
    final hint = switch (widget.mode) {
      _Mode.restock => 'In stock now: ${p.qtyOnHand} ${p.unit}',
      _Mode.reserve => 'Available to reserve: ${p.qtyAvailable} ${p.unit}',
      _Mode.adjust => 'In stock: ${p.qtyOnHand}, reserved: ${p.qtyReserved}',
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(hint, style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.inkSoft)),
        const SizedBox(height: AppSpacing.lg),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: Text(_error!, style: theme.textTheme.bodyMedium?.copyWith(color: StatusColors.errorText)),
          ),
        if (widget.mode == _Mode.adjust) ...[
          Wrap(
            spacing: AppSpacing.sm,
            children: [
              for (final r in const [('damaged', 'Damaged'), ('lost', 'Lost'), ('count', 'Count correction')])
                ChoiceChip(
                  label: Text(r.$2),
                  selected: _reason == r.$1,
                  onSelected: _saving ? null : (_) => setState(() => _reason = r.$1),
                ),
            ],
          ),
          if (_reason == 'count') ...[
            const SizedBox(height: AppSpacing.md),
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(value: false, label: Text('Remove')),
                ButtonSegment(value: true, label: Text('Add')),
              ],
              selected: {_add},
              onSelectionChanged: (s) => setState(() => _add = s.first),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
        ],
        AppTextField(
          label: 'Quantity',
          controller: _qty,
          autofocus: true,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          errorText: _qtyError,
          enabled: !_saving,
        ),
        const SizedBox(height: AppSpacing.lg),
        AppTextField(
          label: 'Note (optional)',
          controller: _note,
          maxLength: 200,
          enabled: !_saving,
          textCapitalization: TextCapitalization.sentences,
        ),
        const SizedBox(height: AppSpacing.xl),
        AppButton(
          label: switch (widget.mode) {
            _Mode.restock => 'Add stock',
            _Mode.reserve => 'Reserve',
            _Mode.adjust => 'Save adjustment',
          },
          onPressed: _submit,
          loading: _saving,
        ),
        if (widget.mode == _Mode.reserve) ...[
          const SizedBox(height: AppSpacing.md),
          Text(
            'Reserved stock is held for up to 10 days, then released automatically.',
            style: theme.textTheme.bodySmall,
          ),
        ],
      ],
    );
  }
}
