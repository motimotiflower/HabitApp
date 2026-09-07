//習慣のデータの型
import 'package:flutter/material.dart';

class Habit {
  final String title;
  final IconData icon;
  final List<String> days; //習慣を行う曜日
  final Map<String, bool> completionHistory; // 日付ごとの達成記録

  Habit({
    required this.title,
    required this.icon,
    this.days = const [],
    Map<String, bool>? completionHistory,
  }) : completionHistory = completionHistory ?? {};

  // Habitを保存しやすい形に変換
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'icon': icon.codePoint,
      'days': days,
      'completionHistory': completionHistory,
    };
  }

  // 保存データからHabitを作り直す
  factory Habit.fromJson(Map<String, dynamic> json) {
    return Habit(
      title: json['title'],
      icon: IconData(json['icon'], fontFamily: 'MaterialIcons'),
      days: List<String>.from(json['days']),

      // Map<dynamic, dynamic> を Map<String, bool> に戻す
      completionHistory: Map<String, bool>.from(
        json['completionHistory'] ?? {},
      ),
    );
  }
}
