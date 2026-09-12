//ホーム画面
import 'package:flutter/material.dart';
import 'package:habitapp/main/widgets/main_background.dart';
import 'package:habitapp/models/habit.dart';
import 'package:habitapp/models/memo.dart';
import 'package:habitapp/models/task.dart';
import 'package:habitapp/z_habit/habit_category_storage.dart';
import 'package:habitapp/z_habit/habit_storage.dart';
import 'package:habitapp/z_memo/memo_storage.dart';
import 'package:habitapp/z_task/task_storage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  List<Habit> _allHabits = [];
  List<Habit> _todayHabits = [];
  List<Task> _todayTasks = [];
  List<Memo> _pinnedMemos = [];
  Map<String, int> _categoryColors = {};

  @override
  void initState() {
    super.initState();
    reload();
  }

  //Homeで使うデータをまとめて読み込む
  Future<void> reload() async {
    final habits = await HabitStorage.loadHabits();
    final tasks = await TaskStorage.loadTasks();
    final memos = await MemoStorage.loadMemos();
    final categoryColors =
        await HabitCategoryStorage.loadCategoryColors();

    final now = DateTime.now();

    const days = ['月', '火', '水', '木', '金', '土', '日'];
    final todayName = days[now.weekday - 1];

    final todayHabits = habits.where((habit) {
      return habit.days.contains(todayName);
    }).toList();

    final todayTasks = tasks.where((task) {
      final deadline = task.deadline;

      if (deadline == null || task.isDone) {
        return false;
      }

      return deadline.year == now.year &&
          deadline.month == now.month &&
          deadline.day == now.day;
    }).toList();

    //Homeにはピン留めしたメモだけ表示
    final pinnedMemos = memos
        .where((memo) => memo.isPinned)
        .toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    if (!mounted) return;

    setState(() {
      _allHabits = habits;
      _todayHabits = todayHabits;
      _todayTasks = todayTasks;
      _pinnedMemos = pinnedMemos;
      _categoryColors = categoryColors;
    });
  }

  //今日の日付キー
  String _todayKey() {
    final now = DateTime.now();

    return '${now.year}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
  }

  //Homeから習慣の達成状態を変更
  Future<void> _toggleHabit(Habit targetHabit) async {
    final habits = await HabitStorage.loadHabits();
    final dateKey = _todayKey();

    for (final habit in habits) {
      if (habit.title == targetHabit.title) {
        habit.completionHistory[dateKey] =
            !(habit.completionHistory[dateKey] ?? false);
        break;
      }
    }

    await HabitStorage.saveHabits(habits);
    await reload();
  }

  //Homeからタスクを完了
  Future<void> _completeTask(Task targetTask) async {
    final tasks = await TaskStorage.loadTasks();

    for (final task in tasks) {
      if (task.title == targetTask.title &&
          task.deadline == targetTask.deadline &&
          task.category == targetTask.category &&
          !task.isDone) {
        task.isDone = true;
        break;
      }
    }

    await TaskStorage.saveTasks(tasks);
    await reload();
  }

  //全習慣の達成記録を1つのマス列にまとめる
  List<_HabitMark> _habitMarks() {
    final marks = <_HabitMark>[];

    for (final habit in _allHabits) {
      final color = habit.category == '未設定'
          ? const Color(0xff526FC5)
          : Color(
              _categoryColors[habit.category] ?? 0xff526FC5,
            );

      for (final entry in habit.completionHistory.entries) {
        if (entry.value) {
          marks.add(
            _HabitMark(
              dateKey: entry.key,
              color: color,
            ),
          );
        }
      }
    }

    marks.sort((a, b) => a.dateKey.compareTo(b.dateKey));
    return marks;
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final topSpace = screenHeight * MainBackground.headerRatio * 0.58;
    final dateKey = _todayKey();
    final habitMarks = _habitMarks();

    //スマホ以外は白い土台を2×2に区切り、スマホはカード表示
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 600;

        final habitRecordCard = _HomeSectionCard(
          title: '習慣の積み重ね',
          icon: Icons.grid_view_rounded,
          minHeight: 166,
          child: _HomeHabitGrid(marks: habitMarks),
        );

        final todayHabitCard = _HomeSectionCard(
          title: '今日の習慣',
          icon: Icons.auto_awesome,
          minHeight: 128,
          child: _todayHabits.isEmpty
              ? const _EmptyText('今日の習慣はありません')
              : Column(
                  children: _todayHabits.map((habit) {
                    final isDone =
                        habit.completionHistory[dateKey] ?? false;
                    final habitColor = habit.category == '未設定'
                        ? const Color(0xff526FC5)
                        : Color(
                            _categoryColors[habit.category] ??
                                0xff526FC5,
                          );

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        children: [
                          Icon(
                            habit.icon,
                            size: 22,
                            color: habitColor,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              habit.title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xff35415F),
                                decoration: isDone
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                          ),
                          Checkbox(
                            value: isDone,
                            activeColor: habitColor,
                            onChanged: (_) {
                              _toggleHabit(habit);
                            },
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
        );

        final todayTaskCard = _HomeSectionCard(
          title: '今日のタスク',
          icon: Icons.check_circle_outline,
          minHeight: 128,
          child: _todayTasks.isEmpty
              ? const _EmptyText('今日締切のタスクはありません')
              : Column(
                  children: _todayTasks.map((task) {
                    return Row(
                      children: [
                        Checkbox(
                          value: false,
                          activeColor: const Color(0xff526FC5),
                          onChanged: (_) {
                            _completeTask(task);
                          },
                        ),
                        Expanded(
                          child: Text(
                            task.title,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Color(0xff35415F),
                            ),
                          ),
                        ),
                        if (task.category != '未設定')
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
                              task.category,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xff526FC5),
                              ),
                            ),
                          ),
                      ],
                    );
                  }).toList(),
                ),
        );

        final memoCard = _HomeSectionCard(
          title: 'メモ',
          icon: Icons.edit_note_outlined,
          minHeight: 128,
          child: _pinnedMemos.isEmpty
              ? const _EmptyText('ピン留めしたメモはありません')
              : Column(
                  children: _pinnedMemos.map((memo) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (memo.isPinned)
                            const Padding(
                              padding: EdgeInsets.only(right: 6, top: 2),
                              child: Icon(
                                Icons.push_pin,
                                size: 15,
                                color: Color(0xff526FC5),
                              ),
                            ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  memo.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xff35415F),
                                  ),
                                ),
                                if (memo.preview.isNotEmpty) ...[
                                  const SizedBox(height: 3),
                                  Text(
                                    memo.preview,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Color(0xff697188),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
        );

        if (isWide) {
          //スマホ以外は、ほかのページと同じ白い土台を使う
          final headerHeight = screenHeight * 0.32;

          return Padding(
            padding: EdgeInsets.only(top: headerHeight),
            child: Container(
              width: double.infinity,
              height: constraints.maxHeight - headerHeight,
              color: const Color(0xffF7F9FF),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    //上段は習慣・タスク。内容が多い方に合わせて行が伸びる
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _HomeWideSection(
                            title: '今日の習慣',
                            icon: Icons.auto_awesome,
                            showRightBorder: true,
                            showBottomBorder: true,
                            child: todayHabitCard.child,
                          ),
                        ),
                        Expanded(
                          child: _HomeWideSection(
                            title: '今日のタスク',
                            icon: Icons.check_circle_outline,
                            showBottomBorder: true,
                            child: todayTaskCard.child,
                          ),
                        ),
                      ],
                    ),

                    //下段。3番目に習慣の記録
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _HomeWideSection(
                            title: '習慣の積み重ね',
                            icon: Icons.grid_view_rounded,
                            showRightBorder: true,
                            child: _HomeHabitGrid(
                              marks: habitMarks,
                            ),
                          ),
                        ),
                        Expanded(
                          child: _HomeWideSection(
                            title: 'メモ',
                            icon: Icons.edit_note_outlined,
                            child: memoCard.child,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        //スマホ版は今まで通りカード表示
        return Padding(
          padding: EdgeInsets.fromLTRB(16, topSpace, 16, 16),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              todayHabitCard,
              const SizedBox(height: 12),
              todayTaskCard,
              const SizedBox(height: 12),
              //スマホでも3番目に習慣の記録を配置
              habitRecordCard,
              const SizedBox(height: 12),
              memoCard,
            ],
          ),
        );
      },
    );
  }
}

