import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:uruvia/app/router/routes.dart';
import 'package:uruvia/app/shell/app_shell.dart';
import 'package:uruvia/app/theme/app_palette.dart';
import 'package:uruvia/features/account/application/active_account.dart';
import 'package:uruvia/features/account/domain/account_type.dart';
import 'package:uruvia/features/notifications/application/notifications_controller.dart';

class _BusinessAccount extends ActiveAccount {
  @override
  AccountType build() => AccountType.business;
}

Widget buildApp({bool business = false}) {
  final router = GoRouter(
    initialLocation: AppRoutes.home,
    routes: [
      ShellRoute(
        builder: (context, state, child) => AppShell(location: state.matchedLocation, child: child),
        routes: [
          GoRoute(path: AppRoutes.home, builder: (_, __) => const Text('home body')),
          GoRoute(path: AppRoutes.wallet, builder: (_, __) => const Text('wallet body')),
        ],
      ),
    ],
  );
  return ProviderScope(
    overrides: <Override>[
      unreadCountProvider.overrideWith((ref) async => 0),
      if (business) activeAccountProvider.overrideWith(_BusinessAccount.new),
    ],
    child: MaterialApp.router(
      theme: ThemeData(extensions: const [AppPalette.individual]),
      routerConfig: router,
    ),
  );
}

void phoneSize(WidgetTester tester) {
  tester.view.physicalSize = const Size(1200, 2400);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
}

void main() {
  testWidgets('Individual sidebar has Wallet and Budget, not Inventory', (tester) async {
    phoneSize(tester);
    await tester.pumpWidget(buildApp());
    expect(find.text('home body'), findsOneWidget);
    expect(find.text('Individual'), findsOneWidget); // header pill

    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();

    expect(find.text('Wallet'), findsOneWidget);
    expect(find.text('Budget'), findsOneWidget);
    expect(find.text('Inventory'), findsNothing);
    expect(find.text('Switch account'), findsOneWidget);
    expect(find.text('Log out'), findsOneWidget);
  });

  testWidgets('Business sidebar has Inventory and a locked Business Hub', (tester) async {
    phoneSize(tester);
    await tester.pumpWidget(buildApp(business: true));

    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();

    expect(find.text('Inventory'), findsOneWidget);
    expect(find.text('Business Hub'), findsOneWidget);
    expect(find.byIcon(Icons.lock_rounded), findsOneWidget);
    expect(find.text('Budget'), findsNothing);
  });

  testWidgets('Tapping a sidebar item opens that screen and closes the drawer', (tester) async {
    phoneSize(tester);
    await tester.pumpWidget(buildApp());

    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Wallet'));
    await tester.pumpAndSettle();

    expect(find.text('wallet body'), findsOneWidget);
    expect(find.text('Log out'), findsNothing);
  });
}
