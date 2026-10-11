import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../account/application/active_account.dart';
import '../../account/domain/account_type.dart';
import '../data/subscription_repository.dart';
import '../domain/plan_models.dart';

final planProvider = FutureProvider.autoDispose<Plan?>((ref) {
  final type = ref.watch(activeAccountProvider);
  return ref.watch(subscriptionRepositoryProvider).planFor(type == AccountType.business ? 'business' : 'individual');
});

/// The live subscription of the active account (kept while screens change, so the sidebar badge does not flicker).
final subscriptionProvider = FutureProvider<Subscription?>((ref) async {
  final account = ref.watch(activeAccountSummaryProvider);
  if (account == null) return null;
  try {
    return await ref.watch(subscriptionRepositoryProvider).current(account.id);
  } catch (_) {
    return null;
  }
});
