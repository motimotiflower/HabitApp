//タスクの保存と読み込み
import 'dart:convert';

import 'package:habitapp/models/task.dart';
import 'package:habitapp/notifications/notification_service.dart';
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
    await NotificationService.syncTasks(tasks);
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

    //以前のデータにIDが無ければ読み込み時に付与して保存し直す
    final hadMissingIds = jsonList.any(
      (json) => json is Map && json['id'] == null,
    );

    final tasks = jsonList
        .map((json) => Task.fromJson(Map<String, dynamic>.from(json)))
        .toList();

    if (hadMissingIds) {
      await saveTasks(tasks);
    }

    return tasks;
  }
}
