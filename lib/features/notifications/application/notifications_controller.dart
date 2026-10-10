import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../account/application/active_account.dart';
import '../data/notifications_repository.dart';
import '../domain/app_notification.dart';

final notificationsProvider = FutureProvider.autoDispose<List<AppNotification>>((ref) async {
  final account = ref.watch(activeAccountSummaryProvider);
  if (account == null) return const [];
  return ref.watch(notificationsRepositoryProvider).list(account.id);
});

/// Number shown on the bell. A failure just hides the badge.
final unreadCountProvider = FutureProvider.autoDispose<int>((ref) async {
  final account = ref.watch(activeAccountSummaryProvider);
  if (account == null) return 0;
  try {
    return await ref.watch(notificationsRepositoryProvider).unreadCount(account.id);
  } catch (_) {
    return 0;
  }
});

class NotificationsActions {
  NotificationsActions(this._ref);
  final Ref _ref;

  void _refresh() {
    _ref.invalidate(notificationsProvider);
    _ref.invalidate(unreadCountProvider);
  }

  Future<void> markRead(String id) async {
    await _ref.read(notificationsRepositoryProvider).markRead(id);
    _refresh();
  }

  Future<void> markAllRead() async {
    final account = _ref.read(activeAccountSummaryProvider);
    if (account == null) return;
    await _ref.read(notificationsRepositoryProvider).markAllRead(account.id);
    _refresh();
  }
}

final notificationsActionsProvider = Provider<NotificationsActions>(NotificationsActions.new);
