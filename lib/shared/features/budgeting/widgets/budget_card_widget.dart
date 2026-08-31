import 'package:flutter/material.dart';
import 'package:uruvia/constants/colors.dart';
import 'package:uruvia/services/currency_service.dart';
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
        return "HARD STOPPED";
      case BudgetStatus.depleted:
        return "DEPLETED";
      case BudgetStatus.warning:
        return "NEAR LIMIT";
      case BudgetStatus.normal:
        return "ON TRACK";
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();
    final double utilization = item.utilizationRatio.clamp(0.0, 1.0);
    final String pctString = (item.utilizationRatio * 100).toStringAsFixed(0);
    final symbol = CurrencyService.instance.activeSymbol;

    return Container(
      margin: const EdgeInsets.only(bottom: 14.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
        border: item.status == BudgetStatus.stopped
            ? Border.all(color: Colors.red.shade400, width: 1.5)
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16.0),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Icon, Category Name, Spent / Allocated, Status Badge
                Row(
                  children: [
                    // Category Icon
                    Container(
                      padding: const EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        color: item.color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Icon(
                        item.icon,
                        color: item.color,
                        size: 22.0,
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
                            text: "Spent: $symbol${item.spentAmount.toStringAsFixed(0)} / $symbol${item.allocatedAmount.toStringAsFixed(0)}",
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
                          text: "$symbol${item.remainingAmount.toStringAsFixed(0)} ($pctString% used)",
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
