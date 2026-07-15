import 'package:flutter_test/flutter_test.dart';
import 'package:uruvia/services/vocabulary_map.dart';

void main() {
  group('Expense Parser Tests', () {
    test('Should parse simple amounts and descriptions', () {
      final res = parseExpenseFromText("Bought diesel for 12000");
      expect(res['amount'], 12000.0);
      expect(res['description'], "Diesel");
      expect(res['category'], "Travel");
      expect(res['merchant'], "Generic Merchant");
    });

    test('Should parse Nigerian slang prices (k)', () {
      final res = parseExpenseFromText("Bought garri at mama put for 5k");
      expect(res['amount'], 5000.0);
      expect(res['description'], "Garri");
      expect(res['merchant'], "Mama Put");
      expect(res['category'], "Meals");
    });

    test('Should parse Nigerian slang prices (thousand)', () {
      final res = parseExpenseFromText("spent 15 thousand naira on software subscription at github");
      expect(res['amount'], 15000.0);
      expect(res['description'], "Software subscription");
      expect(res['merchant'], "Github");
      expect(res['category'], "Software");
    });

    test('Should fallback to last number if no prefix is found', () {
      final res = parseExpenseFromText("ride to office 2500");
      expect(res['amount'], 2500.0);
      expect(res['description'], "Ride to office");
      expect(res['category'], "Travel");
    });

    test('Should preserve original casing and slangs for details', () {
      final res = parseExpenseFromText("bought indomie at bukka for 3500");
      expect(res['amount'], 3500.0);
      expect(res['description'], "Indomie");
      expect(res['merchant'], "Bukka");
      expect(res['category'], "Meals");
    });
  });
}
