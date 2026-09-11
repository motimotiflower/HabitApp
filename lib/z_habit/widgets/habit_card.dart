//データ1件の表示
import 'package:flutter/material.dart';
import 'package:habitapp/models/habit.dart';

class HabitCard extends StatelessWidget {
  const HabitCard({
    super.key,
    required this.habit,
    required this.isDone,
    required this.onChanged,
    required this.onEdit,
    required this.onDelete,
  });

  final Habit habit;
  final bool isDone;
  final VoidCallback onChanged;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
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
          Icon(
            habit.icon,
            color: const Color(0xff526FC5),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  habit.title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xff35415F),
                    decoration:
                        isDone ? TextDecoration.lineThrough : null,
                  ),
                ),

                if (habit.category != '未設定') ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xffE8EDFC),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      habit.category,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xff526FC5),
                      ),
                    ),
                  ),
                ],
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
            value: isDone,
            activeColor: const Color(0xff526FC5),
            onChanged: (_) {
              onChanged();
            },
          ),
        ],
      ),
    );
  }
}
