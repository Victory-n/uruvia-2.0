import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../app/theme/app_palette.dart';
import '../../../app/theme/tokens.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/pro_badge.dart';
import '../application/pro_status.dart';

/// Screen 58. A gentle upgrade card. Shows nothing for Pro accounts.
/// Use at most one per screen and never during payment, invoice or sale flows.
class UpgradePrompt extends ConsumerWidget {
  const UpgradePrompt({super.key, required this.message});
  final String message;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref.watch(isProProvider)) return const SizedBox.shrink();
    final theme = Theme.of(context);
    return AppCard(
      color: AppColors.neutralBg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ProBadge(),
          const SizedBox(height: AppSpacing.sm),
          Text(message, style: theme.textTheme.bodyMedium),
          const SizedBox(height: AppSpacing.md),
          AppButton(
            label: 'See Pro',
            style: AppButtonStyle.secondary,
            expand: false,
            onPressed: () => context.go(AppRoutes.plan),
          ),
        ],
      ),
    );
  }
}
