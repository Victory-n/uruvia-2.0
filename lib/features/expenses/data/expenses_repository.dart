import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/supabase_client.dart';
import '../domain/expense_models.dart';

abstract class ExpensesRepository {
  Future<List<ExpenseCategory>> categories(String accountId);
  Future<ExpenseCategory> createCategory(String accountId, String name);

  /// Expenses from [from] (inclusive) to [to] (exclusive), newest first.
  Future<List<Expense>> between(String accountId, DateTime from, DateTime to);
  Future<Expense?> get(String id);
  Future<void> create({
    required String accountId,
    required int amountKobo,
    required DateTime spentAt,
    String? categoryId,
    String? note,
  });
  Future<void> update(
    String id, {
    required int amountKobo,
    required DateTime spentAt,
    String? categoryId,
    String? note,
  });
  Future<void> delete(String id);
}

class SupabaseExpensesRepository implements ExpensesRepository {
  const SupabaseExpensesRepository();

  static ExpenseCategory _cat(Map r) =>
      ExpenseCategory(id: r['id'] as String, name: r['name'] as String, icon: (r['icon'] as String?) ?? 'category');

  @override
  Future<List<ExpenseCategory>> categories(String accountId) async {
    final rows = await supabase
        .from('expense_categories')
        .select('id, name, icon')
        .eq('account_id', accountId)
        .isFilter('archived_at', null)
        .order('name') as List;
    return [for (final r in rows) _cat(r as Map)];
  }

  @override
  Future<ExpenseCategory> createCategory(String accountId, String name) async {
    final row = await supabase
        .from('expense_categories')
        .insert({'account_id': accountId, 'name': name.trim()})
        .select('id, name, icon')
        .single();
    return _cat(row);
  }

  Expense _expense(Map r, Map<String, String> names) => Expense(
        id: r['id'] as String,
        amountKobo: (r['amount_kobo'] as num).toInt(),
        spentAt: DateTime.parse(r['spent_at'] as String).toLocal(),
        categoryId: r['category_id'] as String?,
        categoryName: names[r['category_id']],
        note: r['note'] as String?,
      );

  Future<Map<String, String>> _names(String accountId) async {
    final cats = await supabase.from('expense_categories').select('id, name').eq('account_id', accountId) as List;
    return {for (final c in cats) c['id'] as String: c['name'] as String};
  }

  @override
  Future<List<Expense>> between(String accountId, DateTime from, DateTime to) async {
    final rows = await supabase
        .from('expenses')
        .select('id, amount_kobo, spent_at, note, category_id')
        .eq('account_id', accountId)
        .gte('spent_at', from.toUtc().toIso8601String())
        .lt('spent_at', to.toUtc().toIso8601String())
        .order('spent_at', ascending: false)
        .limit(1000) as List;
    if (rows.isEmpty) return const [];
    final names = await _names(accountId);
    return [for (final r in rows) _expense(r as Map, names)];
  }

  @override
  Future<Expense?> get(String id) async {
    final row = await supabase
        .from('expenses')
        .select('id, account_id, amount_kobo, spent_at, note, category_id')
        .eq('id', id)
        .maybeSingle();
    if (row == null) return null;
    return _expense(row, await _names(row['account_id'] as String));
  }

  @override
  Future<void> create({
    required String accountId,
    required int amountKobo,
    required DateTime spentAt,
    String? categoryId,
    String? note,
  }) async {
    await supabase.from('expenses').insert({
      'account_id': accountId,
      'amount_kobo': amountKobo,
      'spent_at': spentAt.toUtc().toIso8601String(),
      'category_id': categoryId,
      'note': (note == null || note.trim().isEmpty) ? null : note.trim(),
      'source': 'manual',
    });
  }

  @override
  Future<void> update(
    String id, {
    required int amountKobo,
    required DateTime spentAt,
    String? categoryId,
    String? note,
  }) async {
    await supabase.from('expenses').update({
      'amount_kobo': amountKobo,
      'spent_at': spentAt.toUtc().toIso8601String(),
      'category_id': categoryId,
      'note': (note == null || note.trim().isEmpty) ? null : note.trim(),
    }).eq('id', id);
  }

  @override
  Future<void> delete(String id) async {
    await supabase.from('expenses').delete().eq('id', id);
  }
}

final expensesRepositoryProvider = Provider<ExpensesRepository>((ref) => const SupabaseExpensesRepository());
