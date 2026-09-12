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
    this.categoryColor,
  });

  final Habit habit;
  final bool isDone;
  final VoidCallback onChanged;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final Color? categoryColor;

  @override
  Widget build(BuildContext context) {
    final accentColor = habit.category == '未設定'
        ? const Color(0xff526FC5)
        : (categoryColor ?? const Color(0xff526FC5));

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 14,
      ),
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
            size: 24,
            color: accentColor,
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  habit.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xff35415F),
                    decoration:
                        isDone ? TextDecoration.lineThrough : null,
                  ),
                ),

                if (habit.category != '未設定') ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.13),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      habit.category,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: accentColor,
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
            icon: const Icon(Icons.edit_outlined, size: 20),
            onPressed: onEdit,
          ),

          IconButton(
            tooltip: '削除',
            color: const Color(0xff526FC5),
            icon: const Icon(Icons.delete_outline, size: 20),
            onPressed: onDelete,
          ),

          Checkbox(
            value: isDone,
            activeColor: accentColor,
            onChanged: (_) {
              onChanged();
            },
          ),
        ],
      ),
    );
  }
}
