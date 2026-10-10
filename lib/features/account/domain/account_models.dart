import 'account_type.dart';

class AccountSummary {
  const AccountSummary({required this.id, required this.type, required this.name});
  final String id;
  final AccountType type;
  final String name;
}

/// What the app must know right after sign-in to decide where to go.
class Bootstrap {
  const Bootstrap({
    required this.fullName,
    required this.accounts,
    required this.activeAccountId,
    required this.hasTransactionPin,
  });

  final String? fullName;
  final List<AccountSummary> accounts;
  final String? activeAccountId;
  final bool hasTransactionPin;

  bool get hasAccount => accounts.isNotEmpty;

  AccountType get activeType {
    for (final a in accounts) {
      if (a.id == activeAccountId) return a.type;
    }
    return accounts.isEmpty ? AccountType.individual : accounts.first.type;
  }
}

/// Answers from the three business set-up steps.
class BusinessSetup {
  const BusinessSetup({
    required this.name,
    this.category,
    this.address,
    this.invoicePrefix = 'INV',
    this.vatRateBps = 750,
    this.bankName,
    this.accountNumber,
    this.accountName,
  });

  final String name;
  final String? category;
  final String? address;
  final String invoicePrefix;
  final int vatRateBps;
  final String? bankName;
  final String? accountNumber;
  final String? accountName;

  Map<String, String> get paymentDetails => {
        if ((bankName ?? '').trim().isNotEmpty) 'bank_name': bankName!.trim(),
        if ((accountNumber ?? '').trim().isNotEmpty) 'account_number': accountNumber!.trim(),
        if ((accountName ?? '').trim().isNotEmpty) 'account_name': accountName!.trim(),
      };
}
