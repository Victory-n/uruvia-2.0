import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/supabase_client.dart';
import '../../account/domain/account_models.dart';
import '../../account/domain/account_type.dart';
import '../domain/home_models.dart';

abstract class HomeRepository {
  Future<HomeData> load(AccountSummary account);
}

class SupabaseHomeRepository implements HomeRepository {
  const SupabaseHomeRepository();

  @override
  Future<HomeData> load(AccountSummary account) async {
    final raw = await supabase.rpc('home_summary', params: {'p_account_id': account.id});
    final summary = HomeSummary.fromJson(Map<String, dynamic>.from(raw as Map));

    if (account.type == AccountType.business) {
      return HomeData(summary: summary, recentInvoices: await _recentInvoices(account.id));
    }
    return HomeData(summary: summary, recentExpenses: await _recentExpenses(account.id));
  }

  Future<List<RecentExpense>> _recentExpenses(String accountId) async {
    final rows = await supabase
        .from('expenses')
        .select('id, amount_kobo, spent_at, note, category_id')
        .eq('account_id', accountId)
        .order('spent_at', ascending: false)
        .limit(5) as List;
    if (rows.isEmpty) return const [];

    final cats = await supabase.from('expense_categories').select('id, name').eq('account_id', accountId) as List;
    final names = {for (final c in cats) c['id'] as String: c['name'] as String};

    return [
      for (final r in rows)
        RecentExpense(
          id: r['id'] as String,
          amountKobo: (r['amount_kobo'] as num).toInt(),
          spentAt: DateTime.parse(r['spent_at'] as String).toLocal(),
          note: r['note'] as String?,
          categoryName: names[r['category_id']],
        ),
    ];
  }

  Future<List<RecentInvoice>> _recentInvoices(String accountId) async {
    final rows = await supabase
        .from('invoices')
        .select('id, invoice_number, status, total_kobo, balance_kobo, due_date, customer_id')
        .eq('account_id', accountId)
        .neq('status', 'cancelled')
        .order('created_at', ascending: false)
        .limit(5) as List;
    if (rows.isEmpty) return const [];

    final ids = {for (final r in rows) r['customer_id'] as String}.toList();
    final customers = await supabase.from('customers').select('id, name').inFilter('id', ids) as List;
    final names = {for (final c in customers) c['id'] as String: c['name'] as String};

    return [
      for (final r in rows)
        RecentInvoice(
          id: r['id'] as String,
          number: r['invoice_number'] as String,
          status: r['status'] as String,
          totalKobo: (r['total_kobo'] as num).toInt(),
          balanceKobo: (r['balance_kobo'] as num).toInt(),
          dueDate: r['due_date'] == null ? null : DateTime.parse(r['due_date'] as String),
          customerName: names[r['customer_id']],
        ),
    ];
  }
}

final homeRepositoryProvider = Provider<HomeRepository>((ref) => const SupabaseHomeRepository());
