import 'package:flutter/material.dart';

import '../../../app/router/routes.dart';
import '../../../app/theme/app_palette.dart';
import '../../../app/theme/tokens.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../core/widgets/sub_page.dart';
import '../../subscription/presentation/upgrade_prompt.dart';
import '../domain/health_models.dart';

/// Screen 53. DUMMY business health score.
class HealthScreen extends StatelessWidget {
  const HealthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.extension<AppPalette>()!;
    final score = overallHealthScore(sampleHealthFactors);
    final band = healthBand(score);
    return SubPage(
      title: 'Business health',
      fallbackRoute: AppRoutes.hub,
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.pageMargin),
        children: [
          DecoratedBox(
            decoration: BoxDecoration(color: AppColors.warningBg, borderRadius: BorderRadius.circular(AppRadius.control)),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Text('Preview: sample figures. How the score is worked out is not final.',
                  style: theme.textTheme.bodySmall?.copyWith(color: StatusColors.warningText)),
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          Center(
            child: Semantics(
              label: 'Health score $score out of 100, ${band.label}',
              child: SizedBox(
                width: 160,
                height: 160,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox.expand(
                      child: CircularProgressIndicator(
                        value: score / 100,
                        strokeWidth: 12,
                        color: palette.action,
                        backgroundColor: palette.tint,
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('$score', style: theme.textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w700)),
                        Text('out of 100', style: theme.textTheme.bodySmall?.copyWith(color: AppColors.inkSoft)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Center(child: StatusChip(band.label, tone: band.from >= 60 ? StatusTone.success : StatusTone.warning)),
          const SizedBox(height: AppSpacing.sectionGap),
          Text('What affects your score', style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.md),
          for (final f in sampleHealthFactors) ...[
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(f.name, style: theme.textTheme.bodyLarge)),
                      Text('${f.score}', style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: f.score / 100,
                      minHeight: 8,
                      color: palette.action,
                      backgroundColor: palette.tint,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(f.tip, style: theme.textTheme.bodySmall?.copyWith(color: AppColors.inkSoft)),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          const UpgradePrompt(message: 'Pro keeps your score up to date and tells you what to fix first.'),
        ],
      ),
    );
  }
}
