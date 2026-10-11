import 'package:flutter_test/flutter_test.dart';
import 'package:uruvia/features/savings/domain/savings_models.dart';

void main() {
  test('projected interest is simple interest', () {
    // 100,000 naira at 12% for 6 months = 6,000 naira.
    expect(projectedInterestKobo(10000000, 1200, 6), 600000);
    expect(projectedInterestKobo(10000000, 300, 12), 300000);
  });

  test('accrued interest over days', () {
    expect(accruedInterestKobo(36500000, 1000, 365), 3650000);
    expect(accruedInterestKobo(1000000, 300, 0), 0);
  });

  test('addMonths clamps to the end of the month', () {
    expect(addMonths(DateTime(2026, 1, 31), 1), DateTime(2026, 2, 28));
    expect(addMonths(DateTime(2026, 11, 15), 3), DateTime(2027, 2, 15));
  });

  test('locked pockets stay locked until maturity', () {
    final p = SavingsPocket(
      id: 'a', type: PocketType.locked, name: 'x', balanceKobo: 1, createdAt: DateTime(2026, 1, 1),
      entries: const [], maturesOn: DateTime(2026, 6, 1),
    );
    expect(p.isLocked(now: DateTime(2026, 5, 31)), isTrue);
    expect(p.isLocked(now: DateTime(2026, 6, 2)), isFalse);
  });

  test('withEntry updates the balance', () {
    final p = SavingsPocket(id: 'a', type: PocketType.fixed, name: 'x', balanceKobo: 1000, createdAt: DateTime(2026), entries: const [], targetKobo: 2000);
    final q = p.withEntry(PocketEntry(kind: EntryKind.withdrawal, amountKobo: 400, at: DateTime(2026)));
    expect(q.balanceKobo, 600);
    expect(q.progress, closeTo(0.3, 0.001));
  });

  test('validateNewPocket checks each type', () {
    String? v(PocketType t, {String name = 'Goal', int amt = 0, int? months, int? pct}) =>
        validateNewPocket(type: t, name: name, amountKobo: amt, months: months, spendPercent: pct);
    expect(v(PocketType.fixed), isNull);
    expect(v(PocketType.fixed, name: ' '), isNotNull);
    expect(v(PocketType.saveAsYouSpend), isNotNull);
    expect(v(PocketType.saveAsYouSpend, pct: 10), isNull);
    expect(v(PocketType.locked, months: 6), isNotNull);
    expect(v(PocketType.locked, months: 6, amt: 100), isNull);
  });
}
