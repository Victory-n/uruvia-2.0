import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../shared/widgets/app_text.dart';
import '../../../../theme/individual/app_theme.dart';
import '../../../../theme/business/business_theme.dart';

class SupportHeaderCard extends StatelessWidget {
  final bool isBusiness;

  const SupportHeaderCard({
    super.key,
    this.isBusiness = false,
  });

  @override
  Widget build(BuildContext context) {
    final gradientColors = isBusiness
        ? const [BusinessTheme.charcoal, Color(0xFF2D2522)]
        : const [AppTheme.sleekBlue, Color(0xFF142C48)];

    final shadowColor = isBusiness
        ? BusinessTheme.charcoal.withValues(alpha: 0.2)
        : AppTheme.sleekBlue.withValues(alpha: 0.2);

    final iconColor = isBusiness ? BusinessTheme.primaryAmber : AppTheme.sleekBlue;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: FaIcon(
                    isBusiness ? FontAwesomeIcons.headset : FontAwesomeIcons.question,
                    color: iconColor,
                    size: 13,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppText.custom(
                  isBusiness ? 'Business Support Desk' : 'How can we help you?',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          AppText.paragraph(
            isBusiness
                ? 'Need assistance with your merchant account, inventory, invoices, or settlements? Our priority team is here for your business.'
                : 'Have a question, feedback, or a complaint? Reach out to our dedicated support channels or send us a direct message below.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.88),
              fontSize: 13,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}
