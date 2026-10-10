import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/application/app_lock.dart';
import '../../auth/data/auth_repository.dart';
import '../data/account_repository.dart';
import '../domain/account_models.dart';

/// Profile, accounts and PIN status for the signed-in user (null when signed out).
/// It reloads only when the user changes, not on every token refresh.
final bootstrapProvider = FutureProvider<Bootstrap?>((ref) async {
  final uid = ref.watch(sessionProvider.select((s) => s.valueOrNull?.user.id));
  if (uid == null) return null;
  return ref.watch(accountRepositoryProvider).load();
});

/// Where the signed-in user is in the set-up path.
enum AppStage { starting, failed, signedOut, needsAccount, needsPin, ready }

final appStageProvider = Provider<AppStage>((ref) {
  final session = ref.watch(sessionProvider);
  if (session.isLoading && !session.hasValue) return AppStage.starting;
  if (session.valueOrNull == null) return AppStage.signedOut;

  final boot = ref.watch(bootstrapProvider);
  final b = boot.valueOrNull;
  if (b == null) return boot.hasError ? AppStage.failed : AppStage.starting;

  if (!b.hasAccount) return AppStage.needsAccount;

  final lockPin = ref.watch(hasLockPinProvider);
  if (!lockPin.hasValue) return lockPin.hasError ? AppStage.failed : AppStage.starting;
  if (!b.hasTransactionPin || !lockPin.requireValue) return AppStage.needsPin;
  return AppStage.ready;
});
