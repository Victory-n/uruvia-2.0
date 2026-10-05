import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import '../../../../widgets/app_text.dart';
import '../models/ajo_group.dart';
import '../screens/ajo_details_screen.dart';

class AjoLockedPocketCard extends StatelessWidget {
  final AjoGroup group;
  final VoidCallback? onRefresh;

  const AjoLockedPocketCard({
    super.key,
    required this.group,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormatter =
        NumberFormat.currency(symbol: '\$', decimalDigits: 0);
    final recipient = group.currentRecipient;

    return InkWell(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AjoDetailsScreen(groupId: group.id),
          ),
        );
        onRefresh?.call();
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF2563EB).withValues(alpha: 0.3),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.12),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2563EB).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const FaIcon(
                        FontAwesomeIcons.lock,
                        size: 13,
                        color: Color(0xFF60A5FA),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const AppText.custom(
                      'Ajo Locked Savings Pocket',
                      style: TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2563EB).withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: AppText.button(
                    '${group.members.length} Members',
                    style: const TextStyle(
                      color: Color(0xFF93C5FD),
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText.custom(
                      currencyFormatter.format(group.lockedAmount),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    AppText.paragraph(
                      'Locked in pool · Untouchable balance',
                      style: TextStyle(
                        color: const Color(0xFFCBD5E1).withValues(alpha: 0.8),
                        fontSize: 11.5,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: const [
                    AppText.button(
                      'Manage',
                      style: TextStyle(
                        color: Color(0xFF60A5FA),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 4),
                    FaIcon(
                      FontAwesomeIcons.chevronRight,
                      size: 10,
                      color: Color(0xFF60A5FA),
                    ),
                  ],
                ),
              ],
            ),
            if (recipient != null) ...[
              const SizedBox(height: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const FaIcon(
                      FontAwesomeIcons.calendarCheck,
                      size: 11,
                      color: Color(0xFF38BDF8),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: AppText.paragraph(
                        'Turn ${group.currentTurnIndex} of ${group.members.length}: ${recipient.name}\'s Payout (${recipient.payoutMonth})',
                        style: const TextStyle(
                          color: Color(0xFFE2E8F0),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
