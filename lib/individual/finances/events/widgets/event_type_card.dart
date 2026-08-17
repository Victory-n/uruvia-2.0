import 'package:flutter/material.dart';
import 'package:uruvia/constants/colors.dart';
import 'package:uruvia/widgets/custom_text.dart';

class EventTypeCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final String target;
  final VoidCallback? onTap;

  const EventTypeCard({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.target,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Icon(icon, color: color, size: 20.0),
            ),
            const SizedBox(height: 12.0),
            googleSansText(
              text: title,
              colors: ConstantColor.headingTextPrimary,
              fontWeight: FontWeight.bold,
              size: 14.0,
            ),
            const SizedBox(height: 3.0),
            googleSansText(
              text: target,
              colors: ConstantColor.paragraphTextSecondary,
              fontWeight: FontWeight.normal,
              size: 11.5,
            ),
          ],
        ),
      ),
    );
  }
}
