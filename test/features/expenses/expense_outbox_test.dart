import 'dart:math';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uruvia/core/connectivity/connectivity.dart';
import 'package:uruvia/features/expenses/data/expense_outbox.dart';

PendingExpense item(String id, String account) => PendingExpense(
      id: id, accountId: account, amountKobo: 150000, spentAt: DateTime.utc(2026, 10, 11, 8), note: 'Cash lunch',
    );

void main() {
  test('outbox keeps expenses per account and removes sent ones', () async {
    SharedPreferences.setMockInitialValues({});
    final outbox = ExpenseOutbox(await SharedPreferences.getInstance());
    expect(outbox.all(), isEmpty);
    await outbox.add(item('a', 'acc1'));
    await outbox.add(item('b', 'acc2'));
    expect(outbox.all().length, 2);
    expect(outbox.forAccount('acc1').single.note, 'Cash lunch');
    expect(outbox.forAccount('acc1').single.amountKobo, 150000);
    await outbox.remove('a');
    expect(outbox.all().single.id, 'b');
  });

  test('a damaged outbox reads as empty', () async {
    SharedPreferences.setMockInitialValues({'outbox.expenses.v1': 'not json'});
    expect(ExpenseOutbox(await SharedPreferences.getInstance()).all(), isEmpty);
  });

  test('newClientId looks like a version 4 uuid and differs each time', () {
    final a = newClientId(Random(1));
    expect(RegExp(r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$').hasMatch(a), isTrue);
    expect(newClientId(Random(2)), isNot(a));
  });

  test('isOnlineFrom reads connectivity results', () {
    expect(isOnlineFrom([ConnectivityResult.none]), isFalse);
    expect(isOnlineFrom([]), isFalse);
    expect(isOnlineFrom([ConnectivityResult.wifi]), isTrue);
    expect(isOnlineFrom([ConnectivityResult.none, ConnectivityResult.mobile]), isTrue);
  });
}
