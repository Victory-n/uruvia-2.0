import 'package:flutter_test/flutter_test.dart';
import 'package:uruvia/shared/features/inventory/models/inventory_item.dart';
import 'package:uruvia/shared/features/inventory/models/stock_movement.dart';
import 'package:uruvia/shared/features/inventory/services/inventory_service.dart';
import 'package:uruvia/shared/features/inventory/services/inventory_sales_bridge.dart';

void main() {
  group('InventoryItem Model Tests', () {
    test('Calculates profit margins and status correctly for normal stock', () {
      const item = InventoryItem(
        id: 'item_1',
        itemName: 'Toyota Camry 2022',
        category: 'Vehicles',
        quantity: 40,
        costPrice: 5000000.0,
        sellingPrice: 7000000.0,
        lowStockAlert: true,
        lowStockThreshold: 5,
        unit: 'cars',
      );

      expect(item.isInStock, isTrue);
      expect(item.isLowStock, isFalse);
      expect(item.isOutOfStock, isFalse);
      expect(item.profitMargin, equals(2000000.0));
      expect(item.profitMarginPercentage, equals(40.0));
      expect(item.totalCostValue, equals(200000000.0));
      expect(item.totalPotentialRevenue, equals(280000000.0));
    });

    test('Identifies low stock threshold correctly (e.g. quantity <= threshold)', () {
      const item = InventoryItem(
        id: 'item_2',
        itemName: 'Honda Civic',
        category: 'Vehicles',
        quantity: 3, // <= 5
        costPrice: 3000000.0,
        sellingPrice: 4500000.0,
        lowStockAlert: true,
        lowStockThreshold: 5,
      );

      expect(item.isInStock, isFalse);
      expect(item.isLowStock, isTrue);
      expect(item.isOutOfStock, isFalse);
    });

    test('Identifies out of stock correctly (quantity <= 0)', () {
      const item = InventoryItem(
        id: 'item_3',
        itemName: 'Mercedes Benz C300',
        category: 'Vehicles',
        quantity: 0,
        costPrice: 10000000.0,
        sellingPrice: 14000000.0,
      );

      expect(item.isInStock, isFalse);
      expect(item.isLowStock, isFalse);
      expect(item.isOutOfStock, isTrue);
    });

    test('Serializes to and from Map accurately', () {
      const item = InventoryItem(
        id: 'item_map_test',
        itemName: 'Brake Pads',
        category: 'Spare Parts',
        quantity: 15,
        costPrice: 12000.0,
        sellingPrice: 20000.0,
        lowStockAlert: true,
        lowStockThreshold: 4,
        sku: 'BRK-001',
        unit: 'pairs',
      );

      final map = item.toMap();
      final reconstructed = InventoryItem.fromMap(map);

      expect(reconstructed.id, equals(item.id));
      expect(reconstructed.itemName, equals(item.itemName));
      expect(reconstructed.category, equals(item.category));
      expect(reconstructed.quantity, equals(item.quantity));
      expect(reconstructed.costPrice, equals(item.costPrice));
      expect(reconstructed.sellingPrice, equals(item.sellingPrice));
      expect(reconstructed.lowStockAlert, isTrue);
      expect(reconstructed.lowStockThreshold, equals(4));
      expect(reconstructed.sku, equals('BRK-001'));
      expect(reconstructed.unit, equals('pairs'));
    });
  });

  group('StockMovement Model Tests', () {
    test('Identifies deductions and additions correctly', () {
      final saleMovement = StockMovement(
        id: 'mov_1',
        itemId: 'item_1',
        itemName: 'Toyota Camry 2022',
        changeQuantity: -3,
        resultingQuantity: 37,
        movementType: 'sale',
        referenceId: 'INV-2026-001',
        note: 'Sold 3 units to Customer',
        createdAt: DateTime.now(),
      );

      expect(saleMovement.isDeduction, isTrue);
      expect(saleMovement.isAddition, isFalse);
      expect(saleMovement.resultingQuantity, equals(37));

      final restockMovement = StockMovement(
        id: 'mov_2',
        itemId: 'item_1',
        itemName: 'Toyota Camry 2022',
        changeQuantity: 10,
        resultingQuantity: 47,
        movementType: 'restock',
        createdAt: DateTime.now(),
      );

      expect(restockMovement.isDeduction, isFalse);
      expect(restockMovement.isAddition, isTrue);
    });
  });

  group('InventoryService Isolate Operations Tests', () {
    final sampleItems = [
      const InventoryItem(
        id: '1',
        itemName: 'Toyota Corolla',
        category: 'Vehicles',
        quantity: 40,
        costPrice: 1000.0,
        sellingPrice: 1500.0,
        lowStockThreshold: 5,
      ),
      const InventoryItem(
        id: '2',
        itemName: 'Engine Oil 5W-30',
        category: 'Fluids',
        quantity: 3,
        costPrice: 50.0,
        sellingPrice: 80.0,
        lowStockThreshold: 10,
      ),
      const InventoryItem(
        id: '3',
        itemName: 'Brake Disc',
        category: 'Spare Parts',
        quantity: 0,
        costPrice: 200.0,
        sellingPrice: 350.0,
        lowStockThreshold: 5,
      ),
    ];

    test('Computes aggregate stats correctly in Isolate', () async {
      final stats = await InventoryService.instance.calculateStats(sampleItems);

      expect(stats.totalDistinctItems, equals(3));
      expect(stats.totalUnits, equals(43)); // 40 + 3 + 0
      expect(stats.totalCostValue, equals(40150.0)); // 40000 + 150 + 0
      expect(stats.totalPotentialRevenue, equals(60240.0)); // 60000 + 240 + 0
      expect(stats.lowStockCount, equals(1)); // Engine Oil (3 <= 10)
      expect(stats.outOfStockCount, equals(1)); // Brake Disc (0)
    });

    test('Filters items by low stock status in Isolate', () async {
      final lowStockList = await InventoryService.instance.filterItems(
        sourceItems: sampleItems,
        query: '',
        statusFilter: 'low_stock',
        categoryFilter: 'all',
      );

      expect(lowStockList.length, equals(1));
      expect(lowStockList.first.itemName, equals('Engine Oil 5W-30'));
    });

    test('Filters items by query in Isolate', () async {
      final searchResult = await InventoryService.instance.filterItems(
        sourceItems: sampleItems,
        query: 'corolla',
        statusFilter: 'all',
        categoryFilter: 'all',
      );

      expect(searchResult.length, equals(1));
      expect(searchResult.first.itemName, equals('Toyota Corolla'));
    });
  });

  group('SaleItemLine Tests', () {
    test('Serializes to and from Map accurately', () {
      const line = SaleItemLine(
        itemId: 'item_1',
        itemName: 'Toyota Camry',
        quantity: 3,
        unitPrice: 7000000.0,
      );

      final map = line.toMap();
      final reconstructed = SaleItemLine.fromMap(map);

      expect(reconstructed.itemId, equals(line.itemId));
      expect(reconstructed.itemName, equals(line.itemName));
      expect(reconstructed.quantity, equals(3));
      expect(reconstructed.unitPrice, equals(7000000.0));
    });
  });
}
