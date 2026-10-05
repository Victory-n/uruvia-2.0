import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import '../../../../widgets/app_text.dart';
import '../models/ajo_group.dart';
import '../models/ajo_member.dart';

class AjoDisburseDialog extends StatelessWidget {
  final AjoGroup group;
  final AjoMember recipient;
  final VoidCallback onConfirmed;

  const AjoDisburseDialog({
    super.key,
    required this.group,
    required this.recipient,
    required this.onConfirmed,
  });

  static Future<void> show(
    BuildContext context, {
    required AjoGroup group,
    required AjoMember recipient,
    required VoidCallback onConfirmed,
  }) {
    return showDialog(
      context: context,
      builder: (ctx) => AjoDisburseDialog(
        group: group,
        recipient: recipient,
        onConfirmed: onConfirmed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter =
        NumberFormat.currency(symbol: '\$', decimalDigits: 0);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFDCFCE7),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const FaIcon(
              FontAwesomeIcons.moneyBillWave,
              size: 16,
              color: Color(0xFF16A34A),
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: AppText.subtitle(
              'Disburse Payout',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText.paragraph(
            'You are marking Turn ${group.currentTurnIndex} for payout. The total pot will be automatically transferred to ${recipient.name}\'s designated account.',
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF64748B),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                _buildRow('Recipient', recipient.name),
                const SizedBox(height: 8),
                _buildRow('Payout Pot', currencyFormatter.format(group.totalPotPerTurn)),
                const SizedBox(height: 8),
                _buildRow('Bank', recipient.bankName),
                const SizedBox(height: 8),
                _buildRow('Account Number', recipient.accountNumber),
                const SizedBox(height: 8),
                _buildRow('Turn & Month', 'Turn ${recipient.turnIndex} (${recipient.payoutMonth})'),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const AppText.button('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            onConfirmed();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF16A34A),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const AppText.button(
            'Confirm & Disburse',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        AppText.paragraph(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w500,
          ),
        ),
        AppText.custom(
          value,
          style: const TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }
}
