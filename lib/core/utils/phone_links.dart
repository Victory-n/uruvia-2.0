/// Turns a number a person typed into digits with a country code, for wa.me links.
/// Nigerian numbers written 0803... become 234803... . Returns null if it cannot be a phone number.
String? internationalDigits(String? raw, {String countryCode = '234'}) {
  if (raw == null) return null;
  var d = raw.replaceAll(RegExp(r'[^0-9+]'), '');
  if (d.isEmpty) return null;
  final hadPlus = d.startsWith('+');
  d = d.replaceAll('+', '');
  if (hadPlus) {
    // Already international.
  } else if (d.startsWith('00')) {
    d = d.substring(2);
  } else if (d.startsWith('0')) {
    d = '$countryCode${d.substring(1)}';
  } else if (!d.startsWith(countryCode) && d.length <= 10) {
    d = '$countryCode$d';
  }
  return (d.length < 8 || d.length > 15) ? null : d;
}

/// A link that opens WhatsApp on that number, or null when the number is unusable.
String? whatsappLink(String? phone, {String? message}) {
  final d = internationalDigits(phone);
  if (d == null) return null;
  return 'https://wa.me/$d${message == null ? '' : '?text=${Uri.encodeComponent(message)}'}';
}

/// A link that opens the phone dialler, or null when the number is unusable.
String? telLink(String? phone) {
  final d = internationalDigits(phone);
  return d == null ? null : 'tel:+$d';
}
