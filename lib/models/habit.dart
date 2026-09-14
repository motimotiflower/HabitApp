//習慣のデータの型
import 'package:flutter/material.dart';

class Habit {
  static int _idCounter = 0;

  static String _createId() {
    return '${DateTime.now().microsecondsSinceEpoch}_${_idCounter++}';
  }

  final String id; //同じタイトルでも別の習慣として判定するID
  final String title;
  final IconData icon; //古い保存データとの互換用
  final String? iconAsset; //画像アイコン
  final List<String> days; //習慣を行う曜日
  final String category; //ジャンル
  final bool notificationEnabled; //通知を使うか
  final List<String> notificationDays; //曜日指定
  final DateTime? notificationDate; //日にち指定
  final int? notificationHour; //通知時刻
  final int? notificationMinute;
  final Map<String, bool> completionHistory; //日付ごとの達成記録

  Habit({
    String? id,
    required this.title,
    this.icon = Icons.check,
    this.iconAsset,
    this.days = const [],
    this.category = '未設定',
    this.notificationEnabled = false,
    this.notificationDays = const [],
    this.notificationDate,
    this.notificationHour,
    this.notificationMinute,
    Map<String, bool>? completionHistory,
  })  : id = id ?? _createId(),
        completionHistory = completionHistory ?? {};

  //Habitを保存しやすい形に変換
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'icon': icon.codePoint,
      'iconAsset': iconAsset,
      'days': days,
      'category': category,
      'notificationEnabled': notificationEnabled,
      'notificationDays': notificationDays,
      'notificationDate': notificationDate?.toIso8601String(),
      'notificationHour': notificationHour,
      'notificationMinute': notificationMinute,
      'completionHistory': completionHistory,
    };
  }

  //保存データからHabitを作り直す
  factory Habit.fromJson(Map<String, dynamic> json) {
    return Habit(
      id: json['id'],
      title: json['title'],
      icon: IconData(
        json['icon'] ?? Icons.check.codePoint,
        fontFamily: 'MaterialIcons',
      ),
      iconAsset: json['iconAsset'],
      days: List<String>.from(json['days'] ?? []),
      category: json['category'] ?? '未設定',
      notificationEnabled: json['notificationEnabled'] ?? false,
      notificationDays: List<String>.from(json['notificationDays'] ?? []),
      notificationDate: json['notificationDate'] != null
          ? DateTime.tryParse(json['notificationDate'])
          : null,
      notificationHour: json['notificationHour'],
      notificationMinute: json['notificationMinute'],
      completionHistory: Map<String, bool>.from(
        json['completionHistory'] ?? {},
      ),
    );
  }
}