//Web版の白い領域内に置く区画
class _HomeWideSection extends StatelessWidget {
  const _HomeWideSection({
    required this.title,
    required this.icon,
    required this.child,
    this.showRightBorder = false,
    this.showBottomBorder = false,
  });

  final String title;
  final IconData icon;
  final Widget child;
  final bool showRightBorder;
  final bool showBottomBorder;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 180),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(
          right: showRightBorder
              ? const BorderSide(color: Color(0xffE6EAF4))
              : BorderSide.none,
          bottom: showBottomBorder
              ? const BorderSide(color: Color(0xffE6EAF4))
              : BorderSide.none,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 22,
                color: const Color(0xff526FC5),
              ),
              const SizedBox(width: 9),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff35415F),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

//Home上の白いカード
class _HomeSectionCard extends StatelessWidget {
  const _HomeSectionCard({
    required this.title,
    required this.icon,
    required this.child,
    required this.minHeight,
  });

  final String title;
  final IconData icon;
  final Widget child;
  final double minHeight;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minHeight: minHeight),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: const Color(0xff526FC5),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff35415F),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

//Home用の全習慣マス
class _HomeHabitGrid extends StatelessWidget {
  const _HomeHabitGrid({
    required this.marks,
  });

  final List<_HabitMark> marks;

  static const int _minimumCells = 60;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const cellSize = 14.0;
        const spacing = 4.0;

        //記録が増えるほどマスも増え、区画自体も縦に伸びる
        final cellCount =
            marks.length > _minimumCells ? marks.length : _minimumCells;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: List.generate(cellCount, (index) {
            final hasRecord = index < marks.length;

            return Container(
              width: cellSize,
              height: cellSize,
              decoration: BoxDecoration(
                color: hasRecord
                    ? marks[index].color
                    : const Color(0xffF7F9FF),
                borderRadius: BorderRadius.circular(3),
                border: Border.all(
                  color: hasRecord
                      ? marks[index].color
                      : const Color(0xffDCE3F5),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

class _HabitMark {
  const _HabitMark({
    required this.dateKey,
    required this.color,
  });

  final String dateKey;
  final Color color;
}

class _EmptyText extends StatelessWidget {
  const _EmptyText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xff9AA2B6),
          ),
        ),
      ),
    );
  }
}
