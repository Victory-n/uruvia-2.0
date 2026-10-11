import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../account/application/active_account.dart';
import '../../account/application/bootstrap.dart';
import '../../account/data/account_repository.dart';
import '../../auth/application/app_lock.dart';
import '../../invoices/application/invoices_controller.dart';
import '../data/settings_repository.dart';
import '../domain/settings_models.dart';

final alertPrefsProvider = FutureProvider.autoDispose<Map<String, bool>>(
  (ref) => ref.watch(settingsRepositoryProvider).alertPrefs(),
);

final businessDetailsProvider = FutureProvider.autoDispose<BusinessDetails?>((ref) async {
  final account = ref.watch(activeAccountSummaryProvider);
  if (account == null) return null;
  return ref.watch(settingsRepositoryProvider).businessDetails(account.id);
});

class SettingsActions {
  SettingsActions(this._ref);
  final Ref _ref;

  Future<void> setAlert(String kind, bool enabled) async {
    await _ref.read(settingsRepositoryProvider).setAlertPref(kind, enabled);
    _ref.invalidate(alertPrefsProvider);
  }

  Future<void> saveBusiness(BusinessDetails d) async {
    final account = _ref.read(activeAccountSummaryProvider);
    if (account == null) throw StateError('No active account');
    await _ref.read(settingsRepositoryProvider).updateBusiness(account.id, d);
    _ref.invalidate(businessDetailsProvider);
    _ref.invalidate(businessInfoProvider); // invoices read the same details
    _ref.invalidate(bootstrapProvider);
    await _ref.read(bootstrapProvider.future);
  }

  /// true when [current] is the right PIN on this phone.
  Future<bool> checkCurrentPin(String current) => _ref.read(lockPinStoreProvider).verify(current);

  /// Sets the new PIN on the server and on this phone.
  Future<void> changePin(String newPin) async {
    await _ref.read(accountRepositoryProvider).setTransactionPin(newPin);
    await _ref.read(lockPinStoreProvider).save(newPin);
  }
}

final settingsActionsProvider = Provider<SettingsActions>(SettingsActions.new);
