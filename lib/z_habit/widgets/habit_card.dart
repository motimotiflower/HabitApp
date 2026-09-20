//習慣1件分の表示
import 'package:flutter/material.dart';
import 'package:habitapp/models/habit.dart';

class HabitCard extends StatefulWidget {
  const HabitCard({
    super.key,
    required this.habit,
    required this.isDone,
    required this.onChanged,
    required this.onSubtaskChanged,
    required this.subtaskIsDone,
    required this.onEdit,
    required this.onDelete,
    this.categoryColor,
    this.dragHandle,
  });

  final Habit habit;
  final bool isDone;
  final VoidCallback onChanged;
  final void Function(int index) onSubtaskChanged;
  final bool Function(int index) subtaskIsDone;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final Color? categoryColor;
  final Widget? dragHandle;

  @override
  State<HabitCard> createState() => _HabitCardState();
}

class _HabitCardState extends State<HabitCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final habit = widget.habit;
    final accentColor = habit.category == '未設定'
        ? const Color(0xff526FC5)
        : (widget.categoryColor ?? const Color(0xff526FC5));

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xffF2F4FC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xffCDD5F0), width: 0.6),
      ),
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: 40,
                height: 40,
                child: habit.iconAsset != null
                    ? Image.asset(habit.iconAsset!, fit: BoxFit.contain)
                    : Icon(habit.icon, size: 24, color: accentColor),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      habit.title,
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xff35415F),
                        decoration:
                            widget.isDone ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    if (habit.category != '未設定') ...[
                      const SizedBox(height: 5),
                      Text(
                        habit.category,
                        style: TextStyle(fontSize: 12, color: accentColor),
                      ),
                    ],
                  ],
                ),
              ),
              if (habit.subtasks.isNotEmpty)
                IconButton(
                  tooltip: _expanded ? '閉じる' : 'サブタスクを開く',
                  icon: Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                  ),
                  onPressed: () => setState(() => _expanded = !_expanded),
                ),
              IconButton(
                tooltip: '編集',
                icon: const Icon(Icons.edit_outlined, size: 20),
                color: const Color(0xff526FC5),
                onPressed: widget.onEdit,
              ),
              IconButton(
                tooltip: '削除',
                icon: const Icon(Icons.delete_outline, size: 20),
                color: const Color(0xff526FC5),
                onPressed: widget.onDelete,
              ),
              Checkbox(
                value: widget.isDone,
                activeColor: accentColor,
                onChanged: (_) => widget.onChanged(),
              ),
              if (widget.dragHandle != null) widget.dragHandle!,
            ],
          ),
          if (_expanded && habit.subtasks.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 44, top: 4),
              child: Column(
                children: [
                  for (var i = 0; i < habit.subtasks.length; i++)
                    CheckboxListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                      value: widget.subtaskIsDone(i),
                      activeColor: accentColor,
                      title: Text(
                        habit.subtasks[i].title,
                        style: TextStyle(
                          decoration: widget.subtaskIsDone(i)
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      onChanged: (_) => widget.onSubtaskChanged(i),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
