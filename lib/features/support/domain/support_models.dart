/// What the ticket is about. The first word is saved in the database.
const supportCategories = [
  'Account',
  'Payments',
  'Invoices',
  'Inventory',
  'Subscription',
  'Something is not working',
  'Other',
];

enum TicketStatus {
  open('open', 'Open'),
  inProgress('in_progress', 'In progress'),
  resolved('resolved', 'Resolved');

  const TicketStatus(this.db, this.label);
  final String db;
  final String label;

  static TicketStatus parse(String v) =>
      TicketStatus.values.firstWhere((s) => s.db == v, orElse: () => TicketStatus.open);
}

class SupportTicket {
  const SupportTicket({
    required this.id,
    required this.reference,
    required this.category,
    required this.description,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String reference;
  final String category;
  final String description;
  final TicketStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isResolved => status == TicketStatus.resolved;

  factory SupportTicket.fromRow(Map<String, dynamic> r) => SupportTicket(
        id: r['id'] as String,
        reference: r['reference'] as String,
        category: r['category'] as String,
        description: r['description'] as String,
        status: TicketStatus.parse(r['status'] as String),
        createdAt: DateTime.parse(r['created_at'] as String).toLocal(),
        updatedAt: DateTime.parse(r['updated_at'] as String).toLocal(),
      );
}

class SupportMessage {
  const SupportMessage({required this.id, required this.body, required this.isStaff, required this.createdAt});

  final String id;
  final String body;

  /// true when the Uruvia team wrote it.
  final bool isStaff;
  final DateTime createdAt;

  factory SupportMessage.fromRow(Map<String, dynamic> r) => SupportMessage(
        id: r['id'] as String,
        body: r['body'] as String,
        isStaff: r['is_staff'] as bool,
        createdAt: DateTime.parse(r['created_at'] as String).toLocal(),
      );
}

/// Trims and checks what the user typed. Returns an error message or null.
String? validateSupportText(String value, {int max = 4000}) {
  final v = value.trim();
  if (v.isEmpty) return 'Write a few words so we can help.';
  if (v.length > max) return 'Keep it under $max characters.';
  return null;
}
