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
import '../../expenses/domain/expense_models.dart';
import '../application/budget_controller.dart';
import '../domain/budget_models.dart';
import 'budget_widgets.dart';

class BudgetListScreen extends ConsumerWidget {
  const BudgetListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final value = ref.watch(budgetsProvider);
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.budgetsNew),
        icon: const Icon(Icons.add_rounded),
        label: const Text('New budget'),
      ),
      body: AsyncView<List<BudgetProgress>>(
        value: value,
        onRetry: () => ref.invalidate(budgetsProvider),
        isEmpty: (l) => l.isEmpty,
        empty: EmptyState(
          icon: Icons.pie_chart_outline_rounded,
          title: 'No budgets yet',
          message: 'Set a limit for a category, like Feeding or Transport, and we will warn you before you go over.',
          actionLabel: 'Create a budget',
          onAction: () => context.push(AppRoutes.budgetsNew),
        ),
        data: (list) => RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(budgetsProvider);
            try {
              await ref.read(budgetsProvider.future);
            } catch (_) {}
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(AppSpacing.pageMargin, AppSpacing.lg, AppSpacing.pageMargin, 96),
            children: [
              _Summary(totals: totalsOf(list)),
              const SizedBox(height: AppSpacing.sectionGap),
              for (final b in list) ...[
                _BudgetCard(budget: b),
                const SizedBox(height: AppSpacing.md),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({required this.totals});
  final BudgetTotals totals;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.extension<AppPalette>()!;
    final over = totals.remainingKobo < 0;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(color: palette.hero, borderRadius: BorderRadius.circular(AppRadius.card)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(over ? 'Over budget by' : 'Left to spend', style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70)),
          const SizedBox(height: AppSpacing.xs),
          AmountText(totals.remainingKobo.abs(), size: AmountSize.xl, color: Colors.white),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '${formatNaira(totals.spentKobo, showKobo: false)} spent of ${formatNaira(totals.budgetedKobo, showKobo: false)}',
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

class _BudgetCard extends StatelessWidget {
  const _BudgetCard({required this.budget});
  final BudgetProgress budget;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.extension<AppPalette>()!;
    final over = budget.remainingKobo < 0;
    return AppCard(
      onTap: () => context.push(AppRoutes.budgetDetail(budget.budgetId)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: palette.tint,
                child: Icon(categoryIcon(budget.categoryIcon), color: palette.action, size: 20),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: Text(budget.categoryName, style: theme.textTheme.titleMedium)),
              if (budget.paused) const StatusChip('Paused') else Text(budget.period.label, style: theme.textTheme.bodySmall),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          BudgetBar(budget: budget),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: Text(
                  '${formatNaira(budget.spentKobo, showKobo: false)} of ${formatNaira(budget.amountKobo, showKobo: false)}',
                  style: theme.textTheme.bodyMedium,
                ),
              ),
              Text(
                over
                    ? '${formatNaira(-budget.remainingKobo, showKobo: false)} over'
                    : '${formatNaira(budget.remainingKobo, showKobo: false)} left',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: over ? StatusColors.errorText : AppColors.inkSoft,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
