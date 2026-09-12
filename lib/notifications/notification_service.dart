//習慣・タスクのローカル通知をまとめて管理
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:habitapp/models/habit.dart';
import 'package:habitapp/models/task.dart';
import 'package:habitapp/notifications/notification_preference_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const String _habitIdsKey = 'scheduled_habit_notification_ids';
  static const String _taskIdsKey = 'scheduled_task_notification_ids';
  static const String _batchIdsKey = 'scheduled_batch_notification_ids';

  static Future<void> initialize() async {
    if (kIsWeb) return;

    tz_data.initializeTimeZones();

    try {
      final timezone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timezone.identifier));
    } catch (_) {}

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

    await prefs.remove(key);
  }

  static Future<void> _cancelAllScheduled() async {
    await _cancelSavedIds(_habitIdsKey);
    await _cancelSavedIds(_taskIdsKey);
    await _cancelSavedIds(_batchIdsKey);
  }

  static Future<List<Habit>> _loadHabitsFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('habits');

    if (jsonString == null) return [];

    final list = jsonDecode(jsonString) as List<dynamic>;

    return list
        .map((item) => Habit.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  static Future<List<Task>> _loadTasksFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('tasks');

    if (jsonString == null) return [];

    final list = jsonDecode(jsonString) as List<dynamic>;

    return list
        .map((item) => Task.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  static Future<void> syncHabits(List<Habit> habits) async {
    if (kIsWeb) return;
    await _syncAll(habits, await _loadTasksFromPrefs());
  }

  static Future<void> syncTasks(List<Task> tasks) async {
    if (kIsWeb) return;
    await _syncAll(await _loadHabitsFromPrefs(), tasks);
  }

  static Future<void> syncAll(
    List<Habit> habits,
    List<Task> tasks,
  ) async {
    if (kIsWeb) return;
    await _syncAll(habits, tasks);
  }

  static Future<void> _syncAll(
    List<Habit> habits,
    List<Task> tasks,
  ) async {
    final settings = await NotificationPreferenceStorage.load();

    await _cancelAllScheduled();

    if (settings.mode == GlobalNotificationMode.off) return;

    if (settings.mode == GlobalNotificationMode.batch) {
      await _scheduleBatchNotifications(habits, tasks, settings);
      return;
    }

    await _scheduleHabitNotifications(habits);
    await _scheduleTaskNotifications(tasks);
  }

  static Future<void> _scheduleHabitNotifications(
    List<Habit> habits,
  ) async {
    final ids = <String>[];

    for (final habit in habits) {
      if (!habit.notificationEnabled ||
          habit.notificationHour == null ||
          habit.notificationMinute == null) {
        continue;
      }

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

          ids.add(id.toString());
        }

        continue;
      }

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

        ids.add(id.toString());
      }
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_habitIdsKey, ids);
  }

  static Future<void> _scheduleTaskNotifications(
    List<Task> tasks,
  ) async {
    final ids = <String>[];

    for (final task in tasks) {
      if (task.isDone ||
          !task.notificationEnabled ||
          task.notificationHour == null ||
          task.notificationMinute == null) {
        continue;
      }

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

          ids.add(id.toString());
        }

        continue;
      }

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

        ids.add(id.toString());
      }
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_taskIdsKey, ids);
  }

  static Future<void> _scheduleBatchNotifications(
    List<Habit> habits,
    List<Task> tasks,
    GlobalNotificationSettings settings,
  ) async {
    final weekdayItems = <int, List<String>>{};
    final dateItems = <String, List<String>>{};
    final dateValues = <String, DateTime>{};

    for (final habit in habits) {
      if (!habit.notificationEnabled) continue;

      if (habit.notificationDate != null) {
        final date = habit.notificationDate!;
        final key = '${date.year}-${date.month}-${date.day}';

        dateValues[key] = date;
        dateItems.putIfAbsent(key, () => []).add('習慣：${habit.title}');
      } else {
        final targetDays = habit.notificationDays.isNotEmpty
            ? habit.notificationDays
            : habit.days;

        for (final day in targetDays) {
          weekdayItems
              .putIfAbsent(_weekdayNumber(day), () => [])
              .add('習慣：${habit.title}');
        }
      }
    }

    for (final task in tasks) {
      if (task.isDone || !task.notificationEnabled) continue;

      if (task.notificationDate != null) {
        final date = task.notificationDate!;
        final key = '${date.year}-${date.month}-${date.day}';

        dateValues[key] = date;
        dateItems.putIfAbsent(key, () => []).add('タスク：${task.title}');
      } else {
        for (final day in task.notificationDays) {
          weekdayItems
              .putIfAbsent(_weekdayNumber(day), () => [])
              .add('タスク：${task.title}');
        }
      }
    }

    final ids = <String>[];
    final now = tz.TZDateTime.now(tz.local);

    for (final timeText in settings.batchTimes) {
      final parts = timeText.split(':');
      final hour = int.tryParse(parts.first) ?? 21;
      final minute =
          int.tryParse(parts.length > 1 ? parts[1] : '') ?? 0;

      for (final entry in weekdayItems.entries) {
        final weekday = entry.key;

        var scheduled = tz.TZDateTime(
          tz.local,
          now.year,
          now.month,
          now.day,
          hour,
          minute,
        );

        while (scheduled.weekday != weekday ||
            !scheduled.isAfter(now)) {
          scheduled = scheduled.add(const Duration(days: 1));
        }

        final id = _stableId(
          'batch|weekday|$weekday|$hour|$minute',
        );

        await _plugin.zonedSchedule(
          id: id,
          title: '今日のリマインダー',
          body: entry.value.join('・'),
          scheduledDate: scheduled,
          notificationDetails: _details,
          androidScheduleMode:
              AndroidScheduleMode.inexactAllowWhileIdle,
          matchDateTimeComponents:
              DateTimeComponents.dayOfWeekAndTime,
        );

        ids.add(id.toString());
      }

      for (final entry in dateItems.entries) {
        final date = dateValues[entry.key]!;

        final scheduled = tz.TZDateTime(
          tz.local,
          date.year,
          date.month,
          date.day,
          hour,
          minute,
        );

        if (!scheduled.isAfter(now)) continue;

        final id = _stableId(
          'batch|date|${entry.key}|$hour|$minute',
        );

        await _plugin.zonedSchedule(
          id: id,
          title: '今日のリマインダー',
          body: entry.value.join('・'),
          scheduledDate: scheduled,
          notificationDetails: _details,
          androidScheduleMode:
              AndroidScheduleMode.inexactAllowWhileIdle,
        );

        ids.add(id.toString());
      }
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_batchIdsKey, ids);
  }
}
