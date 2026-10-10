import 'package:flutter/material.dart';

import '../../../app/theme/app_palette.dart';
import '../../../app/theme/tokens.dart';
import '../../../core/utils/dates.dart';
import '../../../core/utils/money.dart';
import '../../customers/domain/customer_models.dart';
import '../domain/invoice_models.dart';
import 'invoice_widgets.dart';

/// The invoice laid out like the paper copy, shown in the preview.
class InvoiceDocument extends StatelessWidget {
  const InvoiceDocument({super.key, required this.business, required this.invoice, required this.items, this.customer});

  final BusinessInfo business;
  final Invoice invoice;
  final List<InvoiceItem> items;
  final Customer? customer;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final soft = theme.textTheme.bodySmall?.copyWith(color: AppColors.inkSoft);
    final i = invoice;
    final vatPct = (i.vatRateBps / 100).toStringAsFixed(i.vatRateBps % 100 == 0 ? 0 : 1);

    Widget total(String label, int kobo, {bool strong = false}) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            children: [
              Expanded(child: Text(label, style: strong ? theme.textTheme.titleMedium : theme.textTheme.bodyMedium)),
              Text(
                formatNaira(kobo, showKobo: kobo % 100 != 0),
                style: strong ? theme.textTheme.titleLarge : theme.textTheme.bodyMedium,
              ),
            ],
          ),
        );

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(business.name, style: theme.textTheme.titleLarge),
                    if ((business.address ?? '').isNotEmpty) Text(business.address!, style: soft),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('INVOICE', style: theme.textTheme.labelLarge),
                  Text(i.number, style: theme.textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.xs),
                  InvoiceStatusChip(i),
                ],
              ),
            ],
          ),
          const Divider(height: AppSpacing.xxl),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Bill to', style: soft),
                    Text(customer?.name ?? i.customerName ?? 'Customer', style: theme.textTheme.titleMedium),
                    if ((customer?.phone ?? '').isNotEmpty) Text(customer!.phone!, style: theme.textTheme.bodyMedium),
                    if ((customer?.address ?? '').isNotEmpty) Text(customer!.address!, style: theme.textTheme.bodyMedium),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Issued ${formatShortDate(i.issueDate)}', style: theme.textTheme.bodyMedium),
                  Text('Due ${formatShortDate(i.dueDate)}', style: theme.textTheme.bodyMedium),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          for (final it in items) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(it.description, style: theme.textTheme.bodyLarge),
                        Text('${it.qty} × ${formatNaira(it.unitPriceKobo, showKobo: false)}', style: soft),
                      ],
                    ),
                  ),
                  Text(formatNaira(it.lineTotalKobo, showKobo: false), style: theme.textTheme.bodyLarge),
                ],
              ),
            ),
            const Divider(height: 1),
          ],
          const SizedBox(height: AppSpacing.md),
          total('Subtotal', i.subtotalKobo),
          if (i.discountKobo > 0) total('Discount', -i.discountKobo),
          if (i.vatEnabled) total('VAT ($vatPct%)', i.vatKobo),
          if (i.chargesKobo > 0) total('Other charges', i.chargesKobo),
          const Divider(height: AppSpacing.xl),
          total('Total', i.totalKobo, strong: true),
          if (i.amountPaidKobo > 0) ...[
            total('Paid', i.amountPaidKobo),
            total('Balance due', i.balanceKobo, strong: true),
          ],
          if (business.hasPaymentDetails) ...[
            const SizedBox(height: AppSpacing.lg),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(color: AppColors.neutralBg, borderRadius: BorderRadius.circular(AppRadius.control)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Pay to', style: soft),
                  if ((business.bankName ?? '').isNotEmpty) Text(business.bankName!, style: theme.textTheme.bodyMedium),
                  Text(business.accountNumber!, style: theme.textTheme.titleMedium),
                  if ((business.accountName ?? '').isNotEmpty) Text(business.accountName!, style: theme.textTheme.bodyMedium),
                ],
              ),
            ),
          ],
          if ((i.notes ?? '').isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            Text('Notes', style: soft),
            Text(i.notes!, style: theme.textTheme.bodyMedium),
          ],
          if ((i.terms ?? '').isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Text('Terms', style: soft),
            Text(i.terms!, style: theme.textTheme.bodyMedium),
          ],
        ],
      ),
    );
  }
}
