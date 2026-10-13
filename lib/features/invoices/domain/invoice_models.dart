enum InvoiceStatus {
  draft('draft', 'Draft'),
  sent('sent', 'Sent'),
  partiallyPaid('partially_paid', 'Partially paid'),
  paid('paid', 'Paid'),
  overdue('overdue', 'Overdue'),
  cancelled('cancelled', 'Cancelled');

  const InvoiceStatus(this.db, this.label);
  final String db;
  final String label;

  static InvoiceStatus parse(String v) =>
      InvoiceStatus.values.firstWhere((s) => s.db == v, orElse: () => InvoiceStatus.draft);
}

/// Ways a payment can be recorded by hand. Wallet payments come with the wallet module.
enum PaymentMethod {
  transfer('transfer', 'Bank transfer'),
  cash('cash', 'Cash'),
  pos('pos', 'POS'),
  card('card', 'Card');

  const PaymentMethod(this.db, this.label);
  final String db;
  final String label;

  static PaymentMethod parse(String v) =>
      PaymentMethod.values.firstWhere((m) => m.db == v, orElse: () => PaymentMethod.transfer);
}

/// "2026-10-10" for a date column.
String isoDate(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

class InvoiceItem {
  const InvoiceItem({
    required this.description,
    required this.qty,
    required this.unitPriceKobo,
    this.productId,
  });

  /// Null for a custom line such as a service.
  final String? productId;
  final String description;
  final int qty;
  final int unitPriceKobo;

  int get lineTotalKobo => qty * unitPriceKobo;

  InvoiceItem copyWith({String? description, int? qty, int? unitPriceKobo}) => InvoiceItem(
        productId: productId,
        description: description ?? this.description,
        qty: qty ?? this.qty,
        unitPriceKobo: unitPriceKobo ?? this.unitPriceKobo,
      );

  Map<String, dynamic> toJson() => {
        'product_id': productId,
        'description': description,
        'qty': qty,
        'unit_price_kobo': unitPriceKobo,
      };

  factory InvoiceItem.fromRow(Map<String, dynamic> r) => InvoiceItem(
        productId: r['product_id'] as String?,
        description: r['description'] as String,
        qty: (r['qty'] as num).toInt(),
        unitPriceKobo: (r['unit_price_kobo'] as num).toInt(),
      );
}

/// The same arithmetic the database runs, used to show totals while the user types.
class InvoiceTotals {
  const InvoiceTotals({required this.subtotalKobo, required this.discountKobo, required this.vatKobo, required this.chargesKobo});

  final int subtotalKobo;
  final int discountKobo;
  final int vatKobo;
  final int chargesKobo;

  int get baseKobo => subtotalKobo > discountKobo ? subtotalKobo - discountKobo : 0;
  int get totalKobo => baseKobo + vatKobo + chargesKobo;

  factory InvoiceTotals.compute({
    required List<InvoiceItem> items,
    required int discountKobo,
    required bool vatEnabled,
    required int vatRateBps,
    required int chargesKobo,
  }) {
    final subtotal = items.fold<int>(0, (s, i) => s + i.lineTotalKobo);
    final base = subtotal > discountKobo ? subtotal - discountKobo : 0;
    // Same rounding as the database: half rounds up.
    final vat = vatEnabled ? (base * vatRateBps + 5000) ~/ 10000 : 0;
    return InvoiceTotals(subtotalKobo: subtotal, discountKobo: discountKobo, vatKobo: vat, chargesKobo: chargesKobo);
  }
}

class Invoice {
  const Invoice({
    required this.id,
    required this.number,
    required this.status,
    required this.customerId,
    required this.issueDate,
    required this.dueDate,
    required this.discountKobo,
    required this.vatEnabled,
    required this.chargesKobo,
    required this.vatRateBps,
    required this.subtotalKobo,
    required this.vatKobo,
    required this.totalKobo,
    required this.amountPaidKobo,
    this.customerName,
    this.notes,
    this.terms,
    this.createdAt,
    this.issuedAt,
    this.paidAt,
    this.cancelledAt,
    this.revisedAt,
  });

  final DateTime? createdAt;
  final DateTime? issuedAt;
  final DateTime? paidAt;
  final DateTime? cancelledAt;
  final DateTime? revisedAt;

  final String id;
  final String number;
  final InvoiceStatus status;
  final String customerId;
  final String? customerName;
  final DateTime issueDate;
  final DateTime dueDate;
  final int discountKobo;
  final bool vatEnabled;
  final int chargesKobo;
  final String? notes;
  final String? terms;
  final int vatRateBps;
  final int subtotalKobo;
  final int vatKobo;
  final int totalKobo;
  final int amountPaidKobo;

  int get balanceKobo => totalKobo - amountPaidKobo;

  /// The status to show: an unpaid invoice past its due date reads Overdue even before the nightly job marks it.
  InvoiceStatus effectiveStatus({DateTime? today}) {
    final t = dateOnly(today ?? DateTime.now());
    if ((status == InvoiceStatus.sent || status == InvoiceStatus.partiallyPaid) && dueDate.isBefore(t)) {
      return InvoiceStatus.overdue;
    }
    return status;
  }

  bool get isDraft => status == InvoiceStatus.draft;
  bool get isOpen => status == InvoiceStatus.sent || status == InvoiceStatus.partiallyPaid || status == InvoiceStatus.overdue;
  bool get canRecordPayment => isOpen && balanceKobo > 0;

  /// Draft, or issued with no payment yet (reopening it releases the reserved stock).
  bool get canEdit => isDraft || ((status == InvoiceStatus.sent || status == InvoiceStatus.overdue) && amountPaidKobo == 0);
  bool get canCancel => status != InvoiceStatus.paid && status != InvoiceStatus.cancelled;

  factory Invoice.fromRow(Map<String, dynamic> r, {String? customerName}) => Invoice(
        id: r['id'] as String,
        number: r['invoice_number'] as String,
        status: InvoiceStatus.parse(r['status'] as String),
        customerId: r['customer_id'] as String,
        customerName: customerName,
        issueDate: DateTime.parse(r['issue_date'] as String),
        dueDate: DateTime.parse(r['due_date'] as String),
        discountKobo: (r['discount_kobo'] as num).toInt(),
        vatEnabled: r['vat_enabled'] as bool,
        chargesKobo: (r['charges_kobo'] as num).toInt(),
        notes: r['notes'] as String?,
        terms: r['terms'] as String?,
        vatRateBps: (r['vat_rate_bps'] as num).toInt(),
        subtotalKobo: (r['subtotal_kobo'] as num).toInt(),
        vatKobo: (r['vat_kobo'] as num).toInt(),
        totalKobo: (r['total_kobo'] as num).toInt(),
        amountPaidKobo: (r['amount_paid_kobo'] as num).toInt(),
        createdAt: _ts(r['created_at']),
        issuedAt: _ts(r['issued_at']),
        paidAt: _ts(r['paid_at']),
        cancelledAt: _ts(r['cancelled_at']),
        revisedAt: _ts(r['revised_at']),
      );
}

class InvoicePayment {
  const InvoicePayment({
    required this.id,
    required this.amountKobo,
    required this.method,
    required this.paidOn,
    this.reference,
  });
  final String id;
  final int amountKobo;
  final PaymentMethod method;
  final DateTime paidOn;
  final String? reference;
}

/// What the invoice document shows about the seller.
class BusinessInfo {
  const BusinessInfo({
    required this.name,
    required this.vatRateBps,
    this.address,
    this.bankName,
    this.accountNumber,
    this.accountName,
    this.logoPath,
  });
  final String? logoPath;
  final String name;
  final int vatRateBps;
  final String? address;
  final String? bankName;
  final String? accountNumber;
  final String? accountName;

  bool get hasPaymentDetails => (accountNumber ?? '').isNotEmpty;
}

/// Quick payment amounts for a balance: a quarter, a half and all of it, in whole naira, without repeats.
List<int> quickPaymentAmounts(int balanceKobo) {
  if (balanceKobo <= 0) return const [];
  int wholeNaira(int kobo) => (kobo ~/ 100) * 100;
  final out = <int>[];
  for (final v in [wholeNaira(balanceKobo ~/ 4), wholeNaira(balanceKobo ~/ 2), balanceKobo]) {
    if (v > 0 && !out.contains(v)) out.add(v);
  }
  return out;
}

/// Totals for the list header.
class InvoiceSummary {
  const InvoiceSummary({required this.outstandingKobo, required this.overdueCount, required this.draftCount});
  final int outstandingKobo;
  final int overdueCount;
  final int draftCount;
}

InvoiceSummary summarizeInvoices(List<Invoice> list, {DateTime? today}) {
  var outstanding = 0;
  var overdue = 0;
  var drafts = 0;
  for (final i in list) {
    if (i.isDraft) drafts++;
    if (i.isOpen) {
      outstanding += i.balanceKobo;
      if (i.effectiveStatus(today: today) == InvoiceStatus.overdue) overdue++;
    }
  }
  return InvoiceSummary(outstandingKobo: outstanding, overdueCount: overdue, draftCount: drafts);
}

DateTime? _ts(Object? v) => v == null ? null : DateTime.parse(v as String).toLocal();

/// One line in an invoice's history.
class InvoiceEvent {
  const InvoiceEvent({required this.when, required this.title, this.detail});
  final DateTime when;
  final String title;
  final String? detail;
}

/// What happened to an invoice, oldest first: created, sent, each payment, paid in full, reopened, cancelled.
/// Reminders are not recorded yet, so they do not appear.
List<InvoiceEvent> invoiceTimeline(Invoice invoice, List<InvoicePayment> payments) {
  final events = <InvoiceEvent>[
    if (invoice.createdAt != null) InvoiceEvent(when: invoice.createdAt!, title: 'Created'),
    if (invoice.issuedAt != null) InvoiceEvent(when: invoice.issuedAt!, title: 'Sent to customer'),
    for (final p in payments)
      InvoiceEvent(
        when: p.paidOn,
        title: 'Payment received',
        detail: '${p.method.label}${p.reference == null ? '' : ' · ${p.reference}'}',
      ),
    if (invoice.revisedAt != null) InvoiceEvent(when: invoice.revisedAt!, title: 'Reopened for changes'),
    if (invoice.paidAt != null) InvoiceEvent(when: invoice.paidAt!, title: 'Paid in full'),
    if (invoice.cancelledAt != null) InvoiceEvent(when: invoice.cancelledAt!, title: 'Cancelled'),
  ];
  events.sort((a, b) => a.when.compareTo(b.when));
  return events;
}
