import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../app/theme/app_palette.dart';
import '../../../app/theme/tokens.dart';
import '../../../core/errors/friendly_error.dart';
import '../../../core/utils/dates.dart';
import '../../../core/utils/money.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/state_views.dart';
import '../../../core/widgets/sub_page.dart';
import '../../sales/application/sales_controller.dart';
import '../application/invoices_controller.dart';
import '../../account/application/active_account.dart';
import '../../account/domain/account_type.dart';
import '../domain/invoice_models.dart';
import 'invoice_widgets.dart';
import 'payment_sheet.dart';
import 'share_sheet.dart';

class InvoiceDetailScreen extends ConsumerWidget {
  const InvoiceDetailScreen({super.key, required this.invoiceId});
  final String invoiceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final value = ref.watch(invoiceProvider(invoiceId));
    final invoice = value.valueOrNull;
    return SubPage(
      title: invoice?.number ?? 'Invoice',
      fallbackRoute: AppRoutes.invoices,
      actions: [
        if (invoice != null && !invoice.isDraft && invoice.status != InvoiceStatus.cancelled)
          IconButton(
            tooltip: 'Share invoice',
            icon: const Icon(Icons.share_outlined),
            onPressed: () => showShareSheet(context, invoice),
          ),
      ],
      body: AsyncView<Invoice?>(
        value: value,
        onRetry: () => ref.invalidate(invoiceProvider(invoiceId)),
        isEmpty: (i) => i == null,
        empty: const EmptyState(icon: Icons.search_off_rounded, title: 'Invoice not found'),
        data: (i) => _Detail(invoice: i!),
      ),
    );
  }
}

class _Detail extends ConsumerStatefulWidget {
  const _Detail({required this.invoice});
  final Invoice invoice;

  @override
  ConsumerState<_Detail> createState() => _DetailState();
}

class _DetailState extends ConsumerState<_Detail> {
  bool _busy = false;

