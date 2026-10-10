import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_palette.dart';
import '../../../app/theme/tokens.dart';
import '../../../core/utils/money.dart';
import '../../../core/widgets/amount_field.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_sheet.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../inventory/application/inventory_controller.dart';
import '../../inventory/domain/inventory_models.dart';
import '../domain/invoice_models.dart';

/// Add a line from inventory or a custom line (a service, delivery and so on), or edit [existing].
Future<InvoiceItem?> showItemSheet(BuildContext context, {InvoiceItem? existing}) {
  return showAppSheet<InvoiceItem>(
    context,
    title: existing == null ? 'Add an item' : 'Edit item',
    builder: (_) => _ItemForm(existing: existing),
  );
}

class _ItemForm extends ConsumerStatefulWidget {
  const _ItemForm({this.existing});
  final InvoiceItem? existing;

  @override
  ConsumerState<_ItemForm> createState() => _ItemFormState();
}

class _ItemFormState extends ConsumerState<_ItemForm> {
  late bool _fromStock = widget.existing == null || widget.existing!.productId != null;
  Product? _product;
  String? _productId;
  late final _description = TextEditingController(text: widget.existing?.description ?? '');
  late final _qty = TextEditingController(text: '${widget.existing?.qty ?? 1}');
  late final _price = TextEditingController(
    text: widget.existing == null ? '' : _plain(widget.existing!.unitPriceKobo),
  );
  String _query = '';
  String? _error;

  @override
  void initState() {
    super.initState();
    _productId = widget.existing?.productId;
  }

  @override
  void dispose() {
    _description.dispose();
    _qty.dispose();
    _price.dispose();
    super.dispose();
  }

  static String _plain(int kobo) => kobo % 100 == 0 ? '${kobo ~/ 100}' : (kobo / 100).toStringAsFixed(2);

  void _pick(Product p) {
    setState(() {
      _product = p;
      _productId = p.id;
      _description.text = p.name;
      _price.text = _plain(p.priceKobo);
      _error = null;
    });
  }

  void _save() {
    final qty = int.tryParse(_qty.text.trim());
    final price = parseNairaToKobo(_price.text);
    final description = _description.text.trim();
    String? error;
    if (_fromStock && _productId == null) {
      error = 'Choose a product first.';
    } else if (description.isEmpty) {
      error = 'Enter a description.';
    } else if (description.length > 200) {
      error = 'Keep the description under 200 characters.';
    } else if (qty == null || qty < 1 || qty > 100000) {
      error = 'Enter a quantity of at least 1.';
    } else if (price == null) {
      error = 'Enter a price.';
    }
    if (error != null) {
      setState(() => _error = error);
      return;
    }
    Navigator.of(context).pop(InvoiceItem(
      productId: _fromStock ? _productId : null,
      description: description,
      qty: qty!,
      unitPriceKobo: price!,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.extension<AppPalette>()!;
    final editing = widget.existing != null;
    final products = ref.watch(productsProvider).valueOrNull ?? const <Product>[];
    final q = _query.trim().toLowerCase();
    final chosen = _product ?? (_productId == null ? null : products.where((p) => p.id == _productId).firstOrNull);
    final qty = int.tryParse(_qty.text.trim()) ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!editing) ...[
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment(value: true, label: Text('From inventory'), icon: Icon(Icons.inventory_2_outlined)),
              ButtonSegment(value: false, label: Text('Custom item'), icon: Icon(Icons.edit_note_rounded)),
            ],
            selected: {_fromStock},
            onSelectionChanged: (s) => setState(() {
              _fromStock = s.first;
              _error = null;
            }),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
        if (_fromStock && chosen == null && !editing) ...[
          TextField(
            decoration: const InputDecoration(hintText: 'Search products', prefixIcon: Icon(Icons.search_rounded)),
            onChanged: (v) => setState(() => _query = v),
          ),
          const SizedBox(height: AppSpacing.sm),
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.35),
            child: products.isEmpty
                ? const Padding(padding: EdgeInsets.all(AppSpacing.lg), child: Text('No products yet. Add one in Inventory, or use a custom item.'))
                : ListView(
                    shrinkWrap: true,
                    children: [
                      for (final p in products)
                        if (q.isEmpty || p.name.toLowerCase().contains(q) || p.sku.toLowerCase().contains(q))
                          ListTile(
                            minTileHeight: 56,
                            title: Text(p.name),
                            subtitle: Text('${p.qtyAvailable} available · ${formatNaira(p.priceKobo, showKobo: false)}'),
                            enabled: p.qtyAvailable > 0,
                            onTap: () => _pick(p),
                          ),
                    ],
                  ),
          ),
        ] else ...[
          if (_fromStock)
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(color: palette.tint, borderRadius: BorderRadius.circular(AppRadius.control)),
              child: Row(
                children: [
                  Icon(Icons.inventory_2_outlined, color: palette.action),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      chosen == null ? _description.text : '${chosen.name} · ${chosen.qtyAvailable} available',
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                  if (!editing)
                    TextButton(
                      onPressed: () => setState(() {
                        _product = null;
                        _productId = null;
                      }),
                      child: const Text('Change'),
                    ),
                ],
              ),
            )
          else
            AppTextField(
              label: 'Description',
              controller: _description,
              textCapitalization: TextCapitalization.sentences,
              maxLength: 200,
            ),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            label: 'Quantity',
            controller: _qty,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (_) => setState(() {}),
            helper: chosen != null && qty > chosen.qtyAvailable
                ? 'Only ${chosen.qtyAvailable} available. You will not be able to issue this invoice until there is enough stock.'
                : null,
          ),
          const SizedBox(height: AppSpacing.lg),
          AmountField(controller: _price, label: 'Price each'),
          if (_error != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(_error!, style: theme.textTheme.bodyMedium?.copyWith(color: StatusColors.errorText)),
          ],
          const SizedBox(height: AppSpacing.xxl),
          AppButton(label: editing ? 'Save item' : 'Add item', onPressed: _save),
        ],
      ],
    );
  }
}
