//習慣のデータの型
import 'package:flutter/material.dart';

class Habit {
  final String title;
  final IconData icon;
  bool isDone; //finalだと値を変えられない

  Habit({required this.title, required this.icon, this.isDone = false});
}
