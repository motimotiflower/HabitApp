//タスク1件分の表示
import 'package:flutter/material.dart';
import 'package:habitapp/models/task.dart';

class TaskCard extends StatelessWidget {
  const TaskCard({
    super.key,
    required this.task,
    required this.onChanged,
    required this.onEdit,
    required this.onDelete,
  });

  final Task task;
  final VoidCallback onChanged;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  //締切日の表示文字
  String _getDeadlineText() {
    if (task.deadline == null) return '締切なし';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final deadline = DateTime(
      task.deadline!.year,
      task.deadline!.month,
      task.deadline!.day,
    );

    final difference = deadline.difference(today).inDays;

    if (difference < 0) return '期限切れ';
    if (difference == 0) return '今日まで';
    if (difference <= 7) return 'あと$difference日';

    return '${deadline.month}月${deadline.day}日まで';
  }

  //重要度の表示文字
  String _getPriorityText() {
    switch (task.priority) {
      case 1:
        return '低';
      case 2:
        return '中';
      case 3:
        return '高';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final priorityText = _getPriorityText();

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(12),

      decoration: BoxDecoration(
        color: const Color.fromARGB(228, 233, 233, 244),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xffD0CAE8),
          width: 0.4,
        ),
      ),

      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xffF2EEFF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.star_outline,
              color: Color(0xff8A7BD9),
              size: 20,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    decoration:
                        task.isDone ? TextDecoration.lineThrough : null,
                  ),
                ),

                const SizedBox(height: 5),

                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    if (task.category != '未設定')
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xffEEE9FF),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          task.category,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xff6F63B7),
                          ),
                        ),
                      ),

                    if (priorityText.isNotEmpty)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star,
                            size: 14,
                            color: Color(0xffD8A84E),
                          ),
                          const SizedBox(width: 2),
                          Text(
                            priorityText,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xff8A6C2D),
                            ),
                          ),
                        ],
                      ),

                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.calendar_today_outlined,
                          size: 13,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _getDeadlineText(),
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 19),
            onPressed: onEdit,
          ),

          IconButton(
            icon: const Icon(Icons.delete_outline, size: 19),
            onPressed: onDelete,
          ),

          Checkbox(
            value: task.isDone,
            onChanged: (_) {
              onChanged();
            },
          ),
        ],
      ),
    );
  }
}
