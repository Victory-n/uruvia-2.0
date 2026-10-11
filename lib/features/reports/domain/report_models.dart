/// DUMMY report data. The free and Pro split is undecided, so these are sample values.
enum ReportPeriod {
  thisMonth('This month'),
  lastMonth('Last month'),
  thisYear('This year');

  const ReportPeriod(this.label);
  final String label;
}

class ReportBar {
  const ReportBar(this.label, this.salesKobo, this.expensesKobo);
  final String label;
  final int salesKobo;
  final int expensesKobo;
}

class TopProduct {
  const TopProduct(this.name, this.unitsSold, this.revenueKobo);
  final String name;
  final int unitsSold;
  final int revenueKobo;
}

class ReportData {
  const ReportData({required this.bars, required this.top});
  final List<ReportBar> bars;
  final List<TopProduct> top;

  int get salesKobo => bars.fold(0, (a, b) => a + b.salesKobo);
  int get expensesKobo => bars.fold(0, (a, b) => a + b.expensesKobo);
  int get profitKobo => salesKobo - expensesKobo;
}

ReportData sampleReport(ReportPeriod p) => switch (p) {
      ReportPeriod.thisMonth => const ReportData(
          bars: [
            ReportBar('Wk 1', 18000000, 9000000),
            ReportBar('Wk 2', 24500000, 11000000),
            ReportBar('Wk 3', 21000000, 12500000),
            ReportBar('Wk 4', 27500000, 10000000),
          ],
          top: [
            TopProduct('Bottled water (pack)', 120, 9600000),
            TopProduct('Rice 50kg', 18, 8100000),
            TopProduct('Vegetable oil 5L', 40, 7200000),
          ],
        ),
      ReportPeriod.lastMonth => const ReportData(
          bars: [
            ReportBar('Wk 1', 15000000, 8000000),
            ReportBar('Wk 2', 19000000, 9500000),
            ReportBar('Wk 3', 17500000, 9000000),
            ReportBar('Wk 4', 22000000, 11500000),
          ],
          top: [
            TopProduct('Rice 50kg', 22, 9900000),
            TopProduct('Bottled water (pack)', 95, 7600000),
            TopProduct('Sugar 1kg', 150, 5250000),
          ],
        ),
      ReportPeriod.thisYear => const ReportData(
          bars: [
            ReportBar('Jun', 61000000, 30000000),
            ReportBar('Jul', 68000000, 34000000),
            ReportBar('Aug', 72500000, 36500000),
            ReportBar('Sep', 79000000, 40000000),
            ReportBar('Oct', 91000000, 42500000),
          ],
          top: [
            TopProduct('Rice 50kg', 210, 94500000),
            TopProduct('Bottled water (pack)', 1100, 88000000),
            TopProduct('Vegetable oil 5L', 380, 68400000),
          ],
        ),
    };

/// Height of a bar from 0 to 1 against the largest value.
double barFraction(int value, int max) => max <= 0 ? 0 : (value / max).clamp(0, 1).toDouble();
