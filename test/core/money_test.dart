import 'package:flutter_test/flutter_test.dart';
import 'package:uruvia/core/utils/money.dart';

void main() {
  test('formats kobo as naira', () {
    expect(formatNaira(128450000), '₦1,284,500.00');
    expect(formatNaira(24850000), '₦248,500.00');
    expect(formatNaira(5), '₦0.05');
    expect(formatNaira(-150000, showKobo: false), '-₦1,500');
  });

  group('parseNairaToKobo', () {
    test('reads whole naira and kobo', () {
      expect(parseNairaToKobo('1,500'), 150000);
      expect(parseNairaToKobo('1500.5'), 150050);
      expect(parseNairaToKobo('₦ 2,000.25'), 200025);
      expect(parseNairaToKobo('1.'), 100);
      expect(parseNairaToKobo('0.05'), 5);
    });

    test('rejects empty and invalid text', () {
      expect(parseNairaToKobo(''), isNull);
      expect(parseNairaToKobo('abc'), isNull);
      expect(parseNairaToKobo('.5'), isNull);
      expect(parseNairaToKobo('1.234'), isNull);
      expect(parseNairaToKobo('1234567890123'), isNull);
    });

    test('round trips with formatNaira', () {
      expect(formatNaira(parseNairaToKobo('1,284,500.00')!), '₦1,284,500.00');
    });
  });
}
