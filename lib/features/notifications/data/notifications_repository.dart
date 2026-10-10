import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/supabase_client.dart';
import '../domain/app_notification.dart';

abstract class NotificationsRepository {
  /// Notifications for the user that belong to [accountId] or to no account in particular.
  Future<List<AppNotification>> list(String accountId);
  Future<int> unreadCount(String accountId);
  Future<void> markRead(String id);
  Future<void> markAllRead(String accountId);
}

class SupabaseNotificationsRepository implements NotificationsRepository {
  const SupabaseNotificationsRepository();

  String _scope(String accountId) => 'account_id.is.null,account_id.eq.$accountId';

  @override
  Future<List<AppNotification>> list(String accountId) async {
    final rows = await supabase
        .from('notifications')
        .select('id, kind, title, body, read_at, created_at')
        .or(_scope(accountId))
        .order('created_at', ascending: false)
        .limit(50) as List;
    return [for (final r in rows) AppNotification.fromJson(Map<String, dynamic>.from(r as Map))];
  }

  @override
  Future<int> unreadCount(String accountId) async {
    final rows = await supabase
        .from('notifications')
        .select('id')
        .or(_scope(accountId))
        .isFilter('read_at', null)
        .limit(100) as List;
    return rows.length;
  }

  @override
  Future<void> markRead(String id) async {
    await supabase.from('notifications').update({'read_at': DateTime.now().toUtc().toIso8601String()}).eq('id', id);
  }

  @override
  Future<void> markAllRead(String accountId) async {
    await supabase
        .from('notifications')
        .update({'read_at': DateTime.now().toUtc().toIso8601String()})
        .or(_scope(accountId))
        .isFilter('read_at', null);
  }
}

final notificationsRepositoryProvider =
    Provider<NotificationsRepository>((ref) => const SupabaseNotificationsRepository());
