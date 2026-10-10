import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../account/application/bootstrap.dart';
import '../../account/data/account_repository.dart';
import '../../account/domain/account_models.dart';
import '../data/auth_repository.dart';
import 'app_lock.dart';

/// The things screens can ask for. Each method throws on failure; screens show `friendlyError`.
class AuthActions {
  AuthActions(this._ref);
  final Ref _ref;

  AuthRepository get _auth => _ref.read(authRepositoryProvider);
  AccountRepository get _accounts => _ref.read(accountRepositoryProvider);

  Future<void> signIn(String email, String password) async {
    await _auth.signIn(email, password);
    _ref.read(appLockProvider.notifier).unlock();
  }

  Future<bool> signUp(String fullName, String email, String password) async {
    final needsCode = await _auth.signUp(fullName: fullName, email: email, password: password);
    if (!needsCode) _ref.read(appLockProvider.notifier).unlock();
    return needsCode;
  }

  Future<void> verifySignUpCode(String email, String code) async {
    await _auth.verifySignUpCode(email, code);
    _ref.read(appLockProvider.notifier).unlock();
  }

  Future<void> resendSignUpCode(String email) => _auth.resendSignUpCode(email);
  Future<void> sendResetCode(String email) => _auth.sendResetCode(email);

  Future<void> resetPassword(String email, String code, String newPassword) async {
    await _auth.resetPassword(email: email, code: code, newPassword: newPassword);
    _ref.read(appLockProvider.notifier).unlock();
  }

  Future<void> signOut() async {
    await _ref.read(lockPinStoreProvider).clear();
    _ref.invalidate(hasLockPinProvider);
    await _auth.signOut();
  }

  Future<void> createIndividualAccount() async {
    final name = _ref.read(bootstrapProvider).valueOrNull?.fullName?.trim();
    await _accounts.createIndividual((name == null || name.isEmpty) ? 'Personal' : name);
    _ref.invalidate(bootstrapProvider);
    await _ref.read(bootstrapProvider.future);
  }

  Future<void> createBusinessAccount(BusinessSetup setup) async {
    await _accounts.createBusiness(setup);
    _ref.invalidate(bootstrapProvider);
    await _ref.read(bootstrapProvider.future);
  }

  /// Saves the PIN on this device, and on the server when the user has none yet.
  Future<void> createPin(String pin, {required bool enableBiometrics}) async {
    final boot = _ref.read(bootstrapProvider).valueOrNull;
    if (boot != null && !boot.hasTransactionPin) {
      await _accounts.setTransactionPin(pin);
    }
    final store = _ref.read(lockPinStoreProvider);
    await store.save(pin);
    await store.setBiometrics(enableBiometrics);
    _ref.read(appLockProvider.notifier).unlock();
    _ref.invalidate(bootstrapProvider);
    _ref.invalidate(biometricsEnabledProvider);
    await _ref.read(bootstrapProvider.future);
    _ref.invalidate(hasLockPinProvider); // last: this moves the router on
  }
}

final authActionsProvider = Provider<AuthActions>(AuthActions.new);
