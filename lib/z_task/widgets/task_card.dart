//タスク1件分の表示
import 'package:flutter/material.dart';
import 'package:habitapp/models/task.dart';

class TaskCard extends StatefulWidget {
  const TaskCard({
    super.key,
    required this.task,
    required this.onChanged,
    required this.onSubtaskChanged,
    required this.onEdit,
    required this.onDelete,
  });

  final Task task;
  final VoidCallback onChanged;
  final void Function(int index) onSubtaskChanged;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  bool _expanded = false;

  String _deadlineText() {
    final deadline = widget.task.deadline;
    if (deadline == null) return '';
    return '${deadline.month}月${deadline.day}日まで';
  }

  @override
  Widget build(BuildContext context) {
    final task = widget.task;
    return Opacity(
      opacity: task.isDone ? 0.68 : 1,
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xffF2F4FC),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xffCDD5F0), width: 0.6),
        ),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.description_outlined,
                    color: Color(0xff526FC5)),
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
                      if (task.deadline != null)
                        Text(_deadlineText(),
                            style: const TextStyle(
                                fontSize: 11, color: Color(0xff81889B))),
                    ],
                  ),
                ),
                if (task.subtasks.isNotEmpty)
                  IconButton(
                    tooltip: _expanded ? '閉じる' : 'サブタスクを開く',
                    icon: Icon(_expanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down),
                    onPressed: () => setState(() => _expanded = !_expanded),
                  ),
                IconButton(
                  tooltip: '編集',
                  icon: const Icon(Icons.edit_outlined, size: 19),
                  color: const Color(0xff526FC5),
                  onPressed: widget.onEdit,
                ),
                Checkbox(
                  value: task.isDone,
                  activeColor: const Color(0xff526FC5),
                  onChanged: (_) => widget.onChanged(),
                ),
              ],
            ),
            if (_expanded)
              Padding(
                padding: const EdgeInsets.only(left: 28),
                child: Column(
                  children: [
                    for (var i = 0; i < task.subtasks.length; i++)
                      CheckboxListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        controlAffinity: ListTileControlAffinity.leading,
                        value: task.subtasks[i].isDone,
                        title: Text(
                          task.subtasks[i].title,
                          style: TextStyle(
                            decoration: task.subtasks[i].isDone
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                        onChanged: (_) => widget.onSubtaskChanged(i),
                      ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: widget.onDelete,
                        icon: const Icon(Icons.delete_outline, size: 18),
                        label: const Text('削除'),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
