import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../shared/widgets/app_text.dart';
import '../../../../theme/individual/app_theme.dart';
import '../../../../theme/business/business_theme.dart';

class SupportChannelCard extends StatelessWidget {
  final dynamic icon;
  final Color iconColor;
  final Color iconBackgroundColor;
  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback onTap;
  final bool isBusiness;

  const SupportChannelCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.iconBackgroundColor,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.onTap,
    this.isBusiness = false,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = isBusiness
        ? BusinessTheme.textMuted.withValues(alpha: 0.15)
        : const Color(0xFFF1F5F9);

    final actionButtonBg = isBusiness
        ? BusinessTheme.primaryAmber.withValues(alpha: 0.1)
        : const Color(0xFFF0F7FF);

    final actionButtonTextColor = isBusiness
        ? BusinessTheme.primaryAmber
        : AppTheme.sleekBlue;

    final titleColor = isBusiness
        ? BusinessTheme.textDark
        : AppTheme.textDark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: iconBackgroundColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: FaIcon(
                icon,
                color: iconColor,
                size: 14,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                AppText.custom(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: titleColor,
                  ),
                ),
                const SizedBox(height: 2),
                AppText.custom(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: isBusiness ? BusinessTheme.textMuted : AppTheme.textMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: actionButtonBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: AppText.custom(
                actionLabel,
                style: TextStyle(
                  color: actionButtonTextColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
