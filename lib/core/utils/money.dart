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
