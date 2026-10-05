import 'ajo_member.dart';

class AjoGroup {
  final String id;
  final String title;
  final String description;
  final double contributionPerMember;
  final String frequency; // 'Monthly', 'Weekly', 'Bi-weekly'
  final int currentTurnIndex;
  final bool isMarkedForPayout;
  final List<AjoMember> members;
  final List<int> completedTurns;
  final DateTime createdAt;

  const AjoGroup({
    required this.id,
    required this.title,
    required this.description,
    required this.contributionPerMember,
    this.frequency = 'Monthly',
    this.currentTurnIndex = 1,
    this.isMarkedForPayout = false,
    required this.members,
    this.completedTurns = const [],
    required this.createdAt,
  });

  double get totalPotPerTurn => contributionPerMember * members.length;

  int get contributedCount => members.where((m) => m.hasContributed).length;

  double get currentCollectedAmount => contributedCount * contributionPerMember;

  double get lockedAmount => currentCollectedAmount;

  bool get allContributedForCurrentTurn =>
      members.isNotEmpty && contributedCount == members.length;

  double get progress =>
      members.isNotEmpty ? (contributedCount / members.length).clamp(0.0, 1.0) : 0.0;

  int get progressPercentage => (progress * 100).round();

  AjoMember? get currentRecipient {
    final matches = members.where((m) => m.turnIndex == currentTurnIndex);
    return matches.isNotEmpty ? matches.first : null;
  }

  bool isTurnCompleted(int turnIndex) => completedTurns.contains(turnIndex);

  AjoGroup copyWith({
    String? id,
    String? title,
    String? description,
    double? contributionPerMember,
    String? frequency,
    int? currentTurnIndex,
    bool? isMarkedForPayout,
    List<AjoMember>? members,
    List<int>? completedTurns,
    DateTime? createdAt,
  }) {
    return AjoGroup(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      contributionPerMember:
          contributionPerMember ?? this.contributionPerMember,
      frequency: frequency ?? this.frequency,
      currentTurnIndex: currentTurnIndex ?? this.currentTurnIndex,
      isMarkedForPayout: isMarkedForPayout ?? this.isMarkedForPayout,
      members: members ?? this.members,
      completedTurns: completedTurns ?? this.completedTurns,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'contribution_per_member': contributionPerMember,
      'frequency': frequency,
      'current_turn_index': currentTurnIndex,
      'is_marked_for_payout': isMarkedForPayout ? 1 : 0,
      'members': members.map((m) => m.toMap()).toList(),
      'completed_turns': completedTurns,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory AjoGroup.fromMap(Map<String, dynamic> map) {
    return AjoGroup(
      id: map['id'] as String,
      title: map['title'] as String,
      description: (map['description'] as String?) ?? '',
      contributionPerMember:
          (map['contribution_per_member'] as num).toDouble(),
      frequency: (map['frequency'] as String?) ?? 'Monthly',
      currentTurnIndex: (map['current_turn_index'] as num?)?.toInt() ?? 1,
      isMarkedForPayout: (map['is_marked_for_payout'] as int?) == 1,
      members: (map['members'] as List<dynamic>)
          .map((m) => AjoMember.fromMap(m as Map<String, dynamic>))
          .toList(),
      completedTurns: (map['completed_turns'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          [],
      createdAt: DateTime.tryParse(map['created_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  static List<AjoGroup> get initialGroups => [
        AjoGroup(
          id: 'ajo-1',
          title: 'Inner Circle Ajo Savings',
          description:
              'Rotating monthly pool for personal goals and investments.',
          contributionPerMember: 50000.0,
          frequency: 'Monthly',
          currentTurnIndex: 1,
          isMarkedForPayout: false,
          completedTurns: const [],
          createdAt: DateTime.now().subtract(const Duration(days: 15)),
          members: const [
            AjoMember(
              id: 'mem-1',
              name: 'Janet Doe',
              bankName: 'Guaranty Trust Bank',
              accountNumber: '0123456789',
              turnIndex: 1,
              payoutMonth: 'September',
              hasContributed: true,
            ),
            AjoMember(
              id: 'mem-2',
              name: 'Victory N.',
              bankName: 'Access Bank',
              accountNumber: '9876543210',
              turnIndex: 2,
              payoutMonth: 'October',
              hasContributed: true,
            ),
            AjoMember(
              id: 'mem-3',
              name: 'Divine E.',
              bankName: 'Kuda Microfinance Bank',
              accountNumber: '1122334455',
              turnIndex: 3,
              payoutMonth: 'November',
              hasContributed: true,
            ),
            AjoMember(
              id: 'mem-4',
              name: 'Abdul M.',
              bankName: 'Zenith Bank',
              accountNumber: '5544332211',
              turnIndex: 4,
              payoutMonth: 'December',
              hasContributed: true,
            ),
            AjoMember(
              id: 'mem-5',
              name: 'Musa K.',
              bankName: 'United Bank for Africa',
              accountNumber: '9988776655',
              turnIndex: 5,
              payoutMonth: 'January',
              hasContributed: true,
            ),
          ],
        ),
      ];
}
