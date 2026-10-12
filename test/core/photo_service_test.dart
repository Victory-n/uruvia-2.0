import 'package:flutter_test/flutter_test.dart';
import 'package:uruvia/core/photos/photo_service.dart';

void main() {
  test('file name stems are unique and safe for storage paths', () {
    final stems = {for (var i = 0; i < 200; i++) newFileStem()};
    expect(stems.length, 200);
    expect(stems.every((s) => RegExp(r'^[0-9a-z]+$').hasMatch(s)), isTrue);
  });

  test('StoredFile compares by bucket and path', () {
    expect(const StoredFile('a', 'b/c.jpg'), const StoredFile('a', 'b/c.jpg'));
    expect(const StoredFile('a', 'b/c.jpg'), isNot(const StoredFile('x', 'b/c.jpg')));
  });
}
