int _int(Object? v) => (v as num?)?.toInt() ?? 0;

/// The numbers on the Home screen (see the `home_summary` database function).
class HomeSummary {
  const HomeSummary({
    this.spentThisMonthKobo = 0,
    this.budgetTotalKobo = 0,
    this.budgetSpentKobo = 0,
    this.budgetOverCount = 0,
    this.salesTodayKobo = 0,
    this.salesMonthKobo = 0,
    this.outstandingKobo = 0,
    this.overdueCount = 0,
    this.lowStockCount = 0,
  });

  final int spentThisMonthKobo;
  final int budgetTotalKobo;
  final int budgetSpentKobo;
  final int budgetOverCount;
  final int salesTodayKobo;
  final int salesMonthKobo;
  final int outstandingKobo;
  final int overdueCount;
  final int lowStockCount;

  factory HomeSummary.fromJson(Map<String, dynamic> j) => HomeSummary(
        spentThisMonthKobo: _int(j['spent_this_month_kobo']),
        budgetTotalKobo: _int(j['budget_total_kobo']),
        budgetSpentKobo: _int(j['budget_spent_kobo']),
        budgetOverCount: _int(j['budget_over_count']),
        salesTodayKobo: _int(j['sales_today_kobo']),
        salesMonthKobo: _int(j['sales_month_kobo']),
        outstandingKobo: _int(j['outstanding_kobo']),
        overdueCount: _int(j['overdue_count']),
        lowStockCount: _int(j['low_stock_count']),
      );

  bool get hasBudget => budgetTotalKobo > 0;
  int get budgetRemainingKobo => budgetTotalKobo - budgetSpentKobo;
  double get budgetFraction => hasBudget ? budgetSpentKobo / budgetTotalKobo : 0;
}

class RecentExpense {
  const RecentExpense({
    required this.id,
    required this.amountKobo,
    required this.spentAt,
    this.note,
    this.categoryName,
  });
  final String id;
  final int amountKobo;
  final DateTime spentAt;
  final String? note;
  final String? categoryName;

  String get title => (note != null && note!.trim().isNotEmpty) ? note!.trim() : (categoryName ?? 'Expense');
}

class RecentInvoice {
  const RecentInvoice({
    required this.id,
    required this.number,
    required this.status,
    required this.totalKobo,
    required this.balanceKobo,
    required this.dueDate,
    this.customerName,
  });
  final String id;
  final String number;
  final String status;
  final int totalKobo;
  final int balanceKobo;
  final DateTime? dueDate;
  final String? customerName;

  /// A sent or part-paid invoice past its due date counts as overdue even before the nightly job runs.
  String effectiveStatus({DateTime? now}) {
    final today = now ?? DateTime.now();
    final due = dueDate;
    if ((status == 'sent' || status == 'partially_paid') &&
        due != null &&
        DateTime(due.year, due.month, due.day).isBefore(DateTime(today.year, today.month, today.day))) {
      return 'overdue';
    }
    return status;
  }
}

class HomeData {
  const HomeData({
    required this.summary,
    this.recentExpenses = const [],
    this.recentInvoices = const [],
  });
  final HomeSummary summary;
  final List<RecentExpense> recentExpenses;
  final List<RecentInvoice> recentInvoices;
}
