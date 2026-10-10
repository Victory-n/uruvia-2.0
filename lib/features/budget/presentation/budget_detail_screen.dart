import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../app/theme/app_palette.dart';
import '../../../app/theme/tokens.dart';
import '../../../core/errors/friendly_error.dart';
import '../../../core/utils/dates.dart';
import '../../../core/utils/money.dart';
import '../../../core/widgets/amount_text.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/state_views.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../core/widgets/sub_page.dart';
import '../../expenses/domain/expense_models.dart';
import '../application/budget_controller.dart';
import '../domain/budget_models.dart';
import 'budget_widgets.dart';

class BudgetDetailScreen extends ConsumerWidget {
  const BudgetDetailScreen({super.key, required this.budgetId});
  final String budgetId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final value = ref.watch(budgetProvider(budgetId));
    final budget = value.valueOrNull;

    return SubPage(
      title: budget?.categoryName ?? 'Budget',
      fallbackRoute: AppRoutes.budgets,
      actions: [
        if (budget != null)
          PopupMenuButton<String>(
            tooltip: 'More',
            onSelected: (v) {
              if (v == 'edit') context.push(AppRoutes.budgetEdit(budgetId));
              if (v == 'delete') _confirmDelete(context, ref);
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'edit', child: Text('Edit budget')),
              PopupMenuItem(value: 'delete', child: Text('Delete budget')),
            ],
          ),
      ],
      body: AsyncView<BudgetProgress?>(
        value: value,
        onRetry: () => ref.invalidate(budgetProvider(budgetId)),
        isEmpty: (b) => b == null,
        empty: const EmptyState(
          icon: Icons.search_off_rounded,
          title: 'Budget not found',
          message: 'It may have been deleted.',
        ),
        data: (b) => _Detail(budget: b!),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete this budget?'),
        content: const Text('Your expenses stay. Only the budget limit is removed.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ref.read(budgetActionsProvider).delete(budgetId);
      if (context.mounted) context.canPop() ? context.pop() : context.go(AppRoutes.budgets);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(friendlyError(e))));
      }
    }
  }
}

class _Detail extends ConsumerWidget {
  const _Detail({required this.budget});
  final BudgetProgress budget;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final palette = theme.extension<AppPalette>()!;
    final expenses = ref.watch(budgetExpensesProvider(budget));
    final over = budget.remainingKobo < 0;
    final days = budget.daysLeft();
    final lastDay = budget.endsOn.subtract(const Duration(days: 1));

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(budgetProvider(budget.budgetId));
        ref.invalidate(budgetExpensesProvider);
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.pageMargin),
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${budget.period.label} · ${formatShortDate(budget.startsOn)} to ${formatShortDate(lastDay)}',
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                    if (budget.paused) const StatusChip('Paused'),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Text(over ? 'Over budget by' : 'Left to spend', style: theme.textTheme.bodySmall),
                AmountText(
                  budget.remainingKobo.abs(),
                  size: AmountSize.xl,
                  color: over ? StatusColors.errorText : AppColors.ink,
                ),
                const SizedBox(height: AppSpacing.md),
                BudgetBar(budget: budget, height: 12),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  '${formatNaira(budget.spentKobo, showKobo: false)} spent of ${formatNaira(budget.amountKobo, showKobo: false)}',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Days left', style: theme.textTheme.bodySmall),
                      Text('$days', style: theme.textTheme.headlineSmall),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('You can spend per day', style: theme.textTheme.bodySmall),
                      AmountText(budget.dailyAllowanceKobo(), size: AmountSize.l, showKobo: false),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sectionGap),
          Text('Expenses in this budget', style: theme.textTheme.titleLarge),
          const SizedBox(height: AppSpacing.sm),
          AsyncView<List<Expense>>(
            value: expenses,
            loading: const Padding(padding: EdgeInsets.all(AppSpacing.xl), child: Center(child: CircularProgressIndicator())),
            onRetry: () => ref.invalidate(budgetExpensesProvider),
            isEmpty: (l) => l.isEmpty,
            empty: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
              child: Text(
                'Nothing spent yet in ${budget.categoryName}.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.inkSoft),
              ),
            ),
            data: (list) => Column(
              children: [
                for (final e in list)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    minTileHeight: 56,
                    leading: CircleAvatar(
                      backgroundColor: palette.tint,
                      child: Icon(categoryIcon(budget.categoryIcon), color: palette.action, size: 20),
                    ),
                    title: Text(e.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                    subtitle: Text(formatShortDate(e.spentAt)),
                    trailing: AmountText(-e.amountKobo),
                    onTap: () => context.push(AppRoutes.expenseEdit(e.id)),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
