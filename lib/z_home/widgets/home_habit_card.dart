import 'package:flutter/material.dart';
import 'package:habitapp/models/habit.dart';
import 'package:habitapp/z_habit/habit_schedule.dart';

// Homeの習慣一覧だけを担当するWidget
class HomeHabitCardContent extends StatelessWidget {
  const HomeHabitCardContent({
    super.key,
    required this.todayHabits,
    required this.carryOverHabits,
    required this.carryOverExpanded,
    required this.categoryColors,
    required this.isDone,
    required this.onToggle,
    required this.onEdit,
    required this.onCarryOverExpandedChanged,
  });

  final List<Habit> todayHabits;
  final List<Habit> carryOverHabits;
  final bool carryOverExpanded;
  final Map<String, int> categoryColors;
  final bool Function(Habit habit) isDone;
  final Future<void> Function(Habit habit) onToggle;
  final Future<void> Function(Habit habit) onEdit;
  final ValueChanged<bool> onCarryOverExpandedChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (carryOverHabits.isNotEmpty) ...[
          InkWell(
            onTap: () => onCarryOverExpandedChanged(!carryOverExpanded),
            child: Row(
              children: [
                const Text(
                  'やり残し',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xffD95C5C),
                  ),
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Divider(color: Color(0xffE5B7B7), thickness: 0.7),
                ),
                const SizedBox(width: 6),
                Icon(
                  carryOverExpanded
                      ? Icons.expand_less_rounded
                      : Icons.expand_more_rounded,
                  color: const Color(0xffD95C5C),
                ),
              ],
            ),
          ),
          if (!carryOverExpanded)
            InkWell(
              onTap: () => onCarryOverExpandedChanged(true),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Text(
                  '${carryOverHabits.first.title} など${carryOverHabits.length}件',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xffD95C5C),
                  ),
                ),
              ),
            ),
          if (carryOverExpanded)
            ...carryOverHabits.map((habit) => _habitRow(habit)),
          const SizedBox(height: 4),
        ],
        _sectionTitle('今日の習慣'),
        if (todayHabits.isEmpty)
          const SizedBox(
            height: 48,
            child: Center(
              child: Text(
                '今日の習慣はありません',
                style: TextStyle(fontSize: 13, color: Color(0xff9AA2B6)),
              ),
            ),
          )
        else
          ...todayHabits.map((habit) => _habitRow(habit)),
      ],
    );
  }

  Widget _habitRow(Habit habit) {
    final done = isDone(habit);
    final habitColor = habit.category == '未設定'
        ? const Color(0xff526FC5)
        : Color(categoryColors[habit.category] ?? 0xff526FC5);
    final sourceDate = habitDisplaySourceDate(habit, DateTime.now()) ?? DateTime.now();
    final deadlineLabel = habitDeadlineLabel(habit, sourceDate);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () => onEdit(habit),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                child: Row(
                  children: [
                    SizedBox(
                      width: 36,
                      height: 36,
                      child: habit.iconAsset != null
                          ? Image.asset(habit.iconAsset!, fit: BoxFit.contain)
                          : Icon(habit.icon, size: 24, color: habitColor),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            habit.title,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xff35415F),
                              decoration: done ? TextDecoration.lineThrough : null,
                            ),
                          ),
                          if (deadlineLabel != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              deadlineLabel,
                              // 締切は補足情報なので小さく赤色で表示
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Color(0xffD95C5C),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Checkbox(
            value: done,
            activeColor: habitColor,
            onChanged: (_) => onToggle(habit),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xff526FC5),
          ),
        ),
        const SizedBox(width: 8),
        const Expanded(
          child: Divider(color: Color(0xffCDD5F0), thickness: 0.7),
        ),
      ],
    );
  }
}
