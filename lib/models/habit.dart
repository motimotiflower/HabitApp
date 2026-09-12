//習慣のデータの型
import 'package:flutter/material.dart';

class Habit {
  static int _idCounter = 0;

  static String _createId() {
    return '${DateTime.now().microsecondsSinceEpoch}_${_idCounter++}';
  }

  final String id; //同じタイトルでも別の習慣として判定するID
  final String title;
  final IconData icon;
  final List<String> days; //習慣を行う曜日
  final String category; //ジャンル
  final Map<String, bool> completionHistory; //日付ごとの達成記録

  Habit({
    String? id,
    required this.title,
    required this.icon,
    this.days = const [],
    this.category = '未設定',
    Map<String, bool>? completionHistory,
  })  : id = id ?? _createId(),
        completionHistory = completionHistory ?? {};

  //Habitを保存しやすい形に変換
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'icon': icon.codePoint,
      'days': days,
      'category': category,
      'completionHistory': completionHistory,
    };
  }

  //保存データからHabitを作り直す
  factory Habit.fromJson(Map<String, dynamic> json) {
    return Habit(
      id: json['id'],
      title: json['title'],
      icon: IconData(json['icon'], fontFamily: 'MaterialIcons'),
      days: List<String>.from(json['days'] ?? []),

      //以前の保存データにはジャンルが無いので未設定にする
      category: json['category'] ?? '未設定',

      //Map<dynamic, dynamic>をMap<String, bool>に戻す
      completionHistory: Map<String, bool>.from(
        json['completionHistory'] ?? {},
      ),
    );
  }
}
