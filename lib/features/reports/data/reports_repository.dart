import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/supabase_client.dart';
import '../domain/report_models.dart';

/// Loads the raw rows the reports are worked out from. Totals are computed in report_models.dart.
abstract class ReportsRepository {
  Future<List<ReportSale>> sales(String accountId, DateTime from, DateTime to);
  Future<List<ReportBudget>> budgets(String accountId);
  Future<List<ReportInvoice>> openInvoices(String accountId);
  Future<List<ReportProduct>> products(String accountId);
  Future<List<StatementLine>> statement(String accountId, String customerId);
}

class SupabaseReportsRepository implements ReportsRepository {
  const SupabaseReportsRepository();

  Future<Map<String, String>> _customerNames(String accountId) async {
    final rows = await supabase.from('customers').select('id, name').eq('account_id', accountId) as List;
    return {for (final r in rows) r['id'] as String: r['name'] as String};
  }

  @override
  Future<List<ReportSale>> sales(String accountId, DateTime from, DateTime to) async {
    final rows = await supabase
        .from('sales')
        .select('id, sold_at, total_kobo, cost_kobo, customer_id')
        .eq('account_id', accountId)
        .isFilter('reversed_at', null)
        .gte('sold_at', from.toUtc().toIso8601String())
        .lt('sold_at', to.toUtc().toIso8601String())
        .limit(2000) as List;
    if (rows.isEmpty) return const [];
    final names = await _customerNames(accountId);
    final ids = [for (final r in rows) r['id'] as String];
    final items = <String, List<ReportSaleItem>>{};
    for (var i = 0; i < ids.length; i += 150) {
      final chunk = ids.sublist(i, i + 150 > ids.length ? ids.length : i + 150);
      final its = await supabase
          .from('sale_items')
          .select('sale_id, description, qty, unit_price_kobo, unit_cost_kobo')
          .inFilter('sale_id', chunk) as List;
      for (final it in its) {
        items.putIfAbsent(it['sale_id'] as String, () => []).add(ReportSaleItem(
              description: it['description'] as String,
              qty: (it['qty'] as num).toInt(),
              unitPriceKobo: (it['unit_price_kobo'] as num).toInt(),
              unitCostKobo: ((it['unit_cost_kobo'] ?? 0) as num).toInt(),
            ));
      }
    }
    return [
      for (final r in rows)
        ReportSale(
          soldAt: DateTime.parse(r['sold_at'] as String).toLocal(),
          totalKobo: (r['total_kobo'] as num).toInt(),
          costKobo: ((r['cost_kobo'] ?? 0) as num).toInt(),
          customerName: names[r['customer_id']],
          items: items[r['id']] ?? const [],
        ),
    ];
  }

  @override
  Future<List<ReportBudget>> budgets(String accountId) async {
    final cats = await supabase.from('expense_categories').select('id, name').eq('account_id', accountId) as List;
    final names = {for (final c in cats) c['id'] as String: c['name'] as String};
    final rows = await supabase
        .from('budgets')
        .select('category_id, amount_kobo, period, paused')
        .eq('account_id', accountId)
        .eq('paused', false) as List;
    return [
      for (final r in rows)
        if (names[r['category_id']] != null)
          ReportBudget(
            categoryName: names[r['category_id']]!,
            monthlyKobo: r['period'] == 'yearly' ? (r['amount_kobo'] as num).toInt() ~/ 12 : (r['amount_kobo'] as num).toInt(),
          ),
    ];
  }

  @override
  Future<List<ReportInvoice>> openInvoices(String accountId) async {
    final rows = await supabase
        .from('invoices')
        .select('invoice_number, customer_id, due_date, total_kobo, balance_kobo')
        .eq('account_id', accountId)
        .inFilter('status', ['sent', 'partially_paid', 'overdue'])
        .gt('balance_kobo', 0)
        .limit(2000) as List;
    if (rows.isEmpty) return const [];
    final names = await _customerNames(accountId);
    return [
      for (final r in rows)
        ReportInvoice(
          number: r['invoice_number'] as String,
          customerName: names[r['customer_id']] ?? 'Customer',
          dueDate: DateTime.parse(r['due_date'] as String),
          totalKobo: (r['total_kobo'] as num).toInt(),
          balanceKobo: (r['balance_kobo'] as num).toInt(),
        ),
    ];
  }

  @override
  Future<List<ReportProduct>> products(String accountId) async {
    final rows = await supabase
        .from('products')
        .select('name, qty_on_hand, cost_kobo, price_kobo')
        .eq('account_id', accountId)
        .isFilter('archived_at', null)
        .limit(2000) as List;
    return [
      for (final r in rows)
        ReportProduct(
          name: r['name'] as String,
          qtyOnHand: ((r['qty_on_hand'] ?? 0) as num).toInt(),
          costKobo: ((r['cost_kobo'] ?? 0) as num).toInt(),
          priceKobo: ((r['price_kobo'] ?? 0) as num).toInt(),
        ),
    ];
  }

  @override
  Future<List<StatementLine>> statement(String accountId, String customerId) async {
    final invoices = await supabase
        .from('invoices')
        .select('id, invoice_number, issue_date, total_kobo')
        .eq('account_id', accountId)
        .eq('customer_id', customerId)
        .inFilter('status', ['sent', 'partially_paid', 'paid', 'overdue'])
        .limit(1000) as List;
    if (invoices.isEmpty) return const [];
    final numbers = {for (final i in invoices) i['id'] as String: i['invoice_number'] as String};
    final lines = <StatementLine>[
      for (final i in invoices)
        StatementLine(
          date: DateTime.parse(i['issue_date'] as String),
          description: 'Invoice ${i['invoice_number']}',
          chargeKobo: (i['total_kobo'] as num).toInt(),
        ),
    ];
    final payments = await supabase
        .from('invoice_payments')
        .select('invoice_id, amount_kobo, paid_on, method')
        .inFilter('invoice_id', numbers.keys.toList()) as List;
    for (final p in payments) {
      lines.add(StatementLine(
        date: DateTime.parse(p['paid_on'] as String),
        description: 'Payment (${p['method']}) for ${numbers[p['invoice_id']]}',
        paymentKobo: (p['amount_kobo'] as num).toInt(),
      ));
    }
    return lines;
  }
}

final reportsRepositoryProvider = Provider<ReportsRepository>((ref) => const SupabaseReportsRepository());
