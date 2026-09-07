//保存処理
import 'dart:convert';

import 'package:habitapp/models/habit.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HabitStorage {
  static const String _key = 'habits';

  //保存==============================
  // 習慣一覧を端末に保存する
  static Future<void> saveHabits(List<Habit> habits) async {
    final prefs = await SharedPreferences.getInstance();

    // Habit → Map → JSON文字列
    final habitList = habits.map((habit) => habit.toJson()).toList();
    final jsonString = jsonEncode(habitList);

    await prefs.setString(_key, jsonString);
  }

  //読み込み===========================
  // 保存した習慣一覧を読み込む
  static Future<List<Habit>> loadHabits() async {
    final prefs = await SharedPreferences.getInstance();

    // 保存してあるJSON文字列を取得
    final jsonString = prefs.getString(_key);

    // 保存データがなければ空のリストを返す
    if (jsonString == null) {
      return [];
    }

    // JSON文字列 → List
    final List<dynamic> decodedList = jsonDecode(jsonString);

    // List<Map> → List<Habit>
    return decodedList.map((json) => Habit.fromJson(json)).toList();
  }
}
