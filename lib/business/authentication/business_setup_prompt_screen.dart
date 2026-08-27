import 'package:flutter/material.dart';
import 'package:uruvia/constants/colors.dart';
import 'package:uruvia/individual/dashboard.dart';
import 'package:uruvia/shared/widgets/custom_text.dart';
import 'business_registration_screen.dart';

/// One-page onboarding prompt shown after login if user is currently an individual account.
class BusinessSetupPromptScreen extends StatelessWidget {
  final String userName;

  const BusinessSetupPromptScreen({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ConstantColor.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => IndividualDashboard(userName: userName),
                ),
                (route) => false,
              );
            },
            child: interText(
              text: 'Skip',
              colors: ConstantColor.subHeadingTextPrimary,
              fontWeight: FontWeight.w600,
              size: 15.0,
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(flex: 1),

              // Icon / Visual Highlight
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: ConstantColor.blueBackground.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Icon(
                  Icons.storefront_rounded,
                  color: ConstantColor.blueBackground,
                  size: 38,
                ),
              ),
              const SizedBox(height: 28),

              // Headline
              interText(
                text: 'Welcome, $userName!\nWant to set up a business account?',
                colors: ConstantColor.headingTextPrimary,
                fontWeight: FontWeight.bold,
                size: 26.0,
              ),
              const SizedBox(height: 14),

              // Description
              interText(
                text:
                    'Set up your business profile to start accepting payments, issuing digital invoices, and managing multi-currency business wallets.',
                colors: ConstantColor.subHeadingTextPrimary,
                fontWeight: FontWeight.normal,
                size: 15.0,
              ),

              const SizedBox(height: 28),

              // Feature Highlights List
              _buildFeatureRow(
                icon: Icons.receipt_long_rounded,
                title: 'Professional Invoicing',
                subtitle:
                    'Send branded invoices and track payments effortlessly.',
              ),
              const SizedBox(height: 16),
              _buildFeatureRow(
                icon: Icons.account_balance_wallet_rounded,
                title: 'Business Wallets',
                subtitle:
                    'Dedicated multi-currency balances for business transactions.',
              ),

              const Spacer(flex: 2),

              // CTA Buttons
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>
                            BusinessRegistrationScreen(userName: userName),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ConstantColor.blueBackground,
                    foregroundColor: Colors.white,
                    elevation: 3,
                    shadowColor: ConstantColor.blueBackground.withOpacity(0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: interText(
                    text: 'Set Up Business Account',
                    colors: Colors.white,
                    fontWeight: FontWeight.bold,
                    size: 16.0,
                  ),
                ),
              ),
              const SizedBox(height: 14),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) =>
                            IndividualDashboard(userName: userName),
                      ),
                      (route) => false,
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: ConstantColor.subHeadingTextPrimary.withOpacity(
                        0.3,
                      ),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: interText(
                    text: 'Skip for Now',
                    colors: ConstantColor.headingTextPrimary,
                    fontWeight: FontWeight.w600,
                    size: 15.0,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureRow({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: ConstantColor.subHeadingTextPrimary.withOpacity(0.15),
            ),
          ),
          child: Icon(icon, color: ConstantColor.blueBackground, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              interText(
                text: title,
                colors: ConstantColor.headingTextPrimary,
                fontWeight: FontWeight.bold,
                size: 15.0,
              ),
              const SizedBox(height: 2),
              interText(
                text: subtitle,
                colors: ConstantColor.subHeadingTextPrimary,
                fontWeight: FontWeight.normal,
                size: 13.0,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
