//習慣を表示するページ
import 'package:flutter/material.dart';
import 'package:habitapp/models/habit.dart';
import 'package:habitapp/z_habit/widgets/habit_card.dart';
import 'package:habitapp/main/widgets/main_content.dart';
import 'package:habitapp/z_habit/habit_storage.dart';
import 'package:habitapp/z_habit/habit_category_storage.dart';
import 'package:habitapp/z_habit/sheets/edit_habit_sheet.dart';
import 'package:habitapp/z_habit/sheets/habit_record_sheet.dart';

class HabitPage extends StatefulWidget {
  const HabitPage({super.key});

  @override
  State<HabitPage> createState() => HabitPageState();
}

class HabitPageState extends State<HabitPage> {
  //選択中の曜日
  int selectedDayIndex = DateTime.now().weekday - 1;

  //指定した日が含まれる週の月曜日を取得
  static DateTime _getMonday(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  //現在表示している週の月曜日
  DateTime displayedMonday = _getMonday(DateTime.now());

  //習慣一覧
  List<Habit> habits = [];

  //ジャンルごとの色
  Map<String, int> _categoryColors = {};

  //データの追加
  void addHabit(Habit habit) {
    setState(() {
      habits.add(habit);
    });

    HabitStorage.saveHabits(habits);
    _reloadCategoryColors();
  }

  //データの編集
  void _editHabit(Habit oldHabit, Habit newHabit) {
    final index = habits.indexOf(oldHabit);
    if (index == -1) return;

    setState(() {
      habits[index] = newHabit;
    });

    HabitStorage.saveHabits(habits);
  }

  //データの削除
  void _deleteHabit(Habit habit) {
    setState(() {
      habits.remove(habit);
    });

    HabitStorage.saveHabits(habits);
  }

  //編集画面
  void _showEditSheet(Habit habit) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.82,
          child: EditHabitSheet(
            habit: habit,
            onSave: (editedHabit) {
              _editHabit(habit, editedHabit);
            },
          ),
        );
      },
    ).whenComplete(_reloadCategoryColors);
  }

  //記録画面
  void _showRecordSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.86,
          child: HabitRecordSheet(
            habits: habits,
            categoryColors: _categoryColors,
          ),
        );
      },
    );
  }

  //削除確認
  void _showDeleteDialog(Habit habit) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('習慣を削除'),
          content: Text('「${habit.title}」を削除しますか？\n達成記録も削除されます。'),
          actions: [
            SizedBox(
              width: double.infinity,
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xff526FC5),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        _deleteHabit(habit);
                      },
                      child: const Text('削除'),
                    ),
                  ),
                  const SizedBox(height: 6),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xff526FC5),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('キャンセル'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  //表示する曜日を変更
  void selectDay(int index) {
    setState(() {
      selectedDayIndex = index;
    });
  }

  //表示する週を変更
  void changeDisplayedWeek(DateTime monday) {
    setState(() {
      displayedMonday = monday;
    });
  }

  @override
  void initState() {
    super.initState();
    reloadHabits();
  }

  //保存データの読み込み
  Future<void> reloadHabits() async {
    final loadedHabits = await HabitStorage.loadHabits();
    final categoryColors =
        await HabitCategoryStorage.loadCategoryColors();

    if (!mounted) return;

    setState(() {
      habits = loadedHabits;
      _categoryColors = categoryColors;
    });
  }

  //ジャンル色だけを読み直す
  Future<void> _reloadCategoryColors() async {
    final categoryColors =
        await HabitCategoryStorage.loadCategoryColors();

    if (!mounted) return;

    setState(() {
      _categoryColors = categoryColors;
    });
  }

  @override
  Widget build(BuildContext context) {
    const days = ["月", "火", "水", "木", "金", "土", "日"];

    final selectedDay = days[selectedDayIndex];

    //選択した曜日に実行する習慣だけ取得
    final selectedDayHabits = habits.where((habit) {
      return habit.days.contains(selectedDay);
    }).toList();

    //表示中の週から、選択した曜日の日付を取得
    final selectedDate = displayedMonday.add(
      Duration(days: selectedDayIndex),
    );

    //達成履歴で使用する日付キー
    final dateKey =
        '${selectedDate.year}-'
        '${selectedDate.month.toString().padLeft(2, '0')}-'
        '${selectedDate.day.toString().padLeft(2, '0')}';

    return MainContent(
      overlap: 0,
      child: Column(
        children: [
          //記録画面への入口
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SizedBox(
                height: 42,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xff526FC5),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                    ),
                  ),
                  onPressed: _showRecordSheet,
                  icon: const Icon(
                    Icons.auto_graph,
                    size: 19,
                  ),
                  label: const Text(
                    '記録',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          //習慣が増えても一覧だけスクロールできる
          Expanded(
            child: selectedDayHabits.isEmpty
                ? const Center(
                    child: Text(
                      'この日の習慣はありません',
                      style: TextStyle(
                        color: Color(0xff81889B),
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: selectedDayHabits.length,
                    itemBuilder: (context, index) {
                      final habit = selectedDayHabits[index];

                      final categoryColor = habit.category == '未設定'
                          ? null
                          : Color(
                              _categoryColors[habit.category] ??
                                  0xff526FC5,
                            );

                      return HabitCard(
                        habit: habit,
                        isDone: habit.completionHistory[dateKey] ?? false,
                        categoryColor: categoryColor,

                        //達成状態の変更
                        onChanged: () {
                          setState(() {
                            habit.completionHistory[dateKey] =
                                !(habit.completionHistory[dateKey] ?? false);
                          });

                          HabitStorage.saveHabits(habits);
                        },

                        //編集
                        onEdit: () {
                          _showEditSheet(habit);
                        },

                        //削除
                        onDelete: () {
                          _showDeleteDialog(habit);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
