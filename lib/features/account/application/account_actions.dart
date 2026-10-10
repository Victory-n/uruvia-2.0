import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/account_repository.dart';
import '../domain/account_type.dart';
import 'bootstrap.dart';

class AccountActions {
  AccountActions(this._ref);
  final Ref _ref;

  AccountRepository get _repo => _ref.read(accountRepositoryProvider);

  /// true when the PIN is right. Throws when the PIN is locked (5 wrong tries).
  Future<bool> verifyPin(String pin) => _repo.verifyTransactionPin(pin);

  /// Makes [type] the active account. The theme and sidebar follow once the profile reloads.
  Future<void> switchTo(AccountType type) async {
    final boot = _ref.read(bootstrapProvider).valueOrNull;
    final target = boot?.accounts.where((a) => a.type == type).firstOrNull;
    if (target == null) return;
    await _repo.setActiveAccount(target.id);
    _ref.invalidate(bootstrapProvider);
    await _ref.read(bootstrapProvider.future);
  }

  Future<void> updateName(String name) async {
    await _repo.updateFullName(name);
    _ref.invalidate(bootstrapProvider);
    await _ref.read(bootstrapProvider.future);
  }
}

final accountActionsProvider = Provider<AccountActions>(AccountActions.new);
