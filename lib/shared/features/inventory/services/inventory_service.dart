import 'dart:isolate';
import '../../../../offline/inventory_repository.dart';
import '../../../../services/notification_service.dart';
import '../models/inventory_item.dart';
import '../models/stock_movement.dart';

class InventoryStats {
  final int totalDistinctItems;
  final int totalUnits;
  final double totalCostValue;
  final double totalPotentialRevenue;
  final int lowStockCount;
  final int outOfStockCount;

  const InventoryStats({
    required this.totalDistinctItems,
    required this.totalUnits,
    required this.totalCostValue,
    required this.totalPotentialRevenue,
    required this.lowStockCount,
    required this.outOfStockCount,
  });

  static const InventoryStats empty = InventoryStats(
    totalDistinctItems: 0,
    totalUnits: 0,
    totalCostValue: 0.0,
    totalPotentialRevenue: 0.0,
    lowStockCount: 0,
    outOfStockCount: 0,
  );
}

class InventoryService {
  static final InventoryService _instance = InventoryService._internal();
  static InventoryService get instance => _instance;
  InventoryService._internal();

  final InventoryRepository _repository = InventoryRepository.instance;
  final NotificationService _notificationService = NotificationService.instance;

  // Cache of already notified low-stock item IDs in this session to prevent spamming
  final Set<String> _notifiedLowStockItemIds = {};

  // Fetch all inventory items, parse off-thread via Isolate, check low stock alerts
  Future<List<InventoryItem>> getItems() async {
    final rawData = await _repository.getInventoryItems();

    // Offload parsing and initial low-stock detection to background Isolate (Rule 1)
    final items = await Isolate.run(() {
      return rawData.map((map) => InventoryItem.fromMap(map)).toList();
    });

    // Check low stock alerts and trigger notifications
    _checkAndTriggerLowStockAlerts(items);

    return items;
  }

  // Trigger low stock notifications
  Future<void> _checkAndTriggerLowStockAlerts(List<InventoryItem> items) async {
    for (final item in items) {
      if (item.lowStockAlert && (item.isLowStock || item.isOutOfStock)) {
        if (!_notifiedLowStockItemIds.contains(item.id)) {
          _notifiedLowStockItemIds.add(item.id);

          final String statusText = item.isOutOfStock
              ? 'OUT OF STOCK'
              : 'LOW STOCK (${item.quantity} ${item.unit} left)';

          await _notificationService.showInstantNotification(
            '⚠️ Stock Alert: ${item.itemName}',
            '${item.itemName} is $statusText. Restock threshold is ${item.lowStockThreshold} ${item.unit}.',
            category: 'reminder',
            payload: 'inventory_${item.id}',
          );
        }
      }
    }
  }

  // Compute stats in background Isolate (Rule 1)
  Future<InventoryStats> calculateStats(List<InventoryItem> items) async {
    if (items.isEmpty) return InventoryStats.empty;

    final itemMaps = items.map((e) => e.toMap()).toList();

    return await Isolate.run(() {
      int totalDistinct = itemMaps.length;
      int totalUnits = 0;
      double totalCost = 0.0;
      double totalRevenue = 0.0;
      int lowStock = 0;
      int outOfStock = 0;

      for (final map in itemMaps) {
        final item = InventoryItem.fromMap(map);
        totalUnits += item.quantity;
        totalCost += item.totalCostValue;
        totalRevenue += item.totalPotentialRevenue;
        if (item.isOutOfStock) {
          outOfStock++;
        } else if (item.isLowStock) {
          lowStock++;
        }
      }

      return InventoryStats(
        totalDistinctItems: totalDistinct,
        totalUnits: totalUnits,
        totalCostValue: totalCost,
        totalPotentialRevenue: totalRevenue,
        lowStockCount: lowStock,
        outOfStockCount: outOfStock,
      );
    });
  }

