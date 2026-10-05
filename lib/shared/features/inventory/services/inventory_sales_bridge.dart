import 'package:flutter/foundation.dart';
import 'inventory_service.dart';

class SaleItemLine {
  final String itemId;
  final String itemName;
  final int quantity;
  final double unitPrice;

  const SaleItemLine({
    required this.itemId,
    required this.itemName,
    required this.quantity,
    required this.unitPrice,
  });

  Map<String, dynamic> toMap() => {
        'item_id': itemId,
        'item_name': itemName,
        'quantity': quantity,
        'unit_price': unitPrice,
      };

  factory SaleItemLine.fromMap(Map<String, dynamic> map) => SaleItemLine(
        itemId: map['item_id']?.toString() ?? '',
        itemName: map['item_name']?.toString() ?? '',
        quantity: (map['quantity'] as num?)?.toInt() ?? 1,
        unitPrice: (map['unit_price'] as num?)?.toDouble() ?? 0.0,
      );
}

class StockCheckResult {
  final bool isAvailable;
  final List<String> insufficientStockItems;

  const StockCheckResult({
    required this.isAvailable,
    required this.insufficientStockItems,
  });
}

class InventorySalesBridge {
  static final InventorySalesBridge _instance =
      InventorySalesBridge._internal();
  static InventorySalesBridge get instance => _instance;
  InventorySalesBridge._internal();

  final InventoryService _inventoryService = InventoryService.instance;

  /// Check whether all lines in an upcoming sale/invoice have enough stock
  Future<StockCheckResult> validateStockAvailability(
    List<SaleItemLine> lines,
  ) async {
    final allInventory = await _inventoryService.getItems();
    final itemMap = {for (var i in allInventory) i.id: i};

    final List<String> insufficient = [];

    for (final line in lines) {
      final stockItem = itemMap[line.itemId];
      if (stockItem == null) {
        insufficient.add('${line.itemName} (Item not found in inventory)');
      } else if (stockItem.quantity < line.quantity) {
        insufficient.add(
          '${stockItem.itemName} (Only ${stockItem.quantity} ${stockItem.unit} available, requested ${line.quantity})',
        );
      }
    }

    return StockCheckResult(
      isAvailable: insufficient.isEmpty,
      insufficientStockItems: insufficient,
    );
  }

  /// Automatically deduct items from inventory when a sale is completed or invoice is marked paid.
  /// Example: 40 cars in inventory -> user buys 3 cars -> invoice paid -> 3 cars deducted (resulting 37).
  Future<bool> processPaidSaleOrInvoice({
    required String referenceId, // e.g., 'INV-2026-0042'
    required List<SaleItemLine> soldItems,
    String? customerName,
    String? notes,
  }) async {
    if (soldItems.isEmpty) return true;

    try {
      for (final line in soldItems) {
        final noteText = customerName != null && customerName.isNotEmpty
            ? 'Sold ${line.quantity} to $customerName (Ref: $referenceId)'
            : 'Sold ${line.quantity} on Invoice $referenceId';

        await _inventoryService.deductStock(
          itemId: line.itemId,
          quantityToDeduct: line.quantity,
          referenceId: referenceId,
          note: notes != null && notes.isNotEmpty ? '$noteText - $notes' : noteText,
        );
      }

      if (kDebugMode) {
        print(
          'InventorySalesBridge: Successfully deducted ${soldItems.length} items for paid invoice $referenceId',
        );
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('InventorySalesBridge Error during stock deduction: $e');
      }
      return false;
    }
  }

  /// Revert stock deduction in the event of an invoice cancellation or customer return
  Future<bool> revertPaidSaleOrInvoice({
    required String referenceId,
    required List<SaleItemLine> returnedItems,
    String? reason,
  }) async {
    if (returnedItems.isEmpty) return true;

    try {
      for (final line in returnedItems) {
        await _inventoryService.restockItem(
          itemId: line.itemId,
          quantityToAdd: line.quantity,
          note: 'Stock restored for refunded/cancelled invoice $referenceId${reason != null ? " ($reason)" : ""}',
        );
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('InventorySalesBridge Error during stock reversion: $e');
      }
      return false;
    }
  }
}
