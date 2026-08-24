import 'package:flutter/material.dart';
import 'package:uruvia/constants/colors.dart';
import '../../widgets/custom_text.dart';
import 'models/wallet_account_type.dart';

class VirtualCardWidget extends StatelessWidget {
  final WalletAccountType accountType;
  final String cardHolderName;
  final String cardNumber;
  final String expiryDate;
  final String accountNumber;
  final String bankName;
  final VoidCallback? onTap;
  final bool showAccountDetails;

  const VirtualCardWidget({
    super.key,
    this.accountType = WalletAccountType.individual,
    this.cardHolderName = "Alex User",
    this.cardNumber = "4532  ••••  ••••  8829",
    this.expiryDate = "08/29",
    this.accountNumber = "8123456789",
    this.bankName = "Uruvia MFB",
    this.onTap,
    this.showAccountDetails = true,
  });

  @override
  Widget build(BuildContext context) {
    final isBusiness = accountType.isBusiness;

    final gradientColors = isBusiness
        ? const [
            Color(0xFF0D3B2E),
            Color(0xFF135D46),
            Color(0xFF1E8262),
          ]
        : const [
            Color(0xFF0F2027),
            Color(0xFF203A43),
            Color(0xFF2C5364),
          ];

    final shadowColor = isBusiness
        ? const Color(0xFF0D3B2E).withOpacity(0.35)
        : const Color(0xFF0F2027).withOpacity(0.35);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(22.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.0),
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header Row: Bank Name & Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 4.0,
                      ),
                      decoration: BoxDecoration(
                        color: isBusiness
                            ? const Color(0xFFFFD700).withOpacity(0.2)
                            : Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6.0),
                        border: isBusiness
                            ? Border.all(color: const Color(0xFFFFD700).withOpacity(0.4), width: 0.8)
                            : null,
                      ),
                      child: googleSansText(
                        text: accountType.badgeText,
                        colors: isBusiness ? const Color(0xFFFFE57F) : Colors.white,
                        fontWeight: FontWeight.bold,
                        size: 9.5,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    googleSansText(
                      text: bankName,
                      colors: Colors.white.withOpacity(0.8),
                      fontWeight: FontWeight.w500,
                      size: 12.0,
                    ),
                  ],
                ),
                const Icon(
                  Icons.nfc_rounded,
                  color: Colors.white70,
                  size: 24.0,
                ),
              ],
            ),
            const SizedBox(height: 24.0),

            // Chip Icon
            Row(
              children: [
                Container(
                  width: 40,
                  height: 28,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD700).withOpacity(0.85),
                    borderRadius: BorderRadius.circular(6.0),
                    border: Border.all(
                      color: Colors.amber.shade700,
                      width: 1.0,
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        left: 8,
                        top: 4,
                        bottom: 4,
                        child: Container(
                          width: 1,
                          color: Colors.amber.shade900.withOpacity(0.5),
                        ),
                      ),
                      Positioned(
                        right: 8,
                        top: 4,
                        bottom: 4,
                        child: Container(
                          width: 1,
                          color: Colors.amber.shade900.withOpacity(0.5),
                        ),
                      ),
                      Center(
                        child: Container(
                          height: 1,
                          width: 24,
                          color: Colors.amber.shade900.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18.0),

            // Card Number
            googleSansText(
              text: cardNumber,
              colors: Colors.white,
              fontWeight: FontWeight.w600,
              size: 18.0,
              letterSpacing: 2.0,
            ),
            const SizedBox(height: 18.0),

            // Cardholder / Business Name & Expiry
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    googleSansText(
                      text: isBusiness ? "BUSINESS NAME" : "CARD HOLDER",
                      colors: Colors.white.withOpacity(0.6),
                      fontWeight: FontWeight.w500,
                      size: 9.0,
                      letterSpacing: 1.0,
                    ),
                    const SizedBox(height: 2.0),
                    googleSansText(
                      text: cardHolderName.toUpperCase(),
                      colors: Colors.white,
                      fontWeight: FontWeight.bold,
                      size: 13.0,
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    googleSansText(
                      text: "EXPIRES",
                      colors: Colors.white.withOpacity(0.6),
                      fontWeight: FontWeight.w500,
                      size: 9.0,
                      letterSpacing: 1.0,
                    ),
                    const SizedBox(height: 2.0),
                    googleSansText(
                      text: expiryDate,
                      colors: Colors.white,
                      fontWeight: FontWeight.bold,
                      size: 13.0,
                    ),
                  ],
                ),
              ],
            ),

            if (showAccountDetails) ...[
              const SizedBox(height: 16.0),
              const Divider(color: Colors.white24, height: 1),
              const SizedBox(height: 12.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      googleSansText(
                        text: "Acct No: ",
                        colors: Colors.white.withOpacity(0.7),
                        size: 12.0,
                        fontWeight: FontWeight.w500,
                      ),
                      googleSansText(
                        text: accountNumber,
                        colors: Colors.white,
                        size: 13.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      googleSansText(
                        text: "Tap for Wallet Details",
                        colors: isBusiness
                            ? const Color(0xFFFFE57F)
                            : ConstantColor.blueBackground.withOpacity(0.9),
                        size: 11.0,
                        fontWeight: FontWeight.w600,
                      ),
                      const SizedBox(width: 4.0),
                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: Colors.white70,
                        size: 12.0,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
