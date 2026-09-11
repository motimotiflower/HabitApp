//メモの保存と読み込み
import 'dart:convert';

import 'package:habitapp/models/memo.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MemoStorage {
  static const String _key = 'memos';

  //メモ一覧を保存
  static Future<void> saveMemos(List<Memo> memos) async {
    final prefs = await SharedPreferences.getInstance();

    final jsonString = jsonEncode(
      memos.map((memo) => memo.toJson()).toList(),
    );

    await prefs.setString(_key, jsonString);
  }

  //保存されているメモ一覧を読み込む
  static Future<List<Memo>> loadMemos() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);

    if (jsonString == null) {
      return [];
    }

    final List<dynamic> jsonList = jsonDecode(jsonString);

    return jsonList
        .map((json) => Memo.fromJson(json))
        .toList();
  }
}
