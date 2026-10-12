import 'package:flutter_test/flutter_test.dart';
import 'package:uruvia/features/sales/domain/sale_models.dart';

Sale s(String id, String number, {String? customer, String? note}) => Sale(
      id: id, number: number, totalKobo: 100, costKobo: 50, soldAt: DateTime(2026, 10, 1), customerName: customer, note: note,
    );

void main() {
  final list = [s('1', 'SAL-00001', customer: 'Ada Stores'), s('2', 'SAL-00002', note: 'cash'), s('3', 'SAL-00003')];

  test('empty query keeps everything', () => expect(filterSales(list, '  ').length, 3));
  test('matches customer, number and note', () {
    expect(filterSales(list, 'ada').single.id, '1');
    expect(filterSales(list, '00002').single.id, '2');
    expect(filterSales(list, 'CASH').single.id, '2');
  });
  test('walk-in sales match "walk"', () => expect(filterSales(list, 'walk').map((e) => e.id), ['2', '3']));

  test('daily totals cover seven days, skip reversed sales and fill gaps with zero', () {
    final now = DateTime(2026, 10, 12, 15);
    final sales = [
      Sale(id: 'a', number: 'A', totalKobo: 500, costKobo: 0, soldAt: DateTime(2026, 10, 12, 9)),
      Sale(id: 'b', number: 'B', totalKobo: 300, costKobo: 0, soldAt: DateTime(2026, 10, 12, 11)),
      Sale(id: 'c', number: 'C', totalKobo: 900, costKobo: 0, soldAt: DateTime(2026, 10, 10), reversedAt: DateTime(2026, 10, 11)),
      Sale(id: 'd', number: 'D', totalKobo: 100, costKobo: 0, soldAt: DateTime(2026, 10, 1)),
    ];
    final t = dailySalesTotals(sales, now: now);
    expect(t.length, 7);
    expect(t.last.totalKobo, 800);
    expect(t.first.day, DateTime(2026, 10, 6));
    expect(t.fold<int>(0, (s, e) => s + e.totalKobo), 800);
  });

  test('receipt text lists items and total', () {
    final text = saleReceiptText(
      businessName: 'Ada Stores',
      sale: Sale(id: 'a', number: 'SAL-1', totalKobo: 1000000, costKobo: 0, soldAt: DateTime(2026, 10, 12)),
      items: const [SaleItem(description: 'Rice', qty: 2, unitPriceKobo: 500000, unitCostKobo: 0)],
    );
    expect(text, contains('Receipt SAL-1'));
    expect(text, contains('Rice  2 x'));
    expect(text, contains('Total:'));
  });
}
