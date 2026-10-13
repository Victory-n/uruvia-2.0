import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../core/utils/dates.dart';
import '../../invoices/application/invoice_pdf.dart' show pdfMoney;
import '../domain/sale_models.dart';

/// A small receipt (80 mm wide, like a till slip) as a PDF, built on the phone with no network.
Future<Uint8List> buildReceiptPdf({required String businessName, required Sale sale, required List<SaleItem> items}) {
  final doc = pw.Document(title: sale.number, author: businessName);
  final bold = pw.TextStyle(fontWeight: pw.FontWeight.bold);
  final soft = pw.TextStyle(fontSize: 8, color: PdfColors.grey700);
  final format = PdfPageFormat(80 * PdfPageFormat.mm, double.infinity, marginAll: 8 * PdfPageFormat.mm);

  doc.addPage(
    pw.Page(
      pageFormat: format,
      build: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Center(child: pw.Text(businessName, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 13))),
          pw.SizedBox(height: 2),
          pw.Center(child: pw.Text('RECEIPT ${sale.number}', style: soft)),
          pw.Center(child: pw.Text(formatShortDate(sale.soldAt), style: soft)),
          if (sale.customerName != null) pw.Center(child: pw.Text(sale.customerName!, style: soft)),
          pw.Divider(),
          for (final i in items) ...[
            pw.Text(i.description, style: const pw.TextStyle(fontSize: 10)),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('${i.qty} x ${pdfMoney(i.unitPriceKobo)}', style: soft),
                pw.Text(pdfMoney(i.totalKobo), style: const pw.TextStyle(fontSize: 10)),
              ],
            ),
            pw.SizedBox(height: 4),
          ],
          pw.Divider(),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [pw.Text('TOTAL', style: bold), pw.Text(pdfMoney(sale.totalKobo), style: bold)],
          ),
          pw.SizedBox(height: 8),
          pw.Center(child: pw.Text('Thank you for your purchase.', style: soft)),
        ],
      ),
    ),
  );
  return doc.save();
}
