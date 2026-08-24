import 'dart:isolate';
import '../models/budget_item.dart';
import '../models/budget_optimizer_model.dart';

class BudgetOptimizerIsolateService {
  /// Calculate optimization recommendations and goal acceleration in a background Isolate
  static Future<OptimizerScenarioResult> calculateScenario({
    required List<BudgetItem> items,
    required String targetGoalTitle,
    required double targetGoalRemaining,
    required double currentMonthlySavingsRate,
    required Map<String, double> adjustedCaps,
  }) async {
    return Isolate.run(() {
      final List<BudgetOptimizationRecommendation> recs = [];
      double totalNewSavings = 0.0;

      for (final item in items) {
        // Evaluate non-essential categories for optimization (Choplife, Transport, Outings, etc.)
        final adjustedCap = adjustedCaps[item.id] ?? item.allocatedAmount;
        final saved = item.allocatedAmount - adjustedCap;

        if (saved > 0) {
          totalNewSavings += saved;
        }

        recs.add(
          BudgetOptimizationRecommendation(
            categoryId: item.id,
            categoryName: item.categoryName,
            currentCap: item.allocatedAmount,
            suggestedCap: adjustedCap,
            potentialMonthlySavings: saved < 0 ? 0.0 : saved,
            targetGoalTitle: targetGoalTitle,
            monthsSaved: 0, // Will be computed globally below
          ),
        );
      }

      // Calculate timeline acceleration for target goal
      final baseSavingsRate = currentMonthlySavingsRate <= 0 ? 20000.0 : currentMonthlySavingsRate;
      final originalMonths = (targetGoalRemaining / baseSavingsRate).ceil();

      final newTotalSavingsRate = baseSavingsRate + totalNewSavings;
      final newMonths = (targetGoalRemaining / newTotalSavingsRate).ceil();
      final monthsAccelerated = originalMonths - newMonths;

      final updatedRecs = recs.map((r) {
        return r.copyWith(monthsSaved: monthsAccelerated < 0 ? 0 : monthsAccelerated);
      }).toList();

      return OptimizerScenarioResult(
        totalMonthlySavings: totalNewSavings,
        targetGoalTitle: targetGoalTitle,
        originalGoalRemaining: targetGoalRemaining,
        originalMonthsToGoal: originalMonths,
        acceleratedMonthsToGoal: newMonths < 1 ? 1 : newMonths,
        monthsAccelerated: monthsAccelerated < 0 ? 0 : monthsAccelerated,
        recommendations: updatedRecs,
      );
    });
  }
}
