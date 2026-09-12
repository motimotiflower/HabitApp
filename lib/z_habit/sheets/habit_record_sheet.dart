//習慣の達成記録を表示する画面
import 'package:flutter/material.dart';
import 'package:habitapp/models/habit.dart';

class HabitRecordSheet extends StatelessWidget {
  const HabitRecordSheet({
    super.key,
    required this.habits,
  });

  final List<Habit> habits;

  //ジャンル未設定なら習慣単体、それ以外はジャンルごとにまとめる
  Map<String, List<Habit>> _groupHabits() {
    final groups = <String, List<Habit>>{};

    for (final habit in habits) {
      final key = habit.category == '未設定'
          ? habit.title
          : habit.category;

      groups.putIfAbsent(key, () => []);
      groups[key]!.add(habit);
    }

    return groups;
  }

  //そのグループで記録されている達成日を古い順に取得
  List<String> _completedRecords(List<Habit> groupHabits) {
    final records = <String>[];

    for (final habit in groupHabits) {
      for (final entry in habit.completionHistory.entries) {
        if (entry.value) {
          records.add(entry.key);
        }
      }
    }

    records.sort();
    return records;
  }

  @override
  Widget build(BuildContext context) {
    final groups = _groupHabits();

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xffF7F9FF),
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '習慣の記録',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff263A70),
                ),
              ),

              const SizedBox(height: 6),

              const Text(
                '続けた分だけ、マスが少しずつ増えていきます',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xff81889B),
                ),
              ),

              const SizedBox(height: 20),

              Expanded(
                child: groups.isEmpty
                    ? const Center(
                        child: Text(
                          'まだ習慣がありません',
                          style: TextStyle(
                            color: Color(0xff81889B),
                          ),
                        ),
                      )
                    : ListView.separated(
                        itemCount: groups.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 24),
                        itemBuilder: (context, index) {
                          final entry = groups.entries.elementAt(index);
                          final records = _completedRecords(entry.value);

                          return _HabitRecordGrid(
                            title: entry.key,
                            completedCount: records.length,
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HabitRecordGrid extends StatelessWidget {
  const _HabitRecordGrid({
    required this.title,
    required this.completedCount,
  });

  final String title;
  final int completedCount;

  static const int _columnCount = 11;
  static const int _minimumRows = 3;

  @override
  Widget build(BuildContext context) {
    //最低3行を表示し、記録が増えたら必要な分だけ行を増やす
    final minimumCells = _columnCount * _minimumRows;
    final neededCells =
        ((completedCount + _columnCount - 1) ~/ _columnCount) * _columnCount;
    final cellCount =
        neededCells > minimumCells ? neededCells : minimumCells;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xff35415F),
          ),
        ),

        const SizedBox(height: 10),

        LayoutBuilder(
          builder: (context, constraints) {
            const spacing = 5.0;
            final cellSize =
                (constraints.maxWidth - spacing * (_columnCount - 1)) /
                    _columnCount;

            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: List.generate(cellCount, (index) {
                final completed = index < completedCount;

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: cellSize,
                  height: cellSize,
                  decoration: BoxDecoration(
                    color: completed
                        ? const Color(0xff526FC5)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: completed
                          ? const Color(0xff526FC5)
                          : const Color(0xffDCE3F5),
                    ),
                  ),
                );
              }),
            );
          },
        ),
      ],
    );
  }
}
