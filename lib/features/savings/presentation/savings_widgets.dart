import 'package:flutter/material.dart';

import '../../../app/theme/app_palette.dart';
import '../../../app/theme/tokens.dart';
import '../../../core/utils/dates.dart';
import '../../../core/widgets/amount_text.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/status_chip.dart';
import '../domain/savings_models.dart';

IconData pocketIcon(PocketType t) => switch (t.iconKey) {
      SavingsIconKey.spend => Icons.shopping_bag_outlined,
      SavingsIconKey.fixed => Icons.flag_outlined,
      SavingsIconKey.locked => Icons.lock_outline_rounded,
    };

/// Row card for one pocket on the overview.
class PocketCard extends StatelessWidget {
  const PocketCard({super.key, required this.pocket, required this.onTap});
  final SavingsPocket pocket;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.extension<AppPalette>()!;
    final progress = pocket.progress;
    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: palette.tint,
                child: Icon(pocketIcon(pocket.type), color: palette.action, size: 20),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(pocket.name, style: theme.textTheme.bodyLarge, maxLines: 1, overflow: TextOverflow.ellipsis),
                    Text(pocket.type.label, style: theme.textTheme.bodySmall?.copyWith(color: AppColors.inkSoft)),
                  ],
                ),
              ),
              AmountText(pocket.balanceKobo),
            ],
          ),
          if (progress != null) ...[
            const SizedBox(height: AppSpacing.md),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                color: palette.action,
                backgroundColor: palette.tint,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text('${(progress * 100).round()}% of ${formatNairaShort(pocket.targetKobo!)}',
                style: theme.textTheme.bodySmall?.copyWith(color: AppColors.inkSoft)),
          ],
          if (pocket.type == PocketType.locked && pocket.maturesOn != null) ...[
            const SizedBox(height: AppSpacing.sm),
            StatusChip(
              pocket.isLocked() ? 'Locked until ${formatShortDate(pocket.maturesOn!)}' : 'Matured',
              tone: pocket.isLocked() ? StatusTone.info : StatusTone.success,
            ),
          ],
          if (pocket.type == PocketType.saveAsYouSpend && pocket.spendPercent != null) ...[
            const SizedBox(height: AppSpacing.sm),
            StatusChip('${pocket.spendPercent}% of each spend', tone: StatusTone.brand),
          ],
        ],
      ),
    );
  }
}

String formatNairaShort(int kobo) => AmountText(kobo, showKobo: false).formatted;

class SavingsPreviewBanner extends StatelessWidget {
  const SavingsPreviewBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(color: AppColors.warningBg, borderRadius: BorderRadius.circular(AppRadius.control)),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            const Icon(Icons.info_outline_rounded, size: 18, color: StatusColors.warningText),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                'Preview: sample figures. No real money is saved yet.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: StatusColors.warningText),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
