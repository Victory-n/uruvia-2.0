import 'package:flutter_test/flutter_test.dart';
import 'package:uruvia/core/utils/money.dart';

void main() {
  test('formats kobo as naira', () {
    expect(formatNaira(128450000), '₦1,284,500.00');
    expect(formatNaira(24850000), '₦248,500.00');
    expect(formatNaira(5), '₦0.05');
    expect(formatNaira(-150000, showKobo: false), '-₦1,500');
  });
}
