//通知全体の動作設定
import 'package:shared_preferences/shared_preferences.dart';

enum GlobalNotificationMode {
  normal,
  off,
  batch,
}

class GlobalNotificationSettings {
  const GlobalNotificationSettings({
    required this.mode,
    required this.batchHour,
    required this.batchMinute,
  });

  final GlobalNotificationMode mode;
  final int batchHour;
  final int batchMinute;
}

class NotificationPreferenceStorage {
  static const _modeKey = 'notification_global_mode';
  static const _batchHourKey = 'notification_batch_hour';
  static const _batchMinuteKey = 'notification_batch_minute';

  static Future<GlobalNotificationSettings> load() async {
    final prefs = await SharedPreferences.getInstance();
    final modeName = prefs.getString(_modeKey) ?? 'normal';

    final mode = GlobalNotificationMode.values.firstWhere(
      (item) => item.name == modeName,
      orElse: () => GlobalNotificationMode.normal,
    );

    return GlobalNotificationSettings(
      mode: mode,
      batchHour: prefs.getInt(_batchHourKey) ?? 21,
      batchMinute: prefs.getInt(_batchMinuteKey) ?? 0,
    );
  }

  static Future<void> save(GlobalNotificationSettings settings) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_modeKey, settings.mode.name);
    await prefs.setInt(_batchHourKey, settings.batchHour);
    await prefs.setInt(_batchMinuteKey, settings.batchMinute);
  }
}
