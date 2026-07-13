import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uruvia/offline/connectivity_service.dart';
import 'package:uruvia/offline/database_helper.dart';
import 'package:uruvia/offline/sync_service.dart';

class InventoryRepository {
  static final InventoryRepository _instance = InventoryRepository._internal();
  static InventoryRepository get instance => _instance;
  InventoryRepository._internal();

  final SupabaseClient _supabaseClient = Supabase.instance.client;
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Retrieve inventory items: fetches from Supabase and caches them if online; loads from SQLite if offline.
  Future<List<Map<String, dynamic>>> getInventoryItems() async {
    final bool isOnline = ConnectivityService.instance.isConnected.value;

    if (isOnline) {
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
          print('Failed to write directly to remote database. Queuing action: $e');
        }
      }
    }

    // 3. Fallback: Queue offline outbox action
    await SyncService.instance.enqueueAction('INSERT', 'inventory_items', item['id'] as String, item);
  }

  // Update an existing inventory item
  Future<void> updateInventoryItem(String id, Map<String, dynamic> updates) async {
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
          print('Failed to update directly to remote database. Queuing action: $e');
        }
      }
    }

    // 4. Fallback: Queue offline outbox action
    await SyncService.instance.enqueueAction('UPDATE', 'inventory_items', id, mergedItem);
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
          print('Failed to delete directly from remote database. Queuing action: $e');
        }
      }
    }

    // 3. Fallback: Queue offline outbox action
    await SyncService.instance.enqueueAction('DELETE', 'inventory_items', id, {});
  }
}
