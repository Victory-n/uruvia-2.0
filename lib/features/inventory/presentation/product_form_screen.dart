import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show PostgrestException;

import '../../../app/router/routes.dart';
import '../../../app/theme/app_palette.dart';
import '../../../app/theme/tokens.dart';
import '../../../core/errors/friendly_error.dart';
import '../../../core/photos/photo_field.dart';
import '../../../core/photos/photo_service.dart';
import '../../../core/utils/money.dart';
import '../../../core/widgets/amount_field.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_sheet.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/state_views.dart';
import '../../../core/widgets/sub_page.dart';
import '../../../core/scanner/barcode_scanner_screen.dart';
import '../../account/application/active_account.dart';
import '../application/inventory_controller.dart';
import '../domain/inventory_models.dart';

/// Add a product, or edit one when [productId] is given.
class ProductFormScreen extends ConsumerWidget {
  const ProductFormScreen({super.key, this.productId, this.initialSku});
  final String? productId;

  /// A scanned barcode to start the SKU with.
  final String? initialSku;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = productId;
    if (id == null) {
      return const SubPage(title: 'Add product', fallbackRoute: AppRoutes.inventory, body: _ProductForm(initialSku: initialSku));
    }
    return SubPage(
      title: 'Edit product',
      fallbackRoute: AppRoutes.productDetail(id),
      body: AsyncView<Product?>(
        value: ref.watch(productProvider(id)),
        onRetry: () => ref.invalidate(productProvider(id)),
        loading: const Center(child: CircularProgressIndicator()),
        isEmpty: (p) => p == null,
        empty: const EmptyState(icon: Icons.search_off_rounded, title: 'Product not found'),
        data: (p) => _ProductForm(existing: p),
      ),
    );
  }
}

class _ProductForm extends ConsumerStatefulWidget {
  const _ProductForm({this.existing, this.initialSku});
  final Product? existing;
  final String? initialSku;

  @override
  ConsumerState<_ProductForm> createState() => _ProductFormState();
}

class _ProductFormState extends ConsumerState<_ProductForm> {
  late final _name = TextEditingController(text: widget.existing?.name ?? '');
  late final _sku = TextEditingController(text: widget.existing?.sku ?? widget.initialSku ?? '');
  late final _cost = TextEditingController(text: _naira(widget.existing?.costKobo));
  late final _price = TextEditingController(text: _naira(widget.existing?.priceKobo));
  final _opening = TextEditingController();
  late final _threshold = TextEditingController(text: '${widget.existing?.lowStockThreshold ?? 5}');
  late String _unit = widget.existing?.unit ?? 'pieces';
  late String? _categoryId = widget.existing?.categoryId;
  late bool _alert = widget.existing?.lowStockAlert ?? true;
  late String? _imagePath = widget.existing?.imagePath;
  int? _costKobo;
  int? _priceKobo;
  String? _nameError;
  String? _priceError;
  String? _costError;
  String? _openingError;
  String? _thresholdError;
  String? _error;
  bool _saving = false;

  bool get _editing => widget.existing != null;

  static String _naira(int? kobo) {
    if (kobo == null || kobo == 0) return '';
    final rest = kobo % 100;
    return rest == 0 ? '${kobo ~/ 100}' : '${kobo ~/ 100}.${rest.toString().padLeft(2, '0')}';
  }

  @override
  void initState() {
    super.initState();
    _costKobo = widget.existing?.costKobo;
    _priceKobo = widget.existing?.priceKobo;
  }

