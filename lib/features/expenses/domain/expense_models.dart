import 'package:flutter/material.dart';

class ExpenseCategory {
  const ExpenseCategory({required this.id, required this.name, this.icon = 'category'});
  final String id;
  final String name;
  final String icon;
}

class Expense {
  const Expense({
    required this.id,
    required this.amountKobo,
    required this.spentAt,
    this.categoryId,
    this.categoryName,
    this.note,
  });

  final String id;
  final int amountKobo;
  final DateTime spentAt;
  final String? categoryId;
  final String? categoryName;
  final String? note;

  String get title => (note != null && note!.trim().isNotEmpty) ? note!.trim() : (categoryName ?? 'Expense');
}

/// The category icon names stored in the database, as Flutter icons.
IconData categoryIcon(String name) => switch (name) {
      'restaurant' => Icons.restaurant_rounded,
      'directions_bus' => Icons.directions_bus_rounded,
      'shield' => Icons.shield_outlined,
      'home' => Icons.home_outlined,
      'phone_android' => Icons.phone_android_rounded,
      'school' => Icons.school_outlined,
      'inventory' => Icons.inventory_2_outlined,
      'groups' => Icons.groups_outlined,
      'local_shipping' => Icons.local_shipping_outlined,
      'bolt' => Icons.bolt_rounded,
      'campaign' => Icons.campaign_outlined,
      _ => Icons.sell_outlined,
    };

/// One slice of the insights screen.
class CategoryTotal {
  const CategoryTotal({required this.name, required this.icon, required this.totalKobo});
  final String name;
  final String icon;
  final int totalKobo;
}

/// Groups a month of expenses by category, biggest first. Expenses without a category go under "No category".
List<CategoryTotal> totalsByCategory(List<Expense> expenses, List<ExpenseCategory> categories) {
  final icons = {for (final c in categories) c.id: c.icon};
  final sums = <String, int>{};
  final iconFor = <String, String>{};
  for (final e in expenses) {
    final key = e.categoryName ?? 'No category';
    sums[key] = (sums[key] ?? 0) + e.amountKobo;
    iconFor[key] = icons[e.categoryId] ?? 'category';
  }
  final list = [
    for (final entry in sums.entries)
      CategoryTotal(name: entry.key, icon: iconFor[entry.key]!, totalKobo: entry.value),
  ]..sort((a, b) => b.totalKobo.compareTo(a.totalKobo));
  return list;
}
