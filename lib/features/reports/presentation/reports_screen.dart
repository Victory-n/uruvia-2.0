import 'package:flutter/material.dart';

import '../../../app/theme/app_palette.dart';
import '../../../app/theme/tokens.dart';
import '../../../core/widgets/amount_text.dart';
import '../../../core/widgets/app_card.dart';
import '../../subscription/presentation/upgrade_prompt.dart';
import '../domain/report_models.dart';

/// Screen 55. DUMMY sample report.
class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  ReportPeriod _period = ReportPeriod.thisMonth;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.extension<AppPalette>()!;
    final data = sampleReport(_period);
    final max = data.bars.fold<int>(0, (a, b) => b.salesKobo > a ? b.salesKobo : a);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.pageMargin),
          children: [
            DecoratedBox(
              decoration: BoxDecoration(color: AppColors.warningBg, borderRadius: BorderRadius.circular(AppRadius.control)),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Text('Preview: sample figures.',
                    style: theme.textTheme.bodySmall?.copyWith(color: StatusColors.warningText)),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Wrap(
              spacing: AppSpacing.sm,
              children: [
                for (final p in ReportPeriod.values)
                  ChoiceChip(label: Text(p.label), selected: _period == p, onSelected: (_) => setState(() => _period = p)),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(child: _Tile(label: 'Sales', kobo: data.salesKobo)),
                const SizedBox(width: AppSpacing.md),
                Expanded(child: _Tile(label: 'Expenses', kobo: data.expensesKobo)),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _Tile(label: 'Profit', kobo: data.profitKobo, color: data.profitKobo >= 0 ? StatusColors.success : StatusColors.errorText),
            const SizedBox(height: AppSpacing.sectionGap),
            Text('Sales and expenses', style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.md),
            AppCard(
              child: Column(
                children: [
                  SizedBox(
                    height: 140,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        for (final b in data.bars)
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                _Bar(fraction: barFraction(b.salesKobo, max), color: palette.action, label: 'Sales ${b.label}'),
                                const SizedBox(width: 4),
                                _Bar(fraction: barFraction(b.expensesKobo, max), color: AppColors.goldLight, label: 'Expenses ${b.label}'),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      for (final b in data.bars)
                        Expanded(child: Text(b.label, textAlign: TextAlign.center, style: theme.textTheme.bodySmall)),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _Legend(color: palette.action, label: 'Sales'),
                      const SizedBox(width: AppSpacing.lg),
                      const _Legend(color: AppColors.goldLight, label: 'Expenses'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sectionGap),
            Text('Top products', style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.md),
            AppCard(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Column(
                children: [
                  for (var i = 0; i < data.top.length; i++) ...[
                    if (i > 0) const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(data.top[i].name, style: theme.textTheme.bodyLarge),
                                Text('${data.top[i].unitsSold} sold',
                                    style: theme.textTheme.bodySmall?.copyWith(color: AppColors.inkSoft)),
                              ],
                            ),
                          ),
                          AmountText(data.top[i].revenueKobo, showKobo: false),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sectionGap),
            const UpgradePrompt(message: 'Pro adds PDF exports and month-by-month comparisons to your reports.'),
          ],
        ),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.label, required this.kobo, this.color});
  final String label;
  final int kobo;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.inkSoft)),
          const SizedBox(height: AppSpacing.xs),
          AmountText(kobo, size: AmountSize.l, showKobo: false, color: color),
        ],
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({required this.fraction, required this.color, required this.label});
  final double fraction;
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      child: Container(
        width: 14,
        height: 130 * fraction,
        decoration: BoxDecoration(color: color, borderRadius: const BorderRadius.vertical(top: Radius.circular(4))),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
        const SizedBox(width: AppSpacing.xs),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
