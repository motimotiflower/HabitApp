//習慣のデータの型
import 'package:flutter/material.dart';

class Habit {
  final String title;
  final IconData icon;
  final List<String> days; //習慣を行う曜日
  final String category; //ジャンル
  final Map<String, bool> completionHistory; //日付ごとの達成記録

  Habit({
    required this.title,
    required this.icon,
    this.days = const [],
    this.category = '未設定',
    Map<String, bool>? completionHistory,
  }) : completionHistory = completionHistory ?? {};

  //Habitを保存しやすい形に変換
  Map<String, dynamic> toJson() {
    return {
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
