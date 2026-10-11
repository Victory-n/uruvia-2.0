import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/savings_models.dart';

/// DUMMY savings. Sample pockets in memory; changes are lost when the app closes.
/// Swap for a repository-backed notifier when the wallet is connected.
class SavingsNotifier extends Notifier<List<SavingsPocket>> {
  int _n = 100;

  @override
  List<SavingsPocket> build() {
    final now = DateTime.now();
    return [
      SavingsPocket(
        id: 's1',
        type: PocketType.fixed,
        name: 'New laptop',
        balanceKobo: 6500000,
        targetKobo: 25000000,
        createdAt: now.subtract(const Duration(days: 40)),
        entries: [
          PocketEntry(kind: EntryKind.contribution, amountKobo: 2500000, at: now.subtract(const Duration(days: 6))),
          PocketEntry(kind: EntryKind.contribution, amountKobo: 4000000, at: now.subtract(const Duration(days: 40))),
        ],
      ),
      SavingsPocket(
        id: 's2',
        type: PocketType.locked,
        name: 'Rent 2027',
        balanceKobo: 20000000,
        maturesOn: addMonths(now, 5),
        createdAt: now.subtract(const Duration(days: 30)),
        entries: [PocketEntry(kind: EntryKind.contribution, amountKobo: 20000000, at: now.subtract(const Duration(days: 30)))],
      ),
      SavingsPocket(
        id: 's3',
        type: PocketType.saveAsYouSpend,
        name: 'Spare change',
        balanceKobo: 340000,
        spendPercent: 10,
        createdAt: now.subtract(const Duration(days: 12)),
        entries: [PocketEntry(kind: EntryKind.contribution, amountKobo: 340000, at: now.subtract(const Duration(days: 2)))],
      ),
    ];
  }

  SavingsPocket? byId(String id) {
    for (final p in state) {
      if (p.id == id) return p;
    }
    return null;
  }

  /// Creates a pocket and returns it.
  SavingsPocket create({
    required PocketType type,
    required String name,
    int amountKobo = 0,
    int? targetKobo,
    int? months,
    int? spendPercent,
  }) {
    _n++;
    final now = DateTime.now();
    final pocket = SavingsPocket(
      id: 's$_n',
      type: type,
      name: name.trim(),
      balanceKobo: amountKobo,
      targetKobo: targetKobo,
      maturesOn: type == PocketType.locked && months != null ? addMonths(now, months) : null,
      spendPercent: type == PocketType.saveAsYouSpend ? spendPercent : null,
      createdAt: now,
      entries: amountKobo > 0 ? [PocketEntry(kind: EntryKind.contribution, amountKobo: amountKobo, at: now)] : const [],
    );
    state = [pocket, ...state];
    return pocket;
  }

  void deposit(String id, int amountKobo) => _apply(id, PocketEntry(kind: EntryKind.contribution, amountKobo: amountKobo, at: DateTime.now()));

  void withdraw(String id, int amountKobo) => _apply(id, PocketEntry(kind: EntryKind.withdrawal, amountKobo: amountKobo, at: DateTime.now()));

  void _apply(String id, PocketEntry e) {
    state = [for (final p in state) p.id == id ? p.withEntry(e) : p];
  }
}

final savingsProvider = NotifierProvider<SavingsNotifier, List<SavingsPocket>>(SavingsNotifier.new);
