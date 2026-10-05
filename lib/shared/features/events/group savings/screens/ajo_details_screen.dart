import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../widgets/app_text.dart';
import '../models/ajo_group.dart';
import '../services/ajo_service.dart';
import '../widgets/ajo_contribution_checklist.dart';
import '../widgets/ajo_disburse_dialog.dart';
import '../widgets/ajo_join_sheet.dart';
import '../widgets/ajo_roster_card.dart';

class AjoDetailsScreen extends StatefulWidget {
  final String groupId;

  const AjoDetailsScreen({
    super.key,
    required this.groupId,
  });

  @override
  State<AjoDetailsScreen> createState() => _AjoDetailsScreenState();
}

class _AjoDetailsScreenState extends State<AjoDetailsScreen> {
  final AjoService _ajoService = AjoService.instance;
  AjoGroup? _group;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGroup();
  }

  Future<void> _loadGroup() async {
    setState(() => _isLoading = true);
    final groups = await _ajoService.getGroups();
    final match = groups.firstWhere(
      (g) => g.id == widget.groupId,
      orElse: () => groups.first,
    );
    if (mounted) {
      setState(() {
        _group = match;
        _isLoading = false;
      });
    }
  }

  Future<void> _handleToggleContribution(String memberId) async {
    if (_group == null) return;
    final updated = await _ajoService.toggleMemberContribution(
      groupId: _group!.id,
      memberId: memberId,
    );
    if (updated != null && mounted) {
      setState(() => _group = updated);
    }
  }

  void _promptDisbursement() {
    if (_group == null) return;
    final recipient = _group!.currentRecipient;
    if (recipient == null) return;

    AjoDisburseDialog.show(
      context,
      group: _group!,
      recipient: recipient,
      onConfirmed: () async {
        final disbursedRecipient =
            await _ajoService.markAndDisburseTurn(_group!.id);
        await _loadGroup();
        if (mounted && disbursedRecipient != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: AppText.paragraph(
                'Successfully disbursed payout to ${disbursedRecipient.name} (${disbursedRecipient.bankName})!',
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: const Color(0xFF16A34A),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
    );
  }

  void _shareInviteLink() {
    if (_group == null) return;
    Share.share(
      'Join my Ajo Savings Pool "${_group!.title}" on Uruvia!\n'
      'Contribution: \$${_group!.contributionPerMember.toStringAsFixed(0)} / ${_group!.frequency.toLowerCase()}.\n'
      'Click to join: https://uruvia.app/events/ajo?id=${_group!.id}',
      subject: 'Join ${_group!.title} on Uruvia',
    );
  }

  void _openMockJoinSheet() {
    if (_group == null) return;
    AjoJoinSheet.show(
      context,
      group: _group!,
      onJoined: (name, bank, account, month) async {
        final updated = await _ajoService.addMember(
          groupId: _group!.id,
          name: name,
          bankName: bank,
          accountNumber: account,
          payoutMonth: month,
        );
        if (updated != null && mounted) {
          setState(() => _group = updated);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: AppText.paragraph(
                '$name successfully joined the Ajo pool!',
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: const Color(0xFF0060E6),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _group == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final group = _group!;
    final recipient = group.currentRecipient;
    final currencyFormatter =
        NumberFormat.currency(symbol: '\$', decimalDigits: 0);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const FaIcon(
            FontAwesomeIcons.arrowLeft,
            color: Color(0xFF0F172A),
            size: 18,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const AppText.subtitle(
          'Ajo Savings Details',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
          ),
        ),
        actions: [
          IconButton(
            icon: const FaIcon(
              FontAwesomeIcons.shareNodes,
              color: Color(0xFF0060E6),
              size: 18,
            ),
            onPressed: _shareInviteLink,
            tooltip: 'Share Invite',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          children: [
            // Top Pool & Locked Balance Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF062C5E), Color(0xFF021735)],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF062C5E).withValues(alpha: 0.2),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2563EB).withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: const [
                            FaIcon(
                              FontAwesomeIcons.lock,
                              color: Color(0xFF93C5FD),
                              size: 11,
                            ),
                            SizedBox(width: 5),
                            AppText.button(
                              'Locked In Wallet Pocket',
                              style: TextStyle(
                                color: Color(0xFFBFDBFE),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      AppText.button(
                        '${group.members.length} Members',
                        style: const TextStyle(
                          color: Color(0xFF93C5FD),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  AppText.custom(
                    group.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  AppText.custom(
                    currencyFormatter.format(group.lockedAmount),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  AppText.paragraph(
                    'Total Locked Pool (${group.frequency}) · Payout Pot: ${currencyFormatter.format(group.totalPotPerTurn)}',
                    style: TextStyle(
                      color: const Color(0xFFCBD5E1).withValues(alpha: 0.8),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Active Payout Highlight Card
            if (recipient != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFBFDBFE)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const FaIcon(
                              FontAwesomeIcons.bullseye,
                              color: Color(0xFF0060E6),
                              size: 14,
                            ),
                            const SizedBox(width: 8),
                            AppText.subtitle(
                              'Active Turn ${group.currentTurnIndex} of ${group.members.length}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1E3A8A),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDBEAFE),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: AppText.button(
                            recipient.payoutMonth,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1D4ED8),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: const Color(0xFF0060E6),
                          child: AppText.button(
                            recipient.initials,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 11,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppText.custom(
                                'Beneficiary: ${recipient.name}',
                                style: const TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              AppText.paragraph(
                                '${recipient.bankName} · ${recipient.accountNumber}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF475569),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 20),

            // Contribution Checklist for Current Round
            AjoContributionChecklist(
              group: group,
              onToggleContribution: _handleToggleContribution,
            ),

            const SizedBox(height: 18),

            // "Mark for Payout & Disburse" Action Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _promptDisbursement,
                icon: const FaIcon(FontAwesomeIcons.moneyBillWave, size: 16),
                label: AppText.button(
                  group.allContributedForCurrentTurn
                      ? 'Mark for Payout & Disburse (${recipient?.name})'
                      : 'Mark for Payout (${group.contributedCount}/${group.members.length} Ready)',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: group.allContributedForCurrentTurn
                      ? const Color(0xFF16A34A)
                      : const Color(0xFF0060E6),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 2,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Full Roster & Schedule Card
            AjoRosterCard(group: group),

            const SizedBox(height: 20),

            // Add/Invite member button
            OutlinedButton.icon(
              onPressed: _openMockJoinSheet,
              icon: const FaIcon(FontAwesomeIcons.userPlus, size: 14),
              label: const AppText.button(
                'Add Member / Simulate Accept Invite',
                style: TextStyle(
                  color: Color(0xFF0060E6),
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF0060E6)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
