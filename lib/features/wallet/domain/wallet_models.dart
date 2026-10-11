/// DUMMY wallet data. Nothing here is saved or sent anywhere.
enum WalletTxKind {
  fund('Wallet funded'),
  send('Sent to bank'),
  receive('Money received'),
  fee('Fee');

  const WalletTxKind(this.label);
  final String label;
}

enum WalletTxStatus {
  completed('Completed'),
  processing('Processing'),
  failed('Failed');

  const WalletTxStatus(this.label);
  final String label;
}

class WalletTx {
  const WalletTx({
    required this.id,
    required this.kind,
    required this.amountKobo,
    required this.feeKobo,
    required this.status,
    required this.createdAt,
    required this.counterparty,
    required this.reference,
    this.narration,
  });

  final String id;
  final WalletTxKind kind;

  /// Always positive. Direction comes from [isCredit].
  final int amountKobo;
  final int feeKobo;
  final WalletTxStatus status;
  final DateTime createdAt;
  final String counterparty;
  final String reference;
  final String? narration;

  bool get isCredit => kind == WalletTxKind.fund || kind == WalletTxKind.receive;

  /// Positive for money in, negative for money out (fee included).
  int get signedKobo => isCredit ? amountKobo : -(amountKobo + feeKobo);
}

class WalletInfo {
  const WalletInfo({
    required this.balanceKobo,
    required this.accountNumber,
    required this.bankName,
    required this.accountName,
    required this.tierLabel,
    required this.dailySendLimitKobo,
  });

  final int balanceKobo;
  final String accountNumber;
  final String bankName;
  final String accountName;
  final String tierLabel;
  final int dailySendLimitKobo;
}

class WalletState {
  const WalletState({required this.info, required this.transactions});
  final WalletInfo info;
  final List<WalletTx> transactions;

  WalletTx? byId(String id) {
    for (final t in transactions) {
      if (t.id == id) return t;
    }
    return null;
  }
}

/// Flat fee on a transfer to a bank. Sample value until Providus confirms its fees.
const sampleTransferFeeKobo = 5000; // ₦50.00

/// Why a send cannot go ahead, or null when it can.
String? validateSend({
  required int amountKobo,
  required int balanceKobo,
  required int dailyLimitKobo,
  required String accountNumber,
}) {
  if (!RegExp(r'^\d{10}$').hasMatch(accountNumber)) return 'Enter a 10-digit account number.';
  if (amountKobo <= 0) return 'Enter an amount.';
  if (amountKobo > dailyLimitKobo) return 'This is above your daily send limit.';
  if (amountKobo + sampleTransferFeeKobo > balanceKobo) return 'Your balance is too low for this amount and the fee.';
  return null;
}

/// Groups newest-first transactions by calendar day (keeps order).
Map<DateTime, List<WalletTx>> groupByDay(List<WalletTx> txs) {
  final out = <DateTime, List<WalletTx>>{};
  for (final t in txs) {
    final d = DateTime(t.createdAt.year, t.createdAt.month, t.createdAt.day);
    out.putIfAbsent(d, () => []).add(t);
  }
  return out;
}
