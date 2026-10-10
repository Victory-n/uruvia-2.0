import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../app/theme/app_palette.dart';
import '../../../app/theme/tokens.dart';
import '../../../core/utils/dates.dart';
import '../../../core/widgets/amount_text.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/utils/money.dart';
import '../domain/home_models.dart';
import 'home_widgets.dart';
import 'wallet_card.dart';

class IndividualHome extends StatelessWidget {
  const IndividualHome({super.key, required this.data});
  final HomeData data;

  @override
  Widget build(BuildContext context) {
    final s = data.summary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const WalletCard(),
        const SizedBox(height: AppSpacing.sectionGap),
        const QuickActions(actions: [
          QuickAction(Icons.add_circle_outline_rounded, 'Add expense', AppRoutes.expenses),
          QuickAction(Icons.pie_chart_outline_rounded, 'Budgets', AppRoutes.budgets),
          QuickAction(Icons.savings_outlined, 'Savings', AppRoutes.savings),
          QuickAction(Icons.receipt_long_outlined, 'Expenses', AppRoutes.expenses),
        ]),
        const SizedBox(height: AppSpacing.sectionGap),
        SectionHeader('This month', actionLabel: 'Budgets', onAction: () => context.go(AppRoutes.budgets)),
        const SizedBox(height: AppSpacing.sm),
        _BudgetCard(summary: s),
        const SizedBox(height: AppSpacing.sectionGap),
        SectionHeader('Recent expenses', actionLabel: 'See all', onAction: () => context.go(AppRoutes.expenses)),
        const SizedBox(height: AppSpacing.sm),
        if (data.recentExpenses.isEmpty)
          InlineEmpty(
            icon: Icons.receipt_long_outlined,
            title: 'No expenses yet',
            message: 'Log what you spend and it will show up here.',
            actionLabel: 'Add expense',
            onAction: () => context.go(AppRoutes.expenses),
          )
        else
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (var i = 0; i < data.recentExpenses.length; i++) ...[
                  if (i > 0) const Divider(),
                  _ExpenseRow(expense: data.recentExpenses[i]),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

class _BudgetCard extends StatelessWidget {
  const _BudgetCard({required this.summary});
  final HomeSummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.extension<AppPalette>()!;

    if (!summary.hasBudget) {
      return AppCard(
        onTap: () => context.go(AppRoutes.budgets),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Spent this month', style: theme.textTheme.bodySmall),
            const SizedBox(height: AppSpacing.xs),
            AmountText(summary.spentThisMonthKobo, size: AmountSize.l),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Set a budget to see how much you have left.',
              style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.inkSoft),
            ),
          ],
        ),
      );
    }

    final f = summary.budgetFraction;
    final over = f > 1;
    final color = over ? StatusColors.error : (f >= 0.8 ? StatusColors.warning : palette.action);
    final left = summary.budgetRemainingKobo;

    return AppCard(
      onTap: () => context.go(AppRoutes.budgets),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Spent of your budgets', style: theme.textTheme.bodySmall),
          const SizedBox(height: AppSpacing.xs),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              AmountText(summary.budgetSpentKobo, size: AmountSize.l),
              const SizedBox(width: AppSpacing.sm),
              Flexible(
                child: Text(
                  'of ${formatNaira(summary.budgetTotalKobo, showKobo: false)}',
                  style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.inkSoft),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: f.clamp(0, 1).toDouble(),
              minHeight: 10,
              color: color,
              backgroundColor: AppColors.border,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            over
                ? '${formatNaira(-left, showKobo: false)} over budget'
                : '${formatNaira(left, showKobo: false)} left',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: over ? StatusColors.errorText : AppColors.inkSoft,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (summary.budgetOverCount > 0) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              '${summary.budgetOverCount} ${summary.budgetOverCount == 1 ? 'budget is' : 'budgets are'} over the limit.',
              style: theme.textTheme.bodySmall?.copyWith(color: StatusColors.errorText),
            ),
          ],
        ],
      ),
    );
  }
}

class _ExpenseRow extends StatelessWidget {
  const _ExpenseRow({required this.expense});
  final RecentExpense expense;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.extension<AppPalette>()!;
    return ListTile(
      minTileHeight: 64,
      leading: CircleAvatar(
        backgroundColor: palette.tint,
        child: Icon(Icons.receipt_long_outlined, color: palette.action, size: 20),
      ),
      title: Text(expense.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.titleMedium),
      subtitle: Text(
        [if (expense.categoryName != null) expense.categoryName!, formatShortDate(expense.spentAt)].join(' · '),
        style: theme.textTheme.bodySmall,
      ),
      trailing: AmountText(-expense.amountKobo, color: AppColors.ink),
    );
  }
}
