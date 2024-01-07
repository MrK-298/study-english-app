import 'package:english/view/word/WordDetail.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  BuildContext? appContext;
  Future<void> initNotification(BuildContext context) async {
    appContext = context;
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await notificationsPlugin.initialize(
      initializationSettings,
      onSelectNotification: onSelectNotification,
    );
  }

  Future<void> onSelectNotification(String? payload) async {
    if (appContext != null) {
      Navigator.push(
          appContext!,
          MaterialPageRoute(
              builder: (context) => WordDetailPage(word: payload.toString())));
    }
  }

  notificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails('1', 'HeartSteel',
          importance: Importance.max),
    );
  }

  Future showNotification(
      {int id = 0, String? title, String? body, String? payLoad}) async {
    return notificationsPlugin.show(
        id, title, body, await notificationDetails());
  }

  Future scheduleNotification({
    int id = 0,
    String? title,
    String? body,
    TimeOfDay? selectedTime
  }) async {
    late TimeOfDay time;
    final String timezoneIdentifier = 'Asia/Ho_Chi_Minh';
    final now = TZDateTime.now(getLocation(timezoneIdentifier));
    if(selectedTime!=null)
    {
      time = selectedTime;
    }
   late TZDateTime scheduledDate = TZDateTime(
    getLocation(timezoneIdentifier),
    now.year,
    now.month,
    now.day,
    time.hour,
    time.minute,
  );
  if (scheduledDate.isBefore(now)) {
    scheduledDate = scheduledDate.add(const Duration(days: 1));
  }
    return notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      await notificationDetails(),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: title,
    );
  }
}
