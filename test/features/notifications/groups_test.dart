import 'package:flutter_test/flutter_test.dart';
import 'package:uruvia/features/notifications/domain/app_notification.dart';

AppNotification n(String kind) => AppNotification(id: kind, kind: kind, title: kind, createdAt: DateTime(2026, 10, 1));

void main() {
  test('kinds map to tabs', () {
    expect(notificationGroupOf('budget_80'), NotificationGroup.money);
    expect(notificationGroupOf('invoice_overdue'), NotificationGroup.business);
    expect(notificationGroupOf('low_stock'), NotificationGroup.business);
    expect(notificationGroupOf('kyc_approved'), NotificationGroup.system);
  });

  test('All shows everything, a tab shows only its own', () {
    final list = [n('budget_80'), n('invoice_overdue'), n('kyc_approved')];
    expect(notificationsIn(list, NotificationGroup.all).length, 3);
    expect(notificationsIn(list, NotificationGroup.business).single.kind, 'invoice_overdue');
  });
}
