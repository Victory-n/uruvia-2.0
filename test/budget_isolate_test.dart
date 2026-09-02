import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uruvia/shared/features/budgeting/logic/budget_isolate.dart';
import 'package:uruvia/shared/features/budgeting/models/budget_item.dart';
import 'package:uruvia/shared/features/budgeting/models/budget_plan.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Budget Models Serialization Tests', () {
    test('BudgetItem toMap and fromMap roundtrip', () {
      const original = BudgetItem(
        id: 'item_1',
        categoryName: 'Groceries',
        icon: Icons.restaurant_outlined,
        allocatedAmount: 50000.0,
        spentAmount: 25000.0,
        softStopThreshold: 0.85,
        isHardStopEnabled: true,
        color: Colors.green,
      );

      final map = original.toMap(planId: 'plan_123');
      expect(map['plan_id'], 'plan_123');
      expect(map['is_hard_stop_enabled'], 1);

      final reconstructed = BudgetItem.fromMap(map);
      expect(reconstructed.id, original.id);
      expect(reconstructed.categoryName, original.categoryName);
      expect(reconstructed.allocatedAmount, 50000.0);
      expect(reconstructed.spentAmount, 25000.0);
      expect(reconstructed.isHardStopEnabled, true);
    });

    test('BudgetPlan toMap and fromMap roundtrip', () {
      final now = DateTime.now();
      final original = BudgetPlan(
        id: 'plan_abc',
        title: 'Monthly Personal Budget',
        totalIncome: 300000.0,
        cycle: BudgetCycle.monthly,
        startDate: now,
        endDate: now.add(const Duration(days: 30)),
        isBusiness: false,
        items: const [
          BudgetItem(
            id: 'item_1',
            categoryName: 'Transport',
            icon: Icons.directions_bus_outlined,
            allocatedAmount: 40000.0,
            spentAmount: 35000.0,
          ),
        ],
      );

      final map = original.toMap(userId: 'user_xyz');
      expect(map['user_id'], 'user_xyz');
      expect(map['cycle'], 'monthly');

      final reconstructed = BudgetPlan.fromMap(map, items: original.items);
      expect(reconstructed.id, original.id);
      expect(reconstructed.title, original.title);
      expect(reconstructed.totalIncome, 300000.0);
      expect(reconstructed.cycle, BudgetCycle.monthly);
      expect(reconstructed.items.length, 1);
    });
  });

  group('Budget Isolate Service Tests (notes.txt Rule #1)', () {
    final now = DateTime.now();
    final testPlan = BudgetPlan(
      id: 'plan_test',
      title: 'Test Budget',
      totalIncome: 200000.0,
      cycle: BudgetCycle.monthly,
      startDate: now.subtract(const Duration(days: 10)),
      endDate: now.add(const Duration(days: 20)),
      items: const [
        BudgetItem(
          id: '1',
          categoryName: 'Groceries',
          icon: Icons.restaurant_outlined,
          allocatedAmount: 60000,
          spentAmount: 50000, // 83% utilization -> Warning
          color: Colors.green,
        ),
        BudgetItem(
          id: '2',
          categoryName: 'Entertainment',
          icon: Icons.sports_esports_outlined,
          allocatedAmount: 40000,
          spentAmount: 40000, // 100% utilized, Hard stop enabled -> Stopped
          isHardStopEnabled: true,
          color: Colors.purple,
        ),
        BudgetItem(
          id: '3',
          categoryName: 'Transport',
          icon: Icons.directions_bus_outlined,
          allocatedAmount: 30000,
          spentAmount: 10000, // Normal
          color: Colors.blue,
        ),
      ],
    );

    test('analyze() runs in Isolate and returns exact calculations & insights', () async {
      final res = await BudgetIsolateService.analyze(testPlan);

      expect(res.totalIncome, 200000.0);
      expect(res.totalAllocated, 130000.0);
      expect(res.totalSpent, 100000.0);
      expect(res.totalRemaining, 30000.0);
      expect(res.unallocatedIncome, 70000.0);
      expect(res.remainingDays, greaterThan(0));
      expect(res.dailySafeSpend, greaterThan(0));

      // Warnings verification
      expect(res.warnings.any((w) => w.contains('Entertainment has hit its Hard Stop limit')), isTrue);
      expect(res.warnings.any((w) => w.contains('Groceries is at 83% utilization')), isTrue);

      // Suggestions verification (unallocated funds tip)
      expect(res.suggestions.any((s) => s['type'] == 'unallocated'), isTrue);
    });

    test('filterItems() runs in Isolate for All vs Warning/Depleted', () async {
      final allItems = await BudgetIsolateService.filterItems(
        items: testPlan.items,
        filter: 'All',
      );
      expect(allItems.length, 3);

      final warningItems = await BudgetIsolateService.filterItems(
        items: testPlan.items,
        filter: 'Warning/Depleted',
      );
      expect(warningItems.length, 2);
      expect(warningItems.map((i) => i.id).toList(), containsAll(['1', '2']));
    });

    test('addItemOrUpdate() and toggleHardStopInItems() in Isolate', () async {
      const newItem = BudgetItem(
        id: '4',
        categoryName: 'Utilities',
        icon: Icons.home_work_outlined,
        allocatedAmount: 20000,
        spentAmount: 0,
      );

      final updatedList = await BudgetIsolateService.addItemOrUpdate(
        items: testPlan.items,
        newItem: newItem,
      );
      expect(updatedList.length, 4);

      final toggledList = await BudgetIsolateService.toggleHardStopInItems(
        items: updatedList,
        itemId: '4',
        isHardStop: true,
      );
      expect(toggledList.firstWhere((i) => i.id == '4').isHardStopEnabled, isTrue);
    });

    test('generate503020Preset() runs in Isolate', () async {
      final preset = await BudgetIsolateService.generate503020Preset(500000.0);
      expect(preset.length, 5);

      final totalPresetAllocated = preset.fold(0.0, (sum, i) => sum + i.allocatedAmount);
      expect(totalPresetAllocated, 500000.0);
    });
  });
}
