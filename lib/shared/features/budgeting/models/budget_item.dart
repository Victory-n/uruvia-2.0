import 'package:flutter/material.dart';

enum BudgetStatus {
  normal,
  warning, // Soft stop threshold reached (e.g. 80%)
  depleted, // 100% utilized
  stopped, // Hard stop active
}

class BudgetItem {
  final String id;
  final String categoryName;
  final IconData icon;
  final double allocatedAmount;
  final double spentAmount;
  final double softStopThreshold; // e.g., 0.8 for 80%
  final bool isHardStopEnabled;
  final Color color;

  const BudgetItem({
    required this.id,
    required this.categoryName,
    required this.icon,
    required this.allocatedAmount,
    required this.spentAmount,
    this.softStopThreshold = 0.8,
    this.isHardStopEnabled = false,
    this.color = Colors.blue,
  });

  double get remainingAmount {
    final rem = allocatedAmount - spentAmount;
    return rem < 0 ? 0.0 : rem;
  }

  double get utilizationRatio {
    if (allocatedAmount <= 0) return 0.0;
    final ratio = spentAmount / allocatedAmount;
    return ratio > 1.0 ? 1.0 : ratio;
  }

  double get utilizationPercentage => utilizationRatio * 100;

  BudgetStatus get status {
    if (isHardStopEnabled && spentAmount >= allocatedAmount) {
      return BudgetStatus.stopped;
    }
    if (spentAmount >= allocatedAmount) {
      return BudgetStatus.depleted;
    }
    if (utilizationRatio >= softStopThreshold) {
      return BudgetStatus.warning;
    }
    return BudgetStatus.normal;
  }

  BudgetItem copyWith({
    String? id,
    String? categoryName,
    IconData? icon,
    double? allocatedAmount,
    double? spentAmount,
    double? softStopThreshold,
    bool? isHardStopEnabled,
    Color? color,
  }) {
    return BudgetItem(
      id: id ?? this.id,
      categoryName: categoryName ?? this.categoryName,
      icon: icon ?? this.icon,
      allocatedAmount: allocatedAmount ?? this.allocatedAmount,
      spentAmount: spentAmount ?? this.spentAmount,
      softStopThreshold: softStopThreshold ?? this.softStopThreshold,
      isHardStopEnabled: isHardStopEnabled ?? this.isHardStopEnabled,
      color: color ?? this.color,
    );
  }

  Map<String, dynamic> toMap({String? planId}) {
    final map = <String, dynamic>{
      'id': id,
      'category_name': categoryName,
      'icon_code_point': icon.codePoint,
      'allocated_amount': allocatedAmount,
      'spent_amount': spentAmount,
      'soft_stop_threshold': softStopThreshold,
      'is_hard_stop_enabled': isHardStopEnabled ? 1 : 0,
      'color_value': color.toARGB32(),
    };
    if (planId != null) {
      map['plan_id'] = planId;
    }
    return map;
  }

  static IconData getIconFromCodePoint(int codePoint) {
    if (codePoint == Icons.restaurant_outlined.codePoint) return Icons.restaurant_outlined;
    if (codePoint == Icons.directions_bus_outlined.codePoint) return Icons.directions_bus_outlined;
    if (codePoint == Icons.sports_esports_outlined.codePoint) return Icons.sports_esports_outlined;
    if (codePoint == Icons.medical_services_outlined.codePoint) return Icons.medical_services_outlined;
    if (codePoint == Icons.shopping_bag_outlined.codePoint) return Icons.shopping_bag_outlined;
    if (codePoint == Icons.home_work_outlined.codePoint) return Icons.home_work_outlined;
    if (codePoint == Icons.school_outlined.codePoint) return Icons.school_outlined;
    if (codePoint == Icons.flight_takeoff_outlined.codePoint) return Icons.flight_takeoff_outlined;
    if (codePoint == Icons.savings_outlined.codePoint) return Icons.savings_outlined;
    return Icons.category_outlined;
  }

  factory BudgetItem.fromMap(Map<String, dynamic> map) {
    final bool isHardStop = map['is_hard_stop_enabled'] is bool
        ? map['is_hard_stop_enabled'] as bool
        : (map['is_hard_stop_enabled'] == 1 || map['is_hard_stop_enabled'] == true);

    final int codePoint = map['icon_code_point'] is int
        ? map['icon_code_point'] as int
        : (int.tryParse(map['icon_code_point']?.toString() ?? '') ?? 58742);

    final int colorVal = map['color_value'] is int
        ? map['color_value'] as int
        : (int.tryParse(map['color_value']?.toString() ?? '') ?? 4280391411);

    return BudgetItem(
      id: (map['id'] ?? '').toString(),
      categoryName: (map['category_name'] ?? map['categoryName'] ?? 'Category').toString(),
      icon: getIconFromCodePoint(codePoint),
      allocatedAmount: (map['allocated_amount'] ?? map['allocatedAmount'] ?? 0.0) is num
          ? (map['allocated_amount'] ?? map['allocatedAmount'] ?? 0.0).toDouble()
          : double.tryParse((map['allocated_amount'] ?? map['allocatedAmount'] ?? 0).toString()) ?? 0.0,
      spentAmount: (map['spent_amount'] ?? map['spentAmount'] ?? 0.0) is num
          ? (map['spent_amount'] ?? map['spentAmount'] ?? 0.0).toDouble()
          : double.tryParse((map['spent_amount'] ?? map['spentAmount'] ?? 0).toString()) ?? 0.0,
      softStopThreshold: (map['soft_stop_threshold'] ?? map['softStopThreshold'] ?? 0.8) is num
          ? (map['soft_stop_threshold'] ?? map['softStopThreshold'] ?? 0.8).toDouble()
          : double.tryParse((map['soft_stop_threshold'] ?? map['softStopThreshold'] ?? 0.8).toString()) ?? 0.8,
      isHardStopEnabled: isHardStop,
      color: Color(colorVal),
    );
  }

  Map<String, dynamic> toJson() => toMap();
  factory BudgetItem.fromJson(Map<String, dynamic> json) => BudgetItem.fromMap(json);
}
