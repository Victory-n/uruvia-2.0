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
}
