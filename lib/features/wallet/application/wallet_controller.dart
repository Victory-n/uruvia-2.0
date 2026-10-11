import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/wallet_models.dart';

/// DUMMY wallet. Starts with sample data; funding and sending only change this
/// in-memory state and are lost when the app closes. Swap this notifier for a
/// repository-backed one when the payment partner is connected.
class WalletNotifier extends Notifier<WalletState> {
  int _n = 100;

  @override
  WalletState build() {
    final now = DateTime.now();
    DateTime ago(int hours) => now.subtract(Duration(hours: hours));
    return WalletState(
      info: const WalletInfo(
        balanceKobo: 12540000,
        accountNumber: '9012345678',
        bankName: 'Providus Bank',
        accountName: 'Uruvia / Sample User',
        tierLabel: 'Tier 1 (sample)',
        dailySendLimitKobo: 5000000,
      ),
      transactions: [
        WalletTx(
            id: 'w5',
            kind: WalletTxKind.receive,
            amountKobo: 4500000,
            feeKobo: 0,
            status: WalletTxStatus.completed,
            createdAt: ago(3),
            counterparty: 'Ada Obi',
            reference: 'URV-SAMPLE-0005',
            narration: 'Invoice payment'),
        WalletTx(
            id: 'w4',
            kind: WalletTxKind.send,
            amountKobo: 1500000,
            feeKobo: sampleTransferFeeKobo,
            status: WalletTxStatus.completed,
            createdAt: ago(20),
            counterparty: 'Emeka Stores · 0123456789',
            reference: 'URV-SAMPLE-0004',
            narration: 'Stock top-up'),
        WalletTx(
            id: 'w3',
            kind: WalletTxKind.fund,
            amountKobo: 10000000,
            feeKobo: 0,
            status: WalletTxStatus.completed,
            createdAt: ago(52),
            counterparty: 'Bank transfer',
            reference: 'URV-SAMPLE-0003'),
        WalletTx(
            id: 'w2',
            kind: WalletTxKind.send,
            amountKobo: 800000,
            feeKobo: sampleTransferFeeKobo,
            status: WalletTxStatus.processing,
            createdAt: ago(76),
            counterparty: 'Ngozi Eze · 2034567890',
            reference: 'URV-SAMPLE-0002'),
        WalletTx(
            id: 'w1',
            kind: WalletTxKind.send,
            amountKobo: 200000,
            feeKobo: sampleTransferFeeKobo,
            status: WalletTxStatus.failed,
            createdAt: ago(100),
            counterparty: 'Tunde A. · 3045678901',
            reference: 'URV-SAMPLE-0001',
            narration: 'Failed, not charged'),
      ],
    );
  }

  /// Pretends a bank transfer arrived.
  void fund(int amountKobo) {
    _n++;
    final tx = WalletTx(
      id: 'w$_n',
      kind: WalletTxKind.fund,
      amountKobo: amountKobo,
      feeKobo: 0,
      status: WalletTxStatus.completed,
      createdAt: DateTime.now(),
      counterparty: 'Bank transfer',
      reference: 'URV-SAMPLE-$_n',
    );
    state = WalletState(
      info: _withBalance(state.info.balanceKobo + amountKobo),
      transactions: [tx, ...state.transactions],
    );
  }

  /// Pretends a transfer went out. Returns the new transaction.
  WalletTx send({required int amountKobo, required String accountNumber, required String name, String? narration}) {
    _n++;
    final tx = WalletTx(
      id: 'w$_n',
      kind: WalletTxKind.send,
      amountKobo: amountKobo,
      feeKobo: sampleTransferFeeKobo,
      status: WalletTxStatus.completed,
      createdAt: DateTime.now(),
      counterparty: '$name · $accountNumber',
      reference: 'URV-SAMPLE-$_n',
      narration: narration,
    );
    state = WalletState(
      info: _withBalance(state.info.balanceKobo - amountKobo - sampleTransferFeeKobo),
      transactions: [tx, ...state.transactions],
    );
    return tx;
  }

  WalletInfo _withBalance(int kobo) {
    final i = state.info;
    return WalletInfo(
      balanceKobo: kobo,
      accountNumber: i.accountNumber,
      bankName: i.bankName,
      accountName: i.accountName,
      tierLabel: i.tierLabel,
      dailySendLimitKobo: i.dailySendLimitKobo,
    );
  }
}

final walletProvider = NotifierProvider<WalletNotifier, WalletState>(WalletNotifier.new);
