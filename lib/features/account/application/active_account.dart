import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/account_type.dart';

/// Which account the user is currently using. It drives the theme, the
/// sidebar and the Home screen. Later this is loaded from
/// `profiles.active_account_type` after the PIN check on switching.
class ActiveAccount extends Notifier<AccountType> {
  @override
  AccountType build() => AccountType.individual;

  void switchTo(AccountType type) => state = type;
}

final activeAccountProvider =
    NotifierProvider<ActiveAccount, AccountType>(ActiveAccount.new);
