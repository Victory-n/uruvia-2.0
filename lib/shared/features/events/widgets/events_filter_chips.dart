import 'package:flutter/material.dart';
import '../../../widgets/app_text.dart';

class EventsFilterChips extends StatelessWidget {
  final String selectedCategory;
  final ValueChanged<String> onSelected;

  static const List<String> categories = [
    'All',
    'Saving',
    'Expense Tracking',
    'Group Savings',
    'Budget Planning',
  ];

  const EventsFilterChips({
    super.key,
    required this.selectedCategory,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categories.map((cat) {
          final isSelected = selectedCategory == cat;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: AppText.button(
                cat,
                style: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF475569),
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              selected: isSelected,
              selectedColor: const Color(0xFF0060E6),
              backgroundColor: Colors.white,
              side: BorderSide(
                color: isSelected
                    ? const Color(0xFF0060E6)
                    : const Color(0xFFE2E8F0),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              onSelected: (selected) {
                if (selected) {
                  onSelected(cat);
                }
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}
