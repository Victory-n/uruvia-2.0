import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_palette.dart';
import '../../../app/theme/tokens.dart';
import '../../../core/errors/friendly_error.dart';
import '../../../core/utils/dates.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/skeleton.dart';
import '../../../core/widgets/state_views.dart';
import '../../account/application/active_account.dart';
import '../../customers/domain/customer_models.dart';
import '../../customers/presentation/customer_picker.dart';
import '../application/report_export.dart';
import '../application/reports_controller.dart';
import '../domain/report_models.dart';

enum _Kind {
  profit('Profit and loss', true),
  sales('Sales', true),
  expenses('Expenses', true),
  inventory('Inventory', false),
  receivables('Receivables', false),
  statement('Customer statement', false);

  const _Kind(this.label, this.usesPeriod);
  final String label;
  final bool usesPeriod;
}

/// Screen 55. Real reports from the account's own sales, expenses, invoices and stock.
class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  _Kind _kind = _Kind.profit;
  ReportPeriod _period = ReportPeriod.thisMonth;
  Customer? _customer;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.pageMargin),
          children: [
            SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  for (final k in _Kind.values)
                    Padding(
                      padding: const EdgeInsets.only(right: AppSpacing.sm),
                      child: ChoiceChip(label: Text(k.label), selected: _kind == k, onSelected: (_) => setState(() => _kind = k)),
                    ),
                ],
              ),
            ),
            if (_kind.usesPeriod) ...[
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                children: [
                  for (final p in ReportPeriod.values)
                    ChoiceChip(label: Text(p.label), selected: _period == p, onSelected: (_) => setState(() => _period = p)),
                ],
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            _body(theme),
          ],
        ),
      ),
    );
  }

  Widget _body(ThemeData theme) {
    if (_kind == _Kind.statement) return _statement(theme);
    final value = ref.watch(reportBundleProvider(_period));
    return _loaded<ReportBundle>(
      value,
      () => ref.invalidate(reportBundleProvider(_period)),
      (b) {
        final periodText = _period.label;
        final table = switch (_kind) {
          _Kind.profit => profitAndLossTable(b.totals, periodText),
          _Kind.sales => salesTable(b.sales, periodText),
          _Kind.expenses => expensesTable(expensesByCategory(b.expenses, b.budgets, _period.months(b.now)), periodText),
          _Kind.inventory => inventoryTable(b.products, 'As of ${formatShortDate(b.now)}'),
          _Kind.receivables => receivablesTable(b.invoices, b.now, formatShortDate),
          _Kind.statement => throw StateError('handled above'),
        };
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_kind == _Kind.profit) ...[
              _Chart(bars: barsFor(_period, b.now, b.sales, b.expenses)),
              const SizedBox(height: AppSpacing.lg),
            ],
            _TableView(table: table),
            if (_kind == _Kind.sales && b.sales.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sectionGap),
              _TableView(table: salesByCustomerTable(b.sales, periodText), compact: true),
            ],
          ],
        );
      },
    );
  }

  /// Loading and error states that fit inside a scrolling page.
  Widget _loaded<T>(AsyncValue<T> value, VoidCallback retry, Widget Function(T) build) => value.when(
        data: build,
        loading: () => const SizedBox(height: 240, child: ListSkeleton()),
        error: (_, __) => SizedBox(
          height: 260,
          child: ErrorState(message: 'We could not load this report. Check your connection and try again.', onRetry: retry),
        ),
      );

  Widget _statement(ThemeData theme) {
    final palette = theme.extension<AppPalette>()!;
    final picker = AppCard(
      onTap: () async {
        final c = await showCustomerPicker(context);
        if (c != null && mounted) setState(() => _customer = c);
      },
      child: Row(
        children: [
          CircleAvatar(backgroundColor: palette.tint, child: Icon(Icons.person_outline_rounded, color: palette.action)),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: Text(_customer?.name ?? 'Choose a customer', style: theme.textTheme.bodyLarge)),
          const Icon(Icons.chevron_right_rounded),
        ],
      ),
    );
    final c = _customer;
    if (c == null) return picker;
    final value = ref.watch(statementProvider(c.id));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        picker,
        const SizedBox(height: AppSpacing.lg),
        _loaded<List<StatementLine>>(
          value,
          () => ref.invalidate(statementProvider(c.id)),
          (lines) => _TableView(table: statementTable(c.name, lines, formatShortDate)),
        ),
      ],
    );
  }
}

