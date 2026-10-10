import 'package:flutter_test/flutter_test.dart';
import 'package:uruvia/core/utils/dates.dart';
import 'package:uruvia/features/expenses/domain/expense_models.dart';

Expense e(int kobo, String? cat, {String? note}) =>
    Expense(id: '$kobo$cat', amountKobo: kobo, spentAt: DateTime(2026, 10, 5), categoryName: cat, categoryId: cat, note: note);

void main() {
  test('totalsByCategory sums and sorts biggest first', () {
    final totals = totalsByCategory(
      [e(100, 'Food'), e(500, 'Rent'), e(250, 'Food'), e(50, null)],
      const [ExpenseCategory(id: 'Food', name: 'Food', icon: 'restaurant')],
    );
    expect(totals.map((t) => t.name), ['Rent', 'Food', 'No category']);
    expect(totals[1].totalKobo, 350);
    expect(totals[1].icon, 'restaurant');
    expect(totals[2].icon, 'category');
  });

  test('title prefers the note, then the category', () {
    expect(e(1, 'Food', note: ' Lunch ').title, 'Lunch');
    expect(e(1, 'Food').title, 'Food');
    expect(e(1, null).title, 'Expense');
  });

  test('month and day labels', () {
    final now = DateTime(2026, 10, 10, 9);
    expect(formatMonthYear(DateTime(2026, 10)), 'October 2026');
    expect(formatDayHeader(DateTime(2026, 10, 10, 8), now: now), 'Today');
    expect(formatDayHeader(DateTime(2026, 10, 9), now: now), 'Yesterday');
    expect(formatDayHeader(DateTime(2026, 10, 5), now: now), 'Mon 5 Oct');
  });
}
