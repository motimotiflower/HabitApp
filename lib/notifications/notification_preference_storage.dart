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
    required this.batchTimes,
  });

  final GlobalNotificationMode mode;

  //HH:mm形式。まとめ通知は複数時刻を持てる
  final List<String> batchTimes;
}

class NotificationPreferenceStorage {
  static const _modeKey = 'notification_global_mode';
  static const _batchTimesKey = 'notification_batch_times';

  //旧バージョンの1時刻設定から移行するため残しておく
  static const _legacyBatchHourKey = 'notification_batch_hour';
  static const _legacyBatchMinuteKey = 'notification_batch_minute';

  static Future<GlobalNotificationSettings> load() async {
    final prefs = await SharedPreferences.getInstance();
    final modeName = prefs.getString(_modeKey) ?? 'normal';

    final mode = GlobalNotificationMode.values.firstWhere(
      (item) => item.name == modeName,
      orElse: () => GlobalNotificationMode.normal,
    );

    var batchTimes = prefs.getStringList(_batchTimesKey);

    //以前の1時刻設定があれば、その値を新形式へ移行
    if (batchTimes == null || batchTimes.isEmpty) {
      final hour = prefs.getInt(_legacyBatchHourKey) ?? 21;
      final minute = prefs.getInt(_legacyBatchMinuteKey) ?? 0;

      batchTimes = [
        '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}',
      ];
    }

    return GlobalNotificationSettings(
      mode: mode,
      batchTimes: batchTimes,
    );
  }

  static Future<void> save(GlobalNotificationSettings settings) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_modeKey, settings.mode.name);
    await prefs.setStringList(_batchTimesKey, settings.batchTimes);

    //旧形式は不要なので削除
    await prefs.remove(_legacyBatchHourKey);
    await prefs.remove(_legacyBatchMinuteKey);
  }
}
