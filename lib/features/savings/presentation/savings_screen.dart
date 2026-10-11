import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../app/theme/app_palette.dart';
import '../../../app/theme/tokens.dart';
import '../../../core/widgets/amount_text.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/state_views.dart';
import '../application/savings_controller.dart';
import 'savings_widgets.dart';

/// Screen 24. DUMMY.
class SavingsScreen extends ConsumerWidget {
  const SavingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final palette = theme.extension<AppPalette>()!;
    final pockets = ref.watch(savingsProvider);
    final total = pockets.fold<int>(0, (a, p) => a + p.balanceKobo);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.pageMargin),
          children: [
            const SavingsPreviewBanner(),
            const SizedBox(height: AppSpacing.lg),
            Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(color: palette.hero, borderRadius: BorderRadius.circular(AppRadius.card)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total saved', style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70)),
                  const SizedBox(height: AppSpacing.xs),
                  AmountText(total, size: AmountSize.xl, color: Colors.white),
                  const SizedBox(height: AppSpacing.xs),
                  Text('${pockets.length} ${pockets.length == 1 ? 'pocket' : 'pockets'}',
                      style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70)),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              label: 'New pocket',
              icon: Icons.add_rounded,
              onPressed: () => context.push(AppRoutes.savingsNew),
            ),
            const SizedBox(height: AppSpacing.sectionGap),
            if (pockets.isEmpty)
              const EmptyState(
                icon: Icons.savings_outlined,
                title: 'No savings yet',
                message: 'Create a pocket to start setting money aside.',
              )
            else
              for (final p in pockets) ...[
                PocketCard(pocket: p, onTap: () => context.push(AppRoutes.savingsDetail(p.id))),
                const SizedBox(height: AppSpacing.md),
              ],
          ],
        ),
      ),
    );
  }
}
