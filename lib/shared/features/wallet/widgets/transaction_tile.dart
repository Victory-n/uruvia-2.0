import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import '../../../../shared/widgets/app_text.dart';
import '../../../../theme/individual/app_theme.dart';
import '../models/transaction.dart';

class TransactionTile extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback? onTap;

  const TransactionTile({super.key, required this.transaction, this.onTap});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      symbol: '\$',
      decimalDigits: 2,
    );
    final String formattedAmount = currencyFormat.format(transaction.amount);
    final String sign = transaction.isCredit ? '+' : '-';
    final Color amountColor = transaction.isCredit
        ? AppTheme.primaryGreen
        : AppTheme.primaryRed;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.sleekBlue.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: FaIcon(
                transaction.isCredit
                    ? FontAwesomeIcons.arrowTrendUp
                    : FontAwesomeIcons.arrowTrendDown,
                color: transaction.isCredit
                    ? AppTheme.primaryGreen
                    : AppTheme.primaryRed,
                size: 16,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText.button(
                    transaction.title,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  AppText.paragraph(
                    transaction.subtitle,
                    style: const TextStyle(color: AppTheme.textMuted),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                AppText.button(
                  '$sign$formattedAmount',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: amountColor,
                  ),
                ),
                const SizedBox(height: 4),
                AppText.paragraph(
                  DateFormat.jm().format(
                    transaction.date,
                  ), // Show time like 5:30 PM
                  style: const TextStyle(color: AppTheme.textMuted),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
