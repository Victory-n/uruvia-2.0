class BudgetOptimizationRecommendation {
  final String categoryId;
  final String categoryName;
  final double currentCap;
  final double suggestedCap;
  final double potentialMonthlySavings;
  final String targetGoalTitle;
  final int monthsSaved;

  const BudgetOptimizationRecommendation({
    required this.categoryId,
    required this.categoryName,
    required this.currentCap,
    required this.suggestedCap,
    required this.potentialMonthlySavings,
    required this.targetGoalTitle,
    required this.monthsSaved,
  });

  BudgetOptimizationRecommendation copyWith({
    String? categoryId,
    String? categoryName,
    double? currentCap,
    double? suggestedCap,
    double? potentialMonthlySavings,
    String? targetGoalTitle,
    int? monthsSaved,
  }) {
    return BudgetOptimizationRecommendation(
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      currentCap: currentCap ?? this.currentCap,
      suggestedCap: suggestedCap ?? this.suggestedCap,
      potentialMonthlySavings: potentialMonthlySavings ?? this.potentialMonthlySavings,
      targetGoalTitle: targetGoalTitle ?? this.targetGoalTitle,
      monthsSaved: monthsSaved ?? this.monthsSaved,
    );
  }
}

class OptimizerScenarioResult {
  final double totalMonthlySavings;
  final String targetGoalTitle;
  final double originalGoalRemaining;
  final int originalMonthsToGoal;
  final int acceleratedMonthsToGoal;
  final int monthsAccelerated;
  final List<BudgetOptimizationRecommendation> recommendations;

  const OptimizerScenarioResult({
    required this.totalMonthlySavings,
    required this.targetGoalTitle,
    required this.originalGoalRemaining,
    required this.originalMonthsToGoal,
    required this.acceleratedMonthsToGoal,
    required this.monthsAccelerated,
    required this.recommendations,
  });
}
