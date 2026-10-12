class AppNotification {
  const AppNotification({
    required this.id,
    required this.kind,
    required this.title,
    required this.createdAt,
    this.body,
    this.readAt,
  });

  final String id;
  final String kind;
  final String title;
  final String? body;
  final DateTime createdAt;
  final DateTime? readAt;

  bool get isRead => readAt != null;

  factory AppNotification.fromJson(Map<String, dynamic> j) => AppNotification(
        id: j['id'] as String,
        kind: j['kind'] as String,
        title: j['title'] as String,
        body: j['body'] as String?,
        createdAt: DateTime.parse(j['created_at'] as String).toLocal(),
        readAt: j['read_at'] == null ? null : DateTime.parse(j['read_at'] as String).toLocal(),
      );
}

/// The tabs on the notifications screen.
enum NotificationGroup {
  all('All'),
  money('Money'),
  business('Business'),
  system('System');

  const NotificationGroup(this.label);
  final String label;
}

/// Which tab a notification belongs to, from its kind. "All" is never returned: it shows everything.
NotificationGroup notificationGroupOf(String kind) {
  if (kind.contains('budget') || kind.contains('expense') || kind.contains('saving') || kind.contains('wallet')) {
    return NotificationGroup.money;
  }
  if (kind.contains('invoice') || kind.contains('stock') || kind.contains('reservation') || kind.contains('sale') || kind.contains('customer')) {
    return NotificationGroup.business;
  }
  return NotificationGroup.system;
}

List<AppNotification> notificationsIn(List<AppNotification> all, NotificationGroup g) =>
    g == NotificationGroup.all ? all : [for (final n in all) if (notificationGroupOf(n.kind) == g) n];
