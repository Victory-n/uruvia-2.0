import '../../../core/utils/dates.dart';
import '../../../core/utils/money.dart';

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
    this.paymentMethod,
    this.note,
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

  /// Database value such as "cash"; null for sales that came from an invoice.
  final String? paymentMethod;
  final String? note;

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
        paymentMethod: r['payment_method'] as String?,
        note: r['note'] as String?,
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

/// Sales whose number, customer or note contains [query] (any case). Empty query keeps everything.
List<Sale> filterSales(List<Sale> all, String query) {
  final q = query.trim().toLowerCase();
  if (q.isEmpty) return all;
  return [
    for (final s in all)
      if (s.number.toLowerCase().contains(q) ||
          (s.customerName ?? 'walk-in customer').toLowerCase().contains(q) ||
          (s.note ?? '').toLowerCase().contains(q))
        s,
  ];
}

/// Sales per calendar day for the last [days] days ending today, oldest first. Reversed sales are left out.
/// Days with no sales are included with zero, so the chart has no gaps.
List<({DateTime day, int totalKobo})> dailySalesTotals(List<Sale> sales, {int days = 7, DateTime? now}) {
  final n = now ?? DateTime.now();
  final today = DateTime(n.year, n.month, n.day);
  final first = today.subtract(Duration(days: days - 1));
  final totals = <DateTime, int>{};
  for (final s in sales) {
    if (s.isReversed) continue;
    final d = DateTime(s.soldAt.year, s.soldAt.month, s.soldAt.day);
    if (d.isBefore(first) || d.isAfter(today)) continue;
    totals[d] = (totals[d] ?? 0) + s.totalKobo;
  }
  return [
    for (var i = 0; i < days; i++)
      (day: DateTime(first.year, first.month, first.day + i), totalKobo: totals[DateTime(first.year, first.month, first.day + i)] ?? 0),
  ];
}

/// A plain-text receipt to send to a customer on WhatsApp or by message.
String saleReceiptText({required String businessName, required Sale sale, required List<SaleItem> items}) {
  final b = StringBuffer()
    ..writeln('Receipt ${sale.number}')
    ..writeln(businessName)
    ..writeln(formatShortDate(sale.soldAt))
    ..writeln();
  for (final i in items) {
    b.writeln('${i.description}  ${i.qty} x ${formatNaira(i.unitPriceKobo, showKobo: false)} = ${formatNaira(i.totalKobo, showKobo: false)}');
  }
  b
    ..writeln()
    ..writeln('Total: ${formatNaira(sale.totalKobo, showKobo: sale.totalKobo % 100 != 0)}');
  b.write('Thank you for your purchase.');
  return b.toString();
}

/// What one sale did to one product's stock.
class SaleStockEffect {
  const SaleStockEffect({required this.productName, required this.change, required this.before, required this.after});
  final String productName;

  /// Change to the stock on hand: negative when goods left the shelf.
  final int change;
  final int before;
  final int after;

  /// Works out before and after from the stock now, taking away every change made since the sale.
  factory SaleStockEffect.fromHistory({
    required String productName,
    required int change,
    required int onHandNow,
    required Iterable<int> laterChanges,
  }) {
    final after = onHandNow - laterChanges.fold<int>(0, (s, d) => s + d);
    return SaleStockEffect(productName: productName, change: change, before: after - change, after: after);
  }
}
