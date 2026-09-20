//親項目の中に表示するサブタスク
class Subtask {
  static int _idCounter = 0;

  static String _createId() =>
      '${DateTime.now().microsecondsSinceEpoch}_${_idCounter++}';

  final String id;
  final String title;
  bool isDone; //タスク用の完了状態
  final Map<String, bool> completionHistory; //習慣用の日付・週ごとの達成記録

  Subtask({
    String? id,
    required this.title,
    this.isDone = false,
    Map<String, bool>? completionHistory,
  })  : id = id ?? _createId(),
        completionHistory = completionHistory ?? {};

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'isDone': isDone,
        'completionHistory': completionHistory,
      };

  factory Subtask.fromJson(Map<String, dynamic> json) {
    return Subtask(
      id: json['id'],
      title: json['title'] ?? '',
      isDone: json['isDone'] ?? false,
      completionHistory:
          Map<String, bool>.from(json['completionHistory'] ?? {}),
    );
  }
}