class _TableView extends ConsumerWidget {
  const _TableView({required this.table, this.compact = false});
  final ReportTable table;
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final businessName = ref.watch(activeAccountSummaryProvider)?.name ?? 'Uruvia';

    Future<void> export(Future<void> Function() job) async {
      try {
        await job();
      } catch (e) {
        if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(friendlyError(e))));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(table.title, style: theme.textTheme.titleLarge),
        Text(table.subtitle, style: theme.textTheme.bodySmall?.copyWith(color: AppColors.inkSoft)),
        const SizedBox(height: AppSpacing.md),
        if (table.summary.isNotEmpty)
          AppCard(
            child: Column(
              children: [
                for (final s in table.summary)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                    child: Row(
                      children: [
                        Expanded(child: Text(s.$1, style: theme.textTheme.bodyMedium)),
                        Text(s.$2.text, style: theme.textTheme.titleMedium),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        const SizedBox(height: AppSpacing.md),
        if (table.rows.isEmpty)
          Text('Nothing to show for this report yet.', style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.inkSoft))
        else
          AppCard(
            padding: EdgeInsets.zero,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 20,
                headingRowHeight: 40,
                dataRowMinHeight: 44,
                dataRowMaxHeight: 56,
                columns: [for (final h in table.headers) DataColumn(label: Text(h, style: theme.textTheme.labelLarge))],
                rows: [
                  for (final r in table.rows)
                    DataRow(cells: [for (final c in r) DataCell(Text(c.text, style: theme.textTheme.bodyMedium))]),
                ],
              ),
            ),
          ),
        if (!compact) ...[
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: 'Share PDF',
                  icon: Icons.picture_as_pdf_outlined,
                  style: AppButtonStyle.secondary,
                  onPressed: () => export(() => shareReportPdf(table, businessName: businessName)),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: AppButton(
                  label: 'Share CSV',
                  icon: Icons.table_chart_outlined,
                  style: AppButtonStyle.secondary,
                  onPressed: () => export(() => shareReportCsv(table, businessName: businessName)),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _Chart extends StatelessWidget {
  const _Chart({required this.bars});
  final List<ReportBar> bars;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.extension<AppPalette>()!;
    final max = bars.fold<int>(0, (a, b) => [a, b.salesKobo, b.expensesKobo].reduce((x, y) => x > y ? x : y));
    return AppCard(
      child: Column(
        children: [
          SizedBox(
            height: 140,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (final b in bars)
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _Bar(fraction: barFraction(b.salesKobo, max), color: palette.action, label: 'Sales ${b.label}'),
                        const SizedBox(width: 3),
                        _Bar(fraction: barFraction(b.expensesKobo, max), color: AppColors.goldLight, label: 'Expenses ${b.label}'),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(children: [for (final b in bars) Expanded(child: Text(b.label, textAlign: TextAlign.center, style: theme.textTheme.bodySmall))]),
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
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({required this.fraction, required this.color, required this.label});
  final double fraction;
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) => Semantics(
        label: label,
        child: Container(
          width: 10,
          height: 130 * fraction,
          decoration: BoxDecoration(color: color, borderRadius: const BorderRadius.vertical(top: Radius.circular(4))),
        ),
      );
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Container(width: 12, height: 12, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
          const SizedBox(width: AppSpacing.xs),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      );
}
