//タスクのデータの型
class Task {
  static int _idCounter = 0;

  static String _createId() {
    return '${DateTime.now().microsecondsSinceEpoch}_${_idCounter++}';
  }

  final String id; //同じタイトルでも別のタスクとして判定するID
  final String title; //タスク名
  final DateTime? deadline; //締切日
  final String category; //ジャンル
  bool isDone; //完了状態

  Task({
    String? id,
    required this.title,
    this.deadline,
    this.category = '未設定',
    this.isDone = false,
  }) : id = id ?? _createId();

  //Taskを保存しやすい形に変換
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'deadline': deadline?.toIso8601String(),
      'category': category,
      'isDone': isDone,
    };
  }

  //保存データからTaskを作り直す
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      deadline: json['deadline'] != null
          ? DateTime.parse(json['deadline'])
          : null,
      category: json['category'] ?? '未設定',
      isDone: json['isDone'] ?? false,
    );
  }
}
