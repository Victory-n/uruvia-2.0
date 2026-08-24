enum WalletAccountType {
  individual,
  businessSme,
}

extension WalletAccountTypeExtension on WalletAccountType {
  bool get isBusiness => this == WalletAccountType.businessSme;
  bool get isIndividual => this == WalletAccountType.individual;

  String get label {
    switch (this) {
      case WalletAccountType.individual:
        return "Personal Virtual Account";
      case WalletAccountType.businessSme:
        return "Business Virtual Account";
    }
  }

  String get badgeText {
    switch (this) {
      case WalletAccountType.individual:
        return "INDIVIDUAL ACCOUNT";
      case WalletAccountType.businessSme:
        return "BUSINESS SME ACCOUNT";
    }
  }
}
