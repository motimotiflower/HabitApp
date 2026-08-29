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
}
