import 'package:flutter_test/flutter_test.dart';
import 'package:uruvia/features/reports/domain/report_models.dart';

ReportSale sale(int day, int total, int cost, {String? customer, List<ReportSaleItem> items = const []}) =>
    ReportSale(soldAt: DateTime(2026, 10, day), totalKobo: total, costKobo: cost, customerName: customer, items: items);

void main() {
  final now = DateTime(2026, 10, 20);

  test('period ranges', () {
    expect(ReportPeriod.thisMonth.range(now), (DateTime(2026, 10), DateTime(2026, 11)));
    expect(ReportPeriod.lastMonth.range(now), (DateTime(2026, 9), DateTime(2026, 10)));
    expect(ReportPeriod.thisYear.range(now), (DateTime(2026), DateTime(2027)));
    expect(ReportPeriod.lastMonth.range(DateTime(2026, 1, 5)), (DateTime(2025, 12), DateTime(2026, 1)));
    expect(ReportPeriod.thisYear.months(now), 10);
  });

  test('profit and loss adds up', () {
    final t = totalsFor(
      [sale(2, 100000, 60000), sale(3, 50000, 20000)],
      [ReportExpense(categoryName: 'Rent', amountKobo: 30000, spentAt: DateTime(2026, 10, 4))],
    );
    expect(t.salesKobo, 150000);
    expect(t.grossKobo, 70000);
    expect(t.netKobo, 40000);
    final table = profitAndLossTable(t, 'This month');
    expect(table.rows.last[1].csv, '400.00');
    expect(table.rows[1][1].csv, '-800.00');
  });

  test('weekly bars cover the month and put sales in the right week', () {
    final bars = barsFor(ReportPeriod.thisMonth, now, [sale(1, 100, 0), sale(9, 200, 0), sale(31, 50, 0)], const []);
    expect(bars.length, 5);
    expect(bars[0].salesKobo, 100);
    expect(bars[1].salesKobo, 200);
    expect(bars[4].salesKobo, 50);
  });

  test('yearly bars run January to the current month', () {
    final bars = barsFor(ReportPeriod.thisYear, now, [sale(2, 100, 0)], const []);
    expect(bars.length, 10);
    expect(bars.last.label, 'Oct');
    expect(bars.last.salesKobo, 100);
  });

  test('best sellers are ranked by revenue and carry profit', () {
    final rows = salesByProduct([
      sale(1, 0, 0, items: const [ReportSaleItem(description: 'Rice', qty: 2, unitPriceKobo: 1000, unitCostKobo: 700)]),
      sale(2, 0, 0, items: const [
        ReportSaleItem(description: 'Rice', qty: 1, unitPriceKobo: 1000, unitCostKobo: 700),
        ReportSaleItem(description: 'Oil', qty: 1, unitPriceKobo: 5000, unitCostKobo: 4000),
      ]),
    ]);
    expect(rows.first.name, 'Oil');
    expect(rows.last.units, 3);
    expect(rows.last.profitKobo, 900);
  });

  test('sales by customer groups walk-ins', () {
    final rows = salesByCustomer([sale(1, 100, 0), sale(2, 300, 0, customer: 'Ada'), sale(3, 50, 0)]);
    expect(rows.first.name, 'Ada');
    expect(rows.last.name, walkInLabel);
    expect(rows.last.count, 2);
  });

  test('expense categories compare with monthly budgets scaled by months', () {
    final rows = expensesByCategory(
      [ReportExpense(categoryName: 'Rent', amountKobo: 500, spentAt: now), ReportExpense(categoryName: '', amountKobo: 100, spentAt: now)],
      const [ReportBudget(categoryName: 'Rent', monthlyKobo: 300), ReportBudget(categoryName: 'Fuel', monthlyKobo: 200)],
      2,
    );
    final rent = rows.firstWhere((r) => r.name == 'Rent');
    expect(rent.budgetKobo, 600);
    expect(rows.firstWhere((r) => r.name == 'Fuel').spentKobo, 0);
    expect(rows.any((r) => r.name == uncategorisedLabel), isTrue);
  });

  test('inventory value at cost and at price', () {
    final v = inventoryValuation(const [
      ReportProduct(name: 'A', qtyOnHand: 10, costKobo: 100, priceKobo: 150),
      ReportProduct(name: 'B', qtyOnHand: 0, costKobo: 999, priceKobo: 999),
    ]);
    expect(v.atCostKobo, 1000);
    expect(v.atPriceKobo, 1500);
    expect(v.potentialProfitKobo, 500);
  });

  test('receivables age buckets', () {
    expect(bucketFor(DateTime(2026, 10, 25), now), AgeBucket.current);
    expect(bucketFor(DateTime(2026, 10, 20), now), AgeBucket.current);
    expect(bucketFor(DateTime(2026, 10, 19), now), AgeBucket.d1to30);
    expect(bucketFor(DateTime(2026, 9, 10), now), AgeBucket.d31to60);
    expect(bucketFor(DateTime(2026, 8, 10), now), AgeBucket.d61to90);
    expect(bucketFor(DateTime(2026, 5, 1), now), AgeBucket.over90);
    final by = receivablesByAge([
      ReportInvoice(number: 'A', customerName: 'x', dueDate: DateTime(2026, 10, 19), totalKobo: 500, balanceKobo: 300),
      ReportInvoice(number: 'B', customerName: 'y', dueDate: DateTime(2026, 10, 10), totalKobo: 500, balanceKobo: 200),
    ], now);
    expect(by[AgeBucket.d1to30], 500);
  });

  test('statement keeps a running balance', () {
    final t = statementTable('Ada', [
      StatementLine(date: DateTime(2026, 10, 5), description: 'Payment', paymentKobo: 400),
      StatementLine(date: DateTime(2026, 10, 1), description: 'Invoice INV-1', chargeKobo: 1000),
    ], (d) => '${d.day}');
    expect(t.rows.first[4].csv, '10.00');
    expect(t.rows.last[4].csv, '6.00');
    expect(t.summary.last.$2.csv, '6.00');
  });

  test('csv quotes commas and quotes', () {
    const t = ReportTable(
      title: 'T',
      subtitle: 's',
      summary: [],
      headers: ['Name', 'Amount'],
      rows: [
        [Cell('Salt, fine'), Cell('1')],
        [Cell('He said "hi"'), Cell('2')],
      ],
    );
    final csv = t.toCsv();
    expect(csv, contains('"Salt, fine",1'));
    expect(csv, contains('"He said ""hi""",2'));
  });

  test('money cells give plain numbers for spreadsheets', () {
    expect(Cell.money(150000).csv, '1500.00');
    expect(Cell.money(-5).csv, '-0.05');
  });
}
