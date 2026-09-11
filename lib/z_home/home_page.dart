//ホーム画面
import 'package:flutter/material.dart';
import 'package:habitapp/main/widgets/main_background.dart';
import 'package:habitapp/models/habit.dart';
import 'package:habitapp/models/memo.dart';
import 'package:habitapp/models/task.dart';
import 'package:habitapp/z_habit/habit_storage.dart';
import 'package:habitapp/z_memo/memo_storage.dart';
import 'package:habitapp/z_task/task_storage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  List<Habit> _todayHabits = [];
  List<Task> _todayTasks = [];
  List<Memo> _recentMemos = [];

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

    //ピン留めを優先して最近のメモを表示
    memos.sort((a, b) {
      if (a.isPinned != b.isPinned) {
        return a.isPinned ? -1 : 1;
      }

      return b.updatedAt.compareTo(a.updatedAt);
    });

    if (!mounted) return;

    setState(() {
      _todayHabits = todayHabits;
      _todayTasks = todayTasks;
      _recentMemos = memos.take(3).toList();
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

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final topSpace = screenHeight * MainBackground.headerRatio * 0.48;
    final dateKey = _todayKey();

    return Padding(
      padding: EdgeInsets.fromLTRB(16, topSpace, 16, 16),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          //今日の習慣
          _HomeSectionCard(
            title: '今日の習慣',
            icon: Icons.auto_awesome,
            child: _todayHabits.isEmpty
                ? const _EmptyText('今日の習慣はありません')
                : Column(
                    children: _todayHabits.map((habit) {
                      final isDone =
                          habit.completionHistory[dateKey] ?? false;

                      return Row(
                        children: [
                          Icon(
                            habit.icon,
                            size: 20,
                            color: const Color(0xff526FC5),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              habit.title,
                              style: TextStyle(
                                color: const Color(0xff35415F),
                                decoration: isDone
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                          ),
                          Checkbox(
                            value: isDone,
                            activeColor: const Color(0xff526FC5),
                            onChanged: (_) {
                              _toggleHabit(habit);
                            },
                          ),
                        ],
                      );
                    }).toList(),
                  ),
          ),

          const SizedBox(height: 12),

          //今日のタスク
          _HomeSectionCard(
            title: '今日のタスク',
            icon: Icons.check_circle_outline,
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
                                  fontSize: 11,
                                  color: Color(0xff526FC5),
                                ),
                              ),
                            ),
                        ],
                      );
                    }).toList(),
                  ),
          ),

          const SizedBox(height: 12),

          //最近のメモ
          _HomeSectionCard(
            title: 'メモ',
            icon: Icons.edit_note_outlined,
            child: _recentMemos.isEmpty
                ? const _EmptyText('メモはまだありません')
                : Column(
                    children: _recentMemos.map((memo) {
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
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xff35415F),
                                    ),
                                  ),
                                  if (memo.content.isNotEmpty) ...[
                                    const SizedBox(height: 3),
                                    Text(
                                      memo.content,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 12,
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
          ),
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
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
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
                size: 19,
                color: const Color(0xff526FC5),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
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

class _EmptyText extends StatelessWidget {
  const _EmptyText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            color: Color(0xff81889B),
          ),
        ),
      ),
    );
  }
}
