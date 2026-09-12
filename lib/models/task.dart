//タスクのデータの型
class Task {
  static int _idCounter = 0;

  static String _createId() {
    return '${DateTime.now().microsecondsSinceEpoch}_${_idCounter++}';
  }

  final String id; //同じタイトルでも別のタスクとして判定するID
  final String title; //タスク名
  final String description; //詳細
  final DateTime? deadline; //締切日
  final String category; //ジャンル
  final bool isFlagged; //Homeに優先表示するフラグ
  final bool notificationEnabled; //通知を使うか
  final List<String> notificationDays; //曜日指定
  final DateTime? notificationDate; //日にち指定
  final int? notificationHour; //通知時刻
  final int? notificationMinute;
  bool isDone; //完了状態

  Task({
    String? id,
    required this.title,
    this.description = '',
    this.deadline,
    this.category = '未設定',
    this.isFlagged = false,
    this.notificationEnabled = false,
    this.notificationDays = const [],
    this.notificationDate,
    this.notificationHour,
    this.notificationMinute,
    this.isDone = false,
  }) : id = id ?? _createId();

  //Taskを保存しやすい形に変換
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'deadline': deadline?.toIso8601String(),
      'category': category,
      'isFlagged': isFlagged,
      'notificationEnabled': notificationEnabled,
      'notificationDays': notificationDays,
      'notificationDate': notificationDate?.toIso8601String(),
      'notificationHour': notificationHour,
      'notificationMinute': notificationMinute,
      'isDone': isDone,
    };
  }

  //保存データからTaskを作り直す
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'] ?? '',
      deadline: json['deadline'] != null
          ? DateTime.parse(json['deadline'])
          : null,
      category: json['category'] ?? '未設定',
      isFlagged: json['isFlagged'] ?? false,
      notificationEnabled: json['notificationEnabled'] ?? false,
      notificationDays: List<String>.from(json['notificationDays'] ?? []),
      notificationDate: json['notificationDate'] != null
          ? DateTime.tryParse(json['notificationDate'])
          : null,
      notificationHour: json['notificationHour'],
      notificationMinute: json['notificationMinute'],
      isDone: json['isDone'] ?? false,
    );
  }
}
