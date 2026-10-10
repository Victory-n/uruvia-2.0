import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../app/theme/app_palette.dart';
import '../../../app/theme/tokens.dart';
import '../../../core/utils/dates.dart';
import '../../../core/widgets/amount_text.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/status_chip.dart';
import '../domain/home_models.dart';
import 'home_widgets.dart';
import 'wallet_card.dart';

class BusinessHome extends StatelessWidget {
  const BusinessHome({super.key, required this.data});
  final HomeData data;

  @override
  Widget build(BuildContext context) {
    final s = data.summary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const WalletCard(),
        const SizedBox(height: AppSpacing.sectionGap),
        const QuickActions(actions: [
          QuickAction(Icons.description_outlined, 'New invoice', AppRoutes.invoices),
          QuickAction(Icons.point_of_sale_rounded, 'Sales', AppRoutes.sales),
          QuickAction(Icons.inventory_2_outlined, 'Inventory', AppRoutes.inventory),
          QuickAction(Icons.people_outline_rounded, 'Customers', AppRoutes.customers),
        ]),
        const SizedBox(height: AppSpacing.sectionGap),
        const SectionHeader('Your business'),
        const SizedBox(height: AppSpacing.sm),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: AppSpacing.md,
          mainAxisSpacing: AppSpacing.md,
          childAspectRatio: 1.45,
          children: [
            StatTile(
              label: 'Sales today',
              value: AmountText(s.salesTodayKobo, size: AmountSize.l, showKobo: false),
              note: 'This month: ${_short(s.salesMonthKobo)}',
              onTap: () => context.go(AppRoutes.sales),
            ),
            StatTile(
              label: 'Owed to you',
              value: AmountText(s.outstandingKobo, size: AmountSize.l, showKobo: false),
              note: s.overdueCount > 0 ? '${s.overdueCount} overdue' : 'Nothing overdue',
              noteColor: s.overdueCount > 0 ? StatusColors.errorText : StatusColors.success,
              onTap: () => context.go(AppRoutes.invoices),
            ),
            StatTile(
              label: 'Low stock',
              value: Text('${s.lowStockCount}', style: _big(context)),
              note: s.lowStockCount == 0 ? 'All stocked up' : 'Items to reorder',
              noteColor: s.lowStockCount > 0 ? StatusColors.warningText : StatusColors.success,
              onTap: () => context.go(AppRoutes.inventory),
            ),
            StatTile(
              label: 'Spent this month',
              value: AmountText(s.spentThisMonthKobo, size: AmountSize.l, showKobo: false),
              note: 'Business expenses',
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sectionGap),
        SectionHeader('Recent invoices', actionLabel: 'See all', onAction: () => context.go(AppRoutes.invoices)),
        const SizedBox(height: AppSpacing.sm),
        if (data.recentInvoices.isEmpty)
          InlineEmpty(
            icon: Icons.description_outlined,
            title: 'No invoices yet',
            message: 'Create your first invoice and share it on WhatsApp.',
            actionLabel: 'New invoice',
            onAction: () => context.go(AppRoutes.invoices),
          )
        else
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (var i = 0; i < data.recentInvoices.length; i++) ...[
                  if (i > 0) const Divider(),
                  _InvoiceRow(invoice: data.recentInvoices[i]),
                ],
              ],
            ),
          ),
      ],
    );
  }

  static TextStyle _big(BuildContext context) => Theme.of(context).textTheme.headlineSmall!;

  static String _short(int kobo) => AmountText(kobo, showKobo: false).formatted;
}

class _InvoiceRow extends StatelessWidget {
  const _InvoiceRow({required this.invoice});
  final RecentInvoice invoice;

  static (String, StatusTone) _chip(String status) => switch (status) {
        'paid' => ('Paid', StatusTone.success),
        'partially_paid' => ('Part paid', StatusTone.info),
        'overdue' => ('Overdue', StatusTone.error),
        'sent' => ('Sent', StatusTone.brand),
        'draft' => ('Draft', StatusTone.neutral),
        _ => (status, StatusTone.neutral),
      };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (label, tone) = _chip(invoice.effectiveStatus());
    final due = invoice.dueDate;
    return ListTile(
      minTileHeight: 64,
      title: Text(
        invoice.customerName ?? invoice.number,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.titleMedium,
      ),
      subtitle: Text(
        [invoice.number, if (due != null) 'Due ${formatShortDate(due)}'].join(' · '),
        style: theme.textTheme.bodySmall,
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          AmountText(invoice.totalKobo),
          const SizedBox(height: 2),
          StatusChip(label, tone: tone),
        ],
      ),
    );
  }
}
