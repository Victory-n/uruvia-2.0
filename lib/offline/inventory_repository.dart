import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uruvia/offline/sync_service.dart';
import 'connectivity_service.dart';
import 'database_helper.dart';

class InventoryRepository {
  static final InventoryRepository _instance = InventoryRepository._internal();
  static InventoryRepository get instance => _instance;
  InventoryRepository._internal();

  SupabaseClient get _supabaseClient => Supabase.instance.client;
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Flushes the offline queue first. Returns true only when no inventory
  // changes are waiting, i.e. it's safe to replace the local cache with
  // server data without losing offline entries.
  Future<bool> _canRefreshCacheFromRemote() async {
    final sync = SyncService.instance;
    if (await sync.pendingCount() > 0) {
      await sync.processQueue();
    }
    return await sync.pendingCount(tableName: 'inventory_items') == 0;
  }

  // Retrieve inventory items: fetches from Supabase and caches them if online; loads from SQLite if offline.
  Future<List<Map<String, dynamic>>> getInventoryItems() async {
    final bool isOnline = ConnectivityService.instance.isConnected.value;

    if (isOnline && await _canRefreshCacheFromRemote()) {
      try {
        if (kDebugMode) {
          print('Fetch inventory from remote Supabase DB...');
        }
        final List<dynamic> response = await _supabaseClient
            .from('inventory_items')
            .select()
            .order('updated_at', ascending: false);

        final items = List<Map<String, dynamic>>.from(response);

        // Overwrite the local SQLite cache with the fresh server data
        await _dbHelper.clearTable('local_inventory_items');
        for (var item in items) {
          final dbItem = Map<String, dynamic>.from(item);
          if (dbItem['low_stock_alert'] is bool) {
            dbItem['low_stock_alert'] = dbItem['low_stock_alert'] ? 1 : 0;
          }
          await _dbHelper.cacheUpsert('local_inventory_items', dbItem);
        }

        return items;
      } catch (e) {
        if (kDebugMode) {
          print('Failed to fetch from remote. Falling back to local cache: $e');
        }
      }
    }

    // Offline (or remote fetch failed) - load from local SQLite database cache
    if (kDebugMode) {
      print('Loading inventory items from local SQLite cache...');
    }
    final List<Map<String, dynamic>> cachedRows = await _dbHelper.queryCache(
      'local_inventory_items',
      orderBy: 'updated_at DESC',
    );

    // Convert SQLite 0/1 back to native booleans
    return cachedRows.map((row) {
      final item = Map<String, dynamic>.from(row);
      if (item['low_stock_alert'] is int) {
        item['low_stock_alert'] = item['low_stock_alert'] == 1;
      }
      return item;
    }).toList();
  }

  // Insert a new inventory item
  Future<void> addInventoryItem(Map<String, dynamic> item) async {
    // 1. Immediately insert into local cache
    final localItem = Map<String, dynamic>.from(item);
    if (localItem['low_stock_alert'] is bool) {
      localItem['low_stock_alert'] = localItem['low_stock_alert'] ? 1 : 0;
    }
    await _dbHelper.cacheUpsert('local_inventory_items', localItem);

    // 2. Perform write to server if online
    final bool isOnline = ConnectivityService.instance.isConnected.value;
    if (isOnline) {
      try {
        await _supabaseClient.from('inventory_items').insert(item);
        if (kDebugMode) {
          print('Successfully added item to remote Supabase database.');
        }
        return;
      } catch (e) {
        if (kDebugMode) {
          print(
            'Failed to write directly to remote database. Queuing action: $e',
          );
        }
      }
    }

    // 3. Fallback: Queue offline outbox action
    await SyncService.instance.enqueueAction(
      'INSERT',
      'inventory_items',
      item['id'] as String,
      item,
    );
  }

