import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../offline/database_helper.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  static NotificationService get instance => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    // 1. Initialize timezone database
    tz.initializeTimeZones();
    // Default fallback timezone is UTC or Africa/Lagos based on currency NGN
    try {
      tz.setLocalLocation(tz.getLocation('Africa/Lagos'));
    } catch (_) {
      // Fallback
    }

    // 2. Android settings
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // 3. iOS settings
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        );

    // 4. Combine initialization settings
    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    // 5. Initialize the plugin
    await _notificationsPlugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (kDebugMode) {
          print("Notification tapped: ${response.payload}");
        }
      },
    );

    _isInitialized = true;
    if (kDebugMode) {
      print("NotificationService initialized successfully.");
    }
  }

  // Check if notification category is enabled in settings
  Future<bool> _isNotificationCategoryEnabled(String category) async {
    return true;
  }

  // Request alert permissions from user
  Future<bool> requestPermissions() async {
    final bool? iosGranted = await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    final bool? androidGranted = await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();

    return (iosGranted ?? false) || (androidGranted ?? false);
  }

  // Helper to get integer ID from string (needed by flutter_local_notifications)
  int _getUniqueId(String uniqueString) {
    return uniqueString.hashCode.abs() % 100000;
  }

  // Show immediate notification
  Future<void> showInstantNotification(
    String title,
    String body, {
    String? payload,
    String category = 'general',
  }) async {
    final enabled = await _isNotificationCategoryEnabled(category);
    if (!enabled) {
      if (kDebugMode) {
        print("Notification suppressed for category: $category");
      }
      return;
    }

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'uruvia_general_channel',
          'General Alerts',
          channelDescription: 'Used for immediate notifications and alarms',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final id = DateTime.now().millisecondsSinceEpoch.toString();
    await _notificationsPlugin.show(
      id: _getUniqueId(id),
      title: title,
      body: body,
      notificationDetails: details,
      payload: payload,
    );
  }

  // Schedule notification at a specific datetime
  Future<void> scheduleNotification(
    String uniqueId,
    String title,
    String body,
    DateTime scheduledTime, {
    String? payload,
    String category = 'reminder',
  }) async {
    final enabled = await _isNotificationCategoryEnabled(category);
    if (!enabled) {
      if (kDebugMode) {
        print("Scheduled notification suppressed for category: $category");
      }
      return;
    }
    final tz.TZDateTime scheduledTZTime = tz.TZDateTime.from(
      scheduledTime,
      tz.local,
    );

    // If the scheduled time is in the past, fire it immediately or skip
    if (scheduledTZTime.isBefore(DateTime.now())) {
      await showInstantNotification(title, body, payload: payload);
      return;
    }

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'uruvia_reminders_channel',
          'Task Reminders',
          channelDescription:
              'Scheduled reminders for low stock, invoices, and payments',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.zonedSchedule(
      id: _getUniqueId(uniqueId),
      title: title,
      body: body,
      scheduledDate: scheduledTZTime,
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: payload,
    );
  }

  // Cancel scheduled notification
  Future<void> cancelNotification(String uniqueId) async {
    // await _notificationsPlugin.cancel(_getUniqueId(uniqueId));
    await _notificationsPlugin.cancel(id: _getUniqueId(uniqueId));
  }
}
