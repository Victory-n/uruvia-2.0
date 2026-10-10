import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../account/application/active_account.dart';
import '../../budget/application/budget_controller.dart';
import '../../home/application/home_controller.dart';
import '../data/expenses_repository.dart';
import '../domain/expense_models.dart';

final categoriesProvider = FutureProvider.autoDispose<List<ExpenseCategory>>((ref) async {
  final account = ref.watch(activeAccountSummaryProvider);
  if (account == null) return const [];
  return ref.watch(expensesRepositoryProvider).categories(account.id);
});

/// First day of the month being looked at.
class SelectedMonth extends Notifier<DateTime> {
  @override
  DateTime build() {
    final now = DateTime.now();
    return DateTime(now.year, now.month);
  }

  void previous() => state = DateTime(state.year, state.month - 1);

  void next() {
    final now = DateTime.now();
    final candidate = DateTime(state.year, state.month + 1);
    if (!candidate.isAfter(DateTime(now.year, now.month))) state = candidate;
  }

  bool get isCurrent {
    final now = DateTime.now();
    return state.year == now.year && state.month == now.month;
  }
}

final selectedMonthProvider = NotifierProvider<SelectedMonth, DateTime>(SelectedMonth.new);

final monthExpensesProvider = FutureProvider.autoDispose<List<Expense>>((ref) async {
  final account = ref.watch(activeAccountSummaryProvider);
  final month = ref.watch(selectedMonthProvider);
  if (account == null) return const [];
  return ref
      .watch(expensesRepositoryProvider)
      .between(account.id, month, DateTime(month.year, month.month + 1));
});

final expenseProvider = FutureProvider.autoDispose.family<Expense?, String>(
  (ref, id) => ref.watch(expensesRepositoryProvider).get(id),
);

class ExpensesActions {
  ExpensesActions(this._ref);
  final Ref _ref;

  ExpensesRepository get _repo => _ref.read(expensesRepositoryProvider);

  void _refresh() {
    _ref.invalidate(monthExpensesProvider);
    _ref.invalidate(homeDataProvider);
    _ref.invalidate(budgetsProvider);
    _ref.invalidate(budgetExpensesProvider);
  }

  Future<void> save({
    String? id,
    required int amountKobo,
    required DateTime spentAt,
    String? categoryId,
    String? note,
  }) async {
    if (id == null) {
      final account = _ref.read(activeAccountSummaryProvider);
      if (account == null) throw StateError('No active account');
      await _repo.create(
        accountId: account.id,
        amountKobo: amountKobo,
        spentAt: spentAt,
        categoryId: categoryId,
        note: note,
      );
    } else {
      await _repo.update(id, amountKobo: amountKobo, spentAt: spentAt, categoryId: categoryId, note: note);
      _ref.invalidate(expenseProvider(id));
    }
    _refresh();
  }

  Future<void> delete(String id) async {
    await _repo.delete(id);
    _refresh();
  }

  Future<ExpenseCategory> addCategory(String name) async {
    final account = _ref.read(activeAccountSummaryProvider);
    if (account == null) throw StateError('No active account');
    final created = await _repo.createCategory(account.id, name);
    _ref.invalidate(categoriesProvider);
    return created;
  }
}

final expensesActionsProvider = Provider<ExpensesActions>(ExpensesActions.new);
