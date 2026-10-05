import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../theme/business/business_theme.dart';
import '../../../widgets/app_text.dart';

class InventoryFilterBar extends StatelessWidget {
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final String selectedStatus; // 'all', 'in_stock', 'low_stock', 'out_of_stock'
  final ValueChanged<String> onStatusChanged;
  final String selectedCategory; // 'all' or category name
  final List<String> availableCategories;
  final ValueChanged<String> onCategoryChanged;

  const InventoryFilterBar({
    super.key,
    required this.searchController,
    required this.onSearchChanged,
    required this.selectedStatus,
    required this.onStatusChanged,
    required this.selectedCategory,
    required this.availableCategories,
    required this.onCategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search Input
        Container(
          decoration: BoxDecoration(
            color: BusinessTheme.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: TextField(
            controller: searchController,
            onChanged: onSearchChanged,
            style: const TextStyle(
              fontSize: 14,
              color: BusinessTheme.charcoal,
              fontFamily: 'Inter',
            ),
            decoration: InputDecoration(
              hintText: 'Search items by name, SKU, category...',
              hintStyle: const TextStyle(
                fontSize: 13,
                color: BusinessTheme.textMuted,
              ),
              prefixIcon: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: FaIcon(
                  FontAwesomeIcons.magnifyingGlass,
                  size: 14,
                  color: BusinessTheme.textMuted,
                ),
              ),
              prefixIconConstraints: const BoxConstraints(minWidth: 40),
              suffixIcon: searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const FaIcon(
                        FontAwesomeIcons.circleXmark,
                        size: 14,
                        color: BusinessTheme.textMuted,
                      ),
                      onPressed: () {
                        searchController.clear();
                        onSearchChanged('');
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Status Filter Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildFilterChip(
                label: 'All Items',
                isSelected: selectedStatus == 'all',
                onTap: () => onStatusChanged('all'),
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                label: 'In Stock',
                isSelected: selectedStatus == 'in_stock',
                onTap: () => onStatusChanged('in_stock'),
                activeColor: BusinessTheme.success,
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                label: 'Low Stock',
                isSelected: selectedStatus == 'low_stock',
                onTap: () => onStatusChanged('low_stock'),
                activeColor: const Color(0xFFD97706),
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                label: 'Out of Stock',
                isSelected: selectedStatus == 'out_of_stock',
                onTap: () => onStatusChanged('out_of_stock'),
                activeColor: BusinessTheme.danger,
              ),
            ],
          ),
        ),

        if (availableCategories.isNotEmpty) ...[
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildCategoryPill(
                  label: 'All Categories',
                  isSelected: selectedCategory.toLowerCase() == 'all',
                  onTap: () => onCategoryChanged('all'),
                ),
                ...availableCategories.map((cat) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 6.0),
                    child: _buildCategoryPill(
                      label: cat,
                      isSelected: selectedCategory.toLowerCase() == cat.toLowerCase(),
                      onTap: () => onCategoryChanged(cat),
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    Color? activeColor,
  }) {
    final effectiveColor = activeColor ?? BusinessTheme.primaryAmber;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? effectiveColor.withValues(alpha: 0.14)
              : BusinessTheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? effectiveColor : Colors.grey.shade200,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: AppText.paragraph(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? effectiveColor : BusinessTheme.textMuted,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryPill({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? BusinessTheme.charcoal
              : BusinessTheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? BusinessTheme.charcoal : Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: AppText.paragraph(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected ? BusinessTheme.white : BusinessTheme.textDark,
          ),
        ),
      ),
    );
  }
}
