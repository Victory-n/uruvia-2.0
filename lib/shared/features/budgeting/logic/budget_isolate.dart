import 'dart:isolate';
import 'package:flutter/material.dart';
import '../models/budget_item.dart';
import '../models/budget_plan.dart';

class BudgetAnalysisResult {
  final double totalIncome;
  final double totalAllocated;
  final double totalSpent;
  final double totalRemaining;
  final double unallocatedIncome;
  final double overallUtilization;
  final double dailySafeSpend;
  final int remainingDays;
  final List<String> warnings;
  final List<Map<String, dynamic>> suggestions;

  const BudgetAnalysisResult({
    required this.totalIncome,
    required this.totalAllocated,
    required this.totalSpent,
    required this.totalRemaining,
    required this.unallocatedIncome,
    required this.overallUtilization,
    required this.dailySafeSpend,
    required this.remainingDays,
    required this.warnings,
    required this.suggestions,
  });
}

class BudgetIsolateService {
  /// Offload budget calculations & smart suggestions processing to a background Isolate (notes.txt rule #1)
  static Future<BudgetAnalysisResult> analyze(BudgetPlan plan) async {
    return Isolate.run(() => _calculateAnalysis(plan));
  }

  /// Offload list filtering over budget categories to background Isolate (notes.txt rule #1)
  static Future<List<BudgetItem>> filterItems({
    required List<BudgetItem> items,
    required String filter,
  }) async {
    return Isolate.run(() {
      if (filter == 'Warning/Depleted') {
        return items.where((item) {
          return item.status == BudgetStatus.warning ||
              item.status == BudgetStatus.depleted ||
              item.status == BudgetStatus.stopped;
        }).toList();
      }
      return List<BudgetItem>.from(items);
    });
  }

  /// Offload category mutations/recalculation to background Isolate (notes.txt rule #1)
  static Future<List<BudgetItem>> addItemOrUpdate({
    required List<BudgetItem> items,
    required BudgetItem newItem,
  }) async {
    return Isolate.run(() {
      final list = List<BudgetItem>.from(items);
      final index = list.indexWhere((i) => i.id == newItem.id);
      if (index >= 0) {
        list[index] = newItem;
      } else {
        list.add(newItem);
      }
      return list;
    });
  }

  /// Offload toggling hard stops in list to background Isolate (notes.txt rule #1)
  static Future<List<BudgetItem>> toggleHardStopInItems({
    required List<BudgetItem> items,
    required String itemId,
    required bool isHardStop,
  }) async {
    return Isolate.run(() {
      final list = List<BudgetItem>.from(items);
      final index = list.indexWhere((i) => i.id == itemId);
      if (index >= 0) {
        list[index] = list[index].copyWith(isHardStopEnabled: isHardStop);
      }
      return list;
    });
  }

  /// Internal worker function running inside the Isolate
  static BudgetAnalysisResult _calculateAnalysis(BudgetPlan plan) {
    final totalIncome = plan.totalIncome;
    final totalAllocated = plan.totalAllocated;
    final totalSpent = plan.totalSpent;
    final totalRemaining = plan.totalRemaining;
    final unallocated = totalIncome - totalAllocated > 0 ? totalIncome - totalAllocated : 0.0;
    final overallUtilization = plan.overallUtilizationRatio * 100;
    final remainingDays = plan.remainingDays;
    final dailySafeSpend = plan.dailySafeSpend;

    final List<String> warnings = [];
    final List<Map<String, dynamic>> suggestions = [];

    // Analyze individual categories for warnings & suggestions
    for (final item in plan.items) {
      if (item.status == BudgetStatus.stopped) {
        warnings.add("${item.categoryName} has hit its Hard Stop limit!");
      } else if (item.status == BudgetStatus.depleted) {
        warnings.add("${item.categoryName} budget is 100% depleted.");
      } else if (item.status == BudgetStatus.warning) {
        final pct = item.utilizationPercentage.toStringAsFixed(0);
        warnings.add("${item.categoryName} is at $pct% utilization.");
      }

      // Check burn rate relative to cycle days
      final totalDays = plan.cycle.defaultDays;
      final elapsedDays = totalDays - remainingDays;
      if (elapsedDays > 0 && totalDays > 0) {
        final expectedBurn = (elapsedDays / totalDays) * item.allocatedAmount;
        if (item.spentAmount > expectedBurn * 1.25 && item.spentAmount < item.allocatedAmount) {
          suggestions.add({
            'type': 'high_burn',
            'category': item.categoryName,
            'title': 'High Spending Burn Rate',
            'description': 'You have spent ${item.utilizationPercentage.toStringAsFixed(0)}% of your ${item.categoryName} budget in $elapsedDays days.',
            'actionText': 'Adjust Cap',
          });
        }
      }

      // Unspent surplus suggestion
      if (remainingDays <= 5 && item.remainingAmount > 5000) {
        suggestions.add({
          'type': 'surplus_sweep',
          'category': item.categoryName,
          'title': 'Unspent Budget Sweep',
          'description': 'You have unspent funds in ${item.categoryName}. Sweep into active Savings Goal?',
          'actionText': 'Sweep Savings',
        });
      }
    }

    // Unallocated income tip
    if (unallocated > 0) {
      suggestions.add({
        'type': 'unallocated',
        'category': 'General',
        'title': 'Unallocated Income Available',
        'description': 'You have remaining unbudgeted income. Apply 50/30/20 rule?',
        'actionText': 'Auto-Allocate',
      });
    }

    return BudgetAnalysisResult(
      totalIncome: totalIncome,
      totalAllocated: totalAllocated,
      totalSpent: totalSpent,
      totalRemaining: totalRemaining,
      unallocatedIncome: unallocated,
      overallUtilization: overallUtilization,
      dailySafeSpend: dailySafeSpend,
      remainingDays: remainingDays,
      warnings: warnings,
      suggestions: suggestions,
    );
  }

  /// Generate 50/30/20 Rule preset items offloaded to Isolate
  static Future<List<BudgetItem>> generate503020Preset(double income) async {
    return Isolate.run(() {
      final needs = income * 0.50;
      final wants = income * 0.30;
      final savings = income * 0.20;

      return [
        BudgetItem(
          id: 'preset_feeding',
          categoryName: 'Feeding & Groceries',
          icon: Icons.restaurant_outlined,
          allocatedAmount: needs * 0.60,
          spentAmount: 0.0,
          color: Colors.green,
        ),
        BudgetItem(
          id: 'preset_transport',
          categoryName: 'Transportation',
          icon: Icons.directions_bus_outlined,
          allocatedAmount: needs * 0.40,
          spentAmount: 0.0,
          color: Colors.blue,
        ),
        BudgetItem(
          id: 'preset_choplife',
          categoryName: 'Choplife & Outings',
          icon: Icons.sports_esports_outlined,
          allocatedAmount: wants * 0.70,
          spentAmount: 0.0,
          color: Colors.purple,
        ),
        BudgetItem(
          id: 'preset_health',
          categoryName: 'Health & Personal Care',
          icon: Icons.medical_services_outlined,
          allocatedAmount: wants * 0.30,
          spentAmount: 0.0,
          color: Colors.orange,
        ),
        BudgetItem(
          id: 'preset_savings',
          categoryName: 'Savings Reserve',
          icon: Icons.savings_outlined,
          allocatedAmount: savings,
          spentAmount: 0.0,
          color: Colors.teal,
        ),
      ];
    });
  }
}
