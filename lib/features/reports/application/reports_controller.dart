import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../account/application/active_account.dart';
import '../../expenses/data/expenses_repository.dart';
import '../../expenses/domain/expense_models.dart';
import '../data/reports_repository.dart';
import '../domain/report_models.dart';

/// Everything the period-based reports need, loaded together.
class ReportBundle {
  const ReportBundle({
    required this.period,
    required this.now,
    required this.sales,
    required this.expenses,
    required this.budgets,
    required this.invoices,
    required this.products,
  });
  final ReportPeriod period;
  final DateTime now;
  final List<ReportSale> sales;
  final List<ReportExpense> expenses;
  final List<ReportBudget> budgets;
  final List<ReportInvoice> invoices;
  final List<ReportProduct> products;

  Totals get totals => totalsFor(sales, expenses);
}

final reportBundleProvider = FutureProvider.autoDispose.family<ReportBundle, ReportPeriod>((ref, period) async {
  final account = ref.watch(activeAccountSummaryProvider);
  if (account == null) throw StateError('No active account');
  final repo = ref.watch(reportsRepositoryProvider);
  final now = DateTime.now();
  final (from, to) = period.range(now);
  final results = await Future.wait([
    repo.sales(account.id, from, to),
    ref.watch(expensesRepositoryProvider).between(account.id, from, to),
    repo.budgets(account.id),
    repo.openInvoices(account.id),
    repo.products(account.id),
  ]);
  final expenses = [
    for (final e in results[1] as List<Expense>)
      ReportExpense(categoryName: e.categoryName ?? '', amountKobo: e.amountKobo, spentAt: e.spentAt),
  ];
  return ReportBundle(
    period: period,
    now: now,
    sales: results[0] as List<ReportSale>,
    expenses: expenses,
    budgets: results[2] as List<ReportBudget>,
    invoices: results[3] as List<ReportInvoice>,
    products: results[4] as List<ReportProduct>,
  );
});

final statementProvider = FutureProvider.autoDispose.family<List<StatementLine>, String>((ref, customerId) async {
  final account = ref.watch(activeAccountSummaryProvider);
  if (account == null) throw StateError('No active account');
  return ref.watch(reportsRepositoryProvider).statement(account.id, customerId);
});
