//習慣ジャンルの保存と読み込み
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class HabitCategoryStorage {
  static const String _key = 'habit_categories';
  static const String _colorKey = 'habit_category_colors';

  //ジャンル一覧を保存
  static Future<void> saveCategories(List<String> categories) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(categories));
  }

  //ジャンル一覧を読み込む
  static Future<List<String>> loadCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);

    if (jsonString == null) return [];

    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList.map((category) => category.toString()).toList();
  }

  //ジャンルごとの色を保存
  static Future<void> saveCategoryColors(Map<String, int> colors) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_colorKey, jsonEncode(colors));
  }

  //ジャンルごとの色を読み込む
  static Future<Map<String, int>> loadCategoryColors() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_colorKey);

    if (jsonString == null) return {};

    final Map<String, dynamic> jsonMap = jsonDecode(jsonString);

    return jsonMap.map(
      (key, value) => MapEntry(key, value as int),
    );
  }
}
