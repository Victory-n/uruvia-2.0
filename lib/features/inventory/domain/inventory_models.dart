class ProductCategory {
  const ProductCategory({required this.id, required this.name});
  final String id;
  final String name;
}

class Product {
  const Product({
    required this.id,
    required this.name,
    required this.sku,
    required this.unit,
    required this.costKobo,
    required this.priceKobo,
    required this.qtyOnHand,
    required this.qtyReserved,
    required this.lowStockAlert,
    required this.lowStockThreshold,
    this.categoryId,
    this.categoryName,
    this.archived = false,
    this.imagePath,
  });

  final String id;
  final String name;
  final String sku;
  final String unit;
  final int costKobo;
  final int priceKobo;
  final int qtyOnHand;
  final int qtyReserved;
  final bool lowStockAlert;
  final int lowStockThreshold;
  final String? categoryId;
  final String? categoryName;
  final bool archived;

  /// Path in the private account-files bucket, or null.
  final String? imagePath;

  int get qtyAvailable => qtyOnHand - qtyReserved;
  bool get isOut => qtyAvailable <= 0;

  /// Running low, but not yet out.
  bool get isLow => !isOut && lowStockAlert && qtyAvailable <= lowStockThreshold;
  bool get needsRestock => isOut || isLow;

  int get stockValueKobo => costKobo * qtyOnHand;
  int get marginKobo => priceKobo - costKobo;
}

enum MovementKind {
  opening('Opening stock'),
  restock('Restocked'),
  reserve('Reserved'),
  release('Reservation released'),
  sale('Sold'),
  adjustDamaged('Damaged'),
  adjustLost('Lost'),
  adjustCount('Count correction'),
  reversal('Sale reversed');

  const MovementKind(this.label);
  final String label;

  static MovementKind parse(String v) => switch (v) {
        'opening' => opening,
        'restock' => restock,
        'reserve' => reserve,
        'release' => release,
        'sale' => sale,
        'adjust_damaged' => adjustDamaged,
        'adjust_lost' => adjustLost,
        'adjust_count' => adjustCount,
        'reversal' => reversal,
        _ => adjustCount,
      };
}

class StockMovement {
  const StockMovement({
    required this.id,
    required this.kind,
    required this.deltaOnHand,
    required this.deltaReserved,
    required this.createdAt,
    this.note,
  });
  final String id;
  final MovementKind kind;
  final int deltaOnHand;
  final int deltaReserved;
  final DateTime createdAt;
  final String? note;

  /// The number to show: the change to In stock, or to Reserved for reserve/release rows.
  int get shownDelta => deltaOnHand != 0 ? deltaOnHand : deltaReserved;
}

class Reservation {
  const Reservation({
    required this.id,
    required this.qty,
    required this.reservedAt,
    required this.expiresAt,
    this.note,
    this.invoiceId,
  });
  final String id;
  final int qty;
  final DateTime reservedAt;
  final DateTime expiresAt;
  final String? note;
  final String? invoiceId;

  int daysLeft({DateTime? now}) {
    final left = expiresAt.difference(now ?? DateTime.now());
    if (left.isNegative) return 0;
    return (left.inHours / 24).ceil();
  }
}

class RestockReminder {
  const RestockReminder({required this.id, required this.productId, required this.remindAt, this.doneAt});
  final String id;
  final String productId;
  final DateTime remindAt;
  final DateTime? doneAt;
}

/// A short code made from the product name, such as "RIC-4821", used when the user leaves SKU empty.
String suggestSku(String name, {int? seed}) {
  final letters = name.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');
  final prefix = letters.isEmpty ? 'ITEM' : letters.substring(0, letters.length < 3 ? letters.length : 3);
  final n = seed ?? DateTime.now().millisecondsSinceEpoch;
  return '$prefix-${(n % 9000 + 1000)}';
}

const stockUnits = ['pieces', 'kg', 'litres', 'bags', 'cartons', 'dozens', 'pairs', 'packs'];

class InventoryTotals {
  const InventoryTotals({required this.products, required this.stockValueKobo, required this.needRestock});
  final int products;
  final int stockValueKobo;
  final int needRestock;
}

InventoryTotals inventoryTotals(List<Product> list) => InventoryTotals(
      products: list.length,
      stockValueKobo: list.fold(0, (s, p) => s + p.stockValueKobo),
      needRestock: list.where((p) => p.needsRestock).length,
    );
