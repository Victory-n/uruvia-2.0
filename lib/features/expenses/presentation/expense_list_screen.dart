import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../app/theme/app_palette.dart';
import '../../../app/theme/tokens.dart';
import '../../../core/errors/friendly_error.dart';
import '../../../core/utils/dates.dart';
import '../../../core/widgets/amount_text.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/state_views.dart';
import '../../../core/widgets/status_chip.dart';
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
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton.small(
            heroTag: 'voice-expense',
            tooltip: 'Add by voice',
            onPressed: () => context.push(AppRoutes.expensesVoice),
            child: const Icon(Icons.mic_rounded),
          ),
          const SizedBox(height: AppSpacing.md),
          FloatingActionButton.extended(
            heroTag: 'add-expense',
            onPressed: () => context.push(AppRoutes.expensesNew),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add expense'),
          ),
        ],
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

class _Body extends ConsumerStatefulWidget {
  const _Body({required this.expenses, required this.icons});
  final List<Expense> expenses;
  final Map<String, String> icons;

  @override
  ConsumerState<_Body> createState() => _BodyState();
}

class _BodyState extends ConsumerState<_Body> {
  String _query = '';
  String? _categoryId;
  DateTimeRange? _range;

  Future<void> _pickRange() async {
    final month = ref.read(selectedMonthProvider);
    final monthEnd = DateTime(month.year, month.month + 1, 0);
    final now = DateTime.now();
    final last = monthEnd.isAfter(now) ? DateTime(now.year, now.month, now.day) : monthEnd;
    final picked = await showDateRangePicker(context: context, firstDate: month, lastDate: last, initialDateRange: _range);
    if (picked != null && mounted) setState(() => _range = picked);
  }

  Map<String, String> get icons => widget.icons;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final all = widget.expenses;
    final expenses = filterExpenses(all, query: _query, categoryId: _categoryId, from: _range?.start, to: _range?.end);
    // Only offer categories that appear this month.
    final used = <String, String>{
      for (final e in all)
        if (e.categoryId != null) e.categoryId!: e.categoryName ?? 'Category',
    };
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
          TextField(
            onChanged: (v) => setState(() => _query = v),
            textInputAction: TextInputAction.search,
            decoration: const InputDecoration(
              hintText: 'Search notes or categories',
              prefixIcon: Icon(Icons.search_rounded),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Align(
            alignment: Alignment.centerLeft,
            child: _range == null
                ? ActionChip(avatar: const Icon(Icons.date_range_rounded, size: 18), label: const Text('Pick dates'), onPressed: _pickRange)
                : InputChip(
                    avatar: const Icon(Icons.date_range_rounded, size: 18),
                    label: Text('${formatShortDate(_range!.start)} to ${formatShortDate(_range!.end)}'),
                    onPressed: _pickRange,
                    onDeleted: () => setState(() => _range = null),
                  ),
          ),
          if (used.length > 1) ...[
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.sm),
                    child: ChoiceChip(label: const Text('All'), selected: _categoryId == null, onSelected: (_) => setState(() => _categoryId = null)),
                  ),
                  for (final entry in used.entries)
                    Padding(
                      padding: const EdgeInsets.only(right: AppSpacing.sm),
                      child: ChoiceChip(
                        label: Text(entry.value),
                        selected: _categoryId == entry.key,
                        onSelected: (s) => setState(() => _categoryId = s ? entry.key : null),
                      ),
                    ),
                ],
              ),
            ),
          ],
          if (expenses.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
              child: Center(child: Text('No expenses match.', style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.inkSoft))),
            ),
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

class _ExpenseTile extends ConsumerWidget {
  const _ExpenseTile({required this.expense, required this.icon});
  final Expense expense;
  final String icon;

  Future<bool> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete this expense?'),
        content: Text(expense.title),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
        ],
      ),
    );
    if (ok != true) return false;
    try {
      await ref.read(expensesActionsProvider).delete(expense.id);
      return true;
    } catch (e) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(friendlyError(e))));
      return false;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tile = _tile(context);
    if (expense.pending) return tile;
    return Dismissible(
      key: ValueKey(expense.id),
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: AppSpacing.lg),
        color: Theme.of(context).extension<AppPalette>()!.tint,
        child: const Icon(Icons.edit_outlined),
      ),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.lg),
        color: StatusColors.errorText.withValues(alpha: 0.12),
        child: const Icon(Icons.delete_outline_rounded, color: StatusColors.errorText),
      ),
      confirmDismiss: (dir) async {
        if (dir == DismissDirection.startToEnd) {
          context.push(AppRoutes.expenseEdit(expense.id));
          return false;
        }
        return _confirmDelete(context, ref);
      },
      child: tile,
    );
  }

  Widget _tile(BuildContext context) {
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
      subtitle: expense.pending
          ? const Align(alignment: Alignment.centerLeft, child: StatusChip('Waiting to send', tone: StatusTone.warning))
          : Text(expense.categoryName ?? 'No category', style: theme.textTheme.bodySmall),
      trailing: AmountText(-expense.amountKobo),
      onTap: expense.pending ? null : () => context.push(AppRoutes.expenseEdit(expense.id)),
    );
  }
}
