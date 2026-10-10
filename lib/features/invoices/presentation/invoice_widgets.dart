import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../app/theme/tokens.dart';
import '../../../core/utils/dates.dart';
import '../../../core/utils/money.dart';
import '../../../core/widgets/status_chip.dart';
import '../domain/invoice_models.dart';

StatusTone invoiceTone(InvoiceStatus s) => switch (s) {
      InvoiceStatus.draft => StatusTone.neutral,
      InvoiceStatus.sent => StatusTone.brand,
      InvoiceStatus.partiallyPaid => StatusTone.info,
      InvoiceStatus.paid => StatusTone.success,
      InvoiceStatus.overdue => StatusTone.error,
      InvoiceStatus.cancelled => StatusTone.neutral,
    };

class InvoiceStatusChip extends StatelessWidget {
  const InvoiceStatusChip(this.invoice, {super.key});
  final Invoice invoice;

  @override
  Widget build(BuildContext context) {
    final s = invoice.effectiveStatus();
    return StatusChip(s.label, tone: invoiceTone(s));
  }
}

/// One invoice in a list: number, customer, amount, status and due date.
class InvoiceTile extends StatelessWidget {
  const InvoiceTile({super.key, required this.invoice, this.showCustomer = true});
  final Invoice invoice;
  final bool showCustomer;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final i = invoice;
    final status = i.effectiveStatus();
    final owing = i.isOpen && i.amountPaidKobo > 0;
    return ListTile(
      minTileHeight: 72,
      title: Text(
        showCustomer ? (i.customerName ?? 'Customer') : i.number,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.titleMedium,
      ),
      subtitle: Text(
        [
          if (showCustomer) i.number,
          if (status == InvoiceStatus.paid || status == InvoiceStatus.cancelled || status == InvoiceStatus.draft)
            formatShortDate(i.issueDate)
          else
            'Due ${formatShortDate(i.dueDate)}',
          if (owing) '${formatNaira(i.balanceKobo, showKobo: false)} left',
        ].join(' · '),
        style: theme.textTheme.bodySmall,
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(formatNaira(i.totalKobo, showKobo: false), style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.xs),
          InvoiceStatusChip(i),
        ],
      ),
      onTap: () => context.push(AppRoutes.invoiceDetail(i.id)),
    );
  }
}
