import '../../../core/utils/money.dart';

enum ReportPeriod {
  thisMonth('This month'),
  lastMonth('Last month'),
  thisYear('This year');

  const ReportPeriod(this.label);
  final String label;

  /// First moment (inclusive) and last moment (exclusive) of the period.
  (DateTime, DateTime) range(DateTime now) => switch (this) {
        ReportPeriod.thisMonth => (DateTime(now.year, now.month), DateTime(now.year, now.month + 1)),
        ReportPeriod.lastMonth => (DateTime(now.year, now.month - 1), DateTime(now.year, now.month)),
        ReportPeriod.thisYear => (DateTime(now.year), DateTime(now.year + 1)),
      };

  /// Whole months the period covers up to [now] (used to scale monthly budgets).
  int months(DateTime now) => this == ReportPeriod.thisYear ? now.month : 1;
}

/// Height of a bar from 0 to 1 against the largest value.
double barFraction(int value, int max) => max <= 0 ? 0 : (value / max).clamp(0, 1).toDouble();

// ------------------------------------------------------------------ raw rows (what the repository loads)

class ReportSaleItem {
  const ReportSaleItem({required this.description, required this.qty, required this.unitPriceKobo, required this.unitCostKobo});
  final String description;
  final int qty;
  final int unitPriceKobo;
  final int unitCostKobo;
}

class ReportSale {
  const ReportSale({required this.soldAt, required this.totalKobo, required this.costKobo, this.customerName, this.items = const []});
  final DateTime soldAt;
  final int totalKobo;
  final int costKobo;
  final String? customerName;
  final List<ReportSaleItem> items;
}

class ReportExpense {
  const ReportExpense({required this.categoryName, required this.amountKobo, required this.spentAt});
  final String categoryName;
  final int amountKobo;
  final DateTime spentAt;
}

/// A budget scaled to one month: a yearly budget counts one twelfth.
class ReportBudget {
  const ReportBudget({required this.categoryName, required this.monthlyKobo});
  final String categoryName;
  final int monthlyKobo;
}

class ReportInvoice {
  const ReportInvoice({required this.number, required this.customerName, required this.dueDate, required this.totalKobo, required this.balanceKobo});
  final String number;
  final String customerName;
  final DateTime dueDate;
  final int totalKobo;
  final int balanceKobo;
}

class ReportProduct {
  const ReportProduct({required this.name, required this.qtyOnHand, required this.costKobo, required this.priceKobo});
  final String name;
  final int qtyOnHand;
  final int costKobo;
  final int priceKobo;
}

class StatementLine {
  const StatementLine({required this.date, required this.description, this.chargeKobo = 0, this.paymentKobo = 0});
  final DateTime date;
  final String description;
  final int chargeKobo;
  final int paymentKobo;
}

// ------------------------------------------------------------------ table every report is shown and exported as

/// One table cell. [csv] is the plain value for spreadsheets (money without symbols or commas).
class Cell {
  const Cell(this.text, [String? csv]) : csv = csv ?? text;
  final String text;
  final String csv;

  factory Cell.money(int kobo) => Cell(formatNaira(kobo, showKobo: kobo % 100 != 0), _plain(kobo));
  factory Cell.number(num n) => Cell('$n');

  static String _plain(int kobo) {
    final sign = kobo < 0 ? '-' : '';
    final a = kobo.abs();
    return '$sign${a ~/ 100}.${(a % 100).toString().padLeft(2, '0')}';
  }
}

class ReportTable {
  const ReportTable({required this.title, required this.subtitle, required this.summary, required this.headers, required this.rows});
  final String title;
  final String subtitle;

  /// Headline figures shown above the table, as label and value.
  final List<(String, Cell)> summary;
  final List<String> headers;
  final List<List<Cell>> rows;

  String toCsv() {
    String esc(String v) => (v.contains(',') || v.contains('"') || v.contains('\n')) ? '"${v.replaceAll('"', '""')}"' : v;
    final lines = <String>[
      esc(title),
      esc(subtitle),
      for (final s in summary) '${esc(s.$1)},${esc(s.$2.csv)}',
      '',
      headers.map(esc).join(','),
      for (final r in rows) r.map((c) => esc(c.csv)).join(','),
    ];
    return '${lines.join('\n')}\n';
  }
}

