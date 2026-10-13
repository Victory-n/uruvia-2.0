import 'package:flutter_test/flutter_test.dart';
import 'package:uruvia/features/inventory/domain/inventory_models.dart';

Product p({int onHand = 10, int reserved = 0, bool alert = true, int threshold = 3, int cost = 100, int price = 150}) =>
    Product(
      id: '1',
      name: 'Rice',
      sku: 'RIC-1000',
      unit: 'bags',
      costKobo: cost,
      priceKobo: price,
      qtyOnHand: onHand,
      qtyReserved: reserved,
      lowStockAlert: alert,
      lowStockThreshold: threshold,
    );

void main() {
  test('available subtracts reserved', () {
    expect(p(onHand: 10, reserved: 4).qtyAvailable, 6);
  });

  test('out, low and healthy states', () {
    expect(p(onHand: 4, reserved: 4).isOut, true);
    expect(p(onHand: 3).isLow, true);
    expect(p(onHand: 3).needsRestock, true);
    expect(p(onHand: 3, alert: false).isLow, false);
    expect(p(onHand: 10).needsRestock, false);
  });

  test('stock value and margin', () {
    expect(p(onHand: 5, cost: 200, price: 300).stockValueKobo, 1000);
    expect(p(cost: 200, price: 300).marginKobo, 100);
  });

  test('suggestSku', () {
    expect(suggestSku('Rice', seed: 1), 'RIC-2001');
    expect(suggestSku('!!', seed: 0), 'ITEM-1000');
  });

  test('reservation daysLeft', () {
    final now = DateTime(2026, 10, 10, 12);
    Reservation r(DateTime e) => Reservation(id: 'r', qty: 1, reservedAt: now, expiresAt: e);
    expect(r(now.add(const Duration(days: 2))).daysLeft(now: now), 2);
    expect(r(now.subtract(const Duration(hours: 1))).daysLeft(now: now), 0);
  });

  test('inventory totals', () {
    final t = inventoryTotals([p(onHand: 2, cost: 100), p(onHand: 10, cost: 50)]);
    expect(t.products, 2);
    expect(t.stockValueKobo, 700);
    expect(t.needRestock, 1);
  });

  test('a scanned code finds the product by SKU, ignoring case and spaces', () {
    expect(findProductByCode([p()], ' ric-1000 ')?.name, 'Rice');
    expect(findProductByCode([p()], '999'), isNull);
    expect(findProductByCode([p()], '  '), isNull);
  });

  test('running balance works back from the stock now', () {
    StockMovement mv(String id, int d) =>
        StockMovement(id: id, kind: MovementKind.sale, deltaOnHand: d, deltaReserved: 0, createdAt: DateTime(2026, 10, 1));
    final rows = withRunningBalance([mv('c', -2), mv('b', 5), mv('a', 10)], 13);
    expect(rows.map((r) => r.onHandAfter), [13, 15, 10]);
  });
}
