import '../../invoices/domain/invoice_models.dart';

class Customer {
  const Customer({
    required this.id,
    required this.name,
    this.phone,
    this.email,
    this.address,
    this.notes,
    this.archived = false,
  });

  final String id;
  final String name;
  final String? phone;
  final String? email;
  final String? address;
  final String? notes;
  final bool archived;

  /// Phone or email, whichever the customer has, for list subtitles.
  String? get contactLine => phone ?? email;

  factory Customer.fromRow(Map<String, dynamic> r) => Customer(
        id: r['id'] as String,
        name: r['name'] as String,
        phone: r['phone'] as String?,
        email: r['email'] as String?,
        address: r['address'] as String?,
        notes: r['notes'] as String?,
        archived: r['archived_at'] != null,
      );
}

/// What a customer has been billed, has paid and still owes, from their invoices.
/// Drafts and cancelled invoices are not counted: they were never a debt.
({int billedKobo, int paidKobo, int outstandingKobo}) customerInvoiceTotals(Iterable<Invoice> invoices) {
  var billed = 0, paid = 0, owed = 0;
  for (final i in invoices) {
    if (i.status == InvoiceStatus.draft || i.status == InvoiceStatus.cancelled) continue;
    billed += i.totalKobo;
    paid += i.amountPaidKobo;
    owed += i.balanceKobo;
  }
  return (billedKobo: billed, paidKobo: paid, outstandingKobo: owed);
}