  // Update an existing inventory item
  Future<void> updateInventoryItem(
    String id,
    Map<String, dynamic> updates,
  ) async {
    // 1. Fetch current item from cache and merge updates
    final List<Map<String, dynamic>> localRows = await _dbHelper.queryCache(
      'local_inventory_items',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (localRows.isEmpty) {
      if (kDebugMode) {
        print('Error: Item with ID $id not found in local cache for updates.');
      }
      return;
    }

    final mergedItem = Map<String, dynamic>.from(localRows.first);

    if (mergedItem['low_stock_alert'] is int) {
      mergedItem['low_stock_alert'] = mergedItem['low_stock_alert'] == 1;
    }

    // Apply updates
    updates.forEach((key, value) {
      mergedItem[key] = value;
    });

    // Update timestamp
    mergedItem['updated_at'] = DateTime.now().toUtc().toIso8601String();

    // 2. Write to local cache
    final localItem = Map<String, dynamic>.from(mergedItem);
    if (localItem['low_stock_alert'] is bool) {
      localItem['low_stock_alert'] = localItem['low_stock_alert'] ? 1 : 0;
    }
    await _dbHelper.cacheUpsert('local_inventory_items', localItem);

    // 3. Perform write to server if online
    final bool isOnline = ConnectivityService.instance.isConnected.value;
    if (isOnline) {
      try {
        await _supabaseClient.from('inventory_items').upsert(mergedItem);
        if (kDebugMode) {
          print('Successfully updated item in remote Supabase database.');
        }
        return;
      } catch (e) {
        if (kDebugMode) {
          print(
            'Failed to update directly to remote database. Queuing action: $e',
          );
        }
      }
    }

    // 4. Fallback: Queue offline outbox action
    await SyncService.instance.enqueueAction(
      'UPDATE',
      'inventory_items',
      id,
      mergedItem,
    );
  }

  // Delete an inventory item
  Future<void> deleteInventoryItem(String id) async {
    // 1. Immediately delete from local cache
    await _dbHelper.deleteCacheRow('local_inventory_items', id);

    // 2. Perform delete from server if online
    final bool isOnline = ConnectivityService.instance.isConnected.value;
    if (isOnline) {
      try {
        await _supabaseClient.from('inventory_items').delete().eq('id', id);
        if (kDebugMode) {
          print('Successfully deleted item from remote Supabase database.');
        }
        return;
      } catch (e) {
        if (kDebugMode) {
          print(
            'Failed to delete directly from remote database. Queuing action: $e',
          );
        }
      }
    }

    // 3. Fallback: Queue offline outbox action
    await SyncService.instance.enqueueAction(
      'DELETE',
      'inventory_items',
      id,
      {},
    );
  }

  // Deduct stock when a sale or invoice payment is made
  Future<bool> deductStock({
    required String itemId,
    required int quantityToDeduct,
    String? referenceId,
    String? note,
  }) async {
    if (quantityToDeduct <= 0) return false;

    final List<Map<String, dynamic>> items = await _dbHelper.queryCache(
      'local_inventory_items',
      where: 'id = ?',
      whereArgs: [itemId],
    );

    if (items.isEmpty) return false;

    final currentItem = items.first;
    final currentQty = (currentItem['quantity'] as num?)?.toInt() ?? 0;
    final newQty = currentQty - quantityToDeduct;

    // Update item quantity
    await updateInventoryItem(itemId, {
      'quantity': newQty,
    });

    // Record stock movement audit entry
    await recordStockMovement({
      'id': 'mov_${DateTime.now().millisecondsSinceEpoch}_$itemId',
      'item_id': itemId,
      'item_name': currentItem['item_name'] ?? 'Item',
      'change_quantity': -quantityToDeduct,
      'resulting_quantity': newQty,
      'movement_type': 'sale',
      'reference_id': referenceId,
      'note': note ?? 'Deducted on sale/invoice payment',
      'created_at': DateTime.now().toIso8601String(),
    });

    return true;
  }

  // Restock an inventory item
  Future<bool> restockItem({
    required String itemId,
    required int quantityToAdd,
    double? newCostPrice,
    String? note,
  }) async {
    if (quantityToAdd <= 0) return false;

    final List<Map<String, dynamic>> items = await _dbHelper.queryCache(
      'local_inventory_items',
      where: 'id = ?',
      whereArgs: [itemId],
    );

    if (items.isEmpty) return false;

    final currentItem = items.first;
    final currentQty = (currentItem['quantity'] as num?)?.toInt() ?? 0;
    final newQty = currentQty + quantityToAdd;

    final Map<String, dynamic> updates = {
      'quantity': newQty,
    };
    if (newCostPrice != null && newCostPrice > 0) {
      updates['cost_price'] = newCostPrice;
    }

    await updateInventoryItem(itemId, updates);

    // Record stock movement audit entry
    await recordStockMovement({
      'id': 'mov_${DateTime.now().millisecondsSinceEpoch}_$itemId',
      'item_id': itemId,
      'item_name': currentItem['item_name'] ?? 'Item',
      'change_quantity': quantityToAdd,
      'resulting_quantity': newQty,
      'movement_type': 'restock',
      'note': note ?? 'Restocked item',
      'created_at': DateTime.now().toIso8601String(),
    });

    return true;
  }

  // Record a stock movement
  Future<void> recordStockMovement(Map<String, dynamic> movement) async {
    await _dbHelper.cacheUpsert('local_stock_movements', movement);
  }

  // Retrieve stock movements for an item
  Future<List<Map<String, dynamic>>> getStockMovements(String itemId) async {
    return await _dbHelper.queryCache(
      'local_stock_movements',
      where: 'item_id = ?',
      whereArgs: [itemId],
      orderBy: 'created_at DESC',
    );
  }
}

