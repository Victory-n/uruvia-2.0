import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../app/theme/app_palette.dart';
import '../../../app/theme/tokens.dart';
import '../../../core/utils/dates.dart';
import '../../../core/widgets/amount_text.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/state_views.dart';
import '../application/expenses_controller.dart';
import '../domain/expense_models.dart';
import 'month_selector.dart';

class ExpenseListScreen extends ConsumerWidget {
  const ExpenseListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final value = ref.watch(monthExpensesProvider);
    final categories = ref.watch(categoriesProvider).valueOrNull ?? const <ExpenseCategory>[];
    final icons = {for (final c in categories) c.id: c.icon};

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.expensesNew),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add expense'),
      ),
      body: Column(
        children: [
          const MonthSelector(),
          Expanded(
            child: AsyncView<List<Expense>>(
              value: value,
              onRetry: () => ref.invalidate(monthExpensesProvider),
              isEmpty: (list) => list.isEmpty,
              empty: EmptyState(
                icon: Icons.receipt_long_outlined,
                title: 'No expenses this month',
                message: 'Log what you spend to see where your money goes.',
                actionLabel: 'Add expense',
                onAction: () => context.push(AppRoutes.expensesNew),
              ),
              data: (list) => _Body(expenses: list, icons: icons),
            ),
          ),
        ],
      ),
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body({required this.expenses, required this.icons});
  final List<Expense> expenses;
  final Map<String, String> icons;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final total = expenses.fold<int>(0, (s, e) => s + e.amountKobo);

    // Group by day (list is already newest first).
    final items = <Object>[];
    DateTime? lastDay;
    for (final e in expenses) {
      final day = DateTime(e.spentAt.year, e.spentAt.month, e.spentAt.day);
      if (day != lastDay) {
        items.add(day);
        lastDay = day;
      }
      items.add(e);
    }

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(monthExpensesProvider);
        try {
          await ref.read(monthExpensesProvider.future);
        } catch (_) {}
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(AppSpacing.pageMargin, AppSpacing.sm, AppSpacing.pageMargin, 96),
        children: [
          AppCard(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Spent', style: theme.textTheme.bodySmall),
                      const SizedBox(height: AppSpacing.xs),
                      AmountText(total, size: AmountSize.l),
                      Text('${expenses.length} ${expenses.length == 1 ? 'expense' : 'expenses'}',
                          style: theme.textTheme.bodySmall),
                    ],
                  ),
                ),
                AppButton(
                  label: 'Insights',
                  style: AppButtonStyle.secondary,
                  icon: Icons.insights_rounded,
                  expand: false,
                  onPressed: () => context.push(AppRoutes.expensesInsights),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          for (final item in items)
            if (item is DateTime)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.md, bottom: AppSpacing.xs),
                child: Text(formatDayHeader(item), style: theme.textTheme.labelLarge?.copyWith(color: AppColors.inkSoft)),
              )
            else
              _ExpenseTile(expense: item as Expense, icon: icons[item.categoryId] ?? 'category'),
        ],
      ),
    );
  }
}

class _ExpenseTile extends StatelessWidget {
  const _ExpenseTile({required this.expense, required this.icon});
  final Expense expense;
  final String icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.extension<AppPalette>()!;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      minTileHeight: 64,
      leading: CircleAvatar(
        backgroundColor: palette.tint,
        child: Icon(categoryIcon(icon), color: palette.action, size: 20),
      ),
      title: Text(expense.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.titleMedium),
      subtitle: Text(expense.categoryName ?? 'No category', style: theme.textTheme.bodySmall),
      trailing: AmountText(-expense.amountKobo),
      onTap: () => context.push(AppRoutes.expenseEdit(expense.id)),
    );
  }
}
