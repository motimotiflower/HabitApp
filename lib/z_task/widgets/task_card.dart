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

  //締切の状態に応じた色
  Color _getDeadlineColor() {
    if (task.isDone || task.deadline == null) {
      return const Color(0xff81889B);
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final deadline = DateTime(
      task.deadline!.year,
      task.deadline!.month,
      task.deadline!.day,
    );

    final difference = deadline.difference(today).inDays;

    if (difference < 0) return const Color(0xffC85C6E);
    if (difference == 0) return const Color(0xff526FC5);

    return const Color(0xff81889B);
  }

  @override
  Widget build(BuildContext context) {
    final deadlineColor = _getDeadlineColor();

    return Opacity(
      opacity: task.isDone ? 0.68 : 1,
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xffF2F4FC),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xffCDD5F0),
            width: 0.6,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xffE8EDFC),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                task.isDone ? Icons.check : Icons.star_outline,
                color: const Color(0xff526FC5),
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
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xff35415F),
                      decoration:
                          task.isDone ? TextDecoration.lineThrough : null,
                    ),
                  ),

                  if (task.description.isNotEmpty) ...[
                    const SizedBox(height: 5),
                    Text(
                      task.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.4,
                        color: Color(0xff697188),
                      ),
                    ),
                  ],

                  const SizedBox(height: 5),

                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      if (task.isFlagged)
                        const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.flag_rounded,
                              size: 14,
                              color: Color(0xff526FC5),
                            ),
                            SizedBox(width: 3),
                            Text(
                              'フラグ',
                              style: TextStyle(
                                fontSize: 11,
                                color: Color(0xff526FC5),
                              ),
                            ),
                          ],
                        ),
                      if (task.category != '未設定')
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xffE4EAFA),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            task.category,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xff4763B4),
                            ),
                          ),
                        ),

                      //締切を設定しているタスクだけ表示
                      if (task.deadline != null)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.calendar_today_outlined,
                              size: 13,
                              color: deadlineColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _getDeadlineText(),
                              style: TextStyle(
                                fontSize: 11,
                                color: deadlineColor,
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
              tooltip: '編集',
              color: const Color(0xff526FC5),
              icon: const Icon(Icons.edit_outlined, size: 19),
              onPressed: onEdit,
            ),

            IconButton(
              tooltip: '削除',
              color: const Color(0xff526FC5),
              icon: const Icon(Icons.delete_outline, size: 19),
              onPressed: onDelete,
            ),

            Checkbox(
              value: task.isDone,
              activeColor: const Color(0xff526FC5),
              onChanged: (_) {
                onChanged();
              },
            ),
          ],
        ),
      ),
    );
  }
}
