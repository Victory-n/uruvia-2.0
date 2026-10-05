import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import '../../../../theme/business/business_theme.dart';
import '../../../widgets/app_text.dart';
import '../services/inventory_service.dart';

class InventoryStatsHeader extends StatelessWidget {
  final InventoryStats stats;

  const InventoryStatsHeader({
    super.key,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      symbol: '₦',
      decimalDigits: 0,
    );

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                title: 'Total Stock Value',
                value: currencyFormatter.format(stats.totalCostValue),
                subtitle: '${stats.totalUnits} total units in stock',
                icon: FontAwesomeIcons.boxesStacked,
                iconColor: BusinessTheme.primaryAmber,
                iconBg: BusinessTheme.primaryAmber.withValues(alpha: 0.12),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                title: 'Potential Revenue',
                value: currencyFormatter.format(stats.totalPotentialRevenue),
                subtitle: '${stats.totalDistinctItems} distinct products',
                icon: FontAwesomeIcons.chartLine,
                iconColor: BusinessTheme.success,
                iconBg: BusinessTheme.success.withValues(alpha: 0.12),
              ),
            ),
          ],
        ),
        if (stats.lowStockCount > 0 || stats.outOfStockCount > 0) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: stats.outOfStockCount > 0
                  ? BusinessTheme.danger.withValues(alpha: 0.08)
                  : const Color(0xFFF59E0B).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: stats.outOfStockCount > 0
                    ? BusinessTheme.danger.withValues(alpha: 0.3)
                    : const Color(0xFFF59E0B).withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                FaIcon(
                  FontAwesomeIcons.triangleExclamation,
                  size: 14,
                  color: stats.outOfStockCount > 0
                      ? BusinessTheme.danger
                      : const Color(0xFFD97706),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: AppText.paragraph(
                    stats.outOfStockCount > 0
                        ? '${stats.outOfStockCount} item(s) out of stock, ${stats.lowStockCount} low stock'
                        : '${stats.lowStockCount} item(s) running low on stock',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: stats.outOfStockCount > 0
                          ? BusinessTheme.danger
                          : const Color(0xFFB45309),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String subtitle,
    required dynamic icon,
    required Color iconColor,
    required Color iconBg,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: BusinessTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: FaIcon(icon, size: 14, color: iconColor),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: AppText.paragraph(
                  title,
                  style: const TextStyle(
                    fontSize: 11,
                    color: BusinessTheme.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          AppText.subtitle(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: BusinessTheme.charcoal,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          AppText.paragraph(
            subtitle,
            style: const TextStyle(
              fontSize: 10,
              color: BusinessTheme.textMuted,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
