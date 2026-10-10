import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uruvia/app/theme/app_palette.dart';
import 'package:uruvia/core/widgets/amount_text.dart';
import 'package:uruvia/core/widgets/app_button.dart';
import 'package:uruvia/core/widgets/app_text_field.dart';
import 'package:uruvia/core/widgets/pin_keypad.dart';
import 'package:uruvia/core/widgets/state_views.dart';
import 'package:uruvia/core/widgets/status_chip.dart';

Widget wrap(Widget child) => MaterialApp(
      theme: ThemeData(extensions: const [AppPalette.business]),
      home: Scaffold(body: SingleChildScrollView(child: child)),
    );

void main() {
  group('AmountText', () {
    testWidgets('formats kobo', (tester) async {
      await tester.pumpWidget(wrap(const AmountText(150000)));
      expect(find.text('₦1,500.00'), findsOneWidget);
    });

    testWidgets('masks the amount when hidden', (tester) async {
      await tester.pumpWidget(wrap(const AmountText(150000, hidden: true)));
      expect(find.text('₦ ••••••'), findsOneWidget);
      expect(find.text('₦1,500.00'), findsNothing);
    });

    testWidgets('signs credits and debits', (tester) async {
      await tester.pumpWidget(wrap(const Column(children: [
        AmountText(150000, signed: true),
        AmountText(-150000, signed: true),
      ])));
      expect(find.text('+₦1,500.00'), findsOneWidget);
      expect(find.text('−₦1,500.00'), findsOneWidget);
    });
  });

  testWidgets('StatusChip shows its text', (tester) async {
    await tester.pumpWidget(wrap(const StatusChip('Overdue', tone: StatusTone.error)));
    expect(find.text('Overdue'), findsOneWidget);
  });

  group('AppButton', () {
    testWidgets('calls onPressed', (tester) async {
      var taps = 0;
      await tester.pumpWidget(wrap(AppButton(label: 'Save', onPressed: () => taps++)));
      await tester.tap(find.text('Save'));
      expect(taps, 1);
    });

    testWidgets('ignores taps while loading', (tester) async {
      var taps = 0;
      await tester.pumpWidget(wrap(AppButton(label: 'Save', loading: true, onPressed: () => taps++)));
      await tester.tap(find.byType(FilledButton), warnIfMissed: false);
      expect(taps, 0);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });

  testWidgets('AppTextField password toggle', (tester) async {
    await tester.pumpWidget(wrap(const AppTextField(label: 'Password', obscure: true)));
    expect(find.byTooltip('Show password'), findsOneWidget);
    await tester.tap(find.byTooltip('Show password'));
    await tester.pump();
    expect(find.byTooltip('Hide password'), findsOneWidget);
  });

  testWidgets('PinKeypad reports digits and delete', (tester) async {
    final digits = <int>[];
    var deletes = 0;
    await tester.pumpWidget(wrap(PinKeypad(onDigit: digits.add, onBackspace: () => deletes++)));
    await tester.tap(find.text('5'));
    await tester.tap(find.text('0'));
    await tester.tap(find.byTooltip('Delete'));
    expect(digits, [5, 0]);
    expect(deletes, 1);
  });

  testWidgets('ErrorState offers Retry', (tester) async {
    var retries = 0;
    await tester.pumpWidget(wrap(SizedBox(height: 500, child: ErrorState(onRetry: () => retries++))));
    await tester.tap(find.text('Retry'));
    expect(retries, 1);
  });

  testWidgets('EmptyState shows title and action', (tester) async {
    var taps = 0;
    await tester.pumpWidget(wrap(SizedBox(
      height: 500,
      child: EmptyState(
        icon: Icons.inbox_outlined,
        title: 'No budgets yet',
        actionLabel: 'Create budget',
        onAction: () => taps++,
      ),
    )));
    expect(find.text('No budgets yet'), findsOneWidget);
    await tester.tap(find.text('Create budget'));
    expect(taps, 1);
  });
}
