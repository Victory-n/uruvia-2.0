import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../account/application/active_account.dart';
import '../../expenses/domain/expense_models.dart';
import '../../home/application/home_controller.dart';
import '../data/budget_repository.dart';
import '../domain/budget_models.dart';

final budgetsProvider = FutureProvider.autoDispose<List<BudgetProgress>>((ref) async {
  final account = ref.watch(activeAccountSummaryProvider);
  if (account == null) return const [];
  return ref.watch(budgetRepositoryProvider).current(account.id);
});

final budgetProvider = FutureProvider.autoDispose.family<BudgetProgress?, String>(
  (ref, id) => ref.watch(budgetRepositoryProvider).get(id),
);

/// Expenses that count towards one budget in its current period.
final budgetExpensesProvider = FutureProvider.autoDispose.family<List<Expense>, BudgetProgress>(
  (ref, budget) => ref.watch(budgetRepositoryProvider).expensesFor(budget),
);

class BudgetActions {
  BudgetActions(this._ref);
  final Ref _ref;

  BudgetRepository get _repo => _ref.read(budgetRepositoryProvider);

  void _refresh([String? id]) {
    _ref.invalidate(budgetsProvider);
    _ref.invalidate(homeDataProvider);
    if (id != null) _ref.invalidate(budgetProvider(id));
  }

  Future<void> create({
    required String categoryId,
    required int amountKobo,
    required BudgetPeriod period,
    required bool repeat,
    required bool alert80,
    required bool alert100,
  }) async {
    final account = _ref.read(activeAccountSummaryProvider);
    if (account == null) throw StateError('No active account');
    await _repo.create(
      accountId: account.id,
      categoryId: categoryId,
      amountKobo: amountKobo,
      period: period,
      repeat: repeat,
      alert80: alert80,
      alert100: alert100,
    );
    _refresh();
  }

  Future<void> update(
    String id, {
    required int amountKobo,
    required bool repeat,
    required bool alert80,
    required bool alert100,
    required bool paused,
  }) async {
    await _repo.update(id,
        amountKobo: amountKobo, repeat: repeat, alert80: alert80, alert100: alert100, paused: paused);
    _refresh(id);
  }

  Future<void> delete(String id) async {
    await _repo.delete(id);
    _refresh(id);
  }
}

final budgetActionsProvider = Provider<BudgetActions>(BudgetActions.new);
