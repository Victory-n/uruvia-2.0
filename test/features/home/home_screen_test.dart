import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uruvia/app/theme/app_palette.dart';
import 'package:uruvia/features/account/application/active_account.dart';
import 'package:uruvia/features/account/application/profile_name.dart';
import 'package:uruvia/features/account/domain/account_type.dart';
import 'package:uruvia/features/home/application/home_controller.dart';
import 'package:uruvia/features/home/domain/home_models.dart';
import 'package:uruvia/features/home/presentation/home_screen.dart';

class _Business extends ActiveAccount {
  @override
  AccountType build() => AccountType.business;
}

Widget app(HomeData data, {bool business = false, bool fail = false}) {
  return ProviderScope(
    overrides: <Override>[
      profileNameProvider.overrideWithValue('Victory Ndukwe'),
      if (business) activeAccountProvider.overrideWith(_Business.new),
      homeDataProvider.overrideWith((ref) async {
        if (fail) throw Exception('boom');
        return data;
      }),
    ],
    child: MaterialApp(
      theme: ThemeData(extensions: const [AppPalette.individual]),
      home: const Scaffold(body: HomeScreen()),
    ),
  );
}

void tall(WidgetTester t) {
  t.view.physicalSize = const Size(1200, 4000);
  t.view.devicePixelRatio = 3;
  addTearDown(t.view.reset);
}

void main() {
  testWidgets('Individual home: budget progress and recent expenses', (t) async {
    tall(t);
    final data = HomeData(
      summary: const HomeSummary(budgetTotalKobo: 10000000, budgetSpentKobo: 4000000, spentThisMonthKobo: 4000000),
      recentExpenses: [
        RecentExpense(id: '1', amountKobo: 250000, spentAt: DateTime.now(), note: 'Lunch', categoryName: 'Food'),
      ],
    );
    await t.pumpWidget(app(data));
    await t.pumpAndSettle();

    expect(find.textContaining('Victory'), findsOneWidget);
    expect(find.text('Wallet balance'), findsOneWidget);
    expect(find.text('Preview'), findsOneWidget);
    expect(find.textContaining('left'), findsOneWidget);
    expect(find.text('Lunch'), findsOneWidget);
    expect(find.text('Sales today'), findsNothing);
  });

  testWidgets('Individual home: empty states', (t) async {
    tall(t);
    await t.pumpWidget(app(const HomeData(summary: HomeSummary())));
    await t.pumpAndSettle();
    expect(find.text('No expenses yet'), findsOneWidget);
    expect(find.textContaining('Set a budget'), findsOneWidget);
  });

  testWidgets('Business home: tiles and overdue invoice', (t) async {
    tall(t);
    final data = HomeData(
      summary: const HomeSummary(salesTodayKobo: 5000000, outstandingKobo: 2000000, overdueCount: 1, lowStockCount: 3),
      recentInvoices: [
        RecentInvoice(
          id: 'i',
          number: 'INV-0001',
          status: 'sent',
          totalKobo: 2000000,
          balanceKobo: 2000000,
          dueDate: DateTime.now().subtract(const Duration(days: 3)),
          customerName: 'Ada Stores',
        ),
      ],
    );
    await t.pumpWidget(app(data, business: true));
    await t.pumpAndSettle();

    expect(find.text('Sales today'), findsOneWidget);
    expect(find.text('1 overdue'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    expect(find.text('Ada Stores'), findsOneWidget);
    expect(find.text('Overdue'), findsOneWidget);
  });

  testWidgets('Shows Retry when loading fails', (t) async {
    await t.pumpWidget(app(const HomeData(summary: HomeSummary()), fail: true));
    await t.pumpAndSettle();
    expect(find.text('Retry'), findsOneWidget);
  });

  test('effectiveStatus marks past-due sent invoices overdue', () {
    final inv = RecentInvoice(
      id: 'x', number: 'N', status: 'sent', totalKobo: 1, balanceKobo: 1,
      dueDate: DateTime(2026, 10, 1),
    );
    expect(inv.effectiveStatus(now: DateTime(2026, 10, 10)), 'overdue');
    expect(inv.effectiveStatus(now: DateTime(2026, 9, 30)), 'sent');
  });

  test('HomeSummary parses numbers from the database', () {
    final s = HomeSummary.fromJson({'sales_today_kobo': 150000, 'overdue_count': 2, 'low_stock_count': 0});
    expect(s.salesTodayKobo, 150000);
    expect(s.overdueCount, 2);
    expect(s.hasBudget, isFalse);
  });
}
