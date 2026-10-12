/// A kind of alert the user can switch on or off.
class AlertKind {
  const AlertKind(this.kind, this.title, this.description);
  final String kind;
  final String title;
  final String description;
}

const individualAlerts = [
  AlertKind('budget_80', 'Budget almost used', 'When you have used 80% of a budget.'),
  AlertKind('budget_100', 'Budget used up', 'When a budget is fully spent.'),
];

const businessAlerts = [
  AlertKind('low_stock', 'Low stock', 'When a product runs low or runs out.'),
  AlertKind('restock_reminder', 'Restock reminders', 'On the day you asked to be reminded.'),
  AlertKind('invoice_overdue', 'Overdue invoices', 'When an invoice passes its due date.'),
  AlertKind('reservation_expired', 'Reserved stock released', 'When stock held for an unpaid invoice is released.'),
];

/// The business details a user can change after set-up.
class BusinessDetails {
  const BusinessDetails({
    required this.name,
    required this.invoicePrefix,
    required this.vatRateBps,
    this.category,
    this.address,
    this.bankName,
    this.accountNumber,
    this.accountName,
    this.logoPath,
  });

  final String? logoPath;
  final String name;
  final String? category;
  final String? address;
  final String invoicePrefix;
  final int vatRateBps;
  final String? bankName;
  final String? accountNumber;
  final String? accountName;

  /// "7.5" or "10".
  String get vatPercentText {
    final v = vatRateBps / 100;
    return vatRateBps % 100 == 0 ? '${vatRateBps ~/ 100}' : v.toString();
  }

  Map<String, String> get paymentDetails => {
        if ((bankName ?? '').trim().isNotEmpty) 'bank_name': bankName!.trim(),
        if ((accountNumber ?? '').trim().isNotEmpty) 'account_number': accountNumber!.trim(),
        if ((accountName ?? '').trim().isNotEmpty) 'account_name': accountName!.trim(),
      };
}
