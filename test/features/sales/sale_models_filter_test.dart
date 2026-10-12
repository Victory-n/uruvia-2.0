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
}