  @override
  void dispose() {
    for (final c in [_name, _sku, _cost, _price, _opening, _threshold]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _addCategory() async {
    final created = await showAppSheet<ProductCategory>(
      context,
      title: 'New category',
      builder: (_) => const _NewCategoryForm(),
    );
    if (created != null) setState(() => _categoryId = created.id);
  }

  Future<void> _save({bool another = false}) async {
    final name = _name.text.trim();
    final price = _priceKobo ?? parseNairaToKobo(_price.text);
    final cost = _costKobo ?? parseNairaToKobo(_cost.text) ?? 0;
    final opening = _opening.text.trim().isEmpty ? 0 : int.tryParse(_opening.text.trim());
    final threshold = int.tryParse(_threshold.text.trim());

    setState(() {
      _nameError = name.isEmpty ? 'Enter the product name.' : (name.length > 120 ? 'Keep it under 120 characters.' : null);
      _priceError = price == null ? 'Enter the selling price.' : null;
      _costError = null;
      _openingError = opening == null ? 'Enter a whole number.' : null;
      _thresholdError = threshold == null ? 'Enter a whole number.' : null;
      _error = null;
    });
    if (_nameError != null || _priceError != null || _openingError != null || _thresholdError != null) return;

    setState(() => _saving = true);
    final actions = ref.read(inventoryActionsProvider);
    try {
      if (_editing) {
        await actions.updateProduct(
          widget.existing!.id,
          name: name,
          sku: _sku.text,
          unit: _unit,
          costKobo: cost,
          priceKobo: price!,
          lowStockAlert: _alert,
          lowStockThreshold: threshold!,
          categoryId: _categoryId,
          imagePath: _imagePath,
        );
      } else {
        await actions.createProduct(
          name: name,
          sku: _sku.text,
          unit: _unit,
          costKobo: cost,
          priceKobo: price!,
          openingQty: opening!,
          lowStockAlert: _alert,
          lowStockThreshold: threshold!,
          categoryId: _categoryId,
          imagePath: _imagePath,
        );
      }
      if (!mounted) return;
      if (another && !_editing) {
        // Keep unit, category and alert settings: the next product is usually similar.
        setState(() {
          _saving = false;
          _name.clear();
          _sku.clear();
          _cost.clear();
          _price.clear();
          _opening.clear();
          _costKobo = null;
          _priceKobo = null;
          _imagePath = null;
          _error = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$name added. Add the next one.')));
        return;
      }
      context.canPop() ? context.pop() : context.go(AppRoutes.inventory);
    } catch (e) {
      if (!mounted) return;
      final duplicate = e is PostgrestException && e.code == '23505';
      setState(() {
        _saving = false;
        _error = duplicate ? 'Another product already uses that SKU. Choose a different one.' : friendlyError(e);
      });
    }
  }

  Future<void> _archive() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove this product?'),
        content: const Text('It will be hidden from your list. Past sales and invoices keep their records.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Remove')),
        ],
      ),
    );
    if (ok != true) return;
    setState(() => _saving = true);
    try {
      await ref.read(inventoryActionsProvider).archive(widget.existing!.id);
      if (mounted) context.go(AppRoutes.inventory);
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
    final categories = ref.watch(productCategoriesProvider);

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.pageMargin),
      children: [
        if (_error != null)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.lg),
            child: Text(_error!, style: theme.textTheme.bodyMedium?.copyWith(color: StatusColors.errorText)),
          ),
        PhotoField(
          label: 'Product photo (optional)',
          bucket: accountFilesBucket,
          folder: '${ref.watch(activeAccountSummaryProvider)?.id}/products',
          path: _imagePath,
          placeholder: Icons.inventory_2_outlined,
          reason: 'Add a photo so you can spot this product quickly. It is stored privately for your team.',
          onChanged: (p) => setState(() => _imagePath = p),
        ),
        const SizedBox(height: AppSpacing.lg),
        AppTextField(
          label: 'Product name',
          controller: _name,
          textCapitalization: TextCapitalization.words,
          errorText: _nameError,
          enabled: !_saving,
          autofocus: !_editing,
        ),
        const SizedBox(height: AppSpacing.lg),
        AppTextField(
          label: 'SKU (optional)',
          controller: _sku,
          helper: 'Your own code or the barcode. Leave empty and we will make one.',
          textCapitalization: TextCapitalization.characters,
          enabled: !_saving,
          suffix: IconButton(
            tooltip: 'Scan barcode',
            icon: const Icon(Icons.qr_code_scanner_rounded),
            onPressed: _saving
                ? null
                : () async {
                    final code = await scanBarcode(context);
                    if (code != null && mounted) setState(() => _sku.text = code);
                  },
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Text('Category', style: theme.textTheme.labelLarge),
        const SizedBox(height: AppSpacing.sm),
        categories.when(
          loading: () => const LinearProgressIndicator(),
          error: (_, __) => TextButton(
            onPressed: () => ref.invalidate(productCategoriesProvider),
            child: const Text('Could not load categories. Retry'),
          ),
          data: (list) => Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final c in list)
                ChoiceChip(
                  label: Text(c.name),
                  selected: _categoryId == c.id,
                  onSelected: _saving ? null : (v) => setState(() => _categoryId = v ? c.id : null),
                ),
              ActionChip(
                avatar: const Icon(Icons.add_rounded, size: 18),
                label: const Text('New'),
                onPressed: _saving ? null : _addCategory,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Text('Unit', style: theme.textTheme.labelLarge),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final u in stockUnits)
              ChoiceChip(
                label: Text(u),
                selected: _unit == u,
                onSelected: _saving ? null : (_) => setState(() => _unit = u),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        AmountField(
          controller: _price,
          label: 'Selling price',
          errorText: _priceError,
          enabled: !_saving,
          onChangedKobo: (v) => _priceKobo = v,
        ),
        const SizedBox(height: AppSpacing.lg),
        AmountField(
          controller: _cost,
          label: 'Cost price (optional)',
          helper: 'What you pay for it. Used to work out your profit.',
          errorText: _costError,
          enabled: !_saving,
          onChangedKobo: (v) => _costKobo = v,
        ),
        if (!_editing) ...[
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            label: 'Opening stock',
            controller: _opening,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            helper: 'How many you have now. You can restock or adjust later.',
            errorText: _openingError,
            enabled: !_saving,
          ),
        ],
        const SizedBox(height: AppSpacing.lg),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          activeThumbColor: palette.action,
          title: const Text('Low-stock alert'),
          subtitle: const Text('Tell me when available stock runs low.'),
          value: _alert,
          onChanged: _saving ? null : (v) => setState(() => _alert = v),
        ),
        if (_alert)
          AppTextField(
            label: 'Alert when available is at or below',
            controller: _threshold,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            errorText: _thresholdError,
            enabled: !_saving,
          ),
        const SizedBox(height: AppSpacing.xxl),
        AppButton(label: _editing ? 'Save changes' : 'Add product', onPressed: () => _save(), loading: _saving),
        if (!_editing) ...[
          const SizedBox(height: AppSpacing.sm),
          AppButton(label: 'Save and add another', style: AppButtonStyle.secondary, onPressed: _saving ? null : () => _save(another: true)),
        ],
        if (_editing) ...[
          const SizedBox(height: AppSpacing.sm),
          AppButton(label: 'Remove product', style: AppButtonStyle.text, onPressed: _saving ? null : _archive),
        ],
      ],
    );
  }
}

class _NewCategoryForm extends ConsumerStatefulWidget {
  const _NewCategoryForm();

  @override
  ConsumerState<_NewCategoryForm> createState() => _NewCategoryFormState();
}

class _NewCategoryFormState extends ConsumerState<_NewCategoryForm> {
  final _name = TextEditingController();
  String? _error;
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    if (name.isEmpty || name.length > 60) {
      setState(() => _error = 'Enter a name up to 60 characters.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final created = await ref.read(inventoryActionsProvider).addCategory(name);
      if (mounted) Navigator.of(context).pop(created);
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
    return Column(
      children: [
        AppTextField(
          label: 'Category name',
          controller: _name,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          errorText: _error,
          enabled: !_saving,
          onSubmitted: (_) => _save(),
        ),
        const SizedBox(height: AppSpacing.xxl),
        AppButton(label: 'Add category', onPressed: _save, loading: _saving),
      ],
    );
  }
}
