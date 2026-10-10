import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/supabase_client.dart';
import '../../expenses/domain/expense_models.dart';
import '../domain/budget_models.dart';

abstract class BudgetRepository {
  /// Budgets whose current period includes today.
  Future<List<BudgetProgress>> current(String accountId);
  Future<BudgetProgress?> get(String budgetId);
  Future<void> create({
    required String accountId,
    required String categoryId,
    required int amountKobo,
    required BudgetPeriod period,
    required bool repeat,
    required bool alert80,
    required bool alert100,
  });
  Future<void> update(
    String budgetId, {
    required int amountKobo,
    required bool repeat,
    required bool alert80,
    required bool alert100,
    required bool paused,
  });
  Future<void> delete(String budgetId);
  Future<List<Expense>> expensesFor(BudgetProgress budget);
}

String _date(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

class SupabaseBudgetRepository implements BudgetRepository {
  const SupabaseBudgetRepository();

  Future<List<BudgetProgress>> _build(List rows) async {
    if (rows.isEmpty) return const [];
    final ids = [for (final r in rows) r['budget_id'] as String];
    final accountId = rows.first['account_id'] as String;

    final flags = await supabase
        .from('budgets')
        .select('id, alert_80, alert_100, paused, repeat')
        .inFilter('id', ids) as List;
    final flagById = {for (final f in flags) f['id'] as String: f as Map};

    final cats = await supabase
        .from('expense_categories')
        .select('id, name, icon')
        .eq('account_id', accountId) as List;
    final catById = {for (final c in cats) c['id'] as String: c as Map};

    return [
      for (final r in rows)
        BudgetProgress(
          budgetId: r['budget_id'] as String,
          categoryId: r['category_id'] as String,
          categoryName: (catById[r['category_id']]?['name'] as String?) ?? 'Category',
          categoryIcon: (catById[r['category_id']]?['icon'] as String?) ?? 'category',
          amountKobo: (r['amount_kobo'] as num).toInt(),
          spentKobo: (r['spent_kobo'] as num).toInt(),
          period: BudgetPeriod.parse(r['period'] as String),
          startsOn: DateTime.parse(r['starts_on'] as String),
          endsOn: DateTime.parse(r['ends_on'] as String),
          alert80: (flagById[r['budget_id']]?['alert_80'] as bool?) ?? true,
          alert100: (flagById[r['budget_id']]?['alert_100'] as bool?) ?? true,
          paused: (flagById[r['budget_id']]?['paused'] as bool?) ?? false,
          repeat: (flagById[r['budget_id']]?['repeat'] as bool?) ?? true,
        ),
    ];
  }

  @override
  Future<List<BudgetProgress>> current(String accountId) async {
    final today = _date(DateTime.now());
    final rows = await supabase
        .from('budget_progress')
        .select('budget_id, account_id, category_id, amount_kobo, period, starts_on, ends_on, spent_kobo')
        .eq('account_id', accountId)
        .lte('starts_on', today)
        .gt('ends_on', today) as List;
    final list = await _build(rows);
    list.sort((a, b) => b.fraction.compareTo(a.fraction));
    return list;
  }

  @override
  Future<BudgetProgress?> get(String budgetId) async {
    final rows = await supabase
        .from('budget_progress')
        .select('budget_id, account_id, category_id, amount_kobo, period, starts_on, ends_on, spent_kobo')
        .eq('budget_id', budgetId) as List;
    final list = await _build(rows);
    return list.isEmpty ? null : list.first;
  }

  @override
  Future<void> create({
    required String accountId,
    required String categoryId,
    required int amountKobo,
    required BudgetPeriod period,
    required bool repeat,
    required bool alert80,
    required bool alert100,
  }) async {
    await supabase.from('budgets').insert({
      'account_id': accountId,
      'category_id': categoryId,
      'amount_kobo': amountKobo,
      'period': period.name,
      'starts_on': _date(periodStart(period)),
      'repeat': repeat,
      'alert_80': alert80,
      'alert_100': alert100,
    });
  }

  @override
  Future<void> update(
    String budgetId, {
    required int amountKobo,
    required bool repeat,
    required bool alert80,
    required bool alert100,
    required bool paused,
  }) async {
    await supabase.from('budgets').update({
      'amount_kobo': amountKobo,
      'repeat': repeat,
      'alert_80': alert80,
      'alert_100': alert100,
      'paused': paused,
    }).eq('id', budgetId);
  }

  @override
  Future<void> delete(String budgetId) async {
    await supabase.from('budgets').delete().eq('id', budgetId);
  }

  @override
  Future<List<Expense>> expensesFor(BudgetProgress b) async {
    final rows = await supabase
        .from('expenses')
        .select('id, amount_kobo, spent_at, note')
        .eq('category_id', b.categoryId)
        .gte('spent_at', b.startsOn.toUtc().toIso8601String())
        .lt('spent_at', b.endsOn.toUtc().toIso8601String())
        .order('spent_at', ascending: false)
        .limit(200) as List;
    return [
      for (final r in rows)
        Expense(
          id: r['id'] as String,
          amountKobo: (r['amount_kobo'] as num).toInt(),
          spentAt: DateTime.parse(r['spent_at'] as String).toLocal(),
          categoryId: b.categoryId,
          categoryName: b.categoryName,
          note: r['note'] as String?,
        ),
    ];
  }
}

final budgetRepositoryProvider = Provider<BudgetRepository>((ref) => const SupabaseBudgetRepository());
