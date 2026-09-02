import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uruvia/offline/connectivity_service.dart';
import 'package:uruvia/offline/database_helper.dart';
import 'package:uruvia/offline/sync_service.dart';
import '../models/budget_item.dart';
import '../models/budget_plan.dart';

class BudgetRepository {
  static final BudgetRepository _instance = BudgetRepository._internal();
  static BudgetRepository get instance => _instance;
  BudgetRepository._internal();

  SupabaseClient get _supabaseClient => Supabase.instance.client;
  DatabaseHelper get _dbHelper => DatabaseHelper.instance;

  String? get _currentUserId => _supabaseClient.auth.currentUser?.id;

  /// Fetch active budget plan: fetches from Supabase & updates SQLite cache when online;
  /// falls back to SQLite cache when offline.
  Future<BudgetPlan> getActiveBudgetPlan({bool isBusiness = false}) async {
    final bool isOnline = ConnectivityService.instance.isConnected.value;
    final String? userId = _currentUserId;

    if (isOnline && userId != null) {
      try {
        if (kDebugMode) {
          print('[BudgetRepository] Fetching budget plans from remote Supabase...');
        }

        final List<dynamic> planRes = await _supabaseClient
            .from('budget_plans')
            .select()
            .eq('user_id', userId)
            .eq('is_business', isBusiness)
            .order('created_at', ascending: false)
            .limit(1);

        if (planRes.isNotEmpty) {
          final planData = Map<String, dynamic>.from(planRes.first);
          final String planId = planData['id'].toString();

          final List<dynamic> itemsRes = await _supabaseClient
              .from('budget_items')
              .select()
              .eq('plan_id', planId)
              .order('created_at', ascending: true);

          final items = itemsRes
              .map((i) => BudgetItem.fromMap(Map<String, dynamic>.from(i)))
              .toList();

          final plan = BudgetPlan.fromMap(planData, items: items);

          // Update local SQLite cache
          await _cacheBudgetPlanLocally(plan);

          return plan;
        }
      } catch (e) {
        if (kDebugMode) {
          print('[BudgetRepository] Failed to fetch remote budget plan. Falling back to local cache: $e');
        }
      }
    }

    // Offline or fallback to local SQLite cache
    if (kDebugMode) {
      print('[BudgetRepository] Loading budget plan from local SQLite cache...');
    }

    final List<Map<String, dynamic>> cachedPlans = await _dbHelper.queryCache(
      'local_budget_plans',
      where: 'is_business = ?',
      whereArgs: [isBusiness ? 1 : 0],
      orderBy: 'created_at DESC',
    );

    if (cachedPlans.isNotEmpty) {
      final planData = Map<String, dynamic>.from(cachedPlans.first);
      final String planId = planData['id'].toString();

      final List<Map<String, dynamic>> cachedItems = await _dbHelper.queryCache(
        'local_budget_items',
        where: 'plan_id = ?',
        whereArgs: [planId],
      );

      final items = cachedItems.map((i) => BudgetItem.fromMap(i)).toList();
      return BudgetPlan.fromMap(planData, items: items);
    }

    // Clean initial starter plan for new users / initial state
    final now = DateTime.now();
    final cleanPlan = BudgetPlan(
      id: 'plan_${now.millisecondsSinceEpoch}',
      title: isBusiness ? 'Business Operational Budget' : 'Personal Monthly Budget',
      totalIncome: 0.0,
      cycle: BudgetCycle.monthly,
      startDate: now,
      endDate: now.add(const Duration(days: 30)),
      isBusiness: isBusiness,
      items: const [],
    );

    return cleanPlan;
  }

  /// Save / Update an entire budget plan
  Future<void> saveBudgetPlan(BudgetPlan plan) async {
    // 1. Write to local SQLite cache
    await _cacheBudgetPlanLocally(plan);

    // 2. Perform write to server if online
    final bool isOnline = ConnectivityService.instance.isConnected.value;
    final String? userId = _currentUserId;

    if (isOnline && userId != null) {
      try {
        final planMap = plan.toMap(userId: userId);
        await _supabaseClient.from('budget_plans').upsert(planMap);

        for (final item in plan.items) {
          final itemMap = item.toMap(planId: plan.id);
          await _supabaseClient.from('budget_items').upsert(itemMap);
        }

        if (kDebugMode) {
          print('[BudgetRepository] Successfully synced budget plan to Supabase.');
        }
        return;
      } catch (e) {
        if (kDebugMode) {
          print('[BudgetRepository] Error syncing budget plan to Supabase: $e');
        }
      }
    }

    // 3. Fallback: Queue offline outbox action
    await SyncService.instance.enqueueAction(
      'UPSERT',
      'budget_plans',
      plan.id,
      plan.toMap(userId: userId),
    );
  }

  /// Save / Update a single budget item
  Future<void> saveBudgetItem(String planId, BudgetItem item) async {
    // 1. Write to local SQLite cache
    await _dbHelper.cacheUpsert('local_budget_items', item.toMap(planId: planId));

    // 2. Perform write to server if online
    final bool isOnline = ConnectivityService.instance.isConnected.value;
    if (isOnline) {
      try {
        await _supabaseClient.from('budget_items').upsert(item.toMap(planId: planId));
        if (kDebugMode) {
          print('[BudgetRepository] Successfully saved budget item to remote Supabase.');
        }
        return;
      } catch (e) {
        if (kDebugMode) {
          print('[BudgetRepository] Failed to save budget item directly: $e');
        }
      }
    }

    // 3. Fallback: Queue offline action
    await SyncService.instance.enqueueAction(
      'UPSERT',
      'budget_items',
      item.id,
      item.toMap(planId: planId),
    );
  }

  /// Delete a single budget item
  Future<void> deleteBudgetItem(String planId, String itemId) async {
    // 1. Delete from local SQLite cache
    await _dbHelper.deleteCacheRow('local_budget_items', itemId);

    // 2. Perform delete on server if online
    final bool isOnline = ConnectivityService.instance.isConnected.value;
    if (isOnline) {
      try {
        await _supabaseClient.from('budget_items').delete().eq('id', itemId);
        if (kDebugMode) {
          print('[BudgetRepository] Successfully deleted budget item from Supabase.');
        }
        return;
      } catch (e) {
        if (kDebugMode) {
          print('[BudgetRepository] Failed to delete budget item directly: $e');
        }
      }
    }

    // 3. Fallback: Queue offline action
    await SyncService.instance.enqueueAction(
      'DELETE',
      'budget_items',
      itemId,
      {'id': itemId, 'plan_id': planId},
    );
  }

  Future<void> _cacheBudgetPlanLocally(BudgetPlan plan) async {
    await _dbHelper.cacheUpsert(
      'local_budget_plans',
      plan.toMap(userId: _currentUserId),
    );

    for (final item in plan.items) {
      await _dbHelper.cacheUpsert(
        'local_budget_items',
        item.toMap(planId: plan.id),
      );
    }
  }
}
