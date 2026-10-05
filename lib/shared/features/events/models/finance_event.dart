import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

enum EventType { saving, expenseTracking, groupSavings, budgetPlanning, custom }

extension EventTypeExtension on EventType {
  String get label {
    switch (this) {
      case EventType.saving:
        return 'Saving';
      case EventType.expenseTracking:
        return 'Expense Tracking';
      case EventType.groupSavings:
        return 'Group Savings';
      case EventType.budgetPlanning:
        return 'Budget Planning';
      case EventType.custom:
        return 'Custom Event';
    }
  }

  Color get primaryColor {
    switch (this) {
      case EventType.saving:
        return const Color(0xFF2E7D32);
      case EventType.expenseTracking:
        return const Color(0xFFD97706);
      case EventType.groupSavings:
        return const Color(0xFF9333EA);
      case EventType.budgetPlanning:
        return const Color(0xFF2563EB);
      case EventType.custom:
        return const Color(0xFF0D9488);
    }
  }

  Color get backgroundColor {
    switch (this) {
      case EventType.saving:
        return const Color(0xFFEAF8ED);
      case EventType.expenseTracking:
        return const Color(0xFFFFF4E5);
      case EventType.groupSavings:
        return const Color(0xFFF6EEFA);
      case EventType.budgetPlanning:
        return const Color(0xFFEBF3FC);
      case EventType.custom:
        return const Color(0xFFE6F7F5);
    }
  }

  FaIconData get icon {
    switch (this) {
      case EventType.saving:
        return FontAwesomeIcons.piggyBank;
      case EventType.expenseTracking:
        return FontAwesomeIcons.bullseye;
      case EventType.groupSavings:
        return FontAwesomeIcons.userGroup;
      case EventType.budgetPlanning:
        return FontAwesomeIcons.buildingColumns;
      case EventType.custom:
        return FontAwesomeIcons.wandMagicSparkles;
    }
  }
}

class FinanceEvent {
  final String id;
  final String title;
  final String description;
  final EventType type;
  final double targetAmount;
  final double currentAmount;
  final DateTime? targetDate;
  final int participants;
  final String category;

  const FinanceEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.targetAmount,
    this.currentAmount = 0.0,
    this.targetDate,
    this.participants = 1,
    this.category = 'General',
  });

  double get progress =>
      targetAmount > 0 ? (currentAmount / targetAmount).clamp(0.0, 1.0) : 0.0;
  int get progressPercentage => (progress * 100).round();
  double get remainingAmount =>
      (targetAmount - currentAmount).clamp(0.0, double.infinity);
  bool get isCompleted => currentAmount >= targetAmount;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.name,
      'target_amount': targetAmount,
      'current_amount': currentAmount,
      'target_date': targetDate?.toIso8601String(),
      'participants': participants,
      'category': category,
    };
  }

  factory FinanceEvent.fromMap(Map<String, dynamic> map) {
    return FinanceEvent(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      type: EventType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => EventType.custom,
      ),
      targetAmount: (map['target_amount'] as num).toDouble(),
      currentAmount: (map['current_amount'] as num?)?.toDouble() ?? 0.0,
      targetDate: map['target_date'] != null
          ? DateTime.tryParse(map['target_date'] as String)
          : null,
      participants: (map['participants'] as num?)?.toInt() ?? 1,
      category: (map['category'] as String?) ?? 'General',
    );
  }

  FinanceEvent copyWith({
    String? id,
    String? title,
    String? description,
    EventType? type,
    double? targetAmount,
    double? currentAmount,
    DateTime? targetDate,
    int? participants,
    String? category,
  }) {
    return FinanceEvent(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      targetDate: targetDate ?? this.targetDate,
      participants: participants ?? this.participants,
      category: category ?? this.category,
    );
  }

  static List<FinanceEvent> get initialEvents => [
    FinanceEvent(
      id: 'ev-1',
      title: 'Summer Vacation 2026',
      description:
          'Saving for flight tickets, resort stay, and itinerary in Bali.',
      type: EventType.saving,
      targetAmount: 3500.0,
      currentAmount: 2450.0,
      targetDate: DateTime.now().add(const Duration(days: 90)),
      participants: 2,
      category: 'Travel',
    ),
    FinanceEvent(
      id: 'ev-2',
      title: 'Wedding Reception Budget',
      description: 'Catering, decoration, photography, and venue arrangements.',
      type: EventType.expenseTracking,
      targetAmount: 15000.0,
      currentAmount: 9200.0,
      targetDate: DateTime.now().add(const Duration(days: 120)),
      participants: 2,
      category: 'Celebration',
    ),
    FinanceEvent(
      id: 'ev-3',
      title: 'Colleague Gift & Party Pool',
      description:
          'Pooled savings among team members for team anniversary and gifts.',
      type: EventType.groupSavings,
      targetAmount: 2000.0,
      currentAmount: 1400.0,
      targetDate: DateTime.now().add(const Duration(days: 30)),
      participants: 8,
      category: 'Group',
    ),
    FinanceEvent(
      id: 'ev-4',
      title: 'Q4 Emergency Reserve',
      description:
          'Targeted contingency fund allocation for unexpected expenses.',
      type: EventType.budgetPlanning,
      targetAmount: 10000.0,
      currentAmount: 7500.0,
      targetDate: DateTime.now().add(const Duration(days: 75)),
      participants: 1,
      category: 'Safety',
    ),
  ];
}
