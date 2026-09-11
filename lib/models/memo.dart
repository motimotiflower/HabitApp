//メモのデータの型
class Memo {
  final String title; //メモのタイトル
  final String content; //本文
  final DateTime updatedAt; //更新日時
  final bool isPinned; //上に固定するか

  Memo({
    required this.title,
    required this.content,
    required this.updatedAt,
    this.isPinned = false,
  });

  //Memoを保存しやすい形に変換
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      'updatedAt': updatedAt.toIso8601String(),
      'isPinned': isPinned,
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

      //以前の保存データには無いのでfalseを初期値にする
      isPinned: json['isPinned'] ?? false,
    );
  }
}
