import 'package:flutter/material.dart';
import 'package:uruvia/constants/colors.dart';
import '../../../widgets/custom_text.dart';

class BudgetFilterBar extends StatelessWidget {
  final String selectedFilter;
  final ValueChanged<String> onFilterChanged;

  const BudgetFilterBar({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        googleSansText(
          text: "Categories",
          colors: ConstantColor.headingTextPrimary,
          fontWeight: FontWeight.bold,
          size: 17.0,
        ),
        Row(
          children: [
            _buildFilterChip('All'),
            const SizedBox(width: 6.0),
            _buildFilterChip('Warning/Depleted'),
          ],
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label) {
    final isSel = selectedFilter == label;
    return ChoiceChip(
      label: googleSansText(
        text: label,
        colors: isSel ? Colors.white : ConstantColor.paragraphTextPrimary,
        fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
        size: 11.5,
      ),
      selected: isSel,
      selectedColor: ConstantColor.blueBackground,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      onSelected: (val) {
        if (val) onFilterChanged(label);
      },
    );
  }
}
