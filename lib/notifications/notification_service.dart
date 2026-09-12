//習慣・タスクのローカル通知をまとめて管理
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:habitapp/models/habit.dart';
import 'package:habitapp/models/task.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const String _habitIdsKey = 'scheduled_habit_notification_ids';
  static const String _taskIdsKey = 'scheduled_task_notification_ids';

  static Future<void> initialize() async {
    if (kIsWeb) return;

    tz_data.initializeTimeZones();

    try {
      final timezone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timezone.identifier));
    } catch (_) {
      //端末のタイムゾーン取得に失敗した場合はUTCのまま使う
    }

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwin = DarwinInitializationSettings();

    await _plugin.initialize(
      settings: const InitializationSettings(
        android: android,
        iOS: darwin,
        macOS: darwin,
      ),
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    await _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  static NotificationDetails get _details => const NotificationDetails(
        android: AndroidNotificationDetails(
          'habitapp_reminders',
          'HabitApp reminders',
          channelDescription: '習慣とタスクのリマインダー',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
        macOS: DarwinNotificationDetails(),
      );

  //ID文字列から毎回同じ通知IDを作る
  static int _stableId(String value) {
    var hash = 17;
    for (final code in value.codeUnits) {
      hash = (hash * 31 + code) & 0x7fffffff;
    }
    return hash;
  }

  static int _weekdayNumber(String day) {
    const map = {
      '月': DateTime.monday,
      '火': DateTime.tuesday,
      '水': DateTime.wednesday,
      '木': DateTime.thursday,
      '金': DateTime.friday,
      '土': DateTime.saturday,
      '日': DateTime.sunday,
    };
    return map[day] ?? DateTime.monday;
  }

  static Future<void> _cancelSavedIds(String key) async {
    if (kIsWeb) return;

    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList(key) ?? const [];

    for (final id in ids) {
      final parsed = int.tryParse(id);
      if (parsed != null) {
        await _plugin.cancel(id: parsed);
      }
    }
  }

  static Future<void> syncHabits(List<Habit> habits) async {
    if (kIsWeb) return;

    await _cancelSavedIds(_habitIdsKey);
    final scheduledIds = <String>[];

    for (final habit in habits) {
      if (!habit.notificationEnabled ||
          habit.notificationHour == null ||
          habit.notificationMinute == null) {
        continue;
      }

      //日にち指定がある場合は1回だけ通知
      if (habit.notificationDate != null) {
        final scheduled = tz.TZDateTime(
          tz.local,
          habit.notificationDate!.year,
          habit.notificationDate!.month,
          habit.notificationDate!.day,
          habit.notificationHour!,
          habit.notificationMinute!,
        );

        if (scheduled.isAfter(tz.TZDateTime.now(tz.local))) {
          final id = _stableId('habit|${habit.id}|date');

          await _plugin.zonedSchedule(
            id: id,
            title: '習慣の時間です',
            body: habit.title,
            scheduledDate: scheduled,
            notificationDetails: _details,
            androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          );

          scheduledIds.add(id.toString());
        }

        continue;
      }

      //曜日指定。古いデータでは習慣自体の曜日をそのまま使う
      final targetDays = habit.notificationDays.isNotEmpty
          ? habit.notificationDays
          : habit.days;

      for (final day in targetDays) {
        final weekday = _weekdayNumber(day);
        final id = _stableId('habit|${habit.id}|$weekday');

        var scheduled = tz.TZDateTime(
          tz.local,
          tz.TZDateTime.now(tz.local).year,
          tz.TZDateTime.now(tz.local).month,
          tz.TZDateTime.now(tz.local).day,
          habit.notificationHour!,
          habit.notificationMinute!,
        );

        while (scheduled.weekday != weekday ||
            !scheduled.isAfter(tz.TZDateTime.now(tz.local))) {
          scheduled = scheduled.add(const Duration(days: 1));
        }

        await _plugin.zonedSchedule(
          id: id,
          title: '習慣の時間です',
          body: habit.title,
          scheduledDate: scheduled,
          notificationDetails: _details,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        );

        scheduledIds.add(id.toString());
      }
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_habitIdsKey, scheduledIds);
  }

  static Future<void> syncTasks(List<Task> tasks) async {
    if (kIsWeb) return;

    await _cancelSavedIds(_taskIdsKey);
    final scheduledIds = <String>[];

    for (final task in tasks) {
      if (task.isDone ||
          !task.notificationEnabled ||
          task.notificationHour == null ||
          task.notificationMinute == null) {
        continue;
      }

      //日にち指定なら締切とは関係なく通知できる
      if (task.notificationDate != null) {
        final scheduled = tz.TZDateTime(
          tz.local,
          task.notificationDate!.year,
          task.notificationDate!.month,
          task.notificationDate!.day,
          task.notificationHour!,
          task.notificationMinute!,
        );

        if (scheduled.isAfter(tz.TZDateTime.now(tz.local))) {
          final id = _stableId('task|${task.id}|date');

          await _plugin.zonedSchedule(
            id: id,
            title: 'タスクのリマインダー',
            body: task.title,
            scheduledDate: scheduled,
            notificationDetails: _details,
            androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          );

          scheduledIds.add(id.toString());
        }

        continue;
      }

      //曜日指定なら毎週通知
      for (final day in task.notificationDays) {
        final weekday = _weekdayNumber(day);
        final id = _stableId('task|${task.id}|$weekday');

        var scheduled = tz.TZDateTime(
          tz.local,
          tz.TZDateTime.now(tz.local).year,
          tz.TZDateTime.now(tz.local).month,
          tz.TZDateTime.now(tz.local).day,
          task.notificationHour!,
          task.notificationMinute!,
        );

        while (scheduled.weekday != weekday ||
            !scheduled.isAfter(tz.TZDateTime.now(tz.local))) {
          scheduled = scheduled.add(const Duration(days: 1));
        }

        await _plugin.zonedSchedule(
          id: id,
          title: 'タスクのリマインダー',
          body: task.title,
          scheduledDate: scheduled,
          notificationDetails: _details,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        );

        scheduledIds.add(id.toString());
      }
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_taskIdsKey, scheduledIds);
  }
}
