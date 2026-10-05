import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../widgets/app_text.dart';
import '../models/ajo_group.dart';
import '../models/ajo_member.dart';

class AjoRosterCard extends StatelessWidget {
  final AjoGroup group;

  const AjoRosterCard({
    super.key,
    required this.group,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const AppText.subtitle(
                'Payout Schedule & Roster',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: AppText.button(
                  '${group.members.length} Turns',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF475569),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...group.members.map((member) => _buildMemberTile(member)),
        ],
      ),
    );
  }

  Widget _buildMemberTile(AjoMember member) {
    final isCurrent = member.turnIndex == group.currentTurnIndex;
    final isCompleted = group.isTurnCompleted(member.turnIndex);

    Color badgeColor;
    Color badgeTextColor;
    String badgeText;

    if (isCompleted) {
      badgeColor = const Color(0xFFDCFCE7);
      badgeTextColor = const Color(0xFF16A34A);
      badgeText = 'Paid Out';
    } else if (isCurrent) {
      badgeColor = const Color(0xFFDBEAFE);
      badgeTextColor = const Color(0xFF1D4ED8);
      badgeText = 'Current Turn';
    } else {
      badgeColor = const Color(0xFFF1F5F9);
      badgeTextColor = const Color(0xFF64748B);
      badgeText = 'Turn ${member.turnIndex}';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCurrent
            ? const Color(0xFFEFF6FF)
            : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCurrent
              ? const Color(0xFF93C5FD)
              : const Color(0xFFE2E8F0),
          width: isCurrent ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: isCurrent
                ? const Color(0xFF0060E6)
                : const Color(0xFFE2E8F0),
            child: AppText.button(
              member.initials,
              style: TextStyle(
                color: isCurrent ? Colors.white : const Color(0xFF334155),
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: AppText.custom(
                        member.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: badgeColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: AppText.button(
                        badgeText,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: badgeTextColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    const FaIcon(
                      FontAwesomeIcons.buildingColumns,
                      size: 10,
                      color: Color(0xFF64748B),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: AppText.paragraph(
                        '${member.bankName} · ${member.accountNumber}',
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: Color(0xFF64748B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const FaIcon(
                      FontAwesomeIcons.calendarDay,
                      size: 10,
                      color: Color(0xFF94A3B8),
                    ),
                    const SizedBox(width: 4),
                    AppText.paragraph(
                      'Payout Month: ${member.payoutMonth}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF94A3B8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
