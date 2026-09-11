//タスクジャンルの保存と読み込み
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class CategoryStorage {
  static const String _key = 'task_categories';

  //ジャンル一覧を保存
  static Future<void> saveCategories(List<String> categories) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(categories));
  }

  //保存されているジャンル一覧を読み込む
  static Future<List<String>> loadCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);

    if (jsonString == null) {
      return [];
    }

    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList.map((category) => category.toString()).toList();
  }
}
