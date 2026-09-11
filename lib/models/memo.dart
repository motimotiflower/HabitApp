//メモ部屋と投稿データ
class MemoMessage {
  final String content; //本文
  final DateTime createdAt; //投稿日時
  final String? imageBase64; //添付画像（基本版はbase64で保存）

  MemoMessage({
    required this.content,
    required this.createdAt,
    this.imageBase64,
  });

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'imageBase64': imageBase64,
    };
  }

  factory MemoMessage.fromJson(Map<String, dynamic> json) {
    return MemoMessage(
      content: json['content'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      imageBase64: json['imageBase64'],
    );
  }
}

class Memo {
  final String title; //部屋名
  final String type; //メモの種類
  final DateTime updatedAt; //最終更新
  final bool isPinned; //Homeに表示するか
  final List<MemoMessage> messages; //壁打ちした投稿一覧

  Memo({
    required this.title,
    this.type = 'メモ',
    required this.updatedAt,
    this.isPinned = false,
    this.messages = const [],
  });

  //一覧表示用の最後の投稿
  String get preview {
    if (messages.isEmpty) return 'まだメモがありません';

    final last = messages.last;

    if (last.content.isNotEmpty) return last.content;
    if (last.imageBase64 != null) return '画像';
    return 'まだメモがありません';
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'type': type,
      'updatedAt': updatedAt.toIso8601String(),
      'isPinned': isPinned,
      'messages': messages.map((message) => message.toJson()).toList(),
    };
  }

  factory Memo.fromJson(Map<String, dynamic> json) {
    //旧Keep型メモを新しい「部屋＋投稿」形式へ移行
    if (json['messages'] == null) {
      final oldContent = (json['content'] ?? '').toString();
      final oldUpdatedAt = json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now();

      return Memo(
        title: json['title'] ?? 'メモ',
        type: 'メモ',
        updatedAt: oldUpdatedAt,
        isPinned: json['isPinned'] ?? false,
        messages: oldContent.isEmpty
            ? []
            : [
                MemoMessage(
                  content: oldContent,
                  createdAt: oldUpdatedAt,
                ),
              ],
      );
    }

    return Memo(
      title: json['title'] ?? 'メモ',
      type: json['type'] ?? 'メモ',
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
      isPinned: json['isPinned'] ?? false,
      messages: (json['messages'] as List<dynamic>? ?? [])
          .map(
            (message) => MemoMessage.fromJson(
              Map<String, dynamic>.from(message),
            ),
          )
          .toList(),
    );
  }
}