// ------------------------------------------------------------------ calculations

class Totals {
  const Totals({required this.salesKobo, required this.costKobo, required this.expensesKobo});
  final int salesKobo;
  final int costKobo;
  final int expensesKobo;
  int get grossKobo => salesKobo - costKobo;
  int get netKobo => grossKobo - expensesKobo;
}

Totals totalsFor(List<ReportSale> sales, List<ReportExpense> expenses) => Totals(
      salesKobo: sales.fold(0, (a, s) => a + s.totalKobo),
      costKobo: sales.fold(0, (a, s) => a + s.costKobo),
      expensesKobo: expenses.fold(0, (a, e) => a + e.amountKobo),
    );

class ReportBar {
  const ReportBar(this.label, this.salesKobo, this.expensesKobo);
  final String label;
  final int salesKobo;
  final int expensesKobo;
}

const _short = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

/// Weekly bars for a month, monthly bars for a year.
List<ReportBar> barsFor(ReportPeriod period, DateTime now, List<ReportSale> sales, List<ReportExpense> expenses) {
  final (from, to) = period.range(now);
  if (period == ReportPeriod.thisYear) {
    final last = now.month;
    return [
      for (var m = 1; m <= last; m++)
        ReportBar(
          _short[m - 1],
          sales.where((s) => s.soldAt.year == from.year && s.soldAt.month == m).fold(0, (a, s) => a + s.totalKobo),
          expenses.where((e) => e.spentAt.year == from.year && e.spentAt.month == m).fold(0, (a, e) => a + e.amountKobo),
        ),
    ];
  }
  final weeks = ((to.difference(from).inDays) / 7).ceil();
  int week(DateTime d) => ((d.day - 1) ~/ 7).clamp(0, weeks - 1);
  return [
    for (var w = 0; w < weeks; w++)
      ReportBar(
        'Wk ${w + 1}',
        sales.where((s) => week(s.soldAt) == w).fold(0, (a, s) => a + s.totalKobo),
        expenses.where((e) => week(e.spentAt) == w).fold(0, (a, e) => a + e.amountKobo),
      ),
  ];
}

ReportTable profitAndLossTable(Totals t, String period) => ReportTable(
      title: 'Profit and loss',
      subtitle: period,
      summary: [('Net profit', Cell.money(t.netKobo))],
      headers: const ['Line', 'Amount'],
      rows: [
        [const Cell('Sales'), Cell.money(t.salesKobo)],
        [const Cell('Cost of goods sold'), Cell.money(-t.costKobo)],
        [const Cell('Gross profit'), Cell.money(t.grossKobo)],
        [const Cell('Expenses'), Cell.money(-t.expensesKobo)],
        [const Cell('Net profit'), Cell.money(t.netKobo)],
      ],
    );

class ProductSales {
  const ProductSales(this.name, this.units, this.revenueKobo, this.profitKobo);
  final String name;
  final int units;
  final int revenueKobo;
  final int profitKobo;
}

/// Best sellers first, by revenue.
List<ProductSales> salesByProduct(List<ReportSale> sales) {
  final map = <String, List<int>>{};
  for (final s in sales) {
    for (final i in s.items) {
      final row = map.putIfAbsent(i.description, () => [0, 0, 0]);
      row[0] += i.qty;
      row[1] += i.qty * i.unitPriceKobo;
      row[2] += i.qty * (i.unitPriceKobo - i.unitCostKobo);
    }
  }
  final list = [for (final e in map.entries) ProductSales(e.key, e.value[0], e.value[1], e.value[2])];
  list.sort((a, b) => b.revenueKobo.compareTo(a.revenueKobo));
  return list;
}

class CustomerSales {
  const CustomerSales(this.name, this.count, this.totalKobo);
  final String name;
  final int count;
  final int totalKobo;
}

