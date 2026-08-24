import 'package:flutter/material.dart';
import 'package:uruvia/constants/colors.dart';
import 'package:uruvia/individual/finances/events/forms/create_saving_event_form.dart';
import '../../../../shared/widgets/custom_text.dart';

class SavingsTypesSheet extends StatelessWidget {
  const SavingsTypesSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const SavingsTypesSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      padding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 32.0),
      // mainAxisSize: MainAxisSize.min,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag Handle
          Center(
            child: Container(
              width: 40.0,
              height: 4.5,
              decoration: BoxDecoration(
                color: const Color(0xFFE0E0E0),
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ),
          const SizedBox(height: 20.0),

          // Modal Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  googleSansText(
                    text: "Select Savings Type",
                    colors: ConstantColor.headingTextPrimary,
                    fontWeight: FontWeight.bold,
                    size: 20.0,
                  ),
                  const SizedBox(height: 2.0),
                  googleSansText(
                    text: "Choose how you want to build your savings",
                    colors: ConstantColor.paragraphTextSecondary,
                    fontWeight: FontWeight.normal,
                    size: 13.0,
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(
                  Icons.close,
                  color: ConstantColor.paragraphTextSecondary,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16.0),

          // 6 Savings Types List
          Flexible(
            child: ListView(
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              children: [
                // 1. Target Goal Savings (Active)
                _buildSavingsTypeCard(
                  context,
                  title: "1. Target Goal Savings",
                  description:
                      "Set a specific monetary target and deadline for personal goals.",
                  icon: Icons.savings_outlined,
                  color: ConstantColor.blueBackground,
                  badgeText: "Active",
                  badgeColor: Colors.green,
                  isEnabled: true,
                  onTap: () {
                    Navigator.pop(context);
                    CreateSavingEventForm.show(
                      context,
                      initialType: 'Target Goal',
                    );
                  },
                ),
                const SizedBox(height: 12.0),

                // 2. Fixed Locked Term Savings (Active)
                _buildSavingsTypeCard(
                  context,
                  title: "2. Fixed / Locked Term Savings",
                  description:
                      "Lock funds for 3, 6, or 12 months to prevent impulse spending.",
                  icon: Icons.lock_clock_outlined,
                  color: Colors.orange,
                  badgeText: "Active",
                  badgeColor: Colors.green,
                  isEnabled: true,
                  onTap: () {
                    Navigator.pop(context);
                    CreateSavingEventForm.show(
                      context,
                      initialType: 'Locked Term',
                    );
                  },
                ),
                const SizedBox(height: 12.0),

                // 3. Group Savings (Collaborative / Office)
                _buildSavingsTypeCard(
                  context,
                  title: "3. Group & Collaborative Savings",
                  description:
                      "Ajo / Esusu shared savings pools for friends, teams, or family.",
                  icon: Icons.groups_outlined,
                  color: Colors.purple,
                  badgeText: "Business / Group Feature",
                  badgeColor: Colors.purple,
                  isEnabled: false,
                  onTap: () {
                    _showInfoSnackBar(
                      context,
                      "Group Savings is available in Business & Team modes.",
                    );
                  },
                ),
                const SizedBox(height: 12.0),

                // 4. Recurring Automated Savings
                _buildSavingsTypeCard(
                  context,
                  title: "4. Recurring Automated Savings",
                  description:
                      "Auto-deduct daily, weekly, or monthly deposits on payday.",
                  icon: Icons.repeat_rounded,
                  color: Colors.teal,
                  badgeText: "Requires Virtual Wallet",
                  badgeColor: Colors.blueGrey,
                  isEnabled: false,
                  onTap: () {
                    _showInfoSnackBar(
                      context,
                      "Requires Virtual Wallet activation.",
                    );
                  },
                ),
                const SizedBox(height: 12.0),

                // 5. Flexible Vault
                _buildSavingsTypeCard(
                  context,
                  title: "5. Flexible Vault (Flexi Savings)",
                  description:
                      "Rainy-day cushion with instant deposits and penalty-free withdrawals.",
                  icon: Icons.bolt_outlined,
                  color: Colors.amber.shade800,
                  badgeText: "Requires Virtual Wallet",
                  badgeColor: Colors.blueGrey,
                  isEnabled: false,
                  onTap: () {
                    _showInfoSnackBar(
                      context,
                      "Requires Virtual Wallet activation.",
                    );
                  },
                ),
                const SizedBox(height: 12.0),

                // 6. Round-Up Spare Change
                _buildSavingsTypeCard(
                  context,
                  title: "6. Round-Up Spare Change",
                  description:
                      "Automatically round up card payments and save the difference.",
                  icon: Icons.monetization_on_outlined,
                  color: Colors.indigo,
                  badgeText: "Requires Virtual Card",
                  badgeColor: Colors.blueGrey,
                  isEnabled: false,
                  onTap: () {
                    _showInfoSnackBar(
                      context,
                      "Requires Virtual Card activation.",
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSavingsTypeCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required String badgeText,
    required Color badgeColor,
    required bool isEnabled,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14.0),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: isEnabled ? Colors.white : const Color(0xFFF9FAFC),
          borderRadius: BorderRadius.circular(14.0),
          border: Border.all(
            color: isEnabled ? color.withOpacity(0.3) : const Color(0xFFEEEEEE),
            width: isEnabled ? 1.2 : 1.0,
          ),
          boxShadow: isEnabled
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Icon(icon, color: color, size: 22.0),
            ),
            const SizedBox(width: 14.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: googleSansText(
                          text: title,
                          colors: ConstantColor.headingTextPrimary,
                          fontWeight: FontWeight.bold,
                          size: 14.5,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8.0,
                          vertical: 3.0,
                        ),
                        decoration: BoxDecoration(
                          color: badgeColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: googleSansText(
                          text: badgeText,
                          colors: badgeColor,
                          fontWeight: FontWeight.bold,
                          size: 10.0,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4.0),
                  googleSansText(
                    text: description,
                    colors: ConstantColor.paragraphTextSecondary,
                    fontWeight: FontWeight.normal,
                    size: 12.5,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showInfoSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: googleSansText(
          text: message,
          colors: Colors.white,
          fontWeight: FontWeight.bold,
          size: 13.0,
        ),
        backgroundColor: ConstantColor.headingTextPrimary,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
