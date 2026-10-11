import 'package:flutter_test/flutter_test.dart';
import 'package:uruvia/features/wallet/domain/wallet_models.dart';

WalletTx tx(WalletTxKind k, int amount, DateTime at) => WalletTx(
      id: 'x', kind: k, amountKobo: amount, feeKobo: k == WalletTxKind.send ? 5000 : 0,
      status: WalletTxStatus.completed, createdAt: at, counterparty: 'c', reference: 'r',
    );

void main() {
  test('signedKobo is positive for credits and includes the fee for sends', () {
    final now = DateTime(2026, 10, 11, 9);
    expect(tx(WalletTxKind.fund, 100000, now).signedKobo, 100000);
    expect(tx(WalletTxKind.send, 100000, now).signedKobo, -105000);
  });

  test('validateSend checks account, amount, limit and balance', () {
    String? v(int amt, {String acct = '0123456789', int bal = 1000000, int lim = 500000}) =>
        validateSend(amountKobo: amt, balanceKobo: bal, dailyLimitKobo: lim, accountNumber: acct);
    expect(v(100000), isNull);
    expect(v(100000, acct: '123'), isNotNull);
    expect(v(0), isNotNull);
    expect(v(600000), isNotNull);
    expect(v(100000, bal: 102000), isNotNull);
  });

  test('groupByDay keeps order and splits days', () {
    final a = tx(WalletTxKind.fund, 1, DateTime(2026, 10, 11, 10));
    final b = tx(WalletTxKind.fund, 1, DateTime(2026, 10, 11, 8));
    final c = tx(WalletTxKind.fund, 1, DateTime(2026, 10, 10, 8));
    final g = groupByDay([a, b, c]);
    expect(g.length, 2);
    expect(g[DateTime(2026, 10, 11)]!.length, 2);
  });
}
