class AjoMember {
  final String id;
  final String name;
  final String bankName;
  final String accountNumber;
  final int turnIndex;
  final String payoutMonth;
  final bool hasContributed;
  final String? avatarUrl;

  const AjoMember({
    required this.id,
    required this.name,
    required this.bankName,
    required this.accountNumber,
    required this.turnIndex,
    required this.payoutMonth,
    this.hasContributed = false,
    this.avatarUrl,
  });

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  AjoMember copyWith({
    String? id,
    String? name,
    String? bankName,
    String? accountNumber,
    int? turnIndex,
    String? payoutMonth,
    bool? hasContributed,
    String? avatarUrl,
  }) {
    return AjoMember(
      id: id ?? this.id,
      name: name ?? this.name,
      bankName: bankName ?? this.bankName,
      accountNumber: accountNumber ?? this.accountNumber,
      turnIndex: turnIndex ?? this.turnIndex,
      payoutMonth: payoutMonth ?? this.payoutMonth,
      hasContributed: hasContributed ?? this.hasContributed,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'bank_name': bankName,
      'account_number': accountNumber,
      'turn_index': turnIndex,
      'payout_month': payoutMonth,
      'has_contributed': hasContributed ? 1 : 0,
      'avatar_url': avatarUrl,
    };
  }

  factory AjoMember.fromMap(Map<String, dynamic> map) {
    return AjoMember(
      id: map['id'] as String,
      name: map['name'] as String,
      bankName: map['bank_name'] as String,
      accountNumber: map['account_number'] as String,
      turnIndex: (map['turn_index'] as num).toInt(),
      payoutMonth: map['payout_month'] as String,
      hasContributed: (map['has_contributed'] as int?) == 1,
      avatarUrl: map['avatar_url'] as String?,
    );
  }
}
