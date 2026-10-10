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
