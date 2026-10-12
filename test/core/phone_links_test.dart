import 'package:flutter_test/flutter_test.dart';
import 'package:uruvia/core/utils/phone_links.dart';

void main() {
  test('Nigerian local numbers become international', () {
    expect(internationalDigits('0803 123 4567'), '2348031234567');
    expect(internationalDigits('+234 803 123 4567'), '2348031234567');
    expect(internationalDigits('2348031234567'), '2348031234567');
    expect(internationalDigits('8031234567'), '2348031234567');
    expect(internationalDigits('00234 803 123 4567'), '2348031234567');
  });

  test('unusable numbers give no link', () {
    expect(internationalDigits(null), isNull);
    expect(internationalDigits('abc'), isNull);
    expect(whatsappLink('12'), isNull);
    expect(telLink(''), isNull);
  });

  test('links are well formed', () {
    expect(whatsappLink('08031234567', message: 'Hi there'), 'https://wa.me/2348031234567?text=Hi%20there');
    expect(telLink('08031234567'), 'tel:+2348031234567');
  });
}
