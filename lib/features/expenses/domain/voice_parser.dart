/// What we understood from a spoken or typed sentence about spending.
class ExpensePrefill {
  const ExpensePrefill({this.amountKobo, this.note = '', required this.spentAt, this.categoryHint});

  final int? amountKobo;
  final String note;
  final DateTime spentAt;

  /// A word like "food" or "transport" to match against the user's categories.
  final String? categoryHint;
}

const _categoryWords = <String, List<String>>{
  'food': ['lunch', 'dinner', 'breakfast', 'food', 'restaurant', 'groceries', 'grocery', 'snack', 'suya', 'rice'],
  'transport': ['taxi', 'uber', 'bolt', 'fuel', 'petrol', 'bus', 'transport', 'keke', 'okada', 'fare'],
  'airtime': ['airtime', 'data', 'recharge'],
  'bills': ['electricity', 'light', 'nepa', 'bill', 'water', 'rent', 'subscription'],
  'health': ['hospital', 'pharmacy', 'drugs', 'medicine', 'clinic'],
  'shopping': ['shopping', 'clothes', 'shoes', 'market'],
  'entertainment': ['movie', 'cinema', 'party', 'game', 'club'],
};

final _amountPattern = RegExp(r'(?:₦|ngn)?\s*(\d[\d,]*(?:\.\d+)?)\s*(k|thousand|million|m)?\b');

/// Turns a sentence such as "Spent 3,500 naira on lunch yesterday" into form fields.
/// Never throws; fields it cannot find are left empty.
ExpensePrefill parseVoiceExpense(String text, {DateTime? now}) {
  final today = now ?? DateTime.now();
  final lower = text.toLowerCase();

  int? kobo;
  final m = _amountPattern.firstMatch(lower);
  if (m != null) {
    final value = double.tryParse(m.group(1)!.replaceAll(',', ''));
    if (value != null) {
      final mult = switch (m.group(2)) {
        'k' || 'thousand' => 1000,
        'm' || 'million' => 1000000,
        _ => 1,
      };
      final result = (value * mult * 100).round();
      if (result > 0) kobo = result;
    }
  }

  var daysBack = 0;
  final ago = RegExp(r'(\d+)\s+days?\s+ago').firstMatch(lower);
  if (lower.contains('day before yesterday')) {
    daysBack = 2;
  } else if (lower.contains('yesterday') || lower.contains('last night')) {
    daysBack = 1;
  } else if (ago != null) {
    daysBack = int.parse(ago.group(1)!);
  }
  final day = DateTime(today.year, today.month, today.day).subtract(Duration(days: daysBack));
  // Midday keeps the date stable across time zones.
  final spentAt = daysBack == 0 ? today : DateTime(day.year, day.month, day.day, 12);

  String? hint;
  final words = lower.split(RegExp(r'[^a-z]+'));
  outer:
  for (final e in _categoryWords.entries) {
    for (final w in e.value) {
      if (words.contains(w)) {
        hint = e.key;
        break outer;
      }
    }
  }

  final trimmed = text.trim();
  final note = trimmed.isEmpty ? '' : trimmed[0].toUpperCase() + trimmed.substring(1);
  return ExpensePrefill(amountKobo: kobo, note: note, spentAt: spentAt, categoryHint: hint);
}
