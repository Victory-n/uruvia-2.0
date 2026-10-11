class Plan {
  const Plan({
    required this.code,
    required this.name,
    required this.priceKobo,
    required this.priceUsdCents,
    this.billingPeriod,
  });

  final String code;
  final String name;
  final int priceKobo;
  final int priceUsdCents;

  /// 'monthly' or 'yearly'. Null until the board decides.
  final String? billingPeriod;

  String get periodLabel => switch (billingPeriod) {
        'monthly' => 'a month',
        'yearly' => 'a year',
        _ => '',
      };

  /// "$5" or "$7.50".
  String get usdLabel =>
      priceUsdCents % 100 == 0 ? '\$${priceUsdCents ~/ 100}' : '\$${(priceUsdCents / 100).toStringAsFixed(2)}';

  factory Plan.fromRow(Map<String, dynamic> r) => Plan(
        code: r['code'] as String,
        name: r['name'] as String,
        priceKobo: (r['price_kobo'] as num).toInt(),
        priceUsdCents: (r['price_usd_cents'] as num).toInt(),
        billingPeriod: r['billing_period'] as String?,
      );
}

class Subscription {
  const Subscription({
    required this.planCode,
    required this.status,
    this.currentPeriodEnd,
    this.graceUntil,
  });

  final String planCode;

  /// active, past_due, cancelled or expired.
  final String status;
  final DateTime? currentPeriodEnd;
  final DateTime? graceUntil;

  /// Mirrors the database rule: active, or past due while the grace period runs.
  bool isLive({DateTime? now}) {
    final n = now ?? DateTime.now();
    if (status == 'active') return currentPeriodEnd == null || currentPeriodEnd!.isAfter(n);
    if (status == 'past_due') return graceUntil == null || graceUntil!.isAfter(n);
    return false;
  }

  factory Subscription.fromRow(Map<String, dynamic> r) => Subscription(
        planCode: r['plan_code'] as String,
        status: r['status'] as String,
        currentPeriodEnd: r['current_period_end'] == null ? null : DateTime.parse(r['current_period_end'] as String).toLocal(),
        graceUntil: r['grace_until'] == null ? null : DateTime.parse(r['grace_until'] as String).toLocal(),
      );
}

/// What Pro includes. The final lists wait for the board (free vs Pro reports and others).
const individualProBenefits = [
  'Smart notifications that warn you before money problems',
  'More reports on your spending',
  'Priority support',
];

const businessProBenefits = [
  'Business Health score',
  'Loan eligibility check',
  'Full reports',
  'Business Hub listing',
  'Smart notifications about stock, invoices and cash',
  'Priority support',
];
