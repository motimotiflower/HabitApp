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
    required this.onArchive,
    required this.onSkip,
    this.categoryColor,
  });

  final Habit habit;
  final bool isDone;
  final VoidCallback onChanged;
  final void Function(int index) onSubtaskChanged;
  final bool Function(int index) subtaskIsDone;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onArchive;
  final VoidCallback onSkip;
  final Color? categoryColor;

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

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      //カード本体のタップで編集する
      onTap: widget.onEdit,
      child: Container(
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
                    if (habit.category != '未設定' || habit.priority >= 2) ...[
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          if (habit.category != '未設定')
                            Text(
                              habit.category,
                              style: TextStyle(fontSize: 12, color: accentColor),
                            ),
                          //優先度はジャンルと同じ補助情報の行に表示する
                          if (habit.priority >= 2) ...[
                            if (habit.category != '未設定')
                              const SizedBox(width: 10),
                            Icon(
                              Icons.flag_rounded,
                              size: 14,
                              color: habit.priority == 3
                                  ? const Color(0xff526FC5)
                                  : const Color(0xffA8B1C9),
                            ),
                            const SizedBox(width: 2),
                            Text(
                              habit.priority == 3 ? '高' : '中',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: habit.priority == 3
                                    ? const Color(0xff526FC5)
                                    : const Color(0xffA8B1C9),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              if (habit.subtasks.isNotEmpty)
                InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => setState(() => _expanded = !_expanded),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${habit.subtasks.length}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xff81889B),
                          ),
                        ),
                        const SizedBox(width: 2),
                        Icon(
                          _expanded
                              ? Icons.expand_less_rounded
                              : Icons.expand_more_rounded,
                          size: 20,
                          color: const Color(0xff81889B),
                        ),
                      ],
                    ),
                  ),
                ),
              //操作を3点メニューにまとめる
              PopupMenuButton<String>(
                tooltip: 'その他',
                icon: const Icon(
                  Icons.more_vert_rounded,
                  size: 21,
                  color: Color(0xff526FC5),
                ),
                onSelected: (value) {
                  if (value == 'skip') widget.onSkip();
                  if (value == 'archive') widget.onArchive();
                  if (value == 'delete') widget.onDelete();
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: 'skip',
                    child: ListTile(
                      leading: Icon(Icons.skip_next_rounded),
                      title: Text('この日をスキップ'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  PopupMenuItem(
                    value: 'archive',
                    child: ListTile(
                      leading: Icon(Icons.archive_outlined),
                      title: Text('アーカイブ'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: ListTile(
                      leading: Icon(Icons.delete_outline),
                      title: Text('削除'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
              Checkbox(
                value: widget.isDone,
                activeColor: accentColor,
                onChanged: (_) => widget.onChanged(),
              ),
            ],
          ),
          if (_expanded && habit.subtasks.isNotEmpty)
            Column(
              children: [
                //親の習慣とサブタスクの境目を薄く区切る
                const Divider(
                  height: 12,
                  thickness: 0.6,
                  color: Color(0xffCDD5F0),
                ),
                for (var i = 0; i < habit.subtasks.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(left: 54),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            habit.subtasks[i].title,
                            style: TextStyle(
                              decoration: widget.subtaskIsDone(i)
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                        ),
                        //親と同じ右端にチェック位置をそろえる
                        Checkbox(
                          value: widget.subtaskIsDone(i),
                          activeColor: accentColor,
                          onChanged: (_) => widget.onSubtaskChanged(i),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
        ],
      ),
      ),
    );
  }
}
