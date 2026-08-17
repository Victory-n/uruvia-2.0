import 'dart:async';
import 'package:flutter/foundation.dart';

class SavingsCalculationInput {
  final double income;
  final double targetAmount;
  final int durationMonths;
  final bool isBusiness;

  const SavingsCalculationInput({
    required this.income,
    required this.targetAmount,
    required this.durationMonths,
    this.isBusiness = false,
  });
}

class SavingsCalculationResult {
  final double dailyTarget;
  final double weeklyTarget;
  final double biWeeklyTarget;
  final double monthlyTarget;
  final double incomeRatioPercentage;
  final String feasibilityStatus; // 'Comfortable', 'Moderate', 'Aggressive'
  final List<String> impulseCutDownSuggestions;
  final Map<String, double> budgetAllocation;

  const SavingsCalculationResult({
    required this.dailyTarget,
    required this.weeklyTarget,
    required this.biWeeklyTarget,
    required this.monthlyTarget,
    required this.incomeRatioPercentage,
    required this.feasibilityStatus,
    required this.impulseCutDownSuggestions,
    required this.budgetAllocation,
  });
}

class SavingsCalculatorIsolateService {
  /// Offloads the savings mathematical calculations to a background Isolate
  /// to ensure the main UI thread remains smooth at 60/120 FPS.
  static Future<SavingsCalculationResult> calculate(SavingsCalculationInput input) async {
    return compute(_performCalculation, input);
  }

  /// Top-level or static function executed inside the background Isolate
  static SavingsCalculationResult _performCalculation(SavingsCalculationInput input) {
    final double income = input.income <= 0 ? 1.0 : input.income;
    final double target = input.targetAmount <= 0 ? 0.0 : input.targetAmount;
    final int months = input.durationMonths <= 0 ? 1 : input.durationMonths;

    final double totalDays = months * 30.4375;
    final double totalWeeks = months * 4.3482;
    final double totalBiWeeks = totalWeeks / 2.0;

    final double monthlyTarget = target / months;
    final double biWeeklyTarget = target / totalBiWeeks;
    final double weeklyTarget = target / totalWeeks;
    final double dailyTarget = target / totalDays;

    final double ratio = (monthlyTarget / income) * 100.0;

    String feasibility;
    if (ratio <= 20.0) {
      feasibility = 'Comfortable';
    } else if (ratio <= 45.0) {
      feasibility = 'Moderate';
    } else {
      feasibility = 'Aggressive';
    }

    final List<String> suggestions = input.isBusiness
        ? const [
            "Reduce non-essential SaaS subscriptions by 15%",
            "Defer non-urgent office equipment purchases",
            "Optimize utility & vendor recurring expenses",
          ]
        : const [
            "Reduce dining out & weekend delivery by ₦15,000/mo",
            "Pause unstreamed entertainment subscriptions",
            "Set daily impulse purchase caps on shopping apps",
          ];

    final Map<String, double> budget = {
      'Essential Needs': income * 0.50,
      'Wants & Lifestyle': income * 0.30,
      'Goal Savings': monthlyTarget,
      'Remaining Buffer': (income * 0.20) - monthlyTarget < 0 ? 0 : (income * 0.20) - monthlyTarget,
    };

    return SavingsCalculationResult(
      dailyTarget: dailyTarget,
      weeklyTarget: weeklyTarget,
      biWeeklyTarget: biWeeklyTarget,
      monthlyTarget: monthlyTarget,
      incomeRatioPercentage: ratio,
      feasibilityStatus: feasibility,
      impulseCutDownSuggestions: suggestions,
      budgetAllocation: budget,
    );
  }
}
