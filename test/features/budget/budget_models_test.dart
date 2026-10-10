import 'package:flutter_test/flutter_test.dart';
import 'package:uruvia/features/budget/domain/budget_models.dart';

BudgetProgress make({int amount = 10000, int spent = 0, DateTime? ends, bool paused = false}) => BudgetProgress(
      budgetId: 'b',
      categoryId: 'c',
      categoryName: 'Feeding',
      categoryIcon: 'restaurant',
      amountKobo: amount,
      spentKobo: spent,
      period: BudgetPeriod.monthly,
      startsOn: DateTime(2026, 10),
      endsOn: ends ?? DateTime(2026, 11),
      paused: paused,
    );

void main() {
  test('state is green below 80%, amber from 80%, red above 100%', () {
    expect(make(spent: 7999).state, BudgetState.green);
    expect(make(spent: 8000).state, BudgetState.amber);
    expect(make(spent: 10000).state, BudgetState.amber);
    expect(make(spent: 10001).state, BudgetState.red);
  });

  test('remaining and fraction', () {
    final b = make(spent: 2500);
    expect(b.remainingKobo, 7500);
    expect(b.fraction, 0.25);
    expect(make(spent: 12000).remainingKobo, -2000);
  });

  test('days left and daily allowance', () {
    final b = make(amount: 310000, spent: 10000); // 300,000 kobo left
    final now = DateTime(2026, 10, 22);
    expect(b.daysLeft(now: now), 10); // 22 Oct to 1 Nov
    expect(b.dailyAllowanceKobo(now: now), 30000);
    expect(make(spent: 20000).dailyAllowanceKobo(now: now), 0); // over budget
    expect(b.daysLeft(now: DateTime(2026, 12, 1)), 0);
  });

  test('period start and end', () {
    final now = DateTime(2026, 10, 17);
    expect(periodStart(BudgetPeriod.monthly, now: now), DateTime(2026, 10));
    expect(periodStart(BudgetPeriod.yearly, now: now), DateTime(2026));
    expect(periodEnd(BudgetPeriod.monthly, DateTime(2026, 12)), DateTime(2027));
    expect(periodEnd(BudgetPeriod.yearly, DateTime(2026)), DateTime(2027));
  });

  test('totals skip paused budgets', () {
    final t = totalsOf([make(amount: 100, spent: 40), make(amount: 200, spent: 50, paused: true)]);
    expect(t.budgetedKobo, 100);
    expect(t.spentKobo, 40);
    expect(t.remainingKobo, 60);
  });
}
