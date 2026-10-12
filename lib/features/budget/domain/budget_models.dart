enum BudgetPeriod {
  monthly('Monthly'),
  yearly('Yearly');

  const BudgetPeriod(this.label);
  final String label;

  static BudgetPeriod parse(String v) => v == 'yearly' ? BudgetPeriod.yearly : BudgetPeriod.monthly;
}

enum BudgetState { green, amber, red }

class BudgetProgress {
  const BudgetProgress({
    required this.budgetId,
    required this.categoryId,
    required this.categoryName,
    required this.categoryIcon,
    required this.amountKobo,
    required this.spentKobo,
    required this.period,
    required this.startsOn,
    required this.endsOn,
    this.alert80 = true,
    this.alert100 = true,
    this.paused = false,
    this.repeat = true,
    this.carryKobo = 0,
    this.nextAmountKobo,
    this.rollover = false,
  });

  final String budgetId;
  final String categoryId;
  final String categoryName;
  final String categoryIcon;
  final int amountKobo;
  final int spentKobo;
  final BudgetPeriod period;
  final DateTime startsOn;
  final DateTime endsOn;
  final bool alert80;
  final bool alert100;
  final bool paused;
  final bool repeat;

  /// Unspent money carried in from the last period (rollover). Already included in [amountKobo].
  final int carryKobo;

  /// An amount that starts with the next period, if the person chose "from next period".
  final int? nextAmountKobo;
  final bool rollover;

  /// What the person set, without the carry-over.
  int get baseKobo => amountKobo - carryKobo;

  int get remainingKobo => amountKobo - spentKobo;
  double get fraction => amountKobo == 0 ? 0 : spentKobo / amountKobo;

  /// Green below 80%, amber from 80% to 100%, red once over the limit.
  BudgetState get state {
    if (spentKobo > amountKobo) return BudgetState.red;
    if (spentKobo * 5 >= amountKobo * 4) return BudgetState.amber;
    return BudgetState.green;
  }

  /// Days left in the period, counting today. Never below 0.
  int daysLeft({DateTime? now}) {
    final t = now ?? DateTime.now();
    final today = DateTime(t.year, t.month, t.day);
    final d = endsOn.difference(today).inDays;
    return d < 0 ? 0 : d;
  }

  /// What you can still spend per day to stay inside the budget (0 when over or out of days).
  int dailyAllowanceKobo({DateTime? now}) {
    final days = daysLeft(now: now);
    if (days <= 0 || remainingKobo <= 0) return 0;
    return remainingKobo ~/ days;
  }
}

/// Start of the current period for a new budget: first of the month, or 1 January.
DateTime periodStart(BudgetPeriod period, {DateTime? now}) {
  final t = now ?? DateTime.now();
  return period == BudgetPeriod.monthly ? DateTime(t.year, t.month) : DateTime(t.year);
}

DateTime periodEnd(BudgetPeriod period, DateTime start) =>
    period == BudgetPeriod.monthly ? DateTime(start.year, start.month + 1) : DateTime(start.year + 1);

class BudgetTotals {
  const BudgetTotals({required this.budgetedKobo, required this.spentKobo});
  final int budgetedKobo;
  final int spentKobo;
  int get remainingKobo => budgetedKobo - spentKobo;
}

BudgetTotals totalsOf(List<BudgetProgress> list) {
  var b = 0, s = 0;
  for (final x in list.where((x) => !x.paused)) {
    b += x.amountKobo;
    s += x.spentKobo;
  }
  return BudgetTotals(budgetedKobo: b, spentKobo: s);
}

/// A typical monthly amount for a category, by name, to start a budget in one tap. Null when there is no suggestion.
int? budgetTemplateKobo(String categoryName) => switch (categoryName.trim().toLowerCase()) {
      'feeding' => 3000000,
      'transport' => 1500000,
      'rent' => 10000000,
      'airtime and data' => 500000,
      'school fees' => 5000000,
      'emergency fund' => 2000000,
      'stock purchases' => 20000000,
      'salaries' => 15000000,
      'utilities' => 2000000,
      'marketing' => 3000000,
      _ => null,
    };

/// Spending per week of a budget period: week 1 is the first 7 days, and so on. Anything outside the period is ignored.
List<int> weeklySpend(Iterable<({DateTime spentAt, int amountKobo})> items, DateTime startsOn, DateTime endsOn) {
  final days = endsOn.difference(startsOn).inDays;
  final weeks = (days / 7).ceil().clamp(1, 53);
  final out = List<int>.filled(weeks, 0);
  for (final e in items) {
    final d = DateTime(e.spentAt.year, e.spentAt.month, e.spentAt.day);
    if (d.isBefore(startsOn) || !d.isBefore(endsOn)) continue;
    final w = d.difference(startsOn).inDays ~/ 7;
    if (w >= 0 && w < weeks) out[w] += e.amountKobo;
  }
  return out;
}
