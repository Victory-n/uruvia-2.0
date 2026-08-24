import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'database_helper.dart';

class SyncService {
  static final SyncService _instance = SyncService._internal();
  static SyncService get instance => _instance;
  SyncService._internal();

  final SupabaseClient _supabaseClient = Supabase.instance.client;
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  bool _isSyncing = false;

  // Queue an action offline
  Future<void> enqueueAction(
    String actionType, // 'INSERT', 'UPDATE', 'DELETE'
    String tableName,
    String recordId,
    Map<String, dynamic> payload,
  ) async {
    final db = await _dbHelper.database;
    final actionId = '${DateTime.now().millisecondsSinceEpoch}_$recordId';

    await db.insert('offline_actions', {
      'id': actionId,
      'action_type': actionType,
      'table_name': tableName,
      'record_id': recordId,
      'payload': jsonEncode(payload),
      'created_at': DateTime.now().millisecondsSinceEpoch,
    });

    if (kDebugMode) {
      print(
        'Queued offline action ($actionType) on table $tableName for record $recordId',
      );
    }
  }

  // Trigger outbox processing loop
  Future<void> processQueue() async {
    if (_isSyncing) return;
    _isSyncing = true;

    if (kDebugMode) {
      print('Starting offline action synchronization...');
    }

    try {
      final db = await _dbHelper.database;

      while (true) {
        // Query the oldest action in FIFO order
        final List<Map<String, dynamic>> actions = await db.query(
          'offline_actions',
          orderBy: 'created_at ASC',
          limit: 1,
        );

        if (actions.isEmpty) {
          if (kDebugMode) {
            print('Sync complete. No pending actions in queue.');
          }
          break;
        }

        final action = actions.first;
        final String actionId = action['id'] as String;
        final String actionType = action['action_type'] as String;
        final String tableName = action['table_name'] as String;
        final String recordId = action['record_id'] as String;
        final Map<String, dynamic> payload =
            jsonDecode(action['payload'] as String) as Map<String, dynamic>;

        bool success = await _syncAction(
          actionType,
          tableName,
          recordId,
          payload,
        );

        if (success) {
          // Remove action from local queue
          await db.delete(
            'offline_actions',
            where: 'id = ?',
            whereArgs: [actionId],
          );
          if (kDebugMode) {
            print('Successfully synced and removed action ID: $actionId');
          }
        } else {
          // If we fail because of connectivity, pause and retry later.
          if (kDebugMode) {
            print(
              'Failed to sync action ID: $actionId. Stopping synchronization loop.',
            );
          }
          break;
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error processing offline queue: $e');
      }
    } finally {
      _isSyncing = false;
    }
  }

  // Sync a single action to Supabase
  Future<bool> _syncAction(
    String actionType,
    String tableName,
    String recordId,
    Map<String, dynamic> payload,
  ) async {
    try {
      if (actionType == 'INSERT' || actionType == 'UPDATE') {
        // SQLite stores boolean values as 0 or 1, but Supabase expects actual booleans.
        final cleanedPayload = Map<String, dynamic>.from(payload);

        if (cleanedPayload.containsKey('low_stock_alert') &&
            cleanedPayload['low_stock_alert'] is int) {
          cleanedPayload['low_stock_alert'] =
              cleanedPayload['low_stock_alert'] == 1;
        }

        await _supabaseClient.from(tableName).upsert(cleanedPayload);
      } else if (actionType == 'DELETE') {
        await _supabaseClient.from(tableName).delete().eq('id', recordId);
      }
      return true;
    } on PostgrestException catch (e) {
      if (kDebugMode) {
        print(
          'Supabase PostgrestException while syncing $tableName: ${e.message} (${e.code})',
        );
      }
      // If error is schema, conflict or validation constraint, discard it from queue to avoid blockages
      if (e.code == '400' ||
          e.code == '409' ||
          e.code == '23505' ||
          e.code == '23503') {
        if (kDebugMode) {
          print(
            'Constraint / Bad Request error: Discarding action to prevent blocking the queue.',
          );
        }
        return true;
      }
      return false; // Temporary connection error
    } catch (e) {
      if (kDebugMode) {
        print('Unexpected error during sync action: $e');
      }
      return false; // Connection issue
    }
  }
}
