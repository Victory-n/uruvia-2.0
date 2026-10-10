import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../core/utils/dates.dart';
import '../../../core/utils/money.dart';
import '../../customers/domain/customer_models.dart';
import '../domain/invoice_models.dart';

/// The built-in PDF font has no naira sign, so amounts print as "NGN 1,500.00".
String pdfMoney(int kobo) => formatNaira(kobo).replaceFirst('₦', 'NGN ');

/// Builds an A4 invoice on the phone, ready to share. No network needed.
Future<Uint8List> buildInvoicePdf({
  required BusinessInfo business,
  required Invoice invoice,
  required List<InvoiceItem> items,
  Customer? customer,
}) {
  final doc = pw.Document(title: invoice.number, author: business.name);

  final bold = pw.TextStyle(fontWeight: pw.FontWeight.bold);
  final soft = pw.TextStyle(fontSize: 9, color: PdfColors.grey700);

  pw.Widget cell(String text, {pw.TextAlign align = pw.TextAlign.left, bool head = false}) => pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        child: pw.Text(
          text,
          textAlign: align,
          style: head ? pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9, color: PdfColors.grey800) : const pw.TextStyle(fontSize: 10),
        ),
      );

  pw.Widget totalRow(String label, String value, {bool strong = false}) => pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 2),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.end,
          children: [
            pw.SizedBox(width: 120, child: pw.Text(label, style: strong ? bold : null)),
            pw.SizedBox(width: 110, child: pw.Text(value, textAlign: pw.TextAlign.right, style: strong ? bold : null)),
          ],
        ),
      );

  final status = invoice.effectiveStatus();

  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(36),
      build: (context) => [
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(business.name, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16)),
                  if ((business.address ?? '').isNotEmpty) pw.Text(business.address!, style: soft),
                ],
              ),
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text('INVOICE', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 18)),
                pw.Text(invoice.number),
                pw.Text(status.label.toUpperCase(), style: soft),
              ],
            ),
          ],
        ),
        pw.SizedBox(height: 20),
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('BILL TO', style: soft),
                  pw.Text(customer?.name ?? invoice.customerName ?? 'Customer', style: bold),
                  if ((customer?.phone ?? '').isNotEmpty) pw.Text(customer!.phone!),
                  if ((customer?.email ?? '').isNotEmpty) pw.Text(customer!.email!),
                  if ((customer?.address ?? '').isNotEmpty) pw.Text(customer!.address!),
                ],
              ),
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text('Issued: ${formatShortDate(invoice.issueDate)}'),
                pw.Text('Due: ${formatShortDate(invoice.dueDate)}'),
              ],
            ),
          ],
        ),
        pw.SizedBox(height: 20),
        pw.Table(
          columnWidths: const {
            0: pw.FlexColumnWidth(5),
            1: pw.FixedColumnWidth(36),
            2: pw.FlexColumnWidth(2),
            3: pw.FlexColumnWidth(2),
          },
          border: const pw.TableBorder(horizontalInside: pw.BorderSide(width: 0.4, color: PdfColors.grey400)),
          children: [
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.grey200),
              children: [
                cell('Item', head: true),
                cell('Qty', head: true, align: pw.TextAlign.right),
                cell('Price', head: true, align: pw.TextAlign.right),
                cell('Amount', head: true, align: pw.TextAlign.right),
              ],
            ),
            for (final i in items)
              pw.TableRow(
                children: [
                  cell(i.description),
                  cell('${i.qty}', align: pw.TextAlign.right),
                  cell(pdfMoney(i.unitPriceKobo), align: pw.TextAlign.right),
                  cell(pdfMoney(i.lineTotalKobo), align: pw.TextAlign.right),
                ],
              ),
          ],
        ),
        pw.SizedBox(height: 12),
        totalRow('Subtotal', pdfMoney(invoice.subtotalKobo)),
        if (invoice.discountKobo > 0) totalRow('Discount', '-${pdfMoney(invoice.discountKobo)}'),
        if (invoice.vatEnabled) totalRow('VAT (${(invoice.vatRateBps / 100).toStringAsFixed(invoice.vatRateBps % 100 == 0 ? 0 : 1)}%)', pdfMoney(invoice.vatKobo)),
        if (invoice.chargesKobo > 0) totalRow('Other charges', pdfMoney(invoice.chargesKobo)),
        pw.Divider(thickness: 0.5),
        totalRow('Total', pdfMoney(invoice.totalKobo), strong: true),
        if (invoice.amountPaidKobo > 0) totalRow('Paid', pdfMoney(invoice.amountPaidKobo)),
        if (invoice.amountPaidKobo > 0) totalRow('Balance due', pdfMoney(invoice.balanceKobo), strong: true),
        pw.SizedBox(height: 20),
        if (business.hasPaymentDetails)
          pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(border: pw.Border.all(width: 0.5, color: PdfColors.grey500)),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('PAY TO', style: soft),
                if ((business.bankName ?? '').isNotEmpty) pw.Text(business.bankName!),
                pw.Text(business.accountNumber!, style: bold),
                if ((business.accountName ?? '').isNotEmpty) pw.Text(business.accountName!),
              ],
            ),
          ),
        if ((invoice.notes ?? '').isNotEmpty) ...[
          pw.SizedBox(height: 14),
          pw.Text('NOTES', style: soft),
          pw.Text(invoice.notes!),
        ],
        if ((invoice.terms ?? '').isNotEmpty) ...[
          pw.SizedBox(height: 10),
          pw.Text('TERMS', style: soft),
          pw.Text(invoice.terms!),
        ],
      ],
    ),
  );

  return doc.save();
}

/// A short text version for sharing in a chat.
String invoiceShareText({required BusinessInfo business, required Invoice invoice}) {
  final b = StringBuffer()
    ..writeln('Invoice ${invoice.number} from ${business.name}')
    ..writeln('Total: ${pdfMoney(invoice.totalKobo)}');
  if (invoice.amountPaidKobo > 0) b.writeln('Balance due: ${pdfMoney(invoice.balanceKobo)}');
  b.writeln('Due: ${formatShortDate(invoice.dueDate)}');
  if (business.hasPaymentDetails) {
    b
      ..writeln()
      ..writeln('Pay to:')
      ..writeln([if ((business.bankName ?? '').isNotEmpty) business.bankName!, business.accountNumber!].join(' - '));
    if ((business.accountName ?? '').isNotEmpty) b.writeln(business.accountName!);
  }
  return b.toString().trim();
}
