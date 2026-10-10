import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/account_type.dart';
import 'bootstrap.dart';

/// Which account the user is currently using. It drives the theme, the
/// sidebar and the Home screen. It starts from the account saved on the
/// profile; switching (with the PIN check) is added with the switcher.
class ActiveAccount extends Notifier<AccountType> {
  @override
  AccountType build() => ref.watch(bootstrapProvider).valueOrNull?.activeType ?? AccountType.individual;

  void switchTo(AccountType type) => state = type;
}

final activeAccountProvider =
    NotifierProvider<ActiveAccount, AccountType>(ActiveAccount.new);
