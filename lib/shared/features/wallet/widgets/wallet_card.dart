import 'package:flutter/material.dart';
import '../../../widgets/app_text.dart';
import '../../../../theme/individual/app_theme.dart';

class WalletCard extends StatelessWidget {
  final String balance;
  final String accountNumber;
  final String cvv;
  final Color? backgroundColor;
  final Gradient? gradient;
  final Color? buttonColor;
  final Color? buttonTextColor;
  final String balanceLabel;
  final String buttonLabel;
  final String? cardTag;
  final VoidCallback? onWithdraw;
  final BorderRadiusGeometry? borderRadius;

  const WalletCard({
    super.key,
    required this.balance,
    required this.accountNumber,
    required this.cvv,
    this.backgroundColor,
    this.gradient,
    this.buttonColor,
    this.buttonTextColor,
    this.balanceLabel = 'Total Balance',
    this.buttonLabel = 'Withdraw',
    this.cardTag,
    this.onWithdraw,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBgColor = gradient == null ? (backgroundColor ?? AppTheme.sleekBlue) : null;
    final effectiveBtnBg = buttonColor ?? AppTheme.white;
    final effectiveBtnText = buttonTextColor ?? (backgroundColor ?? AppTheme.sleekBlue);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: effectiveBgColor,
        gradient: gradient,
        borderRadius: borderRadius ?? BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (backgroundColor ?? AppTheme.sleekBlue).withValues(alpha: 0.18),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      AppText.paragraph(
                        balanceLabel,
                        style: TextStyle(
                          color: AppTheme.white.withValues(alpha: 0.8),
                          fontSize: 13,
                        ),
                      ),
                      if (cardTag != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            cardTag!,
                            style: const TextStyle(
                              color: AppTheme.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  AppText.subtitle(
                    balance,
                    style: const TextStyle(
                      color: AppTheme.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: onWithdraw ?? () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: effectiveBtnBg,
                  foregroundColor: effectiveBtnText,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: AppText.custom(
                  buttonLabel,
                  style: TextStyle(
                    color: effectiveBtnText,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText.paragraph(
                    'Account Number',
                    style: TextStyle(
                      color: AppTheme.white.withValues(alpha: 0.8),
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 4),
                  AppText.paragraph(
                    accountNumber,
                    style: const TextStyle(
                      color: AppTheme.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  AppText.paragraph(
                    'CVV',
                    style: TextStyle(
                      color: AppTheme.white.withValues(alpha: 0.8),
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 4),
                  AppText.paragraph(
                    cvv,
                    style: const TextStyle(
                      color: AppTheme.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
