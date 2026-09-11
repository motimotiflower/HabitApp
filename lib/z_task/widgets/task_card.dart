//タスク1件分の表示
import 'package:flutter/material.dart';
import 'package:habitapp/models/task.dart';

class TaskCard extends StatelessWidget {
  //コンストラクタ ==========================
  const TaskCard({
    super.key,
    required this.task,
    required this.onChanged,
    required this.onDelete,
  });
  //変数====================================
  final Task task; //表示するタスク
  final VoidCallback onChanged; //チェック時に実行する処理
  final VoidCallback onDelete; //削除時に実行する処理

  //締切日の表示文字を作る====================
  String _getDeadlineText() {
    //締切なし
    if (task.deadline == null) {
      return '締切なし';
    }

    final now = DateTime.now();

    //時間を除いて日付だけで比較する
    final today = DateTime(now.year, now.month, now.day);

    final deadline = DateTime(
      task.deadline!.year,
      task.deadline!.month,
      task.deadline!.day,
    );

    //今日から締切までの日数
    final difference = deadline.difference(today).inDays;

    if (difference < 0) {
      return '期限切れ';
    }

    if (difference == 0) {
      return '今日まで';
    }

    if (difference <= 7) {
      return 'あと$difference日';
    }

    return '${deadline.month}月${deadline.day}日まで';
  }

  //========================================
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.all(12),

      //見た目の設定--------------------------
      decoration: BoxDecoration(
        color: const Color.fromARGB(228, 233, 233, 244),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xffD0CAE8), width: 0.4),
      ),

      //表示---------------------------------
      child: Row(
        children: [
          const Icon(Icons.task_alt, color: Color(0xffEBD3E3)),

          const SizedBox(width: 16),

          //タイトルと締切日
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(task.title),

                const SizedBox(height: 4),

                Text(
                  _getDeadlineText(),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),

          //削除ボタン
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 20),
            onPressed: onDelete,
          ),

          Checkbox(
            value: task.isDone,
            onChanged: (value) {
              onChanged();
            },
          ),
        ],
      ),
    );
  }
}
