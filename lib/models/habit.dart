//習慣のデータの型
import 'package:flutter/material.dart';

class Habit {
  final String title;
  final IconData icon;
  final List<String> days; //習慣を行う曜日
  bool isDone; //finalだと値を変えられない

  Habit({
    required this.title,
    required this.icon,
    this.days = const [],
    this.isDone = false,
  });

  // Habitを保存しやすい形に変換
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'icon': icon.codePoint,
      'days': days,
      'isDone': isDone,
    };
  }

  // 保存データからHabitを作り直す
  factory Habit.fromJson(Map<String, dynamic> json) {
    return Habit(
      title: json['title'],
      icon: IconData(json['icon'], fontFamily: 'MaterialIcons'),
      days: List<String>.from(json['days']),
      isDone: json['isDone'],
    );
  }
}
