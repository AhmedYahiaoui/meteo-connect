import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  late final FlutterLocalNotificationsPlugin _notifications;

  NotificationService() {
    _notifications = FlutterLocalNotificationsPlugin();
  }

  Future<void> initialize() async {
    // Initialize timezone data
    tz.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = IOSInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(initializationSettings);

    // Create a notification channel for Android
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'weather_channel', // id
      'Weather Notifications', // title
      'Channel for weather notifications', // description
      importance: Importance.high,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  Future<bool> requestPermission() async {
    if (Platform.isIOS) {
      return await _notifications
              .resolvePlatformSpecificImplementation<
                  IOSFlutterLocalNotificationsPlugin>()
              ?.requestPermissions(
                alert: true,
                badge: true,
                sound: true,
              ) ??
          false;
    } else {
      final status = await Permission.notification.request();
      return status.isGranted;
    }
  }

  Future<void> scheduleWeatherCheck() async {
    // Schedule daily at 7:30 AM
    await _notifications.zonedSchedule(
      0,
      'Weather Alert',
      'Check today\'s weather for your city',
      _nextInstanceOf730AM(),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'weather_channel channelId',
          'Weather Notifications channelName',
          'Weather Notifications channelDescription',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: IOSNotificationDetails(
          sound: 'default.wav',
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  // tz.TZDateTime _nextInstanceOf730AM() {
  //   final now = tz.TZDateTime.now(tz.local);
  //   var scheduledDate = tz.TZDateTime(
  //     tz.local,
  //     now.year,
  //     now.month,
  //     now.day,
  //     7,
  //     30,
  //   );

  //   if (scheduledDate.isBefore(now)) {
  //     scheduledDate = scheduledDate.add(const Duration(days: 1));
  //   }

  //   return scheduledDate;
  // }

  Future<void> showWeatherAlert(String cityName) async {
    await _notifications.show(
      1, // Different ID from daily reminder
      'Weather Alert for $cityName',
      'Adverse weather conditions expected today. Please check the forecast.',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'channelId : weather_alerts',
          'channelName : Weather Alerts',
          'channelDescription : Weather Alerts',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: IOSNotificationDetails(
          sound: 'default.wav',
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  tz.TZDateTime _nextInstanceOf730AM() {
    final now = tz.TZDateTime.now(tz.local);
    // For testing: Schedule 2 minutes from now
    return now.add(const Duration(minutes: 2));

    // Original implementation
    // var scheduledDate = tz.TZDateTime(
    //   tz.local,
    //   now.year,
    //   now.month,
    //   now.day,
    //   7,
    //   30,
    // );
    // if (scheduledDate.isBefore(now)) {
    //   scheduledDate = scheduledDate.add(const Duration(days: 1));
    // }
    // return scheduledDate;
  }
}
