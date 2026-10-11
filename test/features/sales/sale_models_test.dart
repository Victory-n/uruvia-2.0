import 'package:flutter_test/flutter_test.dart';
import 'package:uruvia/features/sales/domain/sale_models.dart';

Sale sale(int total, int cost, DateTime at, {DateTime? reversed}) =>
    Sale(id: 's', number: 'SAL-00001', totalKobo: total, costKobo: cost, soldAt: at, reversedAt: reversed);

void main() {
  quickSaleTests();
  final now = DateTime(2026, 10, 10, 15);

  test('periods', () {
    expect(SalePeriod.today.contains(DateTime(2026, 10, 10, 1), now: now), true);
    expect(SalePeriod.today.contains(DateTime(2026, 10, 9, 23), now: now), false);
    expect(SalePeriod.week.contains(DateTime(2026, 10, 4), now: now), true);
    expect(SalePeriod.week.contains(DateTime(2026, 10, 3), now: now), false);
    expect(SalePeriod.month.contains(DateTime(2026, 10, 1), now: now), true);
    expect(SalePeriod.month.contains(DateTime(2026, 9, 30), now: now), false);
    expect(SalePeriod.all.contains(DateTime(2001), now: now), true);
  });

  test('summary leaves out reversed sales and computes profit', () {
    final s = summarizeSales([
      sale(10000, 6000, now),
      sale(5000, 1000, now),
      sale(99999, 0, now, reversed: now),
    ]);
    expect(s.count, 2);
    expect(s.totalKobo, 15000);
    expect(s.profitKobo, 8000);
  });

  test('sale item profit', () {
    const i = SaleItem(description: 'Rice', qty: 3, unitPriceKobo: 1000, unitCostKobo: 700);
    expect(i.totalKobo, 3000);
    expect(i.profitKobo, 900);
  });
}

void quickSaleTests() {
  test('a counter sale carries its payment method and note', () {
    final s = Sale.fromRow({
      'id': 'x',
      'sale_number': 'SAL-00001',
      'invoice_id': null,
      'customer_id': null,
      'total_kobo': 500000,
      'cost_kobo': 300000,
      'sold_at': '2026-10-11T10:00:00Z',
      'reversed_at': null,
      'payment_method': 'cash',
      'note': 'Market day',
    });
    expect(s.paymentMethod, 'cash');
    expect(s.note, 'Market day');
    expect(s.profitKobo, 200000);
  });
}
