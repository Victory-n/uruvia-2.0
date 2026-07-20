class Sale {
  final String id;
  final String customerName;
  final String invoiceNumber;
  final double amount;
  final DateTime datePaid;
  final String status; // Always 'Paid'
  final String category;

  Sale({
    required this.id,
    required this.customerName,
    required this.invoiceNumber,
    required this.amount,
    required this.datePaid,
    this.status = 'Paid',
    this.category = 'Invoice Payment',
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'customer_name': customerName,
        'invoice_number': invoiceNumber,
        'amount': amount,
        'date_paid': datePaid.toIso8601String(),
        'status': status,
        'category': category,
      };

  factory Sale.fromMap(Map<String, dynamic> map) {
    return Sale(
      id: map['id'] as String,
      customerName: map['customer_name'] as String? ?? 'Client',
      invoiceNumber: map['invoice_number'] as String? ?? '',
      amount: (map['amount'] as num).toDouble(),
      datePaid: map['date_paid'] != null
          ? DateTime.parse(map['date_paid'] as String)
          : DateTime.now(),
      status: map['status'] as String? ?? 'Paid',
      category: map['category'] as String? ?? 'Invoice Payment',
    );
  }
}
