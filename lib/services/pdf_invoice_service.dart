import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:uruvia/screens/invoices/model/invoice_model.dart';

class PdfInvoiceService {
  /// Generates PDF document bytes for a given [Invoice]
  static Future<Uint8List> generateInvoicePdf(Invoice invoice) async {
    final pdf = pw.Document();

    final primaryBlue = PdfColor.fromInt(
      0xFF1E3A8A,
    ); // ConstantColor.blueBackground equivalent
    final lightBlue = PdfColor.fromInt(0xFFEFF6FF);
    final borderBlue = PdfColor.fromInt(0xFFDBEAFE);
    final darkText = PdfColor.fromInt(0xFF1F2937);
    final secondaryText = PdfColor.fromInt(0xFF6B7280);
    final lightBg = PdfColor.fromInt(0xFFF9FAFB);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // Business Header
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      invoice.businessName.isNotEmpty
                          ? invoice.businessName
                          : "My Business",
                      style: pw.TextStyle(
                        fontSize: 22,
                        fontWeight: pw.FontWeight.bold,
                        color: primaryBlue,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      invoice.businessEmail.isNotEmpty
                          ? invoice.businessEmail
                          : "",
                      style: const pw.TextStyle(
                        fontSize: 10,
                        color: PdfColors.grey700,
                      ),
                    ),
                    pw.Text(
                      invoice.businessPhone.isNotEmpty
                          ? invoice.businessPhone
                          : "",
                      style: const pw.TextStyle(
                        fontSize: 10,
                        color: PdfColors.grey700,
                      ),
                    ),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      "INVOICE",
                      style: pw.TextStyle(
                        fontSize: 26,
                        fontWeight: pw.FontWeight.bold,
                        color: primaryBlue,
                      ),
                    ),
                    pw.SizedBox(height: 2),
                    pw.Text(
                      invoice.invoiceNumber,
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                        color: darkText,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: pw.BoxDecoration(
                        color: invoice.status.toLowerCase() == 'paid'
                            ? PdfColor.fromInt(0xFFDCFCE7)
                            : (invoice.status.toLowerCase() == 'overdue'
                                  ? PdfColor.fromInt(0xFFFEE2E2)
                                  : PdfColor.fromInt(0xFFF3F4F6)),
                        borderRadius: pw.BorderRadius.circular(6),
                      ),
                      child: pw.Text(
                        invoice.status.toUpperCase(),
                        style: pw.TextStyle(
                          fontSize: 9,
                          fontWeight: pw.FontWeight.bold,
                          color: invoice.status.toLowerCase() == 'paid'
                              ? PdfColor.fromInt(0xFF166534)
                              : (invoice.status.toLowerCase() == 'overdue'
                                    ? PdfColor.fromInt(0xFF991B1B)
                                    : PdfColor.fromInt(0xFF374151)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 20),

            // Dates Banner Box
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: lightBlue,
                borderRadius: pw.BorderRadius.circular(8),
                border: pw.Border.all(color: borderBlue),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        "INVOICE DATE",
                        style: pw.TextStyle(
                          fontSize: 9,
                          fontWeight: pw.FontWeight.bold,
                          color: secondaryText,
                        ),
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text(
                        formatDate(invoice.invoiceDate),
                        style: pw.TextStyle(
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                          color: darkText,
                        ),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        "DUE DATE",
                        style: pw.TextStyle(
                          fontSize: 9,
                          fontWeight: pw.FontWeight.bold,
                          color: secondaryText,
                        ),
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text(
                        formatDate(invoice.dueDate),
                        style: pw.TextStyle(
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColor.fromInt(0xFFDC2626),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 16),

            // Billed To Section
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  "BILLED TO",
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                    color: secondaryText,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  invoice.customerName.isNotEmpty
                      ? invoice.customerName
                      : "Client",
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                    color: darkText,
                  ),
                ),
                if (invoice.customerEmail.isNotEmpty)
                  pw.Text(
                    invoice.customerEmail,
                    style: const pw.TextStyle(
                      fontSize: 10,
                      color: PdfColors.grey700,
                    ),
                  ),
                if (invoice.customerPhone.isNotEmpty)
                  pw.Text(
                    invoice.customerPhone,
                    style: const pw.TextStyle(
                      fontSize: 10,
                      color: PdfColors.grey700,
                    ),
                  ),
              ],
            ),
            pw.SizedBox(height: 20),

            // Items Table
            pw.TableHelper.fromTextArray(
              border: null,
              headerStyle: pw.TextStyle(
                fontSize: 10,
                fontWeight: pw.FontWeight.bold,
                color: secondaryText,
              ),
              headerDecoration: const pw.BoxDecoration(
                border: pw.Border(
                  bottom: pw.BorderSide(color: PdfColors.grey300, width: 1),
                ),
              ),
              cellHeight: 28,
              cellAlignments: {
                0: pw.Alignment.centerLeft,
                1: pw.Alignment.centerRight,
                2: pw.Alignment.centerRight,
                3: pw.Alignment.centerRight,
              },
              headers: ['DESCRIPTION', 'QTY', 'UNIT PRICE', 'TOTAL'],
              data: invoice.items.map((item) {
                return [
                  item.description,
                  '${item.quantity}',
                  'NGN ${formatCurrency(item.unitPrice)}',
                  'NGN ${formatCurrency(item.total)}',
                ];
              }).toList(),
            ),
            pw.Divider(color: PdfColors.grey300, thickness: 1),
            pw.SizedBox(height: 10),

            // Calculations Breakdown
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.end,
              children: [
                pw.SizedBox(
                  width: 200,
                  child: pw.Column(
                    children: [
                      _buildPdfSummaryRow(
                        "Subtotal",
                        "NGN ${formatCurrency(invoice.subtotal)}",
                      ),
                      if (invoice.taxRate > 0) ...[
                        pw.SizedBox(height: 4),
                        _buildPdfSummaryRow(
                          "Tax (${invoice.taxRate}%)",
                          "NGN ${formatCurrency(invoice.taxAmount)}",
                        ),
                      ],
                      if (invoice.discount > 0) ...[
                        pw.SizedBox(height: 4),
                        _buildPdfSummaryRow(
                          "Discount",
                          "- NGN ${formatCurrency(invoice.discount)}",
                          color: PdfColor.fromInt(0xFFDC2626),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 12),

            // Balance Due Box
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.end,
              children: [
                pw.Container(
                  width: 220,
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                    color: lightBlue,
                    borderRadius: pw.BorderRadius.circular(6),
                    border: pw.Border.all(color: borderBlue),
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        "Balance Due",
                        style: pw.TextStyle(
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                          color: primaryBlue,
                        ),
                      ),
                      pw.Text(
                        "NGN ${formatCurrency(invoice.total)}",
                        style: pw.TextStyle(
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                          color: primaryBlue,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 24),

            // Payment Instructions Card
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: lightBg,
                borderRadius: pw.BorderRadius.circular(8),
                border: pw.Border.all(color: PdfColors.grey300),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    "PAYMENT INSTRUCTIONS",
                    style: pw.TextStyle(
                      fontSize: 9,
                      fontWeight: pw.FontWeight.bold,
                      color: secondaryText,
                    ),
                  ),
                  pw.SizedBox(height: 6),
                  _buildPdfPaymentRow("Bank Name", invoice.bankName),
                  pw.SizedBox(height: 3),
                  _buildPdfPaymentRow("Account Number", invoice.accountNumber),
                  pw.SizedBox(height: 3),
                  _buildPdfPaymentRow("Account Name", invoice.accountName),
                ],
              ),
            ),
            pw.SizedBox(height: 24),

            // Footer
            pw.Center(
              child: pw.Text(
                "Thank you for your patronage!",
                style: pw.TextStyle(
                  fontSize: 11,
                  fontWeight: pw.FontWeight.bold,
                  color: secondaryText,
                ),
              ),
            ),
          ];
        },
      ),
    );

