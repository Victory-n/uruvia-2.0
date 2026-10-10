class Sale {
  const Sale({
    required this.id,
    required this.number,
    required this.totalKobo,
    required this.costKobo,
    required this.soldAt,
    this.invoiceId,
    this.customerId,
    this.customerName,
    this.reversedAt,
  });

  final String id;
  final String number;
  final String? invoiceId;
  final String? customerId;
  final String? customerName;
  final int totalKobo;
  final int costKobo;
  final DateTime soldAt;
  final DateTime? reversedAt;

  int get profitKobo => totalKobo - costKobo;
  bool get isReversed => reversedAt != null;

  factory Sale.fromRow(Map<String, dynamic> r, {String? customerName}) => Sale(
        id: r['id'] as String,
        number: r['sale_number'] as String,
        invoiceId: r['invoice_id'] as String?,
        customerId: r['customer_id'] as String?,
        customerName: customerName,
        totalKobo: (r['total_kobo'] as num).toInt(),
        costKobo: (r['cost_kobo'] as num).toInt(),
        soldAt: DateTime.parse(r['sold_at'] as String).toLocal(),
        reversedAt: r['reversed_at'] == null ? null : DateTime.parse(r['reversed_at'] as String).toLocal(),
      );
}

class SaleItem {
  const SaleItem({
    required this.description,
    required this.qty,
    required this.unitPriceKobo,
    required this.unitCostKobo,
    this.productId,
  });
  final String? productId;
  final String description;
  final int qty;
  final int unitPriceKobo;
  final int unitCostKobo;

  int get totalKobo => qty * unitPriceKobo;
  int get profitKobo => qty * (unitPriceKobo - unitCostKobo);
}

enum SalePeriod {
  today('Today'),
  week('7 days'),
  month('This month'),
  all('All');

  const SalePeriod(this.label);
  final String label;

  bool contains(DateTime when, {DateTime? now}) {
    final n = now ?? DateTime.now();
    final startOfToday = DateTime(n.year, n.month, n.day);
    return switch (this) {
      SalePeriod.today => !when.isBefore(startOfToday),
      SalePeriod.week => !when.isBefore(startOfToday.subtract(const Duration(days: 6))),
      SalePeriod.month => when.year == n.year && when.month == n.month,
      SalePeriod.all => true,
    };
  }
}

class SalesSummary {
  const SalesSummary({required this.count, required this.totalKobo, required this.profitKobo});
  final int count;
  final int totalKobo;
  final int profitKobo;
}

/// Reversed sales are left out of the totals.
SalesSummary summarizeSales(List<Sale> list) {
  var total = 0;
  var profit = 0;
  var count = 0;
  for (final s in list) {
    if (s.isReversed) continue;
    count++;
    total += s.totalKobo;
    profit += s.profitKobo;
  }
  return SalesSummary(count: count, totalKobo: total, profitKobo: profit);
}