  // Filter and search inventory items off-thread via Isolate (Rule 1)
  Future<List<InventoryItem>> filterItems({
    required List<InventoryItem> sourceItems,
    required String query,
    required String statusFilter, // 'all', 'in_stock', 'low_stock', 'out_of_stock'
    required String categoryFilter, // 'all' or specific category
  }) async {
    final itemMaps = sourceItems.map((e) => e.toMap()).toList();

    return await Isolate.run(() {
      final q = query.trim().toLowerCase();

      return itemMaps
          .map((m) => InventoryItem.fromMap(m))
          .where((item) {
            // Category filter
            if (categoryFilter.toLowerCase() != 'all' &&
                item.category.toLowerCase() != categoryFilter.toLowerCase()) {
              return false;
            }

            // Status filter
            if (statusFilter == 'in_stock' && !item.isInStock) {
              return false;
            }
            if (statusFilter == 'low_stock' && !item.isLowStock) {
              return false;
            }
            if (statusFilter == 'out_of_stock' && !item.isOutOfStock) {
              return false;
            }

            // Search query filter
            if (q.isNotEmpty) {
              final nameMatch = item.itemName.toLowerCase().contains(q);
              final skuMatch = item.sku.toLowerCase().contains(q);
              final catMatch = item.category.toLowerCase().contains(q);
              return nameMatch || skuMatch || catMatch;
            }

            return true;
          })
          .toList();
    });
  }

  // Add a new inventory item
  Future<void> addItem(InventoryItem item) async {
    await _repository.addInventoryItem(item.toMap());

    // Record initial stock creation movement
    if (item.quantity > 0) {
      await _repository.recordStockMovement({
        'id': 'mov_${DateTime.now().millisecondsSinceEpoch}_${item.id}',
        'item_id': item.id,
        'item_name': item.itemName,
        'change_quantity': item.quantity,
        'resulting_quantity': item.quantity,
        'movement_type': 'initial',
        'note': 'Initial inventory entry',
        'created_at': DateTime.now().toIso8601String(),
      });
    }

    // Trigger low stock alert if initial quantity is already low
    if (item.lowStockAlert && (item.isLowStock || item.isOutOfStock)) {
      _checkAndTriggerLowStockAlerts([item]);
    }
  }

  // Update an existing inventory item
  Future<void> updateItem(InventoryItem item) async {
    await _repository.updateInventoryItem(item.id, item.toMap());

    // Reset alert tracking in case threshold was updated or restocked
    if (item.quantity > item.lowStockThreshold) {
      _notifiedLowStockItemIds.remove(item.id);
    } else {
      _checkAndTriggerLowStockAlerts([item]);
    }
  }

  // Delete an inventory item
  Future<void> deleteItem(String id) async {
    await _repository.deleteInventoryItem(id);
    _notifiedLowStockItemIds.remove(id);
  }

  // Restock an item
  Future<bool> restockItem({
    required String itemId,
    required int quantityToAdd,
    double? newCostPrice,
    String? note,
  }) async {
    final success = await _repository.restockItem(
      itemId: itemId,
      quantityToAdd: quantityToAdd,
      newCostPrice: newCostPrice,
      note: note,
    );

    if (success) {
      _notifiedLowStockItemIds.remove(itemId);
    }

    return success;
  }

  // Deduct stock (e.g. from manual adjustment or sale)
  Future<bool> deductStock({
    required String itemId,
    required int quantityToDeduct,
    String? referenceId,
    String? note,
  }) async {
    final success = await _repository.deductStock(
      itemId: itemId,
      quantityToDeduct: quantityToDeduct,
      referenceId: referenceId,
      note: note,
    );

    if (success) {
      // Re-check low stock alert after deduction
      final items = await getItems();
      final affected = items.where((i) => i.id == itemId).toList();
      if (affected.isNotEmpty) {
        _checkAndTriggerLowStockAlerts(affected);
      }
    }

    return success;
  }

  // Fetch stock audit movements for an item parsed off-thread
  Future<List<StockMovement>> getItemMovements(String itemId) async {
    final rawData = await _repository.getStockMovements(itemId);

    return await Isolate.run(() {
      return rawData.map((m) => StockMovement.fromMap(m)).toList();
    });
  }
}
