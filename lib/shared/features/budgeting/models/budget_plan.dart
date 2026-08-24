import 'budget_item.dart';

enum BudgetCycle {
  weekly,
  biWeekly,
  monthly,
  custom,
}

extension BudgetCycleExtension on BudgetCycle {
  String get displayName {
    switch (this) {
      case BudgetCycle.weekly:
        return 'Weekly';
      case BudgetCycle.biWeekly:
        return 'Bi-Weekly (Paycheck)';
      case BudgetCycle.monthly:
        return 'Monthly';
      case BudgetCycle.custom:
        return 'Custom Range';
    }
  }

  int get defaultDays {
    switch (this) {
      case BudgetCycle.weekly:
        return 7;
      case BudgetCycle.biWeekly:
        return 14;
      case BudgetCycle.monthly:
        return 30;
      case BudgetCycle.custom:
        return 30;
    }
  }
}

class BudgetPlan {
  final String id;
  final String title;
  final double totalIncome;
  final BudgetCycle cycle;
  final DateTime startDate;
  final DateTime endDate;
  final List<BudgetItem> items;
  final bool isBusiness;

  const BudgetPlan({
    required this.id,
    required this.title,
    required this.totalIncome,
    required this.cycle,
    required this.startDate,
    required this.endDate,
    required this.items,
    this.isBusiness = false,
  });

  double get totalAllocated {
    return items.fold(0.0, (sum, item) => sum + item.allocatedAmount);
  }

  double get totalSpent {
    return items.fold(0.0, (sum, item) => sum + item.spentAmount);
  }

  double get unallocatedIncome {
    final rem = totalIncome - totalAllocated;
    return rem < 0 ? 0.0 : rem;
  }

  double get totalRemaining {
    final rem = totalAllocated - totalSpent;
    return rem < 0 ? 0.0 : rem;
  }

  double get overallUtilizationRatio {
    if (totalAllocated <= 0) return 0.0;
    final ratio = totalSpent / totalAllocated;
    return ratio > 1.0 ? 1.0 : ratio;
  }

  int get remainingDays {
    final now = DateTime.now();
    if (now.isAfter(endDate)) return 0;
    return endDate.difference(now).inDays + 1;
  }

  double get dailySafeSpend {
    final days = remainingDays;
    if (days <= 0) return 0.0;
    return totalRemaining / days;
  }

  BudgetPlan copyWith({
    String? id,
    String? title,
    double? totalIncome,
    BudgetCycle? cycle,
    DateTime? startDate,
    DateTime? endDate,
    List<BudgetItem>? items,
    bool? isBusiness,
  }) {
    return BudgetPlan(
      id: id ?? this.id,
      title: title ?? this.title,
      totalIncome: totalIncome ?? this.totalIncome,
      cycle: cycle ?? this.cycle,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      items: items ?? this.items,
      isBusiness: isBusiness ?? this.isBusiness,
    );
  }
}
