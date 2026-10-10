/// Input rules for the auth screens. Each returns an error message, or null when the value is fine.
class Validators {
  const Validators._();

  static final _email = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]{2,}$');

  static String? email(String value) {
    final v = value.trim();
    if (v.isEmpty) return 'Enter your email.';
    if (!_email.hasMatch(v)) return 'Enter a valid email address.';
    return null;
  }

  static String? fullName(String value) {
    final v = value.trim();
    if (v.length < 2) return 'Enter your full name.';
    if (v.length > 80) return 'That name is too long.';
    return null;
  }

  /// At least 8 characters, with at least one letter and one number.
  static String? newPassword(String value) {
    if (value.length < 8) return 'Use at least 8 characters.';
    if (!RegExp(r'[A-Za-z]').hasMatch(value) || !RegExp(r'[0-9]').hasMatch(value)) {
      return 'Include both letters and numbers.';
    }
    return null;
  }

  static String? password(String value) => value.isEmpty ? 'Enter your password.' : null;

  static String? code(String value) {
    final v = value.trim();
    if (!RegExp(r'^[0-9]{6,8}$').hasMatch(v)) return 'Enter the 6 to 8 digit code from your email.';
    return null;
  }

  static String? businessName(String value) {
    final v = value.trim();
    if (v.isEmpty) return 'Enter your business name.';
    if (v.length > 80) return 'Keep the name under 80 characters.';
    return null;
  }

  /// Invoice prefix: 1 to 8 letters or digits (matches the database rule).
  static String? invoicePrefix(String value) {
    if (!RegExp(r'^[A-Za-z0-9]{1,8}$').hasMatch(value.trim())) {
      return 'Use 1 to 8 letters or numbers.';
    }
    return null;
  }

  /// VAT percent such as 7.5. Returns basis points through [vatToBps].
  static String? vatPercent(String value) {
    final v = double.tryParse(value.trim());
    if (v == null || v < 0 || v > 100) return 'Enter a rate from 0 to 100.';
    return null;
  }

  static int vatToBps(String value) => ((double.tryParse(value.trim()) ?? 0) * 100).round();

  static String? accountNumber(String value) {
    final v = value.trim();
    if (v.isEmpty) return null; // optional
    if (!RegExp(r'^[0-9]{10}$').hasMatch(v)) return 'A Nigerian account number has 10 digits.';
    return null;
  }
}
