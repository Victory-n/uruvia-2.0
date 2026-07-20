import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:uruvia/constants/colors.dart';
import 'package:uruvia/widgets/custom_text.dart';
import 'package:uruvia/services/subscription_service.dart';
import 'package:uruvia/services/plan_capabilities.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uruvia/classes/custom_snackbar.dart';

class PaywallDialog extends StatefulWidget {
  final String title;
  final String description;

  const PaywallDialog({
    super.key,
    this.title = "Unlock Uruvia Premium",
    this.description =
        "Get unlimited contacts, OCR scanning, automated reminders, and Business Health analytics.",
  });

  static Future<void> show(
    BuildContext context, {
    String title = "Unlock Uruvia Premium",
    String description =
        "Get unlimited contacts, OCR scanning, automated reminders, and Business Health analytics.",
  }) async {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          PaywallDialog(title: title, description: description),
    );
  }

  @override
  State<PaywallDialog> createState() => _PaywallDialogState();
}

class _PaywallDialogState extends State<PaywallDialog> {
  String _selectedCurrency = 'NGN'; // 'NGN' or 'USD'
  bool _isProcessing = false;

  final Map<String, Map<String, dynamic>> _pricing = {
    'NGN': {
      'amount': '₦5,000',
      'label': 'Local (Paystack)',
      'gateway': 'Paystack',
      'symbol': '₦',
    },
    'USD': {
      'amount': '\$7',
      'label': 'Global (Stripe)',
      'gateway': 'Stripe',
      'symbol': '\$',
    },
  };

  Future<void> _handlePayment() async {
    setState(() => _isProcessing = true);

    final selected = _pricing[_selectedCurrency]!;
    final gateway = selected['gateway'];
    final amount = selected['amount'];

    // Update state via SubscriptionService
    final success = await SubscriptionService.instance.updatePlanType(
      PlanType.premium,
    );

    setState(() => _isProcessing = false);

    if (mounted) {
      Navigator.pop(context);
      final msg = success
          ? "Successfully upgraded to Uruvia Premium via $gateway ($amount)!"
          : "Payment processed! Premium features unlocked.";
      CustomSnackbar.showSuccess(context, msg);
    }
  }

  @override
  Widget build(BuildContext context) {
    final selected = _pricing[_selectedCurrency]!;

    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20.0),

            // Header Banner
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    ConstantColor.headingTextPrimary,
                    ConstantColor.blueBackground,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      CupertinoIcons.sparkles,
                      color: Colors.amber,
                      size: 28.0,
                    ),
                  ),
                  const SizedBox(width: 14.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        googleSansText(
                          text: widget.title,
                          colors: Colors.white,
                          fontWeight: FontWeight.bold,
                          size: 18.0,
                        ),
                        const SizedBox(height: 4.0),
                        googleSansText(
                          text: widget.description,
                          colors: Colors.white70,
                          fontWeight: FontWeight.normal,
                          size: 12.0,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20.0),

            // Included Features Checklist
            googleSansText(
              text: "Everything in Premium:",
              colors: ConstantColor.headingTextPrimary,
              fontWeight: FontWeight.bold,
              size: 15.0,
            ),
            const SizedBox(height: 12.0),

            _buildFeatureRow(
              CupertinoIcons.person_3_fill,
              "Unlimited Customer Contacts",
              "Free plan caps at 10 contacts",
            ),
            _buildFeatureRow(
              CupertinoIcons.chart_bar_square_fill,
              "Business Health & Analytics",
              "Real-time metrics & performance insights",
            ),
            _buildFeatureRow(
              CupertinoIcons.viewfinder,
              "Invoice OCR Scanning",
              "Scan & auto-populate paper invoices instantly",
            ),
            _buildFeatureRow(
              CupertinoIcons.bell_fill,
              "Intelligent Reminders & Auto-Tasks",
              "Smart tracking for overdue payments",
            ),
            _buildFeatureRow(
              CupertinoIcons.doc_plaintext,
              "Expense & Sales Statements",
              "Export PDF & Excel business statements",
            ),

            const SizedBox(height: 20.0),

            // Currency Selector Header
            googleSansText(
              text: "Select Currency & Plan:",
              colors: ConstantColor.headingTextPrimary,
              fontWeight: FontWeight.bold,
              size: 14.0,
            ),
            const SizedBox(height: 10.0),

            // Currency Switcher Segmented Control
            Row(
              children: [
                Expanded(
                  child: _buildCurrencyCard(
                    currencyKey: 'NGN',
                    amount: '₦5,000 / mo',
                    label: 'Local (Paystack)',
                  ),
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: _buildCurrencyCard(
                    currencyKey: 'USD',
                    amount: '\$7 / mo',
                    label: 'Global (Stripe)',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24.0),

            // Subscribe Action Button
            SizedBox(
              width: double.infinity,
              height: 50.0,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _handlePayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ConstantColor.blueBackground,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  elevation: 0.0,
                ),
                child: _isProcessing
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            CupertinoIcons.lock_open_fill,
                            color: Colors.white,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          googleSansText(
                            text: "Upgrade Now (${selected['amount']}/mo)",
                            colors: Colors.white,
                            fontWeight: FontWeight.bold,
                            size: 16.0,
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 10.0),

            // Dismiss Button
            Center(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: googleSansText(
                  text: "Maybe Later",
                  colors: ConstantColor.paragraphTextSecondary,
                  fontWeight: FontWeight.w500,
                  size: 14.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6.0),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Icon(icon, color: ConstantColor.blueBackground, size: 18.0),
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                googleSansText(
                  text: title,
                  colors: ConstantColor.headingTextPrimary,
                  fontWeight: FontWeight.bold,
                  size: 13.5,
                ),
                googleSansText(
                  text: subtitle,
                  colors: ConstantColor.paragraphTextSecondary,
                  fontWeight: FontWeight.normal,
                  size: 11.5,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencyCard({
    required String currencyKey,
    required String amount,
    required String label,
  }) {
    final isSelected = _selectedCurrency == currencyKey;

    return InkWell(
      onTap: () => setState(() => _selectedCurrency = currencyKey),
      borderRadius: BorderRadius.circular(12.0),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 14.0),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEFF6FF) : Colors.grey.shade50,
          border: Border.all(
            color: isSelected
                ? ConstantColor.blueBackground
                : Colors.grey.shade300,
            width: isSelected ? 2.0 : 1.0,
          ),
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Column(
          children: [
            googleSansText(
              text: amount,
              colors: isSelected
                  ? ConstantColor.blueBackground
                  : ConstantColor.headingTextPrimary,
              fontWeight: FontWeight.bold,
              size: 15.0,
            ),
            const SizedBox(height: 2.0),
            googleSansText(
              text: label,
              colors: ConstantColor.paragraphTextSecondary,
              fontWeight: FontWeight.normal,
              size: 11.0,
            ),
          ],
        ),
      ),
    );
  }
}
