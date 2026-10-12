import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../app/theme/app_palette.dart';
import '../../../app/theme/tokens.dart';
import '../../../core/widgets/app_card.dart';
import '../../customers/application/customers_controller.dart';
import '../../inventory/application/inventory_controller.dart';
import '../domain/home_models.dart';

/// A short checklist for a new business: add a product, a customer, an invoice and a sale.
/// It disappears by itself once all four are done. While the lists are still loading it shows nothing.
class GettingStartedCard extends ConsumerWidget {
  const GettingStartedCard({super.key, required this.data});
  final HomeData data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(productsProvider).valueOrNull;
    final customers = ref.watch(customersProvider).valueOrNull;
    if (products == null || customers == null) return const SizedBox.shrink();

    final steps = <({String label, bool done, String route, bool push})>[
      (label: 'Add your first product', done: products.isNotEmpty, route: AppRoutes.inventoryNew, push: true),
      (label: 'Add a customer', done: customers.isNotEmpty, route: AppRoutes.customersNew, push: true),
      (label: 'Create an invoice', done: data.recentInvoices.isNotEmpty, route: AppRoutes.invoicesNew, push: true),
      (label: 'Record a sale', done: data.summary.salesMonthKobo > 0, route: AppRoutes.salesNew, push: true),
    ];
    final doneCount = steps.where((s) => s.done).length;
    if (doneCount == steps.length) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final palette = theme.extension<AppPalette>()!;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sectionGap),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Get your business going', style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.xs),
            Text('$doneCount of ${steps.length} done', style: theme.textTheme.bodySmall),
            const SizedBox(height: AppSpacing.sm),
            LinearProgressIndicator(value: doneCount / steps.length, minHeight: 6, color: palette.action, backgroundColor: AppColors.border),
            const SizedBox(height: AppSpacing.sm),
            for (final s in steps)
              ListTile(
                contentPadding: EdgeInsets.zero,
                minTileHeight: 48,
                leading: Icon(
                  s.done ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                  color: s.done ? palette.action : AppColors.inkSoft,
                ),
                title: Text(s.label, style: s.done ? theme.textTheme.bodyMedium?.copyWith(decoration: TextDecoration.lineThrough, color: AppColors.inkSoft) : theme.textTheme.bodyMedium),
                trailing: s.done ? null : const Icon(Icons.chevron_right_rounded),
                onTap: s.done ? null : () => context.push(s.route),
              ),
          ],
        ),
      ),
    );
  }
}
