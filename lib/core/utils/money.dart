/// Money is stored and passed around as integer kobo (1 naira = 100 kobo)
/// so there are never floating point errors.
String formatNaira(int kobo, {bool showKobo = true}) {
  final negative = kobo < 0;
  final abs = kobo.abs();
  final naira = abs ~/ 100;
  final rest = abs % 100;
  final grouped = naira.toString().replaceAllMapped(
        RegExp(r'\B(?=(\d{3})+(?!\d))'),
        (_) => ',',
      );
  final fraction = showKobo ? '.${rest.toString().padLeft(2, '0')}' : '';
  return '${negative ? '-' : ''}₦$grouped$fraction';
}

/// Turns what a person typed in an amount field ("1,500", "1500.5", "₦ 2,000.25")
/// into integer kobo. Returns null when the text is empty or not a valid amount.
/// More than two decimal places is invalid.
int? parseNairaToKobo(String input) {
  final cleaned = input.replaceAll(RegExp(r'[₦,\s]'), '');
  if (cleaned.isEmpty) return null;
  final match = RegExp(r'^(\d+)(?:\.(\d{0,2}))?$').firstMatch(cleaned);
  if (match == null) return null;
  final whole = match.group(1)!;
  if (whole.length > 12) return null;
  final fraction = (match.group(2) ?? '').padRight(2, '0');
  return int.parse(whole) * 100 + int.parse(fraction);
}
