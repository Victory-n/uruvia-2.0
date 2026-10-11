import 'package:flutter/material.dart';

import '../../../app/router/routes.dart';
import '../../../app/theme/app_palette.dart';
import '../../../app/theme/tokens.dart';
import '../../../core/widgets/amount_text.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/sub_page.dart';
import '../domain/health_models.dart';

/// Screen 54. DUMMY loan eligibility. Lender terms are undecided, so nothing here is an offer.
class LoanScreen extends StatelessWidget {
  const LoanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.extension<AppPalette>()!;
    final allMet = sampleLoanRequirements.every((r) => r.met);
    return SubPage(
      title: 'Loan eligibility',
      fallbackRoute: AppRoutes.hub,
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.pageMargin),
        children: [
          DecoratedBox(
            decoration: BoxDecoration(color: AppColors.warningBg, borderRadius: BorderRadius.circular(AppRadius.control)),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Text('Preview: sample figures. This is not a loan offer.',
                  style: theme.textTheme.bodySmall?.copyWith(color: StatusColors.warningText)),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(color: palette.hero, borderRadius: BorderRadius.circular(AppRadius.card)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('You may qualify for', style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70)),
                const SizedBox(height: AppSpacing.xs),
                const Row(
                  children: [
                    AmountText(50000000, size: AmountSize.l, showKobo: false, color: Colors.white),
                    Text('  to  ', style: TextStyle(color: Colors.white70)),
                    AmountText(200000000, size: AmountSize.l, showKobo: false, color: Colors.white),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text('Based on your sales and health score.',
                    style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70)),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sectionGap),
          Text('Before you can apply', style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.md),
          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Column(
              children: [
                for (var i = 0; i < sampleLoanRequirements.length; i++) ...[
                  if (i > 0) const Divider(height: 1),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      sampleLoanRequirements[i].met ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                      color: sampleLoanRequirements[i].met ? StatusColors.success : AppColors.inkSoft,
                    ),
                    title: Text(sampleLoanRequirements[i].label),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          AppButton(
            label: allMet ? 'Apply' : 'Tell me when loans open',
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Loans are not open yet. We will let you know.')),
            ),
          ),
        ],
      ),
    );
  }
}
