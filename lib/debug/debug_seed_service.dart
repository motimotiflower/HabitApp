//開発中だけ使う確認用データ
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:habitapp/models/habit.dart';
import 'package:habitapp/models/memo.dart';
import 'package:habitapp/models/task.dart';
import 'package:habitapp/z_habit/habit_category_storage.dart';
import 'package:habitapp/z_habit/habit_storage.dart';
import 'package:habitapp/z_memo/memo_storage.dart';
import 'package:habitapp/z_task/category_storage.dart';
import 'package:habitapp/z_task/task_storage.dart';

class DebugSeedService {
  static Future<void> seedIfNeeded() async {
    if (!kDebugMode) return;

    final habits = await HabitStorage.loadHabits();
    final tasks = await TaskStorage.loadTasks();
    final memos = await MemoStorage.loadMemos();

    if (habits.isNotEmpty || tasks.isNotEmpty || memos.isNotEmpty) return;

    await addSampleData();
  }

  static Future<void> addSampleData() async {
    if (!kDebugMode) return;

    final now = DateTime.now();
    const dayNames = ['月', '火', '水', '木', '金', '土', '日'];
    final todayName = dayNames[now.weekday - 1];
    final todayKey =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    final habits = await HabitStorage.loadHabits();
    final existingHabitIds = habits.map((item) => item.id).toSet();

    final samples = [
      Habit(
        id: 'debug_habit_reading',
        title: '読書',
        icon: Icons.menu_book,
        days: const ['月', '火', '水', '木', '金', '土', '日'],
        category: '勉強',
        completionHistory: {todayKey: true},
      ),
      Habit(
        id: 'debug_habit_stretch',
        title: 'ストレッチ',
        icon: Icons.self_improvement,
        days: const ['月', '水', '金', '日'],
        category: '健康',
      ),
      Habit(
        id: 'debug_habit_water',
        title: '水を飲む',
        icon: Icons.water_drop,
        days: [todayName],
        category: '未設定',
      ),
    ];

    habits.addAll(
      samples.where((item) => !existingHabitIds.contains(item.id)),
    );
    await HabitStorage.saveHabits(habits);

    final tasks = await TaskStorage.loadTasks();
    final existingTaskIds = tasks.map((item) => item.id).toSet();

    final taskSamples = [
      Task(
        id: 'debug_task_report',
        title: 'レポートを提出',
        description: '資料を見直して、提出前に誤字を確認する。',
        deadline: now.add(const Duration(days: 3)),
        category: '大学',
        isFlagged: true,
      ),
      Task(
        id: 'debug_task_mail',
        title: 'メールを返信',
        description: '確認した内容をまとめて返信する。',
        deadline: now.add(const Duration(days: 1)),
        category: '大学',
      ),
      Task(
        id: 'debug_task_idea',
        title: 'アプリのアイデア整理',
        description: '通知・記録・星システムの気になる点をメモする。',
        category: '制作',
        isFlagged: true,
      ),
    ];

    tasks.addAll(
      taskSamples.where((item) => !existingTaskIds.contains(item.id)),
    );
    await TaskStorage.saveTasks(tasks);

    final memos = await MemoStorage.loadMemos();
    final hasDebugMemo = memos.any((memo) => memo.title == 'アイデアメモ');

    if (!hasDebugMemo) {
      memos.add(
        Memo(
          title: 'アイデアメモ',
          updatedAt: now,
          isPinned: true,
          messages: [
            MemoMessage(
              content: '画面を見ながら気になったことをここに残す。',
              createdAt: now.subtract(const Duration(minutes: 2)),
            ),
            MemoMessage(
              content: '文字サイズと余白も確認する。',
              createdAt: now,
            ),
          ],
        ),
      );
      await MemoStorage.saveMemos(memos);
    }

    await HabitCategoryStorage.saveCategories(['勉強', '健康']);
    await HabitCategoryStorage.saveCategoryColors({
      '勉強': const Color(0xff6880D0).toARGB32(),
      '健康': const Color(0xff8B8DD3).toARGB32(),
    });
    await CategoryStorage.saveCategories(['大学', '制作']);
  }
}
