//習慣のデータの型
import 'package:flutter/material.dart';
import 'package:habitapp/models/subtask.dart';

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
  final Map<String, bool> completionHistory; //日付・週ごとの達成記録
  final Map<String, String> completionDates; //実際に達成した日
  final bool shareCompletion; //選択曜日で達成状態を共有するか
  final bool carryOverIfIncomplete; //未達成なら次の設定曜日まで表示するか
  final int priority; //優先度 1:低 2:中 3:高
  final DateTime? endDate; //習慣そのものの終了日（この日を含む）
  final int? carryOverDays; //やり残しを表示する最大日数。nullなら従来通り
  final List<String> skippedDates; //スキップした設定日 yyyy-MM-dd
  final DateTime? startedAt; //この習慣を使い始めた日
  final DateTime? archivedAt; //アーカイブした日。nullなら使用中
  final List<Subtask> subtasks; //親の下に表示するサブタスク

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
    Map<String, String>? completionDates,
    this.shareCompletion = false,
    this.carryOverIfIncomplete = false,
    this.priority = 2,
    this.endDate,
    this.carryOverDays,
    this.skippedDates = const [],
    this.startedAt,
    this.archivedAt,
    this.subtasks = const [],
  })  : id = id ?? _createId(),
        completionHistory = completionHistory ?? {},
        completionDates = completionDates ?? {};

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
      'completionDates': completionDates,
      'shareCompletion': shareCompletion,
      'carryOverIfIncomplete': carryOverIfIncomplete,
      'priority': priority,
      'endDate': endDate?.toIso8601String(),
      'carryOverDays': carryOverDays,
      'skippedDates': skippedDates,
      'startedAt': startedAt?.toIso8601String(),
      'archivedAt': archivedAt?.toIso8601String(),
      'subtasks': subtasks.map((subtask) => subtask.toJson()).toList(),
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
      completionDates: Map<String, String>.from(
        json['completionDates'] ?? {},
      ),
      shareCompletion: json['shareCompletion'] ?? false,
      carryOverIfIncomplete: json['carryOverIfIncomplete'] ?? false,
      priority: json['priority'] ?? 2,
      endDate: json['endDate'] != null ? DateTime.tryParse(json['endDate']) : null,
      carryOverDays: json['carryOverDays'],
      skippedDates: List<String>.from(json['skippedDates'] ?? []),
      //古いデータは開始日なしとして今まで通り表示する
      startedAt: json['startedAt'] != null
          ? DateTime.tryParse(json['startedAt'])
          : null,
      archivedAt: json['archivedAt'] != null
          ? DateTime.tryParse(json['archivedAt'])
          : null,
      subtasks: (json['subtasks'] as List<dynamic>? ?? [])
          .map((item) => Subtask.fromJson(Map<String, dynamic>.from(item)))
          .toList(),
    );
  }
}