const walkInLabel = 'Walk-in customers';

List<CustomerSales> salesByCustomer(List<ReportSale> sales) {
  final map = <String, List<int>>{};
  for (final s in sales) {
    final row = map.putIfAbsent(s.customerName ?? walkInLabel, () => [0, 0]);
    row[0] += 1;
    row[1] += s.totalKobo;
  }
  final list = [for (final e in map.entries) CustomerSales(e.key, e.value[0], e.value[1])];
  list.sort((a, b) => b.totalKobo.compareTo(a.totalKobo));
  return list;
}

ReportTable salesTable(List<ReportSale> sales, String period) {
  final total = sales.fold(0, (a, s) => a + s.totalKobo);
  final byProduct = salesByProduct(sales);
  return ReportTable(
    title: 'Sales',
    subtitle: period,
    summary: [
      ('Total sales', Cell.money(total)),
      ('Number of sales', Cell.number(sales.length)),
      ('Average sale', Cell.money(sales.isEmpty ? 0 : total ~/ sales.length)),
    ],
    headers: const ['Product', 'Units sold', 'Revenue', 'Profit'],
    rows: [for (final p in byProduct) [Cell(p.name), Cell.number(p.units), Cell.money(p.revenueKobo), Cell.money(p.profitKobo)]],
  );
}

ReportTable salesByCustomerTable(List<ReportSale> sales, String period) {
  final byCustomer = salesByCustomer(sales);
  return ReportTable(
    title: 'Sales by customer',
    subtitle: period,
    summary: [('Customers', Cell.number(byCustomer.length))],
    headers: const ['Customer', 'Sales', 'Total'],
    rows: [for (final c in byCustomer) [Cell(c.name), Cell.number(c.count), Cell.money(c.totalKobo)]],
  );
}

class CategorySpend {
  const CategorySpend(this.name, this.spentKobo, this.budgetKobo);
  final String name;
  final int spentKobo;

  /// null when the category has no budget.
  final int? budgetKobo;
}

const uncategorisedLabel = 'No category';

List<CategorySpend> expensesByCategory(List<ReportExpense> expenses, List<ReportBudget> budgets, int months) {
  final spent = <String, int>{};
  for (final e in expenses) {
    final n = e.categoryName.isEmpty ? uncategorisedLabel : e.categoryName;
    spent[n] = (spent[n] ?? 0) + e.amountKobo;
  }
  final budget = <String, int>{};
  for (final b in budgets) {
    budget[b.categoryName] = (budget[b.categoryName] ?? 0) + b.monthlyKobo * months;
  }
  final names = {...spent.keys, ...budget.keys};
  final list = [for (final n in names) CategorySpend(n, spent[n] ?? 0, budget[n])];
  list.sort((a, b) => b.spentKobo.compareTo(a.spentKobo));
  return list;
}

ReportTable expensesTable(List<CategorySpend> rows, String period) {
  final total = rows.fold(0, (a, r) => a + r.spentKobo);
  return ReportTable(
    title: 'Expenses',
    subtitle: period,
    summary: [('Total expenses', Cell.money(total))],
    headers: const ['Category', 'Spent', 'Budget', 'Left'],
    rows: [
      for (final r in rows)
        [
          Cell(r.name),
          Cell.money(r.spentKobo),
          r.budgetKobo == null ? const Cell('-') : Cell.money(r.budgetKobo!),
          r.budgetKobo == null ? const Cell('-') : Cell.money(r.budgetKobo! - r.spentKobo),
        ],
    ],
  );
}

class Valuation {
  const Valuation(this.atCostKobo, this.atPriceKobo);
  final int atCostKobo;
  final int atPriceKobo;
  int get potentialProfitKobo => atPriceKobo - atCostKobo;
}

Valuation inventoryValuation(List<ReportProduct> products) => Valuation(
      products.fold(0, (a, p) => a + p.qtyOnHand * p.costKobo),
      products.fold(0, (a, p) => a + p.qtyOnHand * p.priceKobo),
    );

