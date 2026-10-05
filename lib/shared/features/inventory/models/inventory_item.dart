class InventoryItem {
  final String id;
  final String itemName;
  final String category;
  final int quantity;
  final double costPrice;
  final double sellingPrice;
  final bool lowStockAlert;
  final int lowStockThreshold;
  final String sku;
  final String unit;
  final String? imagePath;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const InventoryItem({
    required this.id,
    required this.itemName,
    required this.category,
    required this.quantity,
    required this.costPrice,
    required this.sellingPrice,
    this.lowStockAlert = true,
    this.lowStockThreshold = 5,
    this.sku = '',
    this.unit = 'units',
    this.imagePath,
    this.createdAt,
    this.updatedAt,
  });

  bool get isOutOfStock => quantity <= 0;
  bool get isLowStock => quantity > 0 && quantity <= lowStockThreshold;
  bool get isInStock => quantity > lowStockThreshold;

  double get profitMargin => sellingPrice - costPrice;
  double get profitMarginPercentage =>
      costPrice > 0 ? ((sellingPrice - costPrice) / costPrice) * 100 : 0.0;
  double get totalCostValue => quantity * costPrice;
  double get totalPotentialRevenue => quantity * sellingPrice;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'item_name': itemName,
      'category': category,
      'quantity': quantity,
      'cost_price': costPrice,
      'selling_price': sellingPrice,
      'low_stock_alert': lowStockAlert ? 1 : 0,
      'low_stock_threshold': lowStockThreshold,
      'sku': sku,
      'unit': unit,
      'image_path': imagePath,
      'created_at': createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
      'updated_at': updatedAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
    };
  }

  factory InventoryItem.fromMap(Map<String, dynamic> map) {
    return InventoryItem(
      id: map['id']?.toString() ?? '',
      itemName: map['item_name']?.toString() ?? 'Unnamed Item',
      category: map['category']?.toString() ?? 'General',
      quantity: (map['quantity'] as num?)?.toInt() ?? 0,
      costPrice: (map['cost_price'] as num?)?.toDouble() ?? 0.0,
      sellingPrice: (map['selling_price'] as num?)?.toDouble() ?? 0.0,
      lowStockAlert: map['low_stock_alert'] == 1 || map['low_stock_alert'] == true,
      lowStockThreshold: (map['low_stock_threshold'] as num?)?.toInt() ?? 5,
      sku: map['sku']?.toString() ?? '',
      unit: map['unit']?.toString() ?? 'units',
      imagePath: map['image_path']?.toString(),
      createdAt: map['created_at'] != null ? DateTime.tryParse(map['created_at'].toString()) : null,
      updatedAt: map['updated_at'] != null ? DateTime.tryParse(map['updated_at'].toString()) : null,
    );
  }

  InventoryItem copyWith({
    String? id,
    String? itemName,
    String? category,
    int? quantity,
    double? costPrice,
    double? sellingPrice,
    bool? lowStockAlert,
    int? lowStockThreshold,
    String? sku,
    String? unit,
    String? imagePath,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return InventoryItem(
      id: id ?? this.id,
      itemName: itemName ?? this.itemName,
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
      costPrice: costPrice ?? this.costPrice,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      lowStockAlert: lowStockAlert ?? this.lowStockAlert,
      lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
      sku: sku ?? this.sku,
      unit: unit ?? this.unit,
      imagePath: imagePath ?? this.imagePath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
