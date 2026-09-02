import 'package:flutter/material.dart';
import 'package:uruvia/constants/colors.dart';
import '../../../widgets/custom_text.dart';

class BudgetEmptyState extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  const BudgetEmptyState({
    super.key,
    this.title = "No Categories Found",
    this.message = "No budget categories match your current view. Tap below to create your first category cap.",
    this.icon = Icons.account_balance_wallet_outlined,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: ConstantColor.blueBackground.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 36.0,
              color: ConstantColor.blueBackground,
            ),
          ),
          const SizedBox(height: 14.0),
          googleSansText(
            text: title,
            colors: ConstantColor.headingTextPrimary,
            size: 16.0,
            fontWeight: FontWeight.bold,
          ),
          const SizedBox(height: 6.0),
          googleSansText(
            text: message,
            colors: ConstantColor.paragraphTextSecondary,
            size: 12.5,
            textAlign: TextAlign.center,
            fontWeight: FontWeight.normal,
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 18.0),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: ConstantColor.blueBackground,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18.0,
                  vertical: 10.0,
                ),
              ),
              onPressed: onAction,
              icon: const Icon(Icons.add, size: 16.0, color: Colors.white),
              label: googleSansText(
                text: actionLabel!,
                colors: Colors.white,
                fontWeight: FontWeight.bold,
                size: 13.0,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
