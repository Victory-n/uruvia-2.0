import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:uruvia/features/customers/domain/customer_models.dart';
import 'package:uruvia/features/invoices/application/invoice_pdf.dart';
import 'package:uruvia/features/invoices/domain/invoice_models.dart';

Invoice inv({
  InvoiceStatus status = InvoiceStatus.sent,
  DateTime? due,
  int total = 10000,
  int paid = 0,
}) =>
    Invoice(
      id: 'i1',
      number: 'INV-00001',
      status: status,
      customerId: 'c1',
      customerName: 'Ada Stores',
      issueDate: DateTime(2026, 10, 1),
      dueDate: due ?? DateTime(2026, 10, 15),
      discountKobo: 0,
      vatEnabled: false,
      chargesKobo: 0,
      vatRateBps: 750,
      subtotalKobo: total,
      vatKobo: 0,
      totalKobo: total,
      amountPaidKobo: paid,
    );

void main() {
  group('InvoiceTotals', () {
    const items = [
      InvoiceItem(description: 'Rice', qty: 2, unitPriceKobo: 50000),
      InvoiceItem(description: 'Delivery', qty: 1, unitPriceKobo: 25000),
    ];

    test('sums lines and adds VAT after the discount', () {
      final t = InvoiceTotals.compute(items: items, discountKobo: 25000, vatEnabled: true, vatRateBps: 750, chargesKobo: 10000);
      expect(t.subtotalKobo, 125000);
      expect(t.baseKobo, 100000);
      expect(t.vatKobo, 7500);
      expect(t.totalKobo, 117500);
    });

    test('no VAT when switched off', () {
      final t = InvoiceTotals.compute(items: items, discountKobo: 0, vatEnabled: false, vatRateBps: 750, chargesKobo: 0);
      expect(t.vatKobo, 0);
      expect(t.totalKobo, 125000);
    });

    test('a discount above the subtotal never makes the total negative', () {
      final t = InvoiceTotals.compute(items: items, discountKobo: 999999, vatEnabled: true, vatRateBps: 750, chargesKobo: 0);
      expect(t.baseKobo, 0);
      expect(t.totalKobo, 0);
    });

    test('VAT rounds half up like the database', () {
      // 50 kobo base at 7.5% = 3.75 -> 4
      final t = InvoiceTotals.compute(
        items: const [InvoiceItem(description: 'x', qty: 1, unitPriceKobo: 50)],
        discountKobo: 0,
        vatEnabled: true,
        vatRateBps: 750,
        chargesKobo: 0,
      );
      expect(t.vatKobo, 4);
    });
  });

  group('Invoice', () {
    final today = DateTime(2026, 10, 20);

    test('unpaid and past due reads overdue', () {
      expect(inv().effectiveStatus(today: today), InvoiceStatus.overdue);
      expect(inv(status: InvoiceStatus.partiallyPaid, paid: 100).effectiveStatus(today: today), InvoiceStatus.overdue);
    });

    test('due today is not overdue yet; paid and draft never are', () {
      expect(inv(due: DateTime(2026, 10, 20)).effectiveStatus(today: today), InvoiceStatus.sent);
      expect(inv(status: InvoiceStatus.paid, paid: 10000).effectiveStatus(today: today), InvoiceStatus.paid);
      expect(inv(status: InvoiceStatus.draft).effectiveStatus(today: today), InvoiceStatus.draft);
    });

    test('what can be done', () {
      expect(inv(status: InvoiceStatus.draft).canEdit, true);
      expect(inv().canEdit, true);
      expect(inv(status: InvoiceStatus.partiallyPaid, paid: 100).canEdit, false);
      expect(inv(status: InvoiceStatus.paid, paid: 10000).canCancel, false);
      expect(inv(status: InvoiceStatus.cancelled).canCancel, false);
      expect(inv().canRecordPayment, true);
      expect(inv(status: InvoiceStatus.paid, paid: 10000).canRecordPayment, false);
    });

    test('summary counts only open balances', () {
      final list = [
        inv(total: 10000, paid: 2500, status: InvoiceStatus.partiallyPaid),
        inv(total: 5000),
        inv(status: InvoiceStatus.paid, total: 9000, paid: 9000),
        inv(status: InvoiceStatus.draft, total: 4000),
      ];
      final s = summarizeInvoices(list, today: DateTime(2026, 10, 10));
      expect(s.outstandingKobo, 12500);
      expect(s.overdueCount, 0);
      expect(s.draftCount, 1);
      expect(summarizeInvoices(list, today: DateTime(2026, 11, 1)).overdueCount, 2);
    });
  });

  test('isoDate pads', () {
    expect(isoDate(DateTime(2026, 3, 7)), '2026-03-07');
  });

  test('status and payment method parse', () {
    expect(InvoiceStatus.parse('partially_paid'), InvoiceStatus.partiallyPaid);
    expect(PaymentMethod.parse('pos'), PaymentMethod.pos);
  });

  group('pdf', () {
    test('money prints as NGN', () {
      expect(pdfMoney(150000), 'NGN 1,500.00');
    });

    test('builds a PDF document', () async {
      const business = BusinessInfo(name: 'Ada Stores', vatRateBps: 750, accountNumber: '0123456789', bankName: 'Test Bank');
      final bytes = await buildInvoicePdf(
        business: business,
        invoice: inv(),
        items: const [InvoiceItem(description: 'Rice 50kg', qty: 2, unitPriceKobo: 5000)],
        customer: const Customer(id: 'c1', name: 'Ada Stores'),
      );
      expect(String.fromCharCodes(bytes.take(4)), '%PDF');
    });

    test('an unreadable logo is skipped instead of failing the invoice', () async {
      const business = BusinessInfo(name: 'Ada Stores', vatRateBps: 750);
      final bytes = await buildInvoicePdf(
        business: business,
        invoice: inv(),
        items: const [InvoiceItem(description: 'Rice 50kg', qty: 2, unitPriceKobo: 5000)],
        logoBytes: Uint8List.fromList([1, 2, 3, 4]),
      );
      expect(String.fromCharCodes(bytes.take(4)), '%PDF');
    });

    test('share text includes pay-to details', () {
      const business = BusinessInfo(name: 'Ada Stores', vatRateBps: 750, accountNumber: '0123456789', bankName: 'Test Bank');
      final text = invoiceShareText(business: business, invoice: inv());
      expect(text, contains('INV-00001'));
      expect(text, contains('0123456789'));
    });
  });

  group('quickPaymentAmounts', () {
    test('offers a quarter, a half and the full balance', () {
      expect(quickPaymentAmounts(100000), [25000, 50000, 100000]);
    });
    test('drops repeats and zero amounts', () {
      expect(quickPaymentAmounts(100), [100]);
      expect(quickPaymentAmounts(0), isEmpty);
    });
    test('keeps amounts in whole naira', () {
      expect(quickPaymentAmounts(100050).every((k) => k == 100050 || k % 100 == 0), isTrue);
    });
  });

  group('invoiceReminderText', () {
    const business = BusinessInfo(name: 'Ada Stores', vatRateBps: 0, accountNumber: '0123456789', bankName: 'Test Bank');
    test('says overdue once the due date has passed', () {
      final text = invoiceReminderText(business: business, invoice: inv(), customerName: 'Chidi', now: DateTime(2030, 1, 1));
      expect(text, startsWith('Hello Chidi,'));
      expect(text, contains('was due on'));
      expect(text, contains('0123456789'));
    });
    test('says due on before the due date', () {
      final text = invoiceReminderText(business: business, invoice: inv(), now: DateTime(2000, 1, 1));
      expect(text, startsWith('Hello,'));
      expect(text, contains('is due on'));
    });
  });
}
