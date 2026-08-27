import 'package:flutter/material.dart';
import 'package:uruvia/constants/colors.dart';
import 'package:uruvia/shared/widgets/custom_text.dart';

/// Slide 4 Visual Graphic: Intelligent Budgeting & Financial Calculators.
class BudgetAnalyticsGraphic extends StatelessWidget {
  const BudgetAnalyticsGraphic({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 260,
      decoration: BoxDecoration(
        color: ConstantColor.blueBackground.withOpacity(0.04),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 280,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: ConstantColor.blueBackground.withOpacity(0.12),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: ConstantColor.blueBackground.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.insights_rounded,
                            color: ConstantColor.blueBackground,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            interText(
                              text: 'Monthly Budget',
                              colors: ConstantColor.headingTextPrimary,
                              fontWeight: FontWeight.bold,
                              size: 13.0,
                            ),
                            googleSansText(
                              text: 'Smart AI Analytics',
                              colors: ConstantColor.paragraphTextSecondary,
                              fontWeight: FontWeight.normal,
                              size: 11.0,
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: interText(
                        text: 'On Track',
                        colors: Colors.green,
                        fontWeight: FontWeight.bold,
                        size: 10.0,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Simulated Bar Chart Visualization
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildChartBar(height: 40, label: 'Mon', color: Colors.blue.shade200),
                    _buildChartBar(height: 65, label: 'Tue', color: Colors.blue.shade300),
                    _buildChartBar(height: 50, label: 'Wed', color: Colors.blue.shade200),
                    _buildChartBar(height: 85, label: 'Thu', color: ConstantColor.blueBackground),
                    _buildChartBar(height: 60, label: 'Fri', color: Colors.blue.shade300),
                    _buildChartBar(height: 95, label: 'Sat', color: ConstantColor.blueBackground),
                  ],
                ),
                const SizedBox(height: 16),

                // Budget Progress Line
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: 0.68,
                    minHeight: 8,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      ConstantColor.blueBackground,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    googleSansText(
                      text: 'Spent: \$1,240.00',
                      colors: ConstantColor.paragraphTextPrimary,
                      fontWeight: FontWeight.w600,
                      size: 11.0,
                    ),
                    googleSansText(
                      text: 'Limit: \$1,800.00',
                      colors: ConstantColor.paragraphTextSecondary,
                      fontWeight: FontWeight.normal,
                      size: 11.0,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildChartBar({
    required double height,
    required String label,
    required Color color,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: height,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 4),
        googleSansText(
          text: label,
          colors: ConstantColor.paragraphTextSecondary,
          fontWeight: FontWeight.normal,
          size: 9.0,
        ),
      ],
    );
  }
}
