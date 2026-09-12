//Homeから開く習慣記録の詳細画面
import 'package:flutter/material.dart';
import 'package:habitapp/models/habit.dart';

class HomeHabitRecordPage extends StatelessWidget {
  const HomeHabitRecordPage({
    super.key,
    required this.habits,
    required this.categoryColors,
  });

  final List<Habit> habits;
  final Map<String, int> categoryColors;

  //ジャンル未設定なら習慣単体、それ以外はジャンルごとにまとめる
  Map<String, List<Habit>> _groupHabits() {
    final groups = <String, List<Habit>>{};

    for (final habit in habits) {
      final key =
          habit.category == '未設定' ? habit.title : habit.category;

      groups.putIfAbsent(key, () => []);
      groups[key]!.add(habit);
    }

    return groups;
  }

  //グループ内の達成回数を数える
  int _completedCount(List<Habit> groupHabits) {
    var count = 0;

    for (final habit in groupHabits) {
      for (final completed in habit.completionHistory.values) {
        if (completed) count++;
      }
    }

    return count;
  }

  Color _groupColor(List<Habit> groupHabits) {
    final firstHabit = groupHabits.first;

    if (firstHabit.category == '未設定') {
      return const Color(0xff526FC5);
    }

    return Color(
      categoryColors[firstHabit.category] ?? 0xff526FC5,
    );
  }

  @override
  Widget build(BuildContext context) {
    final groups = _groupHabits();
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    //ほかのページと同じ青いヘッダーを使う
    final headerHeight = screenHeight * 0.26;
    final titlePosition = headerHeight * 0.26;
    final titlePadding =
        (screenWidth * 0.07).clamp(0.0, 60.0).toDouble();
    final titleFontSize =
        (screenWidth * 0.08).clamp(0.0, 36.0).toDouble();

    return Scaffold(
      backgroundColor: const Color(0xffF7F9FF),
      body: Column(
        children: [
          Container(
            height: headerHeight,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xff102d72),
                  Color(0xff5e78cf),
                ],
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: titlePosition,
                  left: titlePadding,
                  child: Text(
                    '習慣の記録',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: titleFontSize,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Positioned(
                  top: titlePosition,
                  right: screenWidth > 700 ? 60 : screenWidth * 0.06,
                  child: SizedBox(
                    width: 48,
                    height: 48,
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.close,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          //中身はこのあと相談して決める
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(18),
              children: [
                const Text(
                  '星の記録',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff35415F),
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  '習慣の積み重ね',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff35415F),
                  ),
                ),
                const SizedBox(height: 14),
                if (groups.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Text(
                        'まだ記録がありません',
                        style: TextStyle(
                          color: Color(0xff81889B),
                        ),
                      ),
                    ),
                  )
                else
                  ...groups.entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: _RecordGrid(
                        title: entry.key,
                        completedCount: _completedCount(entry.value),
                        color: _groupColor(entry.value),
                      ),
                    );
                  }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RecordGrid extends StatelessWidget {
  const _RecordGrid({
    required this.title,
    required this.completedCount,
    required this.color,
  });

  final String title;
  final int completedCount;
  final Color color;

  static const int _columnCount = 11;
  static const int _minimumRows = 3;

  @override
  Widget build(BuildContext context) {
    final minimumCells = _columnCount * _minimumRows;
    final neededCells =
        ((completedCount + _columnCount - 1) ~/ _columnCount) *
            _columnCount;
    final cellCount =
        neededCells > minimumCells ? neededCells : minimumCells;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: color,
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

                return Container(
                  width: cellSize,
                  height: cellSize,
                  decoration: BoxDecoration(
                    color: completed ? color : Colors.white,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: completed
                          ? color
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
