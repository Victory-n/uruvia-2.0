import 'package:flutter_test/flutter_test.dart';
import 'package:uruvia/features/auth/domain/validators.dart';

void main() {
  test('weakPin rejects easy PINs', () {
    for (final p in ['0000', '1111', '1234', '4321', '2345', '1212', '9876']) {
      expect(Validators.weakPin(p), isNotNull, reason: p);
    }
  });

  test('weakPin accepts ordinary PINs', () {
    for (final p in ['1357', '2580', '4072', '9031']) {
      expect(Validators.weakPin(p), isNull, reason: p);
    }
  });
}
