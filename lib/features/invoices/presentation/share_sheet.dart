import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../app/theme/app_palette.dart';
import '../../../app/theme/tokens.dart';
import '../../../core/errors/friendly_error.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_sheet.dart';
import '../../customers/application/customers_controller.dart';
import '../application/invoice_pdf.dart';
import '../application/invoices_controller.dart';
import '../domain/invoice_models.dart';

/// Share an invoice as a PDF or as a short message, through the phone's share sheet (WhatsApp, email and so on).
Future<void> showShareSheet(BuildContext context, Invoice invoice) {
  return showAppSheet<void>(
    context,
    title: 'Share invoice',
    builder: (_) => _ShareOptions(invoice: invoice),
  );
}

class _ShareOptions extends ConsumerStatefulWidget {
  const _ShareOptions({required this.invoice});
  final Invoice invoice;

  @override
  ConsumerState<_ShareOptions> createState() => _ShareOptionsState();
}

class _ShareOptionsState extends ConsumerState<_ShareOptions> {
  bool _busy = false;
  String? _error;

  Future<BusinessInfo> _business() async {
    final info = await ref.read(businessInfoProvider.future);
    if (info == null) throw StateError('No business details');
    return info;
  }

  Future<void> _sharePdf() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final invoice = widget.invoice;
      final business = await _business();
      final items = await ref.read(invoiceItemsProvider(invoice.id).future);
      final customer = await ref.read(customerProvider(invoice.customerId).future);
      final bytes = await buildInvoicePdf(business: business, invoice: invoice, items: items, customer: customer);
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/${invoice.number}.pdf');
      await file.writeAsBytes(bytes, flush: true);
      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'application/pdf')],
        subject: 'Invoice ${invoice.number} from ${business.name}',
        text: 'Invoice ${invoice.number} from ${business.name}',
      );
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = friendlyError(e);
        });
      }
    }
  }

  Future<void> _shareText() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final business = await _business();
      await Share.share(invoiceShareText(business: business, invoice: widget.invoice));
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = friendlyError(e);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppButton(label: 'Share as PDF', icon: Icons.picture_as_pdf_outlined, onPressed: _sharePdf, loading: _busy),
        const SizedBox(height: AppSpacing.md),
        AppButton(
          label: 'Share as a message',
          icon: Icons.chat_bubble_outline_rounded,
          style: AppButtonStyle.secondary,
          onPressed: _busy ? null : _shareText,
        ),
        if (_error != null) ...[
          const SizedBox(height: AppSpacing.md),
          Text(_error!, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: StatusColors.errorText)),
        ],
      ],
    );
  }
}
