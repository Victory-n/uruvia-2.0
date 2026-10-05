import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import '../../../../widgets/app_text.dart';
import '../models/ajo_group.dart';
import '../models/ajo_member.dart';

class AjoContributionChecklist extends StatelessWidget {
  final AjoGroup group;
  final Function(String memberId) onToggleContribution;

  const AjoContributionChecklist({
    super.key,
    required this.group,
    required this.onToggleContribution,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormatter =
        NumberFormat.currency(symbol: '\$', decimalDigits: 0);
    final recipient = group.currentRecipient;

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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AppText.subtitle(
                    'Round Contributions',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  if (recipient != null)
                    AppText.paragraph(
                      'Collecting for ${recipient.name} (${recipient.payoutMonth})',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                      ),
                    ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: group.allContributedForCurrentTurn
                      ? const Color(0xFFDCFCE7)
                      : const Color(0xFFFFF7ED),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: group.allContributedForCurrentTurn
                        ? const Color(0xFF86EFAC)
                        : const Color(0xFFFED7AA),
                  ),
                ),
                child: AppText.button(
                  '${group.contributedCount}/${group.members.length} Paid',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: group.allContributedForCurrentTurn
                        ? const Color(0xFF16A34A)
                        : const Color(0xFFEA580C),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: group.progress,
              minHeight: 6,
              backgroundColor: const Color(0xFFF1F5F9),
              valueColor: AlwaysStoppedAnimation<Color>(
                group.allContributedForCurrentTurn
                    ? const Color(0xFF16A34A)
                    : const Color(0xFF0060E6),
              ),
            ),
          ),
          const SizedBox(height: 14),
          const AppText.paragraph(
            'Tap a member to verify or mark their contribution received:',
            style: TextStyle(
              fontSize: 11.5,
              color: Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 8),
          ...group.members.map(
            (member) => _buildCheckItem(member, currencyFormatter),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckItem(AjoMember member, NumberFormat currencyFormatter) {
    return InkWell(
      onTap: () => onToggleContribution(member.id),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: member.hasContributed
              ? const Color(0xFFF0FDF4)
              : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: member.hasContributed
                ? const Color(0xFFBBF7D0)
                : const Color(0xFFE2E8F0),
          ),
        ),
        child: Row(
          children: [
            FaIcon(
              member.hasContributed
                  ? FontAwesomeIcons.circleCheck
                  : FontAwesomeIcons.circle,
              color: member.hasContributed
                  ? const Color(0xFF16A34A)
                  : const Color(0xFF94A3B8),
              size: 16,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText.custom(
                    member.name,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: member.hasContributed
                          ? const Color(0xFF0F172A)
                          : const Color(0xFF475569),
                    ),
                  ),
                  AppText.paragraph(
                    currencyFormatter.format(group.contributionPerMember),
                    style: TextStyle(
                      fontSize: 11.5,
                      color: member.hasContributed
                          ? const Color(0xFF16A34A)
                          : const Color(0xFF94A3B8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: member.hasContributed
                    ? const Color(0xFFDCFCE7)
                    : const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(8),
              ),
              child: AppText.button(
                member.hasContributed ? 'Received' : 'Pending',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: member.hasContributed
                      ? const Color(0xFF16A34A)
                      : const Color(0xFF64748B),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
