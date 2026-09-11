//タスクのデータの型
class Task {
  final String title; //タスク名
  final DateTime? deadline; //締切日
  bool isDone; //完了状態

  Task({required this.title, this.deadline, this.isDone = false});

  // Taskを保存しやすい形に変換
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'deadline': deadline?.toIso8601String(),
      'isDone': isDone,
    };
  }

  // 保存データからTaskを作り直す
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      title: json['title'],
      deadline: json['deadline'] != null
          ? DateTime.parse(json['deadline'])
          : null,
      isDone: json['isDone'] ?? false,
    );
  }
}
