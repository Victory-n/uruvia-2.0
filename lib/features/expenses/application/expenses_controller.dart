import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/connectivity/connectivity.dart';
import '../../../core/errors/friendly_error.dart';
import '../../account/application/active_account.dart';
import '../../account/application/bootstrap.dart';
import '../../budget/application/budget_controller.dart';
import '../../home/application/home_controller.dart';
import '../data/expense_outbox.dart';
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
  final end = DateTime(month.year, month.month + 1);
  final pending = [
    for (final p in ref.watch(expenseOutboxProvider).forAccount(account.id))
      if (!p.spentAt.isBefore(month) && p.spentAt.isBefore(end))
        Expense(
          id: p.id,
          amountKobo: p.amountKobo,
          spentAt: p.spentAt,
          categoryId: p.categoryId,
          note: p.note,
          pending: true,
        ),
  ];
  try {
    final saved = await ref.watch(expensesRepositoryProvider).between(account.id, month, end);
    // Anything already sent is in `saved`; the rest is still only on this phone.
    final ids = {for (final e in saved) e.id};
    final all = [...pending.where((p) => !ids.contains(p.id)), ...saved]..sort((a, b) => b.spentAt.compareTo(a.spentAt));
    return all;
  } catch (e) {
    // Offline: show what is waiting on this phone rather than an error.
    if (isNetworkError(e) && pending.isNotEmpty) return pending;
    rethrow;
  }
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

  /// Returns true when a new expense could not be sent and was kept on this phone instead.
  Future<bool> save({
    String? id,
    required int amountKobo,
    required DateTime spentAt,
    String? categoryId,
    String? note,
    String? receiptPath,
  }) async {
    if (id == null) {
      final account = _ref.read(activeAccountSummaryProvider);
      if (account == null) throw StateError('No active account');
      final newId = newClientId();
      Future<void> keepOnPhone() => _ref.read(expenseOutboxProvider).add(PendingExpense(
            id: newId,
            accountId: account.id,
            amountKobo: amountKobo,
            spentAt: spentAt,
            categoryId: categoryId,
            note: (note == null || note.trim().isEmpty) ? null : note.trim(),
            receiptPath: receiptPath,
          ));
      if (!_ref.read(isOnlineProvider)) {
        await keepOnPhone();
        _refresh();
        return true;
      }
      try {
        await _repo.create(
          id: newId,
          accountId: account.id,
          amountKobo: amountKobo,
          spentAt: spentAt,
          categoryId: categoryId,
          note: note,
          receiptPath: receiptPath,
        );
      } catch (e) {
        if (!isNetworkError(e)) rethrow;
        await keepOnPhone();
        _refresh();
        return true;
      }
    } else {
      await _repo.update(id, amountKobo: amountKobo, spentAt: spentAt, categoryId: categoryId, note: note, receiptPath: receiptPath);
      _ref.invalidate(expenseProvider(id));
    }
    _refresh();
    return false;
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

/// Sends expenses that were saved on the phone while offline. Starts once at app
/// start and again whenever the connection comes back or the user signs in.
final outboxSyncProvider = Provider<void>((ref) {
  var running = false;

  Future<void> flush() async {
    if (running || ref.read(appStageProvider) != AppStage.ready || !ref.read(isOnlineProvider)) return;
    running = true;
    try {
      final outbox = ref.read(expenseOutboxProvider);
      var sent = 0;
      for (final p in outbox.all()) {
        try {
          await ref.read(expensesRepositoryProvider).create(
                id: p.id,
                accountId: p.accountId,
                amountKobo: p.amountKobo,
                spentAt: p.spentAt,
                categoryId: p.categoryId,
                note: p.note,
                receiptPath: p.receiptPath,
              );
          await outbox.remove(p.id);
          sent++;
        } catch (e) {
          // No connection: stop and try again later. Any other error keeps the item for the next try.
          if (isNetworkError(e)) break;
        }
      }
      if (sent > 0) {
        ref.invalidate(monthExpensesProvider);
        ref.invalidate(homeDataProvider);
        ref.invalidate(budgetsProvider);
        ref.invalidate(budgetExpensesProvider);
      }
    } finally {
      running = false;
    }
  }

  ref.listen<bool>(isOnlineProvider, (_, online) {
    if (online) flush();
  });
  ref.listen<AppStage>(appStageProvider, (_, stage) {
    if (stage == AppStage.ready) flush();
  }, fireImmediately: true);
});
