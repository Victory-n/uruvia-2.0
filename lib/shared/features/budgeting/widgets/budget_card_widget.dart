import 'package:flutter/material.dart';
import 'package:uruvia/constants/colors.dart';
import '../../../widgets/custom_text.dart';
import '../models/budget_item.dart';

class BudgetCardWidget extends StatelessWidget {
  final BudgetItem item;
  final ValueChanged<bool>? onHardStopToggled;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const BudgetCardWidget({
    super.key,
    required this.item,
    this.onHardStopToggled,
    this.onTap,
    this.onDelete,
  });

  Color _getStatusColor() {
    switch (item.status) {
      case BudgetStatus.stopped:
        return Colors.red.shade700;
      case BudgetStatus.depleted:
        return Colors.redAccent;
      case BudgetStatus.warning:
        return Colors.orangeAccent;
      case BudgetStatus.normal:
        return item.color;
    }
  }

  String _getStatusText() {
    switch (item.status) {
      case BudgetStatus.stopped:
        return 'HARD STOP ACTIVE';
      case BudgetStatus.depleted:
        return 'DEPLETED';
      case BudgetStatus.warning:
        return 'NEAR LIMIT';
      case BudgetStatus.normal:
        return 'ON TRACK';
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();
    final utilization = item.utilizationRatio;
    final pctString = item.utilizationPercentage.toStringAsFixed(0);

    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: item.status == BudgetStatus.stopped
              ? Colors.red.shade300
              : const Color(0xFFEEEEEE),
          width: item.status == BudgetStatus.stopped ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16.0),
        child: InkWell(
          borderRadius: BorderRadius.circular(16.0),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category Header Row
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        item.icon,
                        color: statusColor,
                        size: 20.0,
                      ),
                    ),
                    const SizedBox(width: 12.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          googleSansText(
                            text: item.categoryName,
                            colors: ConstantColor.headingTextPrimary,
                            fontWeight: FontWeight.bold,
                            size: 15.0,
                          ),
                          const SizedBox(height: 2.0),
                          googleSansText(
                            text: "Spent: ₦${item.spentAmount.toStringAsFixed(0)} / ₦${item.allocatedAmount.toStringAsFixed(0)}",
                            colors: ConstantColor.paragraphTextSecondary,
                            fontWeight: FontWeight.w500,
                            size: 12.0,
                          ),
                        ],
                      ),
                    ),
                    // Status Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: googleSansText(
                        text: _getStatusText(),
                        colors: statusColor,
                        fontWeight: FontWeight.bold,
                        size: 9.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14.0),

                // Utilization Progress Bar
                Stack(
                  children: [
                    Container(
                      height: 8.0,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F2F5),
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: utilization,
                      child: Container(
                        height: 8.0,
                        decoration: BoxDecoration(
                          color: statusColor,
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10.0),

                // Footer Row: Remaining Amount & Hard Stop Switch
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        googleSansText(
                          text: "Remaining: ",
                          colors: ConstantColor.paragraphTextSecondary,
                          fontWeight: FontWeight.w500,
                          size: 12.0,
                        ),
                        googleSansText(
                          text: "₦${item.remainingAmount.toStringAsFixed(0)} ($pctString% used)",
                          colors: statusColor,
                          fontWeight: FontWeight.bold,
                          size: 12.0,
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        googleSansText(
                          text: "Hard Stop",
                          colors: ConstantColor.paragraphTextSecondary,
                          fontWeight: FontWeight.w600,
                          size: 11.5,
                        ),
                        const SizedBox(width: 4.0),
                        Transform.scale(
                          scale: 0.7,
                          child: Switch(
                            value: item.isHardStopEnabled,
                            activeColor: Colors.redAccent,
                            onChanged: onHardStopToggled,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
