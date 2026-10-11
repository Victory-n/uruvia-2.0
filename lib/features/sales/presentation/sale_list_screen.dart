import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../app/theme/app_palette.dart';
import '../../../app/theme/tokens.dart';
import '../../../core/utils/dates.dart';
import '../../../core/utils/money.dart';
import '../../../core/widgets/amount_text.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/state_views.dart';
import '../../../core/widgets/status_chip.dart';
import '../application/sales_controller.dart';
import '../domain/sale_models.dart';

class SaleListScreen extends ConsumerStatefulWidget {
  const SaleListScreen({super.key});

  @override
  ConsumerState<SaleListScreen> createState() => _SaleListScreenState();
}

class _SaleListScreenState extends ConsumerState<SaleListScreen> {
  SalePeriod _period = SalePeriod.month;

  @override
  Widget build(BuildContext context) {
    final value = ref.watch(salesProvider);
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.salesNew),
        icon: const Icon(Icons.point_of_sale_rounded),
        label: const Text('Quick sale'),
      ),
      body: AsyncView<List<Sale>>(
      value: value,
      onRetry: () => ref.invalidate(salesProvider),
      isEmpty: (l) => l.isEmpty,
      empty: EmptyState(
        icon: Icons.shopping_bag_outlined,
        title: 'No sales yet',
        message: 'Record a sale at the counter, or it is added automatically when an invoice is paid in full.',
        actionLabel: 'Record a quick sale',
        onAction: () => context.push(AppRoutes.salesNew),
      ),
      data: (all) {
        final shown = [for (final s in all) if (_period.contains(s.soldAt)) s];
        final summary = summarizeSales(shown);
        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(salesProvider);
            try {
              await ref.read(salesProvider.future);
            } catch (_) {}
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(AppSpacing.pageMargin, AppSpacing.lg, AppSpacing.pageMargin, AppSpacing.xxxl),
            children: [
              _Summary(summary: summary),
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    for (final p in SalePeriod.values)
                      Padding(
                        padding: const EdgeInsets.only(right: AppSpacing.sm),
                        child: ChoiceChip(label: Text(p.label), selected: _period == p, onSelected: (_) => setState(() => _period = p)),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              if (shown.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(AppSpacing.xxl),
                  child: Center(child: Text('No sales in this period.')),
                )
              else
                AppCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      for (var i = 0; i < shown.length; i++) ...[
                        if (i > 0) const Divider(),
                        SaleTile(sale: shown[i]),
                      ],
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    ),
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({required this.summary});
  final SalesSummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.extension<AppPalette>()!;
    final white = theme.textTheme.headlineSmall!.copyWith(color: Colors.white);
    Widget stat(String label, Widget child) => Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70)),
              const SizedBox(height: 2),
              child,
            ],
          ),
        );
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(color: palette.hero, borderRadius: BorderRadius.circular(AppRadius.card)),
      child: Row(
        children: [
          stat('Sales', AmountText(summary.totalKobo, size: AmountSize.l, showKobo: false, color: Colors.white)),
          stat('Profit', AmountText(summary.profitKobo, size: AmountSize.l, showKobo: false, color: Colors.white)),
          stat('Orders', Text('${summary.count}', style: white)),
        ],
      ),
    );
  }
}

class SaleTile extends StatelessWidget {
  const SaleTile({super.key, required this.sale});
  final Sale sale;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = sale;
    return ListTile(
      minTileHeight: 72,
      title: Text(s.customerName ?? 'Walk-in customer', maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.titleMedium),
      subtitle: Text('${s.number} · ${formatRelative(s.soldAt)}', style: theme.textTheme.bodySmall),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(formatNaira(s.totalKobo, showKobo: false), style: theme.textTheme.titleMedium),
          if (s.isReversed) const StatusChip('Reversed', tone: StatusTone.neutral),
        ],
      ),
      onTap: () => context.push(AppRoutes.saleDetail(s.id)),
    );
  }
}
