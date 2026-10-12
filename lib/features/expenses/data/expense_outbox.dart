import 'dart:convert';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/services/local_store.dart';

/// A cash expense that was typed while offline and is waiting to be sent.
class PendingExpense {
  const PendingExpense({
    required this.id,
    required this.accountId,
    required this.amountKobo,
    required this.spentAt,
    this.categoryId,
    this.note,
    this.receiptPath,
  });

  final String? receiptPath;

  /// Made on the phone, so sending it twice can never create two expenses.
  final String id;
  final String accountId;
  final int amountKobo;
  final DateTime spentAt;
  final String? categoryId;
  final String? note;

  Map<String, dynamic> toJson() => {
        'id': id,
        'account_id': accountId,
        'amount_kobo': amountKobo,
        'spent_at': spentAt.toUtc().toIso8601String(),
        'category_id': categoryId,
        'note': note,
        'receipt_path': receiptPath,
      };

  factory PendingExpense.fromJson(Map<String, dynamic> j) => PendingExpense(
        id: j['id'] as String,
        accountId: j['account_id'] as String,
        amountKobo: (j['amount_kobo'] as num).toInt(),
        spentAt: DateTime.parse(j['spent_at'] as String).toLocal(),
        categoryId: j['category_id'] as String?,
        note: j['note'] as String?,
        receiptPath: j['receipt_path'] as String?,
      );
}

/// A random version-4 id, so the phone can name a record before the server sees it.
String newClientId([Random? random]) {
  final r = random ?? Random.secure();
  final b = List<int>.generate(16, (_) => r.nextInt(256));
  b[6] = (b[6] & 0x0f) | 0x40;
  b[8] = (b[8] & 0x3f) | 0x80;
  String h(int i) => b[i].toRadixString(16).padLeft(2, '0');
  return '${h(0)}${h(1)}${h(2)}${h(3)}-${h(4)}${h(5)}-${h(6)}${h(7)}-${h(8)}${h(9)}-'
      '${h(10)}${h(11)}${h(12)}${h(13)}${h(14)}${h(15)}';
}

/// Small on-phone queue of unsent expenses. A handful of short records fits in
/// SharedPreferences; larger offline data would need a real local database.
class ExpenseOutbox {
  ExpenseOutbox(this._prefs);
  final SharedPreferences _prefs;

  static const _key = 'outbox.expenses.v1';

  List<PendingExpense> all() {
    final raw = _prefs.getString(_key);
    if (raw == null || raw.isEmpty) return const [];
    try {
      return [for (final j in jsonDecode(raw) as List) PendingExpense.fromJson(Map<String, dynamic>.from(j as Map))];
    } catch (_) {
      return const [];
    }
  }

  List<PendingExpense> forAccount(String accountId) => [for (final p in all()) if (p.accountId == accountId) p];

  Future<void> add(PendingExpense e) => _save([...all(), e]);

  Future<void> remove(String id) => _save([for (final p in all()) if (p.id != id) p]);

  Future<void> _save(List<PendingExpense> list) =>
      _prefs.setString(_key, jsonEncode([for (final p in list) p.toJson()]));
}

final expenseOutboxProvider = Provider<ExpenseOutbox>((ref) => ExpenseOutbox(ref.watch(sharedPrefsProvider)));
