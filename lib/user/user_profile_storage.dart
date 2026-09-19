//ユーザー名などの簡単なプロフィール保存
import 'package:habitapp/core/cloud_backup_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProfileStorage {
  static const String _nameKey = 'user_name';

  //名前を保存
  static Future<void> saveName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_nameKey, name.trim());

    //名前もクラウドへ保存して、別端末でも初回設定を繰り返さない
    await CloudBackupService.backup();
  }

  //名前を読み込む
  static Future<String?> loadName() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString(_nameKey);

    if (name == null || name.trim().isEmpty) return null;
    return name.trim();
  }
}