ReportTable inventoryTable(List<ReportProduct> products, String asOf) {
  final v = inventoryValuation(products);
  final sorted = [...products]..sort((a, b) => (b.qtyOnHand * b.costKobo).compareTo(a.qtyOnHand * a.costKobo));
  return ReportTable(
    title: 'Inventory value',
    subtitle: asOf,
    summary: [('At cost', Cell.money(v.atCostKobo)), ('At selling price', Cell.money(v.atPriceKobo))],
    headers: const ['Product', 'In stock', 'Value at cost', 'Value at price'],
    rows: [
      for (final p in sorted)
        [Cell(p.name), Cell.number(p.qtyOnHand), Cell.money(p.qtyOnHand * p.costKobo), Cell.money(p.qtyOnHand * p.priceKobo)],
    ],
  );
}

enum AgeBucket {
  current('Not due yet'),
  d1to30('1 to 30 days late'),
  d31to60('31 to 60 days late'),
  d61to90('61 to 90 days late'),
  over90('Over 90 days late');

  const AgeBucket(this.label);
  final String label;
}

AgeBucket bucketFor(DateTime dueDate, DateTime now) {
  final today = DateTime(now.year, now.month, now.day);
  final due = DateTime(dueDate.year, dueDate.month, dueDate.day);
  final late = today.difference(due).inDays;
  if (late <= 0) return AgeBucket.current;
  if (late <= 30) return AgeBucket.d1to30;
  if (late <= 60) return AgeBucket.d31to60;
  if (late <= 90) return AgeBucket.d61to90;
  return AgeBucket.over90;
}

Map<AgeBucket, int> receivablesByAge(List<ReportInvoice> invoices, DateTime now) {
  final out = {for (final b in AgeBucket.values) b: 0};
  for (final i in invoices) {
    final b = bucketFor(i.dueDate, now);
    out[b] = out[b]! + i.balanceKobo;
  }
  return out;
}

ReportTable receivablesTable(List<ReportInvoice> invoices, DateTime now, String Function(DateTime) fmtDate) {
  final buckets = receivablesByAge(invoices, now);
  final total = buckets.values.fold(0, (a, v) => a + v);
  final sorted = [...invoices]..sort((a, b) => a.dueDate.compareTo(b.dueDate));
  return ReportTable(
    title: 'Receivables',
    subtitle: 'Unpaid invoices as of ${fmtDate(now)}',
    summary: [
      ('Total owed', Cell.money(total)),
      for (final b in AgeBucket.values) (b.label, Cell.money(buckets[b]!)),
    ],
    headers: const ['Invoice', 'Customer', 'Due', 'Balance', 'Age'],
    rows: [
      for (final i in sorted) [Cell(i.number), Cell(i.customerName), Cell(fmtDate(i.dueDate)), Cell.money(i.balanceKobo), Cell(bucketFor(i.dueDate, now).label)],
    ],
  );
}

/// Charges and payments in date order with a running balance.
ReportTable statementTable(String customerName, List<StatementLine> lines, String Function(DateTime) fmtDate) {
  final sorted = [...lines]..sort((a, b) => a.date.compareTo(b.date));
  var balance = 0;
  final rows = <List<Cell>>[];
  for (final l in sorted) {
    balance += l.chargeKobo - l.paymentKobo;
    rows.add([
      Cell(fmtDate(l.date)),
      Cell(l.description),
      l.chargeKobo == 0 ? const Cell('') : Cell.money(l.chargeKobo),
      l.paymentKobo == 0 ? const Cell('') : Cell.money(l.paymentKobo),
      Cell.money(balance),
    ]);
  }
  final billed = lines.fold(0, (a, l) => a + l.chargeKobo);
  final paid = lines.fold(0, (a, l) => a + l.paymentKobo);
  return ReportTable(
    title: 'Customer statement',
    subtitle: customerName,
    summary: [('Billed', Cell.money(billed)), ('Paid', Cell.money(paid)), ('Owing', Cell.money(billed - paid))],
    headers: const ['Date', 'Details', 'Invoiced', 'Paid', 'Balance'],
    rows: rows,
  );
}