  void _toast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<bool> _confirm(String title, String body, String action) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Not now')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text(action)),
        ],
      ),
    );
    return ok == true;
  }

  Future<void> _run(Future<void> Function() job) async {
    setState(() => _busy = true);
    try {
      await job();
    } catch (e) {
      _toast(friendlyError(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _edit() async {
    final i = widget.invoice;
    if (i.isDraft) {
      context.push(AppRoutes.invoiceEdit(i.id));
      return;
    }
    final ok = await _confirm(
      'Edit this invoice?',
      'It goes back to a draft and the items set aside for it are released. Issue it again when you are done.',
      'Edit invoice',
    );
    if (!ok || !mounted) return;
    await _run(() async {
      await ref.read(invoiceActionsProvider).revertToDraft(i.id);
      if (mounted) context.push(AppRoutes.invoiceEdit(i.id));
    });
  }

  Future<void> _cancel() async {
    final i = widget.invoice;
    final ok = await _confirm(
      'Cancel this invoice?',
      i.amountPaidKobo > 0
          ? 'Payments already recorded stay in your records. Items set aside for it are released. This cannot be undone.'
          : 'Items set aside for it are released. This cannot be undone.',
      'Cancel invoice',
    );
    if (!ok) return;
    await _run(() => ref.read(invoiceActionsProvider).cancel(i.id));
  }

  Future<void> _pay() async {
    final done = await showPaymentSheet(context, widget.invoice);
    if (done == true) _toast('Payment recorded.');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.extension<AppPalette>()!;
    final i = widget.invoice;
    final items = ref.watch(invoiceItemsProvider(i.id));
    final payments = ref.watch(invoicePaymentsProvider(i.id));
    final sale = i.status == InvoiceStatus.paid && ref.watch(activeAccountProvider) == AccountType.business ? ref.watch(saleForInvoiceProvider(i.id)).valueOrNull : null;
    final vatPct = (i.vatRateBps / 100).toStringAsFixed(i.vatRateBps % 100 == 0 ? 0 : 1);

    Widget row(String label, int kobo, {bool strong = false, Color? color}) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            children: [
              Expanded(child: Text(label, style: strong ? theme.textTheme.titleMedium : theme.textTheme.bodyMedium)),
              Text(
                formatNaira(kobo, showKobo: kobo % 100 != 0),
                style: (strong ? theme.textTheme.titleLarge : theme.textTheme.bodyMedium)?.copyWith(color: color),
              ),
            ],
          ),
        );

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.pageMargin),
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => context.push(AppRoutes.customerDetail(i.customerId)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                        child: Text(i.customerName ?? 'Customer', style: theme.textTheme.titleLarge),
                      ),
                    ),
                  ),
                  InvoiceStatusChip(i),
                ],
              ),
              Text(
                'Issued ${formatShortDate(i.issueDate)} · Due ${formatShortDate(i.dueDate)}',
                style: theme.textTheme.bodySmall,
              ),
              const Divider(height: AppSpacing.xxl),
              row('Subtotal', i.subtotalKobo),
              if (i.discountKobo > 0) row('Discount', -i.discountKobo),
              if (i.vatEnabled) row('VAT ($vatPct%)', i.vatKobo),
              if (i.chargesKobo > 0) row('Other charges', i.chargesKobo),
              const Divider(height: AppSpacing.xl),
              row('Total', i.totalKobo, strong: true),
              if (!i.isDraft && i.status != InvoiceStatus.cancelled) ...[
                row('Paid', i.amountPaidKobo),
                row(
                  'Balance',
                  i.balanceKobo,
                  strong: true,
                  color: i.balanceKobo > 0 ? StatusColors.errorText : palette.action,
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        if (i.canRecordPayment) ...[
          AppButton(label: 'Record a payment', icon: Icons.payments_outlined, onPressed: _busy ? null : _pay, loading: _busy),
          const SizedBox(height: AppSpacing.md),
        ],
        if (i.isDraft) ...[
          AppButton(
            label: 'Preview and issue',
            icon: Icons.visibility_outlined,
            onPressed: _busy ? null : () => context.push(AppRoutes.invoicePreview(i.id)),
          ),
          const SizedBox(height: AppSpacing.md),
        ] else if (i.status != InvoiceStatus.cancelled) ...[
          AppButton(
            label: 'View invoice',
            icon: Icons.description_outlined,
            style: AppButtonStyle.secondary,
            onPressed: () => context.push(AppRoutes.invoicePreview(i.id)),
          ),
          const SizedBox(height: AppSpacing.md),
        ],
        if (sale != null) ...[
          AppButton(
            label: 'View sale ${sale.number}',
            icon: Icons.shopping_bag_outlined,
            style: AppButtonStyle.secondary,
            onPressed: () => context.push(AppRoutes.saleDetail(sale.id)),
          ),
          const SizedBox(height: AppSpacing.md),
        ],
        Row(
          children: [
            if (i.canEdit)
              Expanded(
                child: AppButton(label: 'Edit', style: AppButtonStyle.text, onPressed: _busy ? null : _edit),
              ),
            if (i.canCancel)
              Expanded(
                child: AppButton(label: 'Cancel invoice', style: AppButtonStyle.text, onPressed: _busy ? null : _cancel),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.sectionGap),
        Text('Items', style: theme.textTheme.titleLarge),
        const SizedBox(height: AppSpacing.sm),
        AsyncView<List<InvoiceItem>>(
          value: items,
          loading: const Padding(padding: EdgeInsets.all(AppSpacing.xl), child: Center(child: CircularProgressIndicator())),
          onRetry: () => ref.invalidate(invoiceItemsProvider(i.id)),
          data: (list) => AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (var n = 0; n < list.length; n++) ...[
                  if (n > 0) const Divider(),
                  ListTile(
                    minTileHeight: 56,
                    title: Text(list[n].description),
                    subtitle: Text('${list[n].qty} × ${formatNaira(list[n].unitPriceKobo, showKobo: false)}'),
                    trailing: Text(formatNaira(list[n].lineTotalKobo, showKobo: false), style: theme.textTheme.titleMedium),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sectionGap),
        Text('Payments', style: theme.textTheme.titleLarge),
        const SizedBox(height: AppSpacing.sm),
        AsyncView<List<InvoicePayment>>(
          value: payments,
          loading: const Padding(padding: EdgeInsets.all(AppSpacing.xl), child: Center(child: CircularProgressIndicator())),
          onRetry: () => ref.invalidate(invoicePaymentsProvider(i.id)),
          isEmpty: (l) => l.isEmpty,
          empty: Text('No payments recorded yet.', style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.inkSoft)),
          data: (list) => AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (var n = 0; n < list.length; n++) ...[
                  if (n > 0) const Divider(),
                  ListTile(
                    minTileHeight: 56,
                    title: Text(list[n].method.label),
                    subtitle: Text(
                      [formatShortDate(list[n].paidOn), if (list[n].reference != null) list[n].reference!].join(' · '),
                    ),
                    trailing: Text(formatNaira(list[n].amountKobo, showKobo: false), style: theme.textTheme.titleMedium),
                  ),
                ],
              ],
            ),
          ),
        ),
        if ((i.notes ?? '').isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sectionGap),
          Text('Notes', style: theme.textTheme.titleLarge),
          const SizedBox(height: AppSpacing.sm),
          Text(i.notes!, style: theme.textTheme.bodyMedium),
        ],
      ],
    );
  }
}
