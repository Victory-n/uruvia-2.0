import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../app/theme/app_palette.dart';
import '../../../app/theme/tokens.dart';
import '../../../core/utils/money.dart';
import '../../../core/widgets/amount_text.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/state_views.dart';
import '../../../core/widgets/status_chip.dart';
import '../application/inventory_controller.dart';
import '../domain/inventory_models.dart';

class InventoryListScreen extends ConsumerStatefulWidget {
  const InventoryListScreen({super.key});

  @override
  ConsumerState<InventoryListScreen> createState() => _InventoryListScreenState();
}

class _InventoryListScreenState extends ConsumerState<InventoryListScreen> {
  String _query = '';
  String? _categoryId;

  List<Product> _filter(List<Product> all) {
    final q = _query.trim().toLowerCase();
    return [
      for (final p in all)
        if ((_categoryId == null || p.categoryId == _categoryId) &&
            (q.isEmpty || p.name.toLowerCase().contains(q) || p.sku.toLowerCase().contains(q)))
          p,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final value = ref.watch(productsProvider);
    final categories = ref.watch(productCategoriesProvider).valueOrNull ?? const <ProductCategory>[];

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.inventoryNew),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add product'),
      ),
      body: AsyncView<List<Product>>(
        value: value,
        onRetry: () => ref.invalidate(productsProvider),
        isEmpty: (l) => l.isEmpty,
        empty: EmptyState(
          icon: Icons.inventory_2_outlined,
          title: 'No products yet',
          message: 'Add what you sell to track stock, reserve items for customers and get low-stock alerts.',
          actionLabel: 'Add your first product',
          onAction: () => context.push(AppRoutes.inventoryNew),
        ),
        data: (all) {
          final shown = _filter(all);
          final totals = inventoryTotals(all);
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(productsProvider);
              try {
                await ref.read(productsProvider.future);
              } catch (_) {}
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(AppSpacing.pageMargin, AppSpacing.lg, AppSpacing.pageMargin, 96),
              children: [
                _Summary(totals: totals),
                const SizedBox(height: AppSpacing.lg),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search by name or SKU',
                    prefixIcon: const Icon(Icons.search_rounded),
                    filled: true,
                    fillColor: AppColors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.control),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.control),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                  ),
                  onChanged: (v) => setState(() => _query = v),
                ),
                const SizedBox(height: AppSpacing.md),
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: AppSpacing.sm),
                        child: ChoiceChip(
                          label: const Text('All'),
                          selected: _categoryId == null,
                          onSelected: (_) => setState(() => _categoryId = null),
                        ),
                      ),
                      for (final c in categories)
                        Padding(
                          padding: const EdgeInsets.only(right: AppSpacing.sm),
                          child: ChoiceChip(
                            label: Text(c.name),
                            selected: _categoryId == c.id,
                            onSelected: (v) => setState(() => _categoryId = v ? c.id : null),
                          ),
                        ),
                      ActionChip(
                        avatar: const Icon(Icons.tune_rounded, size: 18),
                        label: const Text('Categories'),
                        onPressed: () => context.push(AppRoutes.inventoryCategories),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                if (shown.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(AppSpacing.xxl),
                    child: Center(child: Text('No products match your search.')),
                  )
                else
                  AppCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        for (var i = 0; i < shown.length; i++) ...[
                          if (i > 0) const Divider(),
                          _ProductRow(product: shown[i]),
                        ],
                      ],
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({required this.totals});
  final InventoryTotals totals;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.extension<AppPalette>()!;
    final white = theme.textTheme.headlineSmall!.copyWith(color: Colors.white);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(color: palette.hero, borderRadius: BorderRadius.circular(AppRadius.card)),
      child: Row(
        children: [
          Expanded(child: _Stat(label: 'Products', child: Text('${totals.products}', style: white))),
          Expanded(
            child: _Stat(
              label: 'Stock value',
              child: AmountText(totals.stockValueKobo, size: AmountSize.l, showKobo: false, color: Colors.white),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: () => context.push(AppRoutes.inventoryLow),
              child: _Stat(
                label: 'Need restock',
                child: Row(
                  children: [
                    Text('${totals.needRestock}', style: white),
                    const Icon(Icons.chevron_right_rounded, color: Colors.white70),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.child});
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white70)),
        const SizedBox(height: 2),
        child,
      ],
    );
  }
}

class _ProductRow extends StatelessWidget {
  const _ProductRow({required this.product});
  final Product product;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = product;
    return ListTile(
      minTileHeight: 72,
      title: Text(p.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.titleMedium),
      subtitle: Text(
        [
          '${p.qtyAvailable} available',
          if (p.qtyReserved > 0) '${p.qtyReserved} reserved',
          p.sku,
        ].join(' · '),
        style: theme.textTheme.bodySmall,
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(formatNaira(p.priceKobo, showKobo: false), style: theme.textTheme.titleMedium),
          if (p.isOut)
            const StatusChip('Out of stock', tone: StatusTone.error)
          else if (p.isLow)
            const StatusChip('Low stock', tone: StatusTone.warning),
        ],
      ),
      onTap: () => context.push(AppRoutes.productDetail(p.id)),
    );
  }
}
