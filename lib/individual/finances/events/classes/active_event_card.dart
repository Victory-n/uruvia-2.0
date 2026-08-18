import 'package:flutter/material.dart';
import 'package:uruvia/constants/colors.dart';
import 'package:uruvia/widgets/custom_text.dart';

class ActiveEventCard extends StatelessWidget {
  final String title;
  final String category;
  final String currentAmount;
  final String targetAmount;
  final double progress;
  final Color color;
  final IconData icon;

  const ActiveEventCard({
    super.key,
    required this.title,
    required this.category,
    required this.currentAmount,
    required this.targetAmount,
    required this.progress,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 18.0),
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
                      size: 14.5,
                    ),
                    googleSansText(
                      text: category,
                      colors: ConstantColor.paragraphTextSecondary,
                      fontWeight: FontWeight.normal,
                      size: 12.0,
                    ),
                  ],
                ),
              ),
              googleSansText(
                text: "$currentAmount / $targetAmount",
                colors: ConstantColor.headingTextPrimary,
                fontWeight: FontWeight.bold,
                size: 13.0,
              ),
            ],
          ),
          const SizedBox(height: 12.0),
          ClipRRect(
            borderRadius: BorderRadius.circular(6.0),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6.0,
              backgroundColor: const Color(0xFFF0F4FA),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }
}
