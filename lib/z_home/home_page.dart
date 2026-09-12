//ホーム画面
import 'package:flutter/material.dart';
import 'package:habitapp/main/widgets/main_background.dart';
import 'package:habitapp/models/habit.dart';
import 'package:habitapp/models/memo.dart';
import 'package:habitapp/models/task.dart';
import 'package:habitapp/z_habit/habit_category_storage.dart';
import 'package:habitapp/z_habit/habit_storage.dart';
import 'package:habitapp/z_home/home_habit_record_page.dart';
import 'package:habitapp/z_memo/memo_storage.dart';
import 'package:habitapp/z_task/task_storage.dart';
import 'package:habitapp/z_star/star_storage.dart';

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

    //Homeでは未完了タスクを締切が近い順に表示する
    final todayTasks = tasks.where((task) {
      return !task.isDone;
    }).toList()
      ..sort((a, b) {
        if (a.deadline != null && b.deadline != null) {
          return a.deadline!.compareTo(b.deadline!);
        }
        if (a.deadline != null) return -1;
        if (b.deadline != null) return 1;
        return 0;
      });

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
    bool? wasDone;

    for (final habit in habits) {
      if (habit.id == targetHabit.id) {
        wasDone = habit.completionHistory[dateKey] ?? false;
        habit.completionHistory[dateKey] = !wasDone;
        break;
      }
    }

    await HabitStorage.saveHabits(habits);

    if (wasDone != null) {
      final actionKey =
          'habit|${targetHabit.id}|$dateKey';

      if (!wasDone!) {
        await StarStorage.award(
          actionKey: actionKey,
          source: 'habit',
        );
      } else {
        await StarStorage.revoke(actionKey);
      }
    }

    await reload();
  }

  //Homeからタスクを完了
  Future<void> _completeTask(Task targetTask) async {
    final tasks = await TaskStorage.loadTasks();

    for (final task in tasks) {
      if (task.id == targetTask.id && !task.isDone) {
        task.isDone = true;

        await StarStorage.award(
          actionKey: 'task|${task.id}',
          source: 'task',
        );
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

  //Homeの習慣記録を開く
  void _openHabitRecord() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => HomeHabitRecordPage(
          habits: _allHabits,
          categoryColors: _categoryColors,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final dateKey = _todayKey();
    final habitMarks = _habitMarks();

    //スマホ以外は白い土台を2×2に区切り、スマホはカード表示
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 600;

        final habitRecordCard = _HomeSectionCard(
          title: '習慣の積み重ね',
          icon: Icons.grid_view_rounded,
          minHeight: 190,
          onTap: _openHabitRecord,
          child: _HomeHabitGrid(
            marks: habitMarks,
            fillCard: true,
          ),
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
          title: 'タスク',
          icon: Icons.check_circle_outline,
          minHeight: 128,
          child: _todayTasks.isEmpty
              ? const _EmptyText('未完了のタスクはありません')
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
                        if (task.deadline != null) ...[
                          const SizedBox(width: 10),
                          Text(
                            '${task.deadline!.month}/${task.deadline!.day}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xff81889B),
                            ),
                          ),
                        ],
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

        //Homeはヘッダーも白い内容部分も1つのスクロールにする
        final headerHeight = screenHeight * 0.30;

        //ほかのページと同じ位置・大きさにそろえる
        final titlePosition = headerHeight * 0.26;
        final titlePadding =
            (screenWidth * 0.07).clamp(0.0, 60.0).toDouble();
        final titleFontSize =
            (screenWidth * 0.08).clamp(0.0, 36.0).toDouble();
        final horizontalPadding =
            screenWidth > 700 ? 60.0 : screenWidth * 0.06;

        //中身が空でも4分割がしっかり見える最低高さ
        final sectionMinHeight = isWide
            ? ((screenHeight - headerHeight - 32) / 2)
                .clamp(220.0, double.infinity)
                .toDouble()
            : 220.0;

        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              //Home専用ヘッダー
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
                        'Home',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Positioned(
                      top: titlePosition,
                      right: horizontalPadding,
                      child: const SizedBox(
                        width: 48,
                        height: 48,
                        child: Center(
                          child: Icon(
                            Icons.settings_outlined,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              if (isWide)
                //スマホ以外は1つの白い領域を2×2に区切る
                Container(
                  width: double.infinity,
                  color: const Color(0xffF7F9FF),
                  padding: const EdgeInsets.all(16),
                  child: Table(
                    border: const TableBorder(
                      horizontalInside: BorderSide(
                        color: Color(0xffE6EAF4),
                      ),
                      verticalInside: BorderSide(
                        color: Color(0xffE6EAF4),
                      ),
                    ),
                    columnWidths: const {
                      0: FlexColumnWidth(),
                      1: FlexColumnWidth(),
                    },
                    children: [
                      TableRow(
                        children: [
                          _HomeWideSection(
                            title: '今日の習慣',
                            icon: Icons.auto_awesome,
                            minHeight: sectionMinHeight,
                            child: todayHabitCard.child,
                          ),
                          _HomeWideSection(
                            title: 'タスク',
                            icon: Icons.check_circle_outline,
                            minHeight: sectionMinHeight,
                            child: todayTaskCard.child,
                          ),
                        ],
                      ),
                      TableRow(
                        children: [
                          //3番目に習慣の記録を配置
                          _HomeWideSection(
                            title: '習慣の積み重ね',
                            icon: Icons.grid_view_rounded,
                            minHeight: sectionMinHeight,
                            onTap: _openHabitRecord,
                            child: _HomeHabitGrid(
                              marks: habitMarks,
                              isWide: true,
                            ),
                          ),
                          _HomeWideSection(
                            title: 'メモ',
                            icon: Icons.edit_note_outlined,
                            minHeight: sectionMinHeight,
                            child: memoCard.child,
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              else
                //スマホは今まで通りカードを縦に並べる
                Container(
                  color: const Color(0xffF7F9FF),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      todayHabitCard,
                      const SizedBox(height: 12),
                      todayTaskCard,
                      const SizedBox(height: 12),
                      habitRecordCard,
                      const SizedBox(height: 12),
                      memoCard,
                    ],
                  ),
                ),
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
    required this.minHeight,
    this.onTap,
  });

  final String title;
  final IconData icon;
  final Widget child;
  final double minHeight;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
      constraints: BoxConstraints(minHeight: minHeight),
      child: Padding(
        padding: const EdgeInsets.all(20),
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
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff35415F),
                    ),
                  ),
                ),
                if (onTap != null)
                  const Icon(
                    Icons.chevron_right,
                    color: Color(0xff81889B),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            child,
          ],
        ),
      ),
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
    this.onTap,
  });

  final String title;
  final IconData icon;
  final Widget child;
  final double minHeight;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Container(
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
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff35415F),
                  ),
                ),
              ),
              if (onTap != null)
                const Icon(
                  Icons.chevron_right,
                  color: Color(0xff81889B),
                ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
      ),
    );
  }
}

//Home用の全習慣マス
class _HomeHabitGrid extends StatelessWidget {
  const _HomeHabitGrid({
    required this.marks,
    this.isWide = false,
    this.fillCard = false,
  });

  final List<_HabitMark> marks;
  final bool isWide;
  final bool fillCard;

  static const int _minimumCells = 60;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        //Web・スマホとも少し大きめのマスにする
        final cellSize = isWide ? 22.0 : 16.0;
        final spacing = isWide ? 5.0 : 4.0;

        final columns = constraints.maxWidth.isFinite
            ? ((constraints.maxWidth + spacing) / (cellSize + spacing))
                .floor()
                .clamp(1, 1000)
            : 1;

        //カード表示では横幅いっぱい×最低5行までマスを敷き詰める
        final fillMinimumCells = columns * (isWide ? 6 : 5);
        final minimumCells =
            (isWide || fillCard) && fillMinimumCells > _minimumCells
                ? fillMinimumCells
                : _minimumCells;

        //記録が増えるほどマスも増え、区画自体も縦に伸びる
        final cellCount =
            marks.length > minimumCells ? marks.length : minimumCells;

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
