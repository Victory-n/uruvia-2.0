import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uruvia/core/services/local_store.dart';
import 'package:uruvia/features/auth/application/app_lock.dart';
import 'package:uruvia/features/auth/domain/validators.dart';

class _MemoryStore implements SecureStore {
  final map = <String, String>{};
  @override
  Future<String?> read(String key) async => map[key];
  @override
  Future<void> write(String key, String value) async => map[key] = value;
  @override
  Future<void> delete(String key) async => map.remove(key);
}

void main() {
  group('Validators', () {
    test('email', () {
      expect(Validators.email(''), isNotNull);
      expect(Validators.email('nope'), isNotNull);
      expect(Validators.email(' a@b.co '), isNull);
    });

    test('new password needs 8 characters with letters and numbers', () {
      expect(Validators.newPassword('short1'), isNotNull);
      expect(Validators.newPassword('onlyletters'), isNotNull);
      expect(Validators.newPassword('12345678'), isNotNull);
      expect(Validators.newPassword('goodpass1'), isNull);
    });

    test('code is 6 to 8 digits', () {
      expect(Validators.code('12345'), isNotNull);
      expect(Validators.code('123456'), isNull);
      expect(Validators.code('12345678'), isNull);
      expect(Validators.code('12a456'), isNotNull);
    });

    test('invoice prefix and VAT', () {
      expect(Validators.invoicePrefix('INV'), isNull);
      expect(Validators.invoicePrefix('TOO-LONG-1'), isNotNull);
      expect(Validators.vatPercent('7.5'), isNull);
      expect(Validators.vatPercent('150'), isNotNull);
      expect(Validators.vatToBps('7.5'), 750);
    });

    test('account number is optional but must be 10 digits', () {
      expect(Validators.accountNumber(''), isNull);
      expect(Validators.accountNumber('0123456789'), isNull);
      expect(Validators.accountNumber('123'), isNotNull);
    });
  });

  group('LockPinStore', () {
    test('saves a hash, verifies the right PIN and rejects a wrong one', () async {
      final mem = _MemoryStore();
      final store = LockPinStore(mem);
      expect(await store.hasPin(), isFalse);
      await store.save('1234');
      expect(await store.hasPin(), isTrue);
      expect(mem.map['lock_pin'], isNot(contains('1234')));
      expect(await store.verify('1234'), isTrue);
      expect(await store.verify('1111'), isFalse);
      await store.clear();
      expect(await store.hasPin(), isFalse);
    });
  });

  group('AppLock', () {
    ProviderContainer make() {
      final c = ProviderContainer(overrides: [
        secureStoreProvider.overrideWithValue(_MemoryStore()),
      ]);
      addTearDown(c.dispose);
      return c;
    }

    test('starts locked and unlocks with the right PIN', () async {
      final c = make();
      await c.read(lockPinStoreProvider).save('4321');
      expect(c.read(appLockProvider), isTrue);
      expect(await c.read(appLockProvider.notifier).unlockWithPin('4321'), UnlockResult.ok);
      expect(c.read(appLockProvider), isFalse);
    });

    test('five wrong tries ask for a fresh sign-in', () async {
      final c = make();
      await c.read(lockPinStoreProvider).save('4321');
      final lock = c.read(appLockProvider.notifier);
      for (var i = 0; i < kMaxPinTries - 1; i++) {
        expect(await lock.unlockWithPin('0000'), UnlockResult.wrong);
      }
      expect(await lock.unlockWithPin('0000'), UnlockResult.tooManyTries);
      expect(c.read(appLockProvider), isTrue);
    });

    test('lock() locks again', () {
      final c = make();
      final lock = c.read(appLockProvider.notifier);
      lock.unlock();
      expect(c.read(appLockProvider), isFalse);
      lock.lock();
      expect(c.read(appLockProvider), isTrue);
    });
  });
}
