import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/material.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  static NotificationService get instance => _instance;

  // Helper untuk menghasilkan ID non‑negatif
  int _positiveHash(String value) => value.hashCode & 0x7fffffff;

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // Inisialisasi zona waktu
    tzdata.initializeTimeZones();
    try {
      final String localName = tz.local.name;
      tz.setLocalLocation(tz.getLocation(localName));
    } catch (_) {
      tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));
    }

    // Android specific: request exact alarm permission (Android 12+)
    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (androidPlugin != null) {
      await androidPlugin.requestExactAlarmsPermission();
      // Runtime notification permission (Android 13+)
      await androidPlugin.requestNotificationsPermission();
    }

    // Buat channel notifikasi (Android 8.0+)
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'food_expiry_channel',
      'Peringatan Kadaluarsa',
      description:
          'Notifikasi untuk makanan yang hampir basi atau sudah kadaluarsa',
      importance: Importance.max,
    );
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _plugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        debugPrint('Notification clicked: ${response.payload}');
      },
    );
  }

  // -----------------------------------------------------------------
  // Jadwalkan notifikasi makanan kadaluarsa
  // -----------------------------------------------------------------
  Future<void> scheduleFoodExpiryNotification({
    required String id,
    required String name,
    required DateTime expiryDate,
  }) async {
    // Hapus notifikasi yang mungkin masih ada
    await cancelNotifications(id);

    final DateTime warningDate = expiryDate.subtract(const Duration(days: 1));

    // 1 hari sebelum kadaluarsa
    if (warningDate.isAfter(DateTime.now())) {
      await _scheduleNotification(
        id: _positiveHash(id),
        title: 'Makanan Hampir Basi! ⚠️',
        body: '$name akan kadaluarsa besok.',
        scheduledDate: warningDate,
      );
    }

    // Pada hari kadaluarsa
    if (expiryDate.isAfter(DateTime.now())) {
      await _scheduleNotification(
        id: _positiveHash(id) + 1,
        title: 'Makanan Kadaluarsa! ❌',
        body: '$name telah kadaluarsa hari ini.',
        scheduledDate: expiryDate,
      );
    }
  }

  // -----------------------------------------------------------------
  // Helper untuk menjadwalkan satu notifikasi
  // -----------------------------------------------------------------
  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    final tz.TZDateTime tzDate = tz.TZDateTime.from(scheduledDate, tz.local);
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tzDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'food_expiry_channel',
          'Peringatan Kadaluarsa',
          channelDescription:
              'Notifikasi untuk makanan yang hampir basi atau sudah kadaluarsa',
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

  // -----------------------------------------------------------------
  // Batalkan semua notifikasi terkait satu ID makanan
  // -----------------------------------------------------------------
  Future<void> cancelNotifications(String id) async {
    final int base = _positiveHash(id);
    await _plugin.cancel(base);
    await _plugin.cancel(base + 1);
  }
}
