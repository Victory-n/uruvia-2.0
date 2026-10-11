/// DUMMY business health data. The bands and factors are undecided, so these are sample values.
enum HealthBand {
  needsWork('Needs work', 0),
  fair('Fair', 40),
  good('Good', 60),
  excellent('Excellent', 80);

  const HealthBand(this.label, this.from);
  final String label;
  final int from;
}

HealthBand healthBand(int score) {
  var band = HealthBand.needsWork;
  for (final b in HealthBand.values) {
    if (score >= b.from) band = b;
  }
  return band;
}

class HealthFactor {
  const HealthFactor(this.name, this.score, this.tip);
  final String name;

  /// 0 to 100.
  final int score;
  final String tip;
}

const sampleHealthFactors = [
  HealthFactor('Sales trend', 78, 'Sales are up on last month. Keep your best sellers in stock.'),
  HealthFactor('Invoice collection', 64, 'A few invoices are overdue. Send a reminder to those customers.'),
  HealthFactor('Stock health', 71, 'Two products are close to running out.'),
  HealthFactor('Expense control', 55, 'Spending grew faster than sales. Review your biggest categories.'),
];

/// The overall score is the average of the factors.
int overallHealthScore(List<HealthFactor> factors) {
  if (factors.isEmpty) return 0;
  return (factors.fold<int>(0, (a, f) => a + f.score) / factors.length).round();
}

class LoanRequirement {
  const LoanRequirement(this.label, this.met);
  final String label;
  final bool met;
}

const sampleLoanRequirements = [
  LoanRequirement('Verify your identity (KYC)', false),
  LoanRequirement('At least 6 months of activity', true),
  LoanRequirement('Business details complete', true),
  LoanRequirement('Health score of 60 or more', true),
];
