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

  Map<String, dynamic> toMap({String? userId}) {
    final map = <String, dynamic>{
      'id': id,
      'title': title,
      'total_income': totalIncome,
      'cycle': cycle.name,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'is_business': isBusiness ? 1 : 0,
    };
    if (userId != null) {
      map['user_id'] = userId;
    }
    return map;
  }

  factory BudgetPlan.fromMap(Map<String, dynamic> map, {List<BudgetItem>? items}) {
    final bool isBiz = map['is_business'] is bool
        ? map['is_business'] as bool
        : (map['is_business'] == 1 || map['is_business'] == true);

    final String cycleStr = (map['cycle'] ?? 'monthly').toString();
    final BudgetCycle parsedCycle = BudgetCycle.values.firstWhere(
      (c) => c.name.toLowerCase() == cycleStr.toLowerCase(),
      orElse: () => BudgetCycle.monthly,
    );

    final DateTime start = map['start_date'] != null
        ? DateTime.tryParse(map['start_date'].toString()) ?? DateTime.now()
        : DateTime.now();

    final DateTime end = map['end_date'] != null
        ? DateTime.tryParse(map['end_date'].toString()) ?? DateTime.now().add(const Duration(days: 30))
        : DateTime.now().add(const Duration(days: 30));

    List<BudgetItem> parsedItems = items ?? [];
    if (parsedItems.isEmpty && map['items'] is List) {
      parsedItems = (map['items'] as List)
          .map((i) => BudgetItem.fromMap(Map<String, dynamic>.from(i as Map)))
          .toList();
    }

    return BudgetPlan(
      id: (map['id'] ?? '').toString(),
      title: (map['title'] ?? 'Budget Plan').toString(),
      totalIncome: (map['total_income'] ?? map['totalIncome'] ?? 0.0) is num
          ? (map['total_income'] ?? map['totalIncome'] ?? 0.0).toDouble()
          : double.tryParse((map['total_income'] ?? map['totalIncome'] ?? 0).toString()) ?? 0.0,
      cycle: parsedCycle,
      startDate: start,
      endDate: end,
      items: parsedItems,
      isBusiness: isBiz,
    );
  }

  Map<String, dynamic> toJson() {
    final map = toMap();
    map['items'] = items.map((i) => i.toJson()).toList();
    return map;
  }

  factory BudgetPlan.fromJson(Map<String, dynamic> json) => BudgetPlan.fromMap(json);
}
