import 'package:flutter_test/flutter_test.dart';
import 'package:uruvia/features/expenses/domain/voice_parser.dart';

void main() {
  final now = DateTime(2026, 10, 11, 9, 30);

  test('reads amount, category and date', () {
    final r = parseVoiceExpense('Spent 3,500 naira on lunch yesterday', now: now);
    expect(r.amountKobo, 350000);
    expect(r.categoryHint, 'food');
    expect(r.spentAt.day, 10);
    expect(r.note, 'Spent 3,500 naira on lunch yesterday');
  });

  test('understands k and thousand', () {
    expect(parseVoiceExpense('airtime 2k', now: now).amountKobo, 200000);
    expect(parseVoiceExpense('paid 12 thousand for fuel', now: now).amountKobo, 1200000);
    expect(parseVoiceExpense('2.5k taxi', now: now).amountKobo, 250000);
  });

  test('days ago and today', () {
    expect(parseVoiceExpense('bus 500 2 days ago', now: now).spentAt.day, 9);
    expect(parseVoiceExpense('bus 500', now: now).spentAt, now);
  });

  test('missing pieces stay empty', () {
    final r = parseVoiceExpense('something happened', now: now);
    expect(r.amountKobo, isNull);
    expect(r.categoryHint, isNull);
  });
}
