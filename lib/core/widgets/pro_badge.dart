import 'package:flutter/material.dart';

import '../../app/theme/app_palette.dart';
import '../../app/theme/tokens.dart';

/// Gold pill with a crown, shown beside Pro features and on the profile of subscribers.
class ProBadge extends StatelessWidget {
  const ProBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Pro',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [AppColors.goldDark, AppColors.goldLight]),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.workspace_premium_rounded, size: 14, color: AppColors.ink),
            const SizedBox(width: 2),
            Text(
              'Pro',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.ink,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
