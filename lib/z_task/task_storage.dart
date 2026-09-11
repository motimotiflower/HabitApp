//タスクの保存と読み込み
import 'dart:convert';

import 'package:habitapp/models/task.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TaskStorage {
  //保存時に使うキー
  static const String _key = 'tasks';

  //タスク一覧を保存=================================
  static Future<void> saveTasks(List<Task> tasks) async {
    final prefs = await SharedPreferences.getInstance();

    //TaskをMapに変換してからJSON文字列にする
    final jsonString = jsonEncode(tasks.map((task) => task.toJson()).toList());

    await prefs.setString(_key, jsonString);
  }

  //保存されているタスク一覧を読み込む=================
  static Future<List<Task>> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();

    //保存されているJSON文字列を取得
    final jsonString = prefs.getString(_key);

    //まだ保存データがない場合
    if (jsonString == null) {
      return [];
    }

    //JSON文字列をListに戻す
    final List<dynamic> jsonList = jsonDecode(jsonString);

    //MapからTaskに戻す
    return jsonList.map((json) => Task.fromJson(json)).toList();
  }
}
