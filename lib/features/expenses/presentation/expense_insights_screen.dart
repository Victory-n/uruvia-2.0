import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/router/routes.dart';
import '../../../app/theme/app_palette.dart';
import '../../../app/theme/tokens.dart';
import '../../../core/widgets/amount_text.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/state_views.dart';
import '../../../core/widgets/sub_page.dart';
import '../application/expenses_controller.dart';
import '../domain/expense_models.dart';
import 'month_selector.dart';

class ExpenseInsightsScreen extends ConsumerWidget {
  const ExpenseInsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final value = ref.watch(monthExpensesProvider);
    final categories = ref.watch(categoriesProvider).valueOrNull ?? const <ExpenseCategory>[];

    return SubPage(
      title: 'Spending insights',
      fallbackRoute: AppRoutes.expenses,
      body: Column(
        children: [
          const MonthSelector(),
          Expanded(
            child: AsyncView<List<Expense>>(
              value: value,
              onRetry: () => ref.invalidate(monthExpensesProvider),
              isEmpty: (l) => l.isEmpty,
              empty: const EmptyState(
                icon: Icons.insights_rounded,
                title: 'Nothing to show yet',
                message: 'Add some expenses and your spending breakdown will appear here.',
              ),
              data: (list) => _Insights(expenses: list, categories: categories),
            ),
          ),
        ],
      ),
    );
  }
}

class _Insights extends ConsumerWidget {
  const _Insights({required this.expenses, required this.categories});
  final List<Expense> expenses;
  final List<ExpenseCategory> categories;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final palette = theme.extension<AppPalette>()!;
    final total = expenses.fold<int>(0, (s, e) => s + e.amountKobo);
    final rows = totalsByCategory(expenses, categories);

    final month = ref.watch(selectedMonthProvider);
    final now = DateTime.now();
    final isCurrent = month.year == now.year && month.month == now.month;
    final daysElapsed = isCurrent ? now.day : DateTime(month.year, month.month + 1, 0).day;
    final perDay = total ~/ (daysElapsed == 0 ? 1 : daysElapsed);
    final biggest = expenses.reduce((a, b) => a.amountKobo >= b.amountKobo ? a : b);

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.pageMargin),
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Total spent', style: theme.textTheme.bodySmall),
              const SizedBox(height: AppSpacing.xs),
              AmountText(total, size: AmountSize.xl),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(child: _Fact(label: 'Average per day', amount: perDay)),
                  Expanded(child: _Fact(label: 'Biggest expense', amount: biggest.amountKobo)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sectionGap),
        Text('By category', style: theme.textTheme.titleLarge),
        const SizedBox(height: AppSpacing.md),
        for (final r in rows)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(categoryIcon(r.icon), size: 20, color: palette.action),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(child: Text(r.name, style: theme.textTheme.titleMedium)),
                    AmountText(r.totalKobo, showKobo: false),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: total == 0 ? 0 : r.totalKobo / total,
                    minHeight: 8,
                    color: palette.action,
                    backgroundColor: AppColors.border,
                  ),
                ),
                const SizedBox(height: 2),
                Text('${total == 0 ? 0 : (r.totalKobo * 100 / total).round()}% of spending',
                    style: theme.textTheme.bodySmall),
              ],
            ),
          ),
      ],
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact({required this.label, required this.amount});
  final String label;
  final int amount;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        AmountText(amount, showKobo: false),
      ],
    );
  }
}
