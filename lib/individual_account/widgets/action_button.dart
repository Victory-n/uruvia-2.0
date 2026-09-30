import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../shared/widgets/app_text.dart';
import '../../theme/individual/app_theme.dart';

class ActionButton extends StatelessWidget {
  final dynamic icon;
  final String label;
  final VoidCallback onTap;

  const ActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: AppTheme.white,
          elevation: 4,
          shadowColor: AppTheme.sleekBlue.withValues(alpha: 0.1),
          shape: const CircleBorder(),
          child: InkWell(
            onTap: onTap,
            customBorder: const CircleBorder(),
            child: Container(
              padding: const EdgeInsets.all(16),
              child: FaIcon(icon, color: AppTheme.sleekBlue, size: 18),
            ),
          ),
        ),
        const SizedBox(height: 8),
        AppText.paragraph(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
