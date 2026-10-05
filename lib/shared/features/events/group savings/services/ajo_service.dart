import 'dart:isolate';
import '../models/ajo_group.dart';
import '../models/ajo_member.dart';

class AjoService {
  static final AjoService _instance = AjoService._internal();
  static AjoService get instance => _instance;
  AjoService._internal();

  List<AjoGroup> _cachedGroups = [];
  bool _initialized = false;

  /// Load groups and offload processing to Isolate (Rule 1, Rule 3)
  Future<List<AjoGroup>> getGroups() async {
    if (!_initialized) {
      final initialMaps = AjoGroup.initialGroups.map((g) => g.toMap()).toList();

      // Rule 1: Offload parsing to background Isolate
      _cachedGroups = await Isolate.run(() {
        return initialMaps.map((m) => AjoGroup.fromMap(m)).toList();
      });
      _initialized = true;
    }
    return List.unmodifiable(_cachedGroups);
  }

  /// Calculate total locked Ajo balance across all groups in background Isolate (Rule 1)
  Future<double> calculateTotalLockedAmount() async {
    final groups = await getGroups();
    final groupMaps = groups.map((g) => g.toMap()).toList();

    return await Isolate.run(() {
      double totalLocked = 0.0;
      for (final map in groupMaps) {
        final group = AjoGroup.fromMap(map);
        totalLocked += group.lockedAmount;
      }
      return totalLocked;
    });
  }

  /// Toggle contribution status for a member in the current turn
  Future<AjoGroup?> toggleMemberContribution({
    required String groupId,
    required String memberId,
  }) async {
    final index = _cachedGroups.indexWhere((g) => g.id == groupId);
    if (index == -1) return null;

    final group = _cachedGroups[index];
    final updatedMembers = group.members.map((m) {
      if (m.id == memberId) {
        return m.copyWith(hasContributed: !m.hasContributed);
      }
      return m;
    }).toList();

    final updatedGroup = group.copyWith(members: updatedMembers);
    _cachedGroups[index] = updatedGroup;
    return updatedGroup;
  }

  /// Mark and execute automated payout to the current turn recipient
  /// Decreases locked balance, marks turn complete, and advances to next turn
  Future<AjoMember?> markAndDisburseTurn(String groupId) async {
    final index = _cachedGroups.indexWhere((g) => g.id == groupId);
    if (index == -1) return null;

    final group = _cachedGroups[index];
    final recipient = group.currentRecipient;
    if (recipient == null) return null;

    final newCompletedTurns = List<int>.from(group.completedTurns)
      ..add(group.currentTurnIndex);

    final nextTurnIndex = group.currentTurnIndex + 1;
    final hasNextTurn = nextTurnIndex <= group.members.length;

    // Reset contribution flags for the next round
    final nextRoundMembers = group.members.map((m) {
      return m.copyWith(hasContributed: false);
    }).toList();

    final updatedGroup = group.copyWith(
      currentTurnIndex: hasNextTurn ? nextTurnIndex : group.currentTurnIndex,
      completedTurns: newCompletedTurns,
      isMarkedForPayout: true,
      members: hasNextTurn ? nextRoundMembers : group.members,
    );

    _cachedGroups[index] = updatedGroup;
    return recipient;
  }

  /// Add a new member who accepted the invite with their preferred bank details
  Future<AjoGroup?> addMember({
    required String groupId,
    required String name,
    required String bankName,
    required String accountNumber,
    required String payoutMonth,
  }) async {
    final index = _cachedGroups.indexWhere((g) => g.id == groupId);
    if (index == -1) return null;

    final group = _cachedGroups[index];
    final newMember = AjoMember(
      id: 'mem-${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      bankName: bankName,
      accountNumber: accountNumber,
      turnIndex: group.members.length + 1,
      payoutMonth: payoutMonth,
      hasContributed: false,
    );

    final updatedMembers = List<AjoMember>.from(group.members)..add(newMember);
    final updatedGroup = group.copyWith(members: updatedMembers);
    _cachedGroups[index] = updatedGroup;
    return updatedGroup;
  }
}
