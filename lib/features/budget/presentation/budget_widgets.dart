import 'package:flutter/material.dart';

import '../../../app/theme/app_palette.dart';
import '../domain/budget_models.dart';

Color budgetColor(BuildContext context, BudgetState state) => switch (state) {
      BudgetState.green => Theme.of(context).extension<AppPalette>()!.action,
      BudgetState.amber => StatusColors.warning,
      BudgetState.red => StatusColors.error,
    };

/// Progress bar coloured by budget state (green, amber, red).
class BudgetBar extends StatelessWidget {
  const BudgetBar({super.key, required this.budget, this.height = 10});
  final BudgetProgress budget;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '${(budget.fraction * 100).round()} percent used',
      child: ExcludeSemantics(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: budget.fraction.clamp(0, 1).toDouble(),
            minHeight: height,
            color: budgetColor(context, budget.state),
            backgroundColor: AppColors.border,
          ),
        ),
      ),
    );
  }
}
