import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/local_store.dart';

const kPinLength = 4;
const kLockAfter = Duration(minutes: 3);
const kMaxPinTries = 5;

/// Keeps the app-lock PIN on this device only, as a salted hash in secure storage.
class LockPinStore {
  LockPinStore(this._store);
  final SecureStore _store;

  static const _kPin = 'lock_pin';
  static const _kBio = 'lock_biometrics';

  static String _hash(String salt, String pin) {
    var digest = utf8.encode('$salt:$pin');
    for (var i = 0; i < 2000; i++) {
      digest = sha256.convert(digest).bytes;
    }
    return base64Url.encode(digest);
  }

  Future<bool> hasPin() async => (await _store.read(_kPin)) != null;

  Future<void> save(String pin) async {
    final r = Random.secure();
    final salt = base64Url.encode(List<int>.generate(16, (_) => r.nextInt(256)));
    await _store.write(_kPin, '$salt:${_hash(salt, pin)}');
  }

  Future<bool> verify(String pin) async {
    final stored = await _store.read(_kPin);
    if (stored == null) return false;
    final parts = stored.split(':');
    if (parts.length != 2) return false;
    return _hash(parts[0], pin) == parts[1];
  }

  Future<bool> biometricsEnabled() async => (await _store.read(_kBio)) == '1';
  Future<void> setBiometrics(bool on) => on ? _store.write(_kBio, '1') : _store.delete(_kBio);

  Future<void> clear() async {
    await _store.delete(_kPin);
    await _store.delete(_kBio);
  }
}

final lockPinStoreProvider = Provider<LockPinStore>((ref) => LockPinStore(ref.watch(secureStoreProvider)));

/// Whether this device already has an app-lock PIN. Invalidate after saving or clearing it.
final hasLockPinProvider = FutureProvider<bool>((ref) => ref.watch(lockPinStoreProvider).hasPin());

final biometricsEnabledProvider =
    FutureProvider<bool>((ref) => ref.watch(lockPinStoreProvider).biometricsEnabled());

enum UnlockResult { ok, wrong, tooManyTries }

/// true = the lock screen is showing. The app starts locked; signing in or creating
/// the PIN unlocks it. It locks again after 3 minutes in the background or idle.
class AppLock extends Notifier<bool> {
  DateTime _lastActive = DateTime.now();
  DateTime? _pausedAt;
  int _wrongTries = 0;

  @override
  bool build() => true;

  void unlock() {
    _wrongTries = 0;
    _lastActive = DateTime.now();
    state = false;
  }

  void lock() => state = true;

  /// Called on every tap or key press.
  void touch() {
    if (!state) _lastActive = DateTime.now();
  }

  void onPaused() => _pausedAt = DateTime.now();

  void onResumed() {
    final at = _pausedAt;
    _pausedAt = null;
    if (at != null && DateTime.now().difference(at) >= kLockAfter) lock();
  }

  /// Called by a timer: locks when nothing has happened for 3 minutes.
  void checkIdle() {
    if (!state && DateTime.now().difference(_lastActive) >= kLockAfter) lock();
  }

  Future<UnlockResult> unlockWithPin(String pin) async {
    if (await ref.read(lockPinStoreProvider).verify(pin)) {
      unlock();
      return UnlockResult.ok;
    }
    _wrongTries++;
    return _wrongTries >= kMaxPinTries ? UnlockResult.tooManyTries : UnlockResult.wrong;
  }

  Future<bool> unlockWithBiometrics() async {
    final store = ref.read(lockPinStoreProvider);
    if (!await store.biometricsEnabled()) return false;
    final ok = await ref.read(biometricsProvider).authenticate('Unlock Uruvia');
    if (ok) unlock();
    return ok;
  }

  int get triesLeft => kMaxPinTries - _wrongTries;
}

final appLockProvider = NotifierProvider<AppLock, bool>(AppLock.new);
