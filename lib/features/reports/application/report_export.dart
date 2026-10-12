import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import '../domain/report_models.dart';

/// The built-in PDF font has no naira sign, so money prints as "NGN 1,500".
String _pdfText(String s) => s.replaceAll('₦', 'NGN ');

/// A4 table of one report.
Future<List<int>> buildReportPdf(ReportTable t, {required String businessName}) async {
  final doc = pw.Document(title: t.title, author: businessName);
  final bold = pw.TextStyle(fontWeight: pw.FontWeight.bold);
  final soft = pw.TextStyle(fontSize: 9, color: PdfColors.grey700);
  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(36),
      build: (_) => [
        pw.Text(_pdfText(businessName), style: soft),
        pw.SizedBox(height: 4),
        pw.Text(_pdfText(t.title), style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
        pw.Text(_pdfText(t.subtitle), style: soft),
        pw.SizedBox(height: 12),
        for (final s in t.summary)
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(vertical: 2),
            child: pw.Row(children: [
              pw.SizedBox(width: 160, child: pw.Text(_pdfText(s.$1))),
              pw.Text(_pdfText(s.$2.text), style: bold),
            ]),
          ),
        pw.SizedBox(height: 14),
        if (t.rows.isEmpty)
          pw.Text('Nothing to show for this report.', style: soft)
        else
          pw.TableHelper.fromTextArray(
            headers: t.headers,
            data: [for (final r in t.rows) [for (final c in r) _pdfText(c.text)]],
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9),
            cellStyle: const pw.TextStyle(fontSize: 9),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
            cellAlignments: {for (var i = 1; i < t.headers.length; i++) i: pw.Alignment.centerRight},
          ),
      ],
    ),
  );
  return doc.save();
}

String _fileStem(ReportTable t) => t.title.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-');

Future<void> shareReportPdf(ReportTable t, {required String businessName}) async {
  final bytes = await buildReportPdf(t, businessName: businessName);
  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/${_fileStem(t)}.pdf');
  await file.writeAsBytes(bytes, flush: true);
  await SharePlus.instance.share(ShareParams(files: [XFile(file.path, mimeType: 'application/pdf')], subject: '${t.title} - $businessName'));
}

Future<void> shareReportCsv(ReportTable t, {required String businessName}) async {
  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/${_fileStem(t)}.csv');
  // A byte-order mark makes Excel read the file as UTF-8.
  await file.writeAsBytes([0xEF, 0xBB, 0xBF, ...utf8.encode(t.toCsv())], flush: true);
  await SharePlus.instance.share(ShareParams(files: [XFile(file.path, mimeType: 'text/csv')], subject: '${t.title} - $businessName'));
}
