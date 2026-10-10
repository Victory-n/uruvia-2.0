import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../app/theme/app_palette.dart';
import '../../../app/theme/tokens.dart';
import '../../../core/widgets/amount_text.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/state_views.dart';
import '../application/invoices_controller.dart';
import '../domain/invoice_models.dart';
import 'invoice_widgets.dart';

enum _Filter {
  all('All'),
  draft('Drafts'),
  unpaid('Unpaid'),
  overdue('Overdue'),
  paid('Paid');

  const _Filter(this.label);
  final String label;

  bool matches(Invoice i) {
    final s = i.effectiveStatus();
    return switch (this) {
      _Filter.all => true,
      _Filter.draft => s == InvoiceStatus.draft,
      _Filter.unpaid => i.isOpen,
      _Filter.overdue => s == InvoiceStatus.overdue,
      _Filter.paid => s == InvoiceStatus.paid,
    };
  }
}

class InvoiceListScreen extends ConsumerStatefulWidget {
  const InvoiceListScreen({super.key});

  @override
  ConsumerState<InvoiceListScreen> createState() => _InvoiceListScreenState();
}

class _InvoiceListScreenState extends ConsumerState<InvoiceListScreen> {
  _Filter _filter = _Filter.all;
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final value = ref.watch(invoicesProvider);
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.invoicesNew),
        icon: const Icon(Icons.add_rounded),
        label: const Text('New invoice'),
      ),
      body: AsyncView<List<Invoice>>(
        value: value,
        onRetry: () => ref.invalidate(invoicesProvider),
        isEmpty: (l) => l.isEmpty,
        empty: EmptyState(
          icon: Icons.description_outlined,
          title: 'No invoices yet',
          message: 'Create an invoice, send it to your customer and track who has paid.',
          actionLabel: 'Create your first invoice',
          onAction: () => context.push(AppRoutes.invoicesNew),
        ),
        data: (all) {
          final summary = summarizeInvoices(all);
          final q = _query.trim().toLowerCase();
          final shown = [
            for (final i in all)
              if (_filter.matches(i) &&
                  (q.isEmpty || i.number.toLowerCase().contains(q) || (i.customerName ?? '').toLowerCase().contains(q)))
                i,
          ];
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(invoicesProvider);
              try {
                await ref.read(invoicesProvider.future);
              } catch (_) {}
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(AppSpacing.pageMargin, AppSpacing.lg, AppSpacing.pageMargin, 96),
              children: [
                _Summary(summary: summary),
                const SizedBox(height: AppSpacing.lg),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search by customer or number',
                    prefixIcon: const Icon(Icons.search_rounded),
                    filled: true,
                    fillColor: AppColors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.control),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.control),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                  ),
                  onChanged: (v) => setState(() => _query = v),
                ),
                const SizedBox(height: AppSpacing.md),
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      for (final f in _Filter.values)
                        Padding(
                          padding: const EdgeInsets.only(right: AppSpacing.sm),
                          child: ChoiceChip(
                            label: Text(f.label),
                            selected: _filter == f,
                            onSelected: (_) => setState(() => _filter = f),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                if (shown.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(AppSpacing.xxl),
                    child: Center(child: Text('No invoices match.')),
                  )
                else
                  AppCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        for (var i = 0; i < shown.length; i++) ...[
                          if (i > 0) const Divider(),
                          InvoiceTile(invoice: shown[i]),
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
  final InvoiceSummary summary;

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
          stat('Waiting to be paid', AmountText(summary.outstandingKobo, size: AmountSize.l, showKobo: false, color: Colors.white)),
          stat('Overdue', Text('${summary.overdueCount}', style: white)),
          stat('Drafts', Text('${summary.draftCount}', style: white)),
        ],
      ),
    );
  }
}
