import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../theme/business/business_theme.dart';
import '../../../widgets/app_text.dart';
import '../models/inventory_item.dart';

class StockStatusBadge extends StatelessWidget {
  final InventoryItem item;
  final bool compact;

  const StockStatusBadge({
    super.key,
    required this.item,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    dynamic icon;
    String label;

    if (item.isOutOfStock) {
      bgColor = BusinessTheme.danger.withValues(alpha: 0.12);
      textColor = BusinessTheme.danger;
      icon = FontAwesomeIcons.circleXmark;
      label = 'Out of Stock';
    } else if (item.isLowStock) {
      bgColor = const Color(0xFFF59E0B).withValues(alpha: 0.15); // Warm amber
      textColor = const Color(0xFFD97706);
      icon = FontAwesomeIcons.triangleExclamation;
      label = 'Low Stock (${item.quantity} ${item.unit})';
    } else {
      bgColor = BusinessTheme.success.withValues(alpha: 0.12);
      textColor = BusinessTheme.success;
      icon = FontAwesomeIcons.circleCheck;
      label = 'In Stock (${item.quantity})';
    }

    if (compact) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            FaIcon(icon, size: 10, color: textColor),
            const SizedBox(width: 4),
            AppText.paragraph(
              label,
              style: TextStyle(
                color: textColor,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: textColor.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FaIcon(icon, size: 12, color: textColor),
          const SizedBox(width: 6),
          AppText.paragraph(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
