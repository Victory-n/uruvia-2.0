import 'package:flutter/material.dart';
import 'package:uruvia/constants/colors.dart';
import 'package:uruvia/shared/widgets/custom_text.dart';

/// Reusable selection widget for Account Type (Individual vs Business).
class AccountTypeSelectorWidget extends StatelessWidget {
  final String selectedAccountType;
  final ValueChanged<String> onAccountTypeChanged;

  const AccountTypeSelectorWidget({
    super.key,
    required this.selectedAccountType,
    required this.onAccountTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        googleSansText(
          text: 'Account Type',
          colors: ConstantColor.headingTextPrimary,
          fontWeight: FontWeight.w600,
          size: 13.0,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildTypeCard(
                type: 'individual',
                title: 'Individual',
                subtitle: 'Personal wallet & savings',
                icon: Icons.person_outline_rounded,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTypeCard(
                type: 'business',
                title: 'Business',
                subtitle: 'Inventory & commerce',
                icon: Icons.storefront_outlined,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTypeCard({
    required String type,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final isSelected = selectedAccountType == type;

    return GestureDetector(
      onTap: () => onAccountTypeChanged(type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected
              ? ConstantColor.blueBackground.withOpacity(0.06)
              : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? ConstantColor.blueBackground
                : Colors.grey.shade300,
            width: isSelected ? 2.0 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: ConstantColor.blueBackground.withOpacity(0.12),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected
                    ? ConstantColor.blueBackground
                    : Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected
                    ? Colors.white
                    : ConstantColor.paragraphTextSecondary,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  interText(
                    text: title,
                    colors: isSelected
                        ? ConstantColor.blueBackground
                        : ConstantColor.headingTextPrimary,
                    fontWeight: FontWeight.bold,
                    size: 13.0,
                  ),
                  const SizedBox(height: 2),
                  googleSansText(
                    text: subtitle,
                    colors: ConstantColor.paragraphTextSecondary,
                    fontWeight: FontWeight.normal,
                    size: 10.0,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
