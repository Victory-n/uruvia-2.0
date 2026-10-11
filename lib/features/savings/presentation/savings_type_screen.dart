import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../app/theme/app_palette.dart';
import '../../../app/theme/tokens.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/sub_page.dart';
import '../../../core/widgets/status_chip.dart';
import '../domain/savings_models.dart';
import 'savings_widgets.dart';

/// Screen 25. Pick the kind of pocket.
class SavingsTypeScreen extends StatelessWidget {
  const SavingsTypeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.extension<AppPalette>()!;
    return SubPage(
      title: 'New pocket',
      fallbackRoute: AppRoutes.savings,
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.pageMargin),
        children: [
          Text('What do you want to save for?', style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.lg),
          for (final t in PocketType.values) ...[
            AppCard(
              onTap: () => context.push(AppRoutes.savingsCreate(t.db)),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: palette.tint,
                    child: Icon(pocketIcon(t), color: palette.action, size: 20),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(t.label, style: theme.textTheme.bodyLarge),
                        const SizedBox(height: AppSpacing.xs),
                        Text(t.blurb, style: theme.textTheme.bodySmall?.copyWith(color: AppColors.inkSoft)),
                        const SizedBox(height: AppSpacing.sm),
                        StatusChip(t.rateLabel, tone: t == PocketType.locked ? StatusTone.success : StatusTone.brand),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          Text('Interest is simple interest. Rates are sample values until launch.',
              style: theme.textTheme.bodySmall?.copyWith(color: AppColors.inkSoft)),
        ],
      ),
    );
  }
}
