import 'package:flutter_test/flutter_test.dart';
import 'package:uruvia/features/health/domain/health_models.dart';
import 'package:uruvia/features/reports/domain/report_models.dart';

void main() {
  test('health bands', () {
    expect(healthBand(10), HealthBand.needsWork);
    expect(healthBand(40), HealthBand.fair);
    expect(healthBand(72), HealthBand.good);
    expect(healthBand(95), HealthBand.excellent);
  });

  test('overall score is the average', () {
    expect(overallHealthScore(const [HealthFactor('a', 50, ''), HealthFactor('b', 100, '')]), 75);
    expect(overallHealthScore(const []), 0);
  });

  test('bar fraction', () {
    expect(barFraction(50, 100), 0.5);
    expect(barFraction(5, 0), 0);
  });
}
