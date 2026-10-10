import 'package:flutter_test/flutter_test.dart';
import 'package:uruvia/core/utils/dates.dart';

void main() {
  final now = DateTime(2026, 10, 10, 15);
  test('formatShortDate', () {
    expect(formatShortDate(DateTime(2026, 10, 3), now: now), '3 Oct');
    expect(formatShortDate(DateTime(2025, 1, 5), now: now), '5 Jan 2025');
  });
  test('formatRelative', () {
    expect(formatRelative(DateTime(2026, 10, 10, 14, 59, 30), now: now), 'Just now');
    expect(formatRelative(DateTime(2026, 10, 10, 14, 30), now: now), '30 min ago');
    expect(formatRelative(DateTime(2026, 10, 10, 12), now: now), '3 h ago');
    expect(formatRelative(DateTime(2026, 10, 9, 20), now: now), 'Yesterday');
    expect(formatRelative(DateTime(2026, 10, 1), now: now), '1 Oct');
  });
  test('greetingFor', () {
    expect(greetingFor(DateTime(2026, 1, 1, 8)), 'Good morning');
    expect(greetingFor(DateTime(2026, 1, 1, 13)), 'Good afternoon');
    expect(greetingFor(DateTime(2026, 1, 1, 19)), 'Good evening');
  });
}