    return pdf.save();
  }

  /// Saves the invoice PDF file to the device's storage.
  /// Returns the saved [File].
  static Future<File> saveInvoicePdfLocally(Invoice invoice) async {
    final pdfBytes = await generateInvoicePdf(invoice);
    Directory appDocDir;

    try {
      if (Platform.isAndroid) {
        final externalDir = await getExternalStorageDirectory();
        appDocDir = externalDir ?? await getApplicationDocumentsDirectory();
      } else {
        appDocDir = await getApplicationDocumentsDirectory();
      }
    } catch (_) {
      appDocDir = await getApplicationDocumentsDirectory();
    }

    final sanitizedInvoiceNum = invoice.invoiceNumber.replaceAll(
      RegExp(r'[^\w\-]'),
      '_',
    );
    final fileName = "Invoice_$sanitizedInvoiceNum.pdf";
    final file = File("${appDocDir.path}/$fileName");
    await file.writeAsBytes(pdfBytes);
    return file;
  }

  /// Generates a temporary PDF file for sharing.
  static Future<File> getTempInvoicePdf(Invoice invoice) async {
    final pdfBytes = await generateInvoicePdf(invoice);
    final tempDir = await getTemporaryDirectory();
    final sanitizedInvoiceNum = invoice.invoiceNumber.replaceAll(
      RegExp(r'[^\w\-]'),
      '_',
    );
    final fileName = "Invoice_$sanitizedInvoiceNum.pdf";
    final file = File("${tempDir.path}/$fileName");
    await file.writeAsBytes(pdfBytes);
    return file;
  }

  /// Shares the generated PDF file along with an optional message text.
  static Future<ShareResult> shareInvoicePdf(
    Invoice invoice, {
    String? text,
  }) async {
    final file = await getTempInvoicePdf(invoice);
    final xFile = XFile(file.path);
    return Share.shareXFiles(
      [xFile],
      text: text,
      subject: 'Invoice #${invoice.invoiceNumber}',
    );
  }

  static pw.Widget _buildPdfSummaryRow(
    String label,
    String value, {
    PdfColor color = PdfColors.black,
  }) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          label,
          style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
        ),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 10,
            fontWeight: pw.FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildPdfPaymentRow(String label, String value) {
    return pw.Row(
      children: [
        pw.SizedBox(
          width: 100,
          child: pw.Text(
            label,
            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
          ),
        ),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 9,
            fontWeight: pw.FontWeight.bold,
            color: PdfColor.fromInt(0xFF1F2937),
          ),
        ),
      ],
    );
  }
}
