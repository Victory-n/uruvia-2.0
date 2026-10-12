import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/photos/photo_field.dart';
import '../../../core/photos/photo_service.dart';
import '../../../app/router/routes.dart';
import '../../../app/theme/app_palette.dart';
import '../../../app/theme/tokens.dart';
import '../../../core/errors/friendly_error.dart';
import '../../../core/utils/dates.dart';
import '../../../core/utils/money.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/state_views.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../core/widgets/sub_page.dart';
import '../application/inventory_controller.dart';
import '../domain/inventory_models.dart';
import 'stock_sheets.dart';

class ProductDetailScreen extends ConsumerWidget {
  const ProductDetailScreen({super.key, required this.productId});
  final String productId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final value = ref.watch(productProvider(productId));
    final product = value.valueOrNull;
    return SubPage(
      title: product?.name ?? 'Product',
      fallbackRoute: AppRoutes.inventory,
      actions: [
        if (product != null)
          IconButton(
            tooltip: 'Edit product',
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.push(AppRoutes.productEdit(productId)),
          ),
      ],
      body: AsyncView<Product?>(
        value: value,
        onRetry: () => ref.invalidate(productProvider(productId)),
        isEmpty: (p) => p == null,
        empty: const EmptyState(icon: Icons.search_off_rounded, title: 'Product not found'),
        data: (p) => _Detail(product: p!),
      ),
    );
  }
}

class _Detail extends ConsumerWidget {
  const _Detail({required this.product});
  final Product product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final p = product;
    final reservations = ref.watch(reservationsProvider(p.id));
    final movements = ref.watch(movementsProvider(p.id));

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.pageMargin),
      children: [
        if (p.imagePath != null) ...[
          Center(child: StoredImage(bucket: accountFilesBucket, path: p.imagePath, size: 160, placeholder: Icons.inventory_2_outlined)),
          const SizedBox(height: AppSpacing.md),
        ],
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: Text([if (p.categoryName != null) p.categoryName!, p.sku].join(' · '), style: theme.textTheme.bodySmall)),
                  if (p.isOut)
                    const StatusChip('Out of stock', tone: StatusTone.error)
                  else if (p.isLow)
                    const StatusChip('Low stock', tone: StatusTone.warning),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  _Number(label: 'In stock', value: p.qtyOnHand),
                  _Number(label: 'Reserved', value: p.qtyReserved),
                  _Number(label: 'Available', value: p.qtyAvailable, strong: true),
                ],
              ),
              const Divider(height: AppSpacing.xxl),
              Row(
                children: [
                  Expanded(child: _Money(label: 'Selling price', kobo: p.priceKobo)),
                  Expanded(child: _Money(label: 'Cost price', kobo: p.costKobo)),
                  Expanded(child: _Money(label: 'Profit each', kobo: p.marginKobo)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            Expanded(
              child: AppButton(
                label: 'Restock',
                icon: Icons.add_rounded,
                onPressed: () => showRestockSheet(context, p),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: AppButton(
                label: 'Reserve',
                icon: Icons.bookmark_add_outlined,
                style: AppButtonStyle.secondary,
                onPressed: p.qtyAvailable > 0 ? () => showReserveSheet(context, p) : null,
              ),
            ),
          ],
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () => showAdjustSheet(context, p),
            icon: const Icon(Icons.tune_rounded),
            label: const Text('Adjust stock (damaged, lost, count)'),
          ),
        ),
        const SizedBox(height: AppSpacing.sectionGap),
        Text('Reserved for customers', style: theme.textTheme.titleLarge),
        const SizedBox(height: AppSpacing.sm),
        AsyncView<List<Reservation>>(
          value: reservations,
          loading: const _Loading(),
          onRetry: () => ref.invalidate(reservationsProvider(p.id)),
          isEmpty: (l) => l.isEmpty,
          empty: Text('Nothing is reserved.', style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.inkSoft)),
          data: (list) => Column(
            children: [for (final r in list) _ReservationTile(productId: p.id, reservation: r)],
          ),
        ),
        const SizedBox(height: AppSpacing.sectionGap),
        Text('Stock history', style: theme.textTheme.titleLarge),
        const SizedBox(height: AppSpacing.sm),
        AsyncView<List<StockMovement>>(
          value: movements,
          loading: const _Loading(),
          onRetry: () => ref.invalidate(movementsProvider(p.id)),
          isEmpty: (l) => l.isEmpty,
          empty: Text('No movements yet.', style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.inkSoft)),
          data: (list) => AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (var i = 0; i < list.length; i++) ...[
                  if (i > 0) const Divider(),
                  _MovementTile(movement: list[i]),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Loading extends StatelessWidget {
  const _Loading();
  @override
  Widget build(BuildContext context) =>
      const Padding(padding: EdgeInsets.all(AppSpacing.xl), child: Center(child: CircularProgressIndicator()));
}

class _Number extends StatelessWidget {
  const _Number({required this.label, required this.value, this.strong = false});
  final String label;
  final int value;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.extension<AppPalette>()!;
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.bodySmall),
          Text(
            '$value',
            style: theme.textTheme.headlineMedium?.copyWith(color: strong ? palette.action : AppColors.ink),
          ),
        ],
      ),
    );
  }
}

class _Money extends StatelessWidget {
  const _Money({required this.label, required this.kobo});
  final String label;
  final int kobo;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.bodySmall),
        Text(formatNaira(kobo, showKobo: false), style: theme.textTheme.titleMedium),
      ],
    );
  }
}

class _ReservationTile extends ConsumerWidget {
  const _ReservationTile({required this.productId, required this.reservation});
  final String productId;
  final Reservation reservation;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final r = reservation;
    final days = r.daysLeft();
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${r.qty} reserved', style: theme.textTheme.titleMedium),
                Text(
                  [
                    if (r.note != null) r.note!,
                    r.invoiceId != null ? 'For an invoice' : 'Booked ${formatShortDate(r.reservedAt)}',
                    days == 0 ? 'ends today' : 'releases in $days ${days == 1 ? 'day' : 'days'}',
                  ].join(' · '),
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          // Stock held by an invoice is released by cancelling the invoice, not from here.
          if (r.invoiceId == null)
            TextButton(
              onPressed: () async {
                try {
                  await ref.read(inventoryActionsProvider).release(productId, r.id);
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(friendlyError(e))));
                  }
                }
              },
              child: const Text('Release'),
            ),
        ],
      ),
    );
  }
}

class _MovementTile extends StatelessWidget {
  const _MovementTile({required this.movement});
  final StockMovement movement;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final m = movement;
    final d = m.shownDelta;
    final reservedOnly = m.deltaOnHand == 0;
    final text = '${d > 0 ? '+' : ''}$d';
    return ListTile(
      minTileHeight: 56,
      title: Text(m.kind.label),
      subtitle: Text(
        [formatRelative(m.createdAt), if (m.note != null && m.note != m.kind.label) m.note!].join(' · '),
        style: theme.textTheme.bodySmall,
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            text,
            style: theme.textTheme.titleMedium?.copyWith(
              color: reservedOnly ? AppColors.inkSoft : (d > 0 ? StatusColors.success : StatusColors.errorText),
            ),
          ),
          if (reservedOnly) Text('reserved', style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}
