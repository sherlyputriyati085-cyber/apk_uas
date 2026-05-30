import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/material.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();
    // Set the local timezone to the device's default
    // Request exact alarm permission on Android 12+ if not already granted
    try {
      final String localName = tz.local.name;
      tz.setLocalLocation(tz.getLocation(localName));
    } catch (e) {
      tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));
    }
    final androidPlugin = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidPlugin != null) {
      await androidPlugin.requestExactAlarmsPermission();
    }

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        debugPrint('Notification clicked: ${response.payload}');
      },
    );

    // Request permissions for newer Android versions
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
  }

  Future<void> scheduleFoodExpiryNotification({
    required String id,
    required String name,
    required DateTime expiryDate,
  }) async {
    // Attempt to schedule notifications for the item.
    // 1 day before expiry
    final warningDate = expiryDate.subtract(const Duration(days: 1));
    if (warningDate.isAfter(DateTime.now())) {
      await _scheduleNotification(
        id: id.hashCode,
        title: 'Makanan Hampir Basi! ⚠️',
        body: '$name akan kadaluarsa besok.',
        scheduledDate: warningDate,
      );
    }

    // On the expiry date itself
    if (expiryDate.isAfter(DateTime.now())) {
      await _scheduleNotification(
        id: id.hashCode + 1,
        title: 'Makanan Kadaluarsa! ❌',
        body: '$name telah kadaluarsa hari ini.',
        scheduledDate: expiryDate,
      );
    }
  }

  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'food_expiry_channel',
          'Peringatan Kadaluarsa',
          channelDescription: 'Notifikasi untuk makanan yang hampir basi',
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancelNotifications(String id) async {
    await flutterLocalNotificationsPlugin.cancel(id.hashCode);
    await flutterLocalNotificationsPlugin.cancel(id.hashCode + 1);
  }
}
