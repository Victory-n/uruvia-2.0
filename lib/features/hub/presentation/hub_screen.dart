import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../app/theme/app_palette.dart';
import '../../../app/theme/tokens.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/pro_badge.dart';
import '../../subscription/application/pro_status.dart';
import '../../subscription/presentation/upgrade_prompt.dart';

/// Business Hub: the Pro tools in one place. DUMMY content behind each tile.
class HubScreen extends ConsumerWidget {
  const HubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final palette = theme.extension<AppPalette>()!;
    final isPro = ref.watch(isProProvider);

    final tiles = [
      (Icons.monitor_heart_outlined, 'Business health', 'A score for how your business is doing.', AppRoutes.health, true),
      // Loan eligibility is hidden until lender terms and Play/Apple lending approvals are in place.
      (Icons.bar_chart_rounded, 'Reports', 'Sales, expenses and profit.', AppRoutes.reports, false),
      (Icons.notifications_active_outlined, 'Smart alerts', 'Low stock, overdue invoices and more.', AppRoutes.notifications, false),
    ];

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.pageMargin),
          children: [
            Row(
              children: [
                Text('Business Hub', style: theme.textTheme.titleLarge),
                const SizedBox(width: AppSpacing.sm),
                const ProBadge(),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            if (!isPro) ...[
              const UpgradePrompt(message: 'The Hub is part of Pro. You can look around with sample figures first.'),
              const SizedBox(height: AppSpacing.lg),
            ],
            for (final t in tiles) ...[
              AppCard(
                onTap: () => t.$5 ? context.push(t.$4) : context.go(t.$4),
                child: Row(
                  children: [
                    CircleAvatar(backgroundColor: palette.tint, child: Icon(t.$1, color: palette.action, size: 20)),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(t.$2, style: theme.textTheme.bodyLarge),
                          Text(t.$3, style: theme.textTheme.bodySmall?.copyWith(color: AppColors.inkSoft)),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          ],
        ),
      ),
    );
  }
}
