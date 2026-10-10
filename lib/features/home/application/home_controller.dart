import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../account/application/active_account.dart';
import '../data/home_repository.dart';
import '../domain/home_models.dart';

/// Home numbers and recent items for the active account. Reloads when the account changes.
final homeDataProvider = FutureProvider.autoDispose<HomeData>((ref) async {
  final account = ref.watch(activeAccountSummaryProvider);
  if (account == null) return const HomeData(summary: HomeSummary());
  return ref.watch(homeRepositoryProvider).load(account);
});
