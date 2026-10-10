import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/account_models.dart';
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

/// The account (id, type, name) the user is currently using.
final activeAccountSummaryProvider = Provider<AccountSummary?>((ref) {
  final type = ref.watch(activeAccountProvider);
  final boot = ref.watch(bootstrapProvider).valueOrNull;
  if (boot == null) return null;
  for (final a in boot.accounts) {
    if (a.type == type) return a;
  }
  return null;
});
