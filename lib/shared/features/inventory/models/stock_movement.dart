class StockMovement {
  final String id;
  final String itemId;
  final String itemName;
  final int changeQuantity;
  final int resultingQuantity;
  final String movementType; // 'sale', 'restock', 'adjustment', 'return'
  final String? referenceId; // e.g. 'INV-0012'
  final String? note;
  final DateTime createdAt;

  const StockMovement({
    required this.id,
    required this.itemId,
    required this.itemName,
    required this.changeQuantity,
    required this.resultingQuantity,
    required this.movementType,
    this.referenceId,
    this.note,
    required this.createdAt,
  });

  bool get isDeduction => changeQuantity < 0;
  bool get isAddition => changeQuantity > 0;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'item_id': itemId,
      'item_name': itemName,
      'change_quantity': changeQuantity,
      'resulting_quantity': resultingQuantity,
      'movement_type': movementType,
      'reference_id': referenceId,
      'note': note,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory StockMovement.fromMap(Map<String, dynamic> map) {
    return StockMovement(
      id: map['id']?.toString() ?? '',
      itemId: map['item_id']?.toString() ?? '',
      itemName: map['item_name']?.toString() ?? '',
      changeQuantity: (map['change_quantity'] as num?)?.toInt() ?? 0,
      resultingQuantity: (map['resulting_quantity'] as num?)?.toInt() ?? 0,
      movementType: map['movement_type']?.toString() ?? 'adjustment',
      referenceId: map['reference_id']?.toString(),
      note: map['note']?.toString(),
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
