//Homeから開く習慣記録の詳細画面
import 'package:flutter/material.dart';
import 'package:habitapp/main/widgets/main_background.dart';
import 'package:habitapp/models/habit.dart';

class HomeHabitRecordPage extends StatefulWidget {
  const HomeHabitRecordPage({
    super.key,
    required this.habits,
    required this.categoryColors,
    this.onHabitsChanged,
  });

  final List<Habit> habits;
  final Map<String, int> categoryColors;
  final Future<void> Function(List<Habit> habits)? onHabitsChanged;

  @override
  State<HomeHabitRecordPage> createState() =>
      _HomeHabitRecordPageState();
}

class _HomeHabitRecordPageState
    extends State<HomeHabitRecordPage> {
  //ジャンル未設定なら習慣単体、それ以外はジャンルごとにまとめる
  Map<String, List<Habit>> _groupHabits() {
    final groups = <String, List<Habit>>{};

    for (final habit in widget.habits) {
      if (habit.archivedAt != null) continue;
      final key =
          habit.category == '未設定' ? habit.title : habit.category;

      groups.putIfAbsent(key, () => []);
      groups[key]!.add(habit);
    }

    return groups;
  }

  int _completedCount(List<Habit> groupHabits) {
    var count = 0;

    for (final habit in groupHabits) {
      for (final completed in habit.completionHistory.values) {
        if (completed) count++;
      }
    }

    return count;
  }

  //全部カードでは達成1件ごとのジャンル色をそのまま使う
  List<Color> _allCompletedColors(List<Habit> habits) {
    final colors = <Color>[];
    for (final habit in habits) {
      final color = habit.category == '未設定'
          ? const Color(0xff526FC5)
          : Color(widget.categoryColors[habit.category] ?? 0xff526FC5);
      for (final completed in habit.completionHistory.values) {
        if (completed) colors.add(color);
      }
    }
    return colors;
  }

  Color _groupColor(List<Habit> groupHabits) {
    final firstHabit = groupHabits.first;

    if (firstHabit.category == '未設定') {
      return const Color(0xff526FC5);
    }

    return Color(
      widget.categoryColors[firstHabit.category] ?? 0xff526FC5,
    );
  }

  Future<void> _restoreHabit(Habit habit) async {
    final index = widget.habits.indexOf(habit);
    if (index == -1) return;

    //復元した日より前に新しく表示しない
    final restored = Habit(
      id: habit.id,
      title: habit.title,
      icon: habit.icon,
      iconAsset: habit.iconAsset,
      days: habit.days,
      category: habit.category,
      notificationEnabled: habit.notificationEnabled,
      notificationDays: habit.notificationDays,
      notificationDate: habit.notificationDate,
      notificationHour: habit.notificationHour,
      notificationMinute: habit.notificationMinute,
      completionHistory: Map<String, bool>.from(habit.completionHistory),
      completionDates: Map<String, String>.from(habit.completionDates),
      shareCompletion: habit.shareCompletion,
      carryOverIfIncomplete: habit.carryOverIfIncomplete,
      startedAt: DateTime.now(),
      archivedAt: null,
      subtasks: habit.subtasks,
    );
    setState(() => widget.habits[index] = restored);
    await widget.onHabitsChanged?.call(widget.habits);
    if (!mounted) return;

    //復元も数秒間だけ取り消せるようにする
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: const Text('アーカイブから戻しました'),
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: '元に戻す',
            onPressed: () async {
              setState(() => widget.habits[index] = habit);
              await widget.onHabitsChanged?.call(widget.habits);
            },
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final groups = _groupHabits();
    final archivedHabits = widget.habits
        .where((habit) => habit.archivedAt != null)
        .toList();
    final activeHabits = widget.habits
        .where((habit) => habit.archivedAt == null)
        .toList();

    //一番上の「全部」は、現在の全グループの達成をまとめる
    final allCompletedCount = _completedCount(activeHabits);
    final allCompletedColors = _allCompletedColors(activeHabits);

    //並んだカード同士で縦のマス数もそろえる
    final maxCompleted = groups.values.isEmpty
        ? allCompletedCount
        : [
            allCompletedCount,
            ...groups.values.map(_completedCount),
          ].reduce((a, b) => a > b ? a : b);
    const columns = 11;
    const minimumCells = columns * 3;
    final roundedCells =
        ((maxCompleted + columns - 1) ~/ columns) * columns;
    final commonCellCount =
        roundedCells > minimumCells ? roundedCells : minimumCells;

    return Scaffold(
      backgroundColor: const Color(0xffF7F9FF),
      //メモ部屋と同じ高さ・余白・戻るボタンのヘッダー
      appBar: AppBar(
        //各詳細ページで上下の余白をそろえる
        toolbarHeight: MainBackground.detailToolbarHeight,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        //上部だけ星空背景にする
        //AppBar自体の前面まで画像を敷く
        flexibleSpace: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/images/background_sky.png',
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
            ),
          ],
        ),
        titleSpacing: 0,
        title: const Text(
          '記録',
          style: TextStyle(
            color: Colors.white,
            fontSize: 23,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
        children: [
          if (archivedHabits.isNotEmpty) ...[
            ExpansionTile(
              tilePadding: EdgeInsets.zero,
              leading: const Icon(Icons.archive_outlined),
              title: Text('アーカイブ  ${archivedHabits.length}件'),
              children: archivedHabits.map((habit) {
                return ListTile(
                  contentPadding: const EdgeInsets.only(left: 12),
                  title: Text(habit.title),
                  trailing: TextButton.icon(
                    onPressed: () => _restoreHabit(habit),
                    icon: const Icon(Icons.unarchive_outlined),
                    label: const Text('戻す'),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
          ],
          if (groups.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Text(
                  'まだ記録がありません',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xff81889B),
                  ),
                ),
              ),
            )
          else ...[
            //最上部はすべての習慣記録を合計したカード
            _RecordGrid(
              title: '全部',
              completedCount: allCompletedCount,
              color: const Color(0xff526FC5),
              cellCount: commonCellCount,
              completedColors: allCompletedColors,
            ),
            const SizedBox(height: 22),
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 700;
                final columnCount = constraints.maxWidth >= 1200
                    ? 3
                    : constraints.maxWidth >= 700
                        ? 2
                        : 1;
                const gap = 18.0;
                final itemWidth = columnCount == 1
                    ? constraints.maxWidth
                    : (constraints.maxWidth -
                            gap * (columnCount - 1)) /
                        columnCount;

                return Wrap(
                  spacing: gap,
                  runSpacing: 22,
                  children: groups.entries.map((entry) {
                    return SizedBox(
                      width: itemWidth,
                      child: _RecordGrid(
                        title: entry.key,
                        completedCount: _completedCount(entry.value),
                        color: _groupColor(entry.value),
                        compact: isWide,
                        cellCount: commonCellCount,
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
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
    required this.cellCount,
    this.compact = false,
    this.completedColors,
  });

  final String title;
  final int completedCount;
  final Color color;
  final int cellCount;
  final bool compact;
  final List<Color>? completedColors;

  static const int _columnCount = 11;

  @override
  Widget build(BuildContext context) {

    //ジャンル・習慣ごとにカードで分けて見やすくする
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xffE2E7F5),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: const Color(0xff35415F),
            ),
          ),
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (context, constraints) {
              final spacing = compact ? 4.0 : 5.0;

              //カード幅いっぱいに11列のマスを敷き詰める
              final cellSize = (constraints.maxWidth -
                      spacing * (_columnCount - 1)) /
                  _columnCount;

              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: List.generate(cellCount, (index) {
                  final completed = index < completedCount;
                  //全部カードだけは各達成元のジャンル色を使う
                  final cellColor = completed &&
                          completedColors != null &&
                          index < completedColors!.length
                      ? completedColors![index]
                      : color;

                  return Container(
                    width: cellSize,
                    height: cellSize,
                    decoration: BoxDecoration(
                      color: completed ? cellColor : const Color(0xffF8FAFF),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: completed
                            ? cellColor
                            : const Color(0xffDCE3F5),
                      ),
                    ),
                  );
                }),
              );
            },
          ),
        ],
      ),
    );
  }
}
