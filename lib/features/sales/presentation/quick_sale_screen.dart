import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../app/theme/app_palette.dart';
import '../../../app/theme/tokens.dart';
import '../../../core/errors/friendly_error.dart';
import '../../../core/utils/money.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/sub_page.dart';
import '../../customers/domain/customer_models.dart';
import '../../customers/presentation/customer_picker.dart';
import '../../invoices/domain/invoice_models.dart';
import '../../invoices/presentation/item_sheet.dart';
import '../application/sales_controller.dart';

/// Screen 51. A sale at the counter: items, how it was paid, done. Stock goes down at once.
class QuickSaleScreen extends ConsumerStatefulWidget {
  const QuickSaleScreen({super.key});

  @override
  ConsumerState<QuickSaleScreen> createState() => _QuickSaleScreenState();
}

class _QuickSaleScreenState extends ConsumerState<QuickSaleScreen> {
  final List<InvoiceItem> _items = [];
  final _note = TextEditingController();
  Customer? _customer;
  PaymentMethod _method = PaymentMethod.cash;
  String? _error;
  bool _saving = false;

  int get _total => _items.fold(0, (a, i) => a + i.lineTotalKobo);

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _addItem() async {
    final item = await showItemSheet(context);
    if (item != null && mounted) setState(() => _items.add(item));
  }

  Future<void> _editItem(int i) async {
    final item = await showItemSheet(context, existing: _items[i]);
    if (item != null && mounted) setState(() => _items[i] = item);
  }

  Future<void> _pickCustomer() async {
    final c = await showCustomerPicker(context);
    if (c != null && mounted) setState(() => _customer = c);
  }

  Future<void> _save() async {
    if (_items.isEmpty) {
      setState(() => _error = 'Add at least one item.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final id = await ref.read(salesActionsProvider).recordQuickSale(
            customerId: _customer?.id,
            method: _method.db,
            note: _note.text,
            items: [for (final i in _items) i.toJson()],
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sale recorded.')));
      context.pushReplacement(AppRoutes.saleDetail(id));
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
    final palette = theme.extension<AppPalette>()!;
    return SubPage(
      title: 'Quick sale',
      fallbackRoute: AppRoutes.sales,
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.pageMargin),
        children: [
          AppCard(
            onTap: _saving ? null : _pickCustomer,
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: palette.tint,
                  child: Icon(Icons.person_outline_rounded, color: palette.action),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(_customer?.name ?? 'Walk-in customer (tap to choose)', style: theme.textTheme.bodyLarge),
                ),
                if (_customer != null)
                  IconButton(
                    tooltip: 'Remove customer',
                    icon: const Icon(Icons.close_rounded),
                    onPressed: _saving ? null : () => setState(() => _customer = null),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sectionGap),
          Row(
            children: [
              Expanded(child: Text('Items', style: theme.textTheme.titleLarge)),
              TextButton.icon(
                onPressed: _saving ? null : _addItem,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add item'),
              ),
            ],
          ),
          if (_items.isEmpty)
            AppCard(
              onTap: _addItem,
              child: Text('Tap to add the first item.',
                  style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.inkSoft)),
            )
          else
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  for (var i = 0; i < _items.length; i++) ...[
                    if (i > 0) const Divider(),
                    ListTile(
                      minTileHeight: 64,
                      title: Text(_items[i].description, maxLines: 2, overflow: TextOverflow.ellipsis),
                      subtitle: Text('${_items[i].qty} × ${formatNaira(_items[i].unitPriceKobo, showKobo: false)}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(formatNaira(_items[i].lineTotalKobo, showKobo: false), style: theme.textTheme.titleMedium),
                          IconButton(
                            tooltip: 'Remove item',
                            icon: const Icon(Icons.close_rounded),
                            onPressed: _saving ? null : () => setState(() => _items.removeAt(i)),
                          ),
                        ],
                      ),
                      onTap: _saving ? null : () => _editItem(i),
                    ),
                  ],
                ],
              ),
            ),
          const SizedBox(height: AppSpacing.sectionGap),
          Text('Paid by', style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            children: [
              for (final m in PaymentMethod.values)
                ChoiceChip(
                  label: Text(m.label),
                  selected: _method == m,
                  onSelected: _saving ? null : (_) => setState(() => _method = m),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(label: 'Note (optional)', controller: _note, maxLength: 120),
          const SizedBox(height: AppSpacing.lg),
          AppCard(
            color: palette.tint,
            child: Row(
              children: [
                Expanded(child: Text('Total', style: theme.textTheme.titleMedium)),
                Text(formatNaira(_total, showKobo: _total % 100 != 0), style: theme.textTheme.titleLarge),
              ],
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(_error!, style: theme.textTheme.bodySmall?.copyWith(color: StatusColors.errorText)),
          ],
          const SizedBox(height: AppSpacing.xxl),
          AppButton(label: 'Record sale', loading: _saving, onPressed: _saving ? null : _save),
        ],
      ),
    );
  }
}
