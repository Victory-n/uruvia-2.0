import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../app/theme/tokens.dart';
import '../../../core/errors/friendly_error.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/state_views.dart';
import '../../../core/widgets/sub_page.dart';
import '../../customers/application/customers_controller.dart';
import '../application/invoices_controller.dart';
import '../domain/invoice_models.dart';
import 'invoice_document.dart';
import 'share_sheet.dart';

/// Shows the invoice as the customer will see it. A draft can be issued from here.
class InvoicePreviewScreen extends ConsumerStatefulWidget {
  const InvoicePreviewScreen({super.key, required this.invoiceId});
  final String invoiceId;

  @override
  ConsumerState<InvoicePreviewScreen> createState() => _InvoicePreviewScreenState();
}

class _InvoicePreviewScreenState extends ConsumerState<InvoicePreviewScreen> {
  bool _issuing = false;

  Future<void> _issue(Invoice invoice) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Issue this invoice?'),
        content: const Text(
          'The items are set aside for this customer so they cannot be sold twice. '
          'You can still edit the invoice until a payment is recorded.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Not yet')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Issue invoice')),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    setState(() => _issuing = true);
    try {
      await ref.read(invoiceActionsProvider).issue(invoice.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invoice issued. You can share it now.')));
      context.pushReplacement(AppRoutes.invoiceDetail(invoice.id));
    } catch (e) {
      if (mounted) {
        setState(() => _issuing = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(friendlyError(e))));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final id = widget.invoiceId;
    final invoice = ref.watch(invoiceProvider(id));
    final items = ref.watch(invoiceItemsProvider(id));
    final business = ref.watch(businessInfoProvider);
    final inv = invoice.valueOrNull;
    final customer = inv == null ? null : ref.watch(customerProvider(inv.customerId)).valueOrNull;

    final itemList = items.valueOrNull;
    final info = business.valueOrNull;

    Widget content;
    if (invoice.hasError || items.hasError || business.hasError) {
      content = ErrorState(onRetry: () {
        ref.invalidate(invoiceProvider(id));
        ref.invalidate(invoiceItemsProvider(id));
        ref.invalidate(businessInfoProvider);
      });
    } else if (invoice.hasValue && inv == null) {
      content = const EmptyState(icon: Icons.search_off_rounded, title: 'Invoice not found');
    } else if (inv == null || itemList == null || info == null) {
      content = const Center(child: CircularProgressIndicator());
    } else {
      content = ListView(
        padding: const EdgeInsets.all(AppSpacing.pageMargin),
        children: [
          InvoiceDocument(business: info, invoice: inv, items: itemList, customer: customer),
          const SizedBox(height: AppSpacing.xxl),
          if (inv.isDraft) ...[
            AppButton(label: 'Issue invoice', onPressed: () => _issue(inv), loading: _issuing),
            const SizedBox(height: AppSpacing.md),
            AppButton(
              label: 'Edit',
              style: AppButtonStyle.secondary,
              onPressed: _issuing ? null : () => context.push(AppRoutes.invoiceEdit(inv.id)),
            ),
          ] else
            AppButton(label: 'Share invoice', icon: Icons.share_outlined, onPressed: () => showShareSheet(context, inv)),
        ],
      );
    }

    return SubPage(title: 'Preview', fallbackRoute: AppRoutes.invoices, body: content);
  }
}
