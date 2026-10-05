import 'dart:io';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import '../../../../theme/business/business_theme.dart';
import '../../../widgets/app_text.dart';
import '../models/inventory_item.dart';
import 'stock_status_badge.dart';

class InventoryItemCard extends StatelessWidget {
  final InventoryItem item;
  final VoidCallback onTap;
  final VoidCallback onRestock;
  final VoidCallback onDeduct;
  final VoidCallback onEdit;

  const InventoryItemCard({
    super.key,
    required this.item,
    required this.onTap,
    required this.onRestock,
    required this.onDeduct,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      symbol: '₦',
      decimalDigits: 0,
    );
    final bool hasImage = item.imagePath != null &&
        item.imagePath!.isNotEmpty &&
        File(item.imagePath!).existsSync();

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: BusinessTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: item.isOutOfStock
                ? BusinessTheme.danger.withValues(alpha: 0.3)
                : item.isLowStock
                    ? const Color(0xFFF59E0B).withValues(alpha: 0.3)
                    : Colors.grey.shade200,
            width: item.isLowStock || item.isOutOfStock ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Item Image / Icon, Name, Category & Stock Badge
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (hasImage)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      File(item.imagePath!),
                      width: 44,
                      height: 44,
                      fit: BoxFit.cover,
                    ),
                  )
                else
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: item.isOutOfStock
                          ? BusinessTheme.danger.withValues(alpha: 0.1)
                          : item.isLowStock
                              ? const Color(0xFFF59E0B).withValues(alpha: 0.1)
                              : BusinessTheme.primaryAmber.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: FaIcon(
                      item.isOutOfStock
                          ? FontAwesomeIcons.boxOpen
                          : FontAwesomeIcons.box,
                      size: 18,
                      color: item.isOutOfStock
                          ? BusinessTheme.danger
                          : item.isLowStock
                              ? const Color(0xFFD97706)
                              : BusinessTheme.primaryAmber,
                    ),
                  ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText.subtitle(
                        item.itemName,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: BusinessTheme.charcoal,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          AppText.paragraph(
                            item.category,
                            style: const TextStyle(
                              fontSize: 11,
                              color: BusinessTheme.textMuted,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (item.sku.isNotEmpty) ...[
                            const SizedBox(width: 6),
                            Container(
                              width: 3,
                              height: 3,
                              decoration: const BoxDecoration(
                                color: BusinessTheme.textMuted,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            AppText.paragraph(
                              'SKU: ${item.sku}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: BusinessTheme.textMuted,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                StockStatusBadge(item: item, compact: true),
              ],
            ),
            const SizedBox(height: 14),

            // Mid Row: Quantity Counter & Financial Details
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: BusinessTheme.backgroundLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const AppText.paragraph(
                        'In Stock',
                        style: TextStyle(
                          fontSize: 10,
                          color: BusinessTheme.textMuted,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          AppText.title(
                            '${item.quantity}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: item.isOutOfStock
                                  ? BusinessTheme.danger
                                  : item.isLowStock
                                      ? const Color(0xFFD97706)
                                      : BusinessTheme.charcoal,
                            ),
                          ),
                          const SizedBox(width: 4),
                          AppText.paragraph(
                            item.unit,
                            style: const TextStyle(
                              fontSize: 11,
                              color: BusinessTheme.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const AppText.paragraph(
                        'Selling Price',
                        style: TextStyle(
                          fontSize: 10,
                          color: BusinessTheme.textMuted,
                        ),
                      ),
                      const SizedBox(height: 2),
                      AppText.subtitle(
                        currencyFormatter.format(item.sellingPrice),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: BusinessTheme.charcoal,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const AppText.paragraph(
                        'Margin',
                        style: TextStyle(
                          fontSize: 10,
                          color: BusinessTheme.textMuted,
                        ),
                      ),
                      const SizedBox(height: 2),
                      AppText.paragraph(
                        '+${item.profitMarginPercentage.toStringAsFixed(0)}%',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: BusinessTheme.success,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Bottom Actions Bar: Quick Restock, Quick Deduct, and Edit
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onRestock,
                    icon: const FaIcon(FontAwesomeIcons.plus, size: 11),
                    label: const AppText.button(
                      'Restock',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      foregroundColor: BusinessTheme.charcoal,
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onDeduct,
                    icon: const FaIcon(FontAwesomeIcons.minus, size: 11),
                    label: const AppText.button(
                      'Record Sale',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      foregroundColor: BusinessTheme.charcoal,
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: onEdit,
                  icon: const FaIcon(
                    FontAwesomeIcons.penToSquare,
                    size: 14,
                    color: BusinessTheme.textMuted,
                  ),
                  tooltip: 'Edit Item',
                  style: IconButton.styleFrom(
                    backgroundColor: BusinessTheme.backgroundLight,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
