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
