//メモのデータの型
class Memo {
  final String title; //メモのタイトル
  final String content; //本文
  final DateTime updatedAt; //更新日時

  Memo({
    required this.title,
    required this.content,
    required this.updatedAt,
  });

  //Memoを保存しやすい形に変換
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  //保存データからMemoを作り直す
  factory Memo.fromJson(Map<String, dynamic> json) {
    return Memo(
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }
}
