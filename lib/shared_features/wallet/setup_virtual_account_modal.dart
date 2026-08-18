import 'package:flutter/material.dart';
import 'package:uruvia/constants/colors.dart';
import 'package:uruvia/shared_features/wallet/models/wallet_account_type.dart';
import 'package:uruvia/shared_features/wallet/virtual_account_setup_screen.dart';
import 'package:uruvia/widgets/custom_text.dart';

class SetupVirtualAccountModal extends StatelessWidget {
  final WalletAccountType accountType;
  final VoidCallback onSetupComplete;

  const SetupVirtualAccountModal({
    super.key,
    this.accountType = WalletAccountType.individual,
    required this.onSetupComplete,
  });

  static Future<void> show(
    BuildContext context, {
    WalletAccountType accountType = WalletAccountType.individual,
    required VoidCallback onSetupComplete,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SetupVirtualAccountModal(
        accountType: accountType,
        onSetupComplete: onSetupComplete,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isBusiness = accountType.isBusiness;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.0)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle indicator
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2.0),
                ),
              ),
            ),
            const SizedBox(height: 20.0),

            // Header Banner / Icon
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14.0),
                  decoration: BoxDecoration(
                    color: (isBusiness ? Colors.teal : ConstantColor.blueBackground)
                        .withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isBusiness ? Icons.storefront_rounded : Icons.account_balance_wallet_outlined,
                    color: isBusiness ? Colors.teal.shade800 : ConstantColor.blueBackground,
                    size: 28.0,
                  ),
                ),
                const SizedBox(width: 14.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      googleSansText(
                        text: isBusiness
                            ? "Setup Business Virtual Account"
                            : "Setup Virtual Account",
                        colors: ConstantColor.headingTextPrimary,
                        fontWeight: FontWeight.bold,
                        size: 19.0,
                      ),
                      const SizedBox(height: 2.0),
                      googleSansText(
                        text: isBusiness
                            ? "Dedicated business account for client payouts & expenses"
                            : "Unlock your personalized digital account & card",
                        colors: ConstantColor.paragraphTextSecondary,
                        fontWeight: FontWeight.w400,
                        size: 12.5,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24.0),
            const Divider(height: 1),
            const SizedBox(height: 20.0),

            // Benefits List
            if (isBusiness) ...[
              _buildFeatureItem(
                icon: Icons.credit_card_rounded,
                title: "Instant Business Debit Card",
                subtitle: "Pay for software tools (Adobe, Figma, hosting), ads, and gear subscriptions.",
              ),
              const SizedBox(height: 16.0),
              _buildFeatureItem(
                icon: Icons.payments_outlined,
                title: "Client Payment Collection",
                subtitle: "Receive direct client milestone payouts for web dev, photography, and video services.",
              ),
              const SizedBox(height: 16.0),
              _buildFeatureItem(
                icon: Icons.receipt_long_outlined,
                title: "Vendor & Expense Payments",
                subtitle: "Settle business bills, pay contractors, and keep business expenses organized.",
              ),
              const SizedBox(height: 16.0),
              _buildFeatureItem(
                icon: Icons.verified_user_rounded,
                title: "Separate Business Finances",
                subtitle: "Keep your SME project income separate from your personal budget.",
              ),
            ] else ...[
              _buildFeatureItem(
                icon: Icons.credit_card_rounded,
                title: "Instant Virtual Card",
                subtitle: "Issued immediately for online shopping, subscriptions, and global payments.",
              ),
              const SizedBox(height: 16.0),
              _buildFeatureItem(
                icon: Icons.payments_outlined,
                title: "Direct Salary Deposit",
                subtitle: "Transfer your salary seamlessly into your dedicated virtual account.",
              ),
              const SizedBox(height: 16.0),
              _buildFeatureItem(
                icon: Icons.shopping_bag_outlined,
                title: "Spend & Pay Expenses",
                subtitle: "Make payments and settle personal expenses directly from your balance.",
              ),
              const SizedBox(height: 16.0),
              _buildFeatureItem(
                icon: Icons.security_rounded,
                title: "Bank-Grade Security",
                subtitle: "Full control to freeze card, change PIN, and monitor live transactions.",
              ),
            ],
            const SizedBox(height: 28.0),

            // Continue CTA Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Close bottom sheet
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VirtualAccountSetupScreen(
                        accountType: accountType,
                        onSetupComplete: onSetupComplete,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isBusiness ? Colors.teal.shade800 : ConstantColor.blueBackground,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.0),
                  ),
                ),
                child: googleSansText(
                  text: isBusiness ? "Continue to Business Setup" : "Continue to Setup",
                  colors: Colors.white,
                  fontWeight: FontWeight.bold,
                  size: 16.0,
                ),
              ),
            ),
            const SizedBox(height: 12.0),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10.0),
          decoration: BoxDecoration(
            color: accountType.isBusiness
                ? Colors.teal.withOpacity(0.08)
                : ConstantColor.lightBackground,
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Icon(
            icon,
            color: accountType.isBusiness ? Colors.teal.shade800 : ConstantColor.blueBackground,
            size: 22.0,
          ),
        ),
        const SizedBox(width: 14.0),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              googleSansText(
                text: title,
                colors: ConstantColor.headingTextPrimary,
                fontWeight: FontWeight.w600,
                size: 15.0,
              ),
              const SizedBox(height: 3.0),
              googleSansText(
                text: subtitle,
                colors: ConstantColor.paragraphTextSecondary,
                fontWeight: FontWeight.w400,
                size: 12.5,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
