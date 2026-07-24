import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../models/prayer_models.dart';

class NotificationService {
  final _plugin = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    tz.initializeTimeZones();
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  Future<void> schedulePrayerNotifications(PrayerTimes times) async {
    await _plugin.cancelAll();
    var id = 100;
    for (final entry in times.values.entries) {
      if (entry.key == 'Sunrise') continue;
      final parts = entry.value.split(':');
      var moment = DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
        int.parse(parts[0]),
        int.parse(parts[1]),
      );
      if (moment.isBefore(DateTime.now())) {
        moment = moment.add(const Duration(days: 1));
      }
      await _plugin.zonedSchedule(
        id++,
        '${entry.key} prayer',
        'It is time for ${entry.key}.',
        tz.TZDateTime.from(moment, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'prayer_times',
            'Prayer times',
            channelDescription: 'Prayer time reminders',
            importance: Importance.max,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  Future<void> scheduleDailyHadith({
    int hour = 9,
    int minute = 0,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    await _plugin.zonedSchedule(
      50,
      'Hadith of the Day',
      'Open Al-Quran to read today’s verified Hadith and reference.',
      scheduled,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_hadith',
          'Daily Hadith',
          channelDescription: 'Daily verified Hadith reminder',
          importance: Importance.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }
}
