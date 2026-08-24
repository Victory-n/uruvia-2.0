import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uruvia/constants/colors.dart';
import '../../../widgets/custom_text.dart';
import '../logic/calculator_isolate.dart';

class BreakdownResultsCard extends StatelessWidget {
  final SavingsCalculationResult? result;
  final VoidCallback? onConvertToSavingEvent;

  const BreakdownResultsCard({
    super.key,
    required this.result,
    this.onConvertToSavingEvent,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(symbol: '₦', decimalDigits: 2);

    final double daily = result?.dailyTarget ?? 0.0;
    final double weekly = result?.weeklyTarget ?? 0.0;
    final double biWeekly = result?.biWeeklyTarget ?? 0.0;
    final double monthly = result?.monthlyTarget ?? 0.0;
    final double ratio = result?.incomeRatioPercentage ?? 0.0;
    final String status = result?.feasibilityStatus ?? 'Comfortable';

    Color statusColor;
    if (status == 'Comfortable') {
      statusColor = Colors.green;
    } else if (status == 'Moderate') {
      statusColor = Colors.orange;
    } else {
      statusColor = Colors.redAccent;
    }

    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header & Feasibility Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              googleSansText(
                text: "Savings Required",
                colors: ConstantColor.headingTextPrimary,
                fontWeight: FontWeight.bold,
                size: 16.0,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Row(
                  children: [
                    Icon(Icons.circle, size: 8.0, color: statusColor),
                    const SizedBox(width: 5.0),
                    googleSansText(
                      text: "$status (${ratio.toStringAsFixed(1)}%)",
                      colors: statusColor,
                      fontWeight: FontWeight.bold,
                      size: 11.5,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16.0),

          // 2x2 Grid of Micro Targets
          Row(
            children: [
              Expanded(
                child: _buildRateTile(
                  title: "Daily Target",
                  amount: currencyFormatter.format(daily),
                  icon: Icons.today_outlined,
                  color: ConstantColor.blueBackground,
                ),
              ),
              const SizedBox(width: 10.0),
              Expanded(
                child: _buildRateTile(
                  title: "Weekly Target",
                  amount: currencyFormatter.format(weekly),
                  icon: Icons.calendar_view_week_outlined,
                  color: Colors.purple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10.0),
          Row(
            children: [
              Expanded(
                child: _buildRateTile(
                  title: "Bi-Weekly Target",
                  amount: currencyFormatter.format(biWeekly),
                  icon: Icons.date_range_outlined,
                  color: Colors.teal,
                ),
              ),
              const SizedBox(width: 10.0),
              Expanded(
                child: _buildRateTile(
                  title: "Monthly Target",
                  amount: currencyFormatter.format(monthly),
                  icon: Icons.calendar_month_outlined,
                  color: Colors.deepOrange,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20.0),

          // Convert to Saving Event Button
          SizedBox(
            width: double.infinity,
            height: 48.0,
            child: OutlinedButton.icon(
              onPressed: onConvertToSavingEvent,
              icon: const Icon(Icons.add_task_rounded, color: ConstantColor.blueBackground),
              label: googleSansText(
                text: "Convert to Saving Event",
                colors: ConstantColor.blueBackground,
                fontWeight: FontWeight.bold,
                size: 14.0,
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: ConstantColor.blueBackground, width: 1.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRateTile({
    required String title,
    required String amount,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFC),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16.0),
              const SizedBox(width: 6.0),
              googleSansText(
                text: title,
                colors: ConstantColor.paragraphTextSecondary,
                fontWeight: FontWeight.w500,
                size: 11.5,
              ),
            ],
          ),
          const SizedBox(height: 8.0),
          googleSansText(
            text: amount,
            colors: ConstantColor.headingTextPrimary,
            fontWeight: FontWeight.bold,
            size: 14.5,
          ),
        ],
      ),
    );
  }
}
