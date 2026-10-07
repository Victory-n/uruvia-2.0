import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'connectivity_service.dart';
import 'database_helper.dart';
import 'sync_service.dart';

/// Profile access with the offline-first rules:
///
/// * First time this user is seen on the device -> read from Supabase and
///   cache the row locally.
/// * Every later time -> return the local copy immediately, then (if online)
///   flush the offline queue and refresh the cache in the background.
class ProfileRepository {
  static final ProfileRepository _instance = ProfileRepository._internal();
  static ProfileRepository get instance => _instance;
  ProfileRepository._internal();

  static const String _table = 'local_profiles';

  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  SupabaseClient get _client => Supabase.instance.client;

  /// Returns the profile for [userId].
  ///
  /// Throws if this is the first load on the device and Supabase can't be
  /// reached.
  Future<Map<String, dynamic>> loadProfile(String userId) async {
    var rows = await _dbHelper.queryCache(_table);

    // The cache belongs to somebody else: start clean.
    if (rows.isNotEmpty && rows.first['id'] != userId) {
      await _dbHelper.clearAllData();
      rows = [];
    }

    if (rows.isEmpty) {
      // First load for this user: Supabase is the source of truth.
      final remote = await _fetchRemote(userId);
      await _dbHelper.cacheUpsert(_table, remote);
      return remote;
    }

    // Consecutive load: serve the local copy, then sync quietly.
    unawaited(syncAndRefresh(userId));
    return Map<String, dynamic>.from(rows.first);
  }

  /// Reads the cached profile without touching the network.
  Future<Map<String, dynamic>?> getCachedProfile() async {
    final rows = await _dbHelper.queryCache(_table);
    return rows.isEmpty ? null : Map<String, dynamic>.from(rows.first);
  }

  /// Pushes pending offline actions, then refreshes the cached profile.
  /// Never overwrites the cache while profile changes are still queued.
  Future<void> syncAndRefresh(String userId) async {
    try {
      if (!await ConnectivityService.instance.checkConnection()) return;

      await SyncService.instance.processQueue();
      if (await SyncService.instance.pendingCount(tableName: 'profiles') > 0) {
        return;
      }

      final remote = await _fetchRemote(userId);
      await _dbHelper.cacheUpsert(_table, remote);
    } catch (e) {
      if (kDebugMode) {
        print('Profile background refresh failed: $e');
      }
    }
  }

  Future<Map<String, dynamic>> _fetchRemote(String userId) async {
    final row = await _client
        .from('profiles')
        .select()
        .eq('id', userId)
        .single();

    return {
      'id': row['id'],
      'first_name': row['first_name'] ?? '',
      'last_name': row['last_name'] ?? '',
      'email': row['email'],
      'phone': row['phone'],
      'currency': row['currency'] ?? 'NGN',
      'active_account_type': row['active_account_type'] ?? 'individual',
      'updated_at': row['updated_at'] ?? DateTime.now().toIso8601String(),
    };
  }
}
