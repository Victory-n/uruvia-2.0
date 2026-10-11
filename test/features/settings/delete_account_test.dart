import 'package:flutter_test/flutter_test.dart';
import 'package:uruvia/core/config/app_links.dart';
import 'package:uruvia/features/settings/domain/delete_account.dart';

void main() {
  test('confirm word accepts DELETE in any case and ignores spaces', () {
    expect(isDeleteConfirmed('DELETE'), isTrue);
    expect(isDeleteConfirmed(' delete '), isTrue);
    expect(isDeleteConfirmed('del'), isFalse);
    expect(isDeleteConfirmed(''), isFalse);
  });

  test('legal links point at uruvia.com over https', () {
    expect(AppLinks.privacy, 'https://uruvia.com/privacy');
    expect(AppLinks.terms, 'https://uruvia.com/terms');
  });
}
