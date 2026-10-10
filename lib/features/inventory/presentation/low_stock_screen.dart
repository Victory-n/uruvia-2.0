import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../app/theme/tokens.dart';
import '../../../core/errors/friendly_error.dart';
import '../../../core/utils/dates.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/state_views.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../core/widgets/sub_page.dart';
import '../application/inventory_controller.dart';
import '../domain/inventory_models.dart';
import 'stock_sheets.dart';

/// Products that are out or running low, plus restock reminders.
class LowStockScreen extends ConsumerWidget {
  const LowStockScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(productsProvider);
    final reminders = ref.watch(remindersProvider).valueOrNull ?? const <RestockReminder>[];
    final names = {for (final p in products.valueOrNull ?? const <Product>[]) p.id: p.name};

    return SubPage(
      title: 'Low stock and reminders',
      fallbackRoute: AppRoutes.inventory,
      body: AsyncView<List<Product>>(
        value: products,
        onRetry: () => ref.invalidate(productsProvider),
        data: (all) {
          final low = [for (final p in all) if (p.needsRestock) p]
            ..sort((a, b) => a.qtyAvailable.compareTo(b.qtyAvailable));
          if (low.isEmpty && reminders.isEmpty) {
            return const EmptyState(
              icon: Icons.check_circle_outline_rounded,
              title: 'Everything is stocked up',
              message: 'Products that run low will show here so you can restock in time.',
            );
          }
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.pageMargin),
            children: [
              if (low.isNotEmpty) ...[
                Text('Needs restocking', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: AppSpacing.sm),
                for (final p in low) ...[
                  _LowTile(product: p),
                  const SizedBox(height: AppSpacing.md),
                ],
              ],
              if (reminders.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.lg),
                Text('Reminders', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: AppSpacing.sm),
                for (final r in reminders)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.alarm_rounded),
                    title: Text(names[r.productId] ?? 'Product'),
                    subtitle: Text('Remind me on ${formatShortDate(r.remindAt)}'),
                    trailing: IconButton(
                      tooltip: 'Cancel reminder',
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => ref.read(inventoryActionsProvider).removeReminder(r.id),
                    ),
                  ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _LowTile extends ConsumerWidget {
  const _LowTile({required this.product});
  final Product product;

  Future<void> _remind(BuildContext context, WidgetRef ref) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 3)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked == null) return;
    try {
      // 8 am on the chosen day.
      await ref.read(inventoryActionsProvider).addReminder(product.id, DateTime(picked.year, picked.month, picked.day, 8));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('We will remind you on ${formatShortDate(picked)}.')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(friendlyError(e))));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final p = product;
    return AppCard(
      onTap: () => context.push(AppRoutes.productDetail(p.id)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(p.name, style: theme.textTheme.titleMedium)),
              p.isOut
                  ? const StatusChip('Out of stock', tone: StatusTone.error)
                  : const StatusChip('Low stock', tone: StatusTone.warning),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '${p.qtyAvailable} available of ${p.qtyOnHand} ${p.unit} (alert at ${p.lowStockThreshold})',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              TextButton.icon(
                onPressed: () => showRestockSheet(context, p),
                icon: const Icon(Icons.add_rounded),
                label: const Text('Restock'),
              ),
              TextButton.icon(
                onPressed: () => _remind(context, ref),
                icon: const Icon(Icons.alarm_add_rounded),
                label: const Text('Remind me'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
