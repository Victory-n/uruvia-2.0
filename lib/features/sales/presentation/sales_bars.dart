import 'package:flutter/material.dart';

import '../../../app/theme/app_palette.dart';
import '../../../app/theme/tokens.dart';
import '../../../core/utils/money.dart';
import '../domain/sale_models.dart';

/// Seven small bars, one per day, with the day letter underneath. No chart package needed.
class SalesBars extends StatelessWidget {
  const SalesBars({super.key, required this.sales});
  final List<Sale> sales;

  static const _letters = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.extension<AppPalette>()!;
    final data = dailySalesTotals(sales);
    final max = data.fold<int>(0, (m, d) => d.totalKobo > m ? d.totalKobo : m);
    const barArea = 72.0;
    return Semantics(
      label: 'Sales for the last 7 days. ${[for (final d in data) formatNaira(d.totalKobo, showKobo: false)].join(', ')}',
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (final d in data)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: barArea,
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          height: max == 0 ? 3 : (barArea * d.totalKobo / max).clamp(3, barArea).toDouble(),
                          decoration: BoxDecoration(
                            color: d.totalKobo == 0 ? palette.tint : palette.action,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(_letters[d.day.weekday - 1], style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
