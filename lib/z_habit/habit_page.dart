//習慣を表示するページ
import 'package:flutter/material.dart';
import 'package:habitapp/models/habit.dart';
import 'package:habitapp/z_habit/widgets/habit_card.dart';
import 'package:habitapp/main/widgets/main_content.dart';
import 'package:habitapp/z_habit/habit_storage.dart';

//習慣画面を表すWidget======================================
class HabitPage extends StatefulWidget {
  const HabitPage({super.key});

  // HabitPageと_HabitPageStateを結び付ける
  @override
  State<HabitPage> createState() => HabitPageState();
}

//HabitPageの値や見た目の管理(ここ限定）=======================
class HabitPageState extends State<HabitPage> {
  //変数-------------------------------------

  //選択中の曜日
  int selectedDayIndex = DateTime.now().weekday - 1;

  List<Habit> habits = [
    //habit(モデル)
    Habit(title: "読書", icon: Icons.sunny),
    Habit(title: "タスク", icon: Icons.abc),
  ];

  //データの追加==========================
  void addHabit(Habit habit) {
    setState(() {
      habits.add(habit);
    });

    // 保存処理はHabitStorageに任せる
    HabitStorage.saveHabits(habits);
  }

  // 保存データを取得======================
  // HabitPageが作られた時に読み込む
  @override
  void initState() {
    super.initState();
    _loadHabits();
  }

  Future<void> _loadHabits() async {
    final loadedHabits = await HabitStorage.loadHabits();

    setState(() {
      habits = loadedHabits;
    });
  }

  //表示する曜日を変更
  void selectDay(int index) {
    setState(() {
      selectedDayIndex = index;
    });
  }

  //画面を作る処理==================================
  @override
  Widget build(BuildContext context) {
    //変数------------------
    //今日の曜日を取得
    const days = ["月", "火", "水", "木", "金", "土", "日"];
    //選択中の曜日
    final selectedDay = days[selectedDayIndex];

    //選択した曜日の習慣だけ取得
    final selectedDayHabits = habits.where((habit) {
      return habit.days.contains(selectedDay);
    }).toList();

    final now = DateTime.now();

    // 今週の月曜日を取得
    final monday = now.subtract(Duration(days: now.weekday - 1));

    // 選択中の曜日の日付
    final selectedDate = monday.add(Duration(days: selectedDayIndex));

    // 保存用の日付キーを作る
    final dateKey =
        '${selectedDate.year}-'
        '${selectedDate.month.toString().padLeft(2, '0')}-'
        '${selectedDate.day.toString().padLeft(2, '0')}';
    //------------------------
    return MainContent(
      overlap: 10,

      //必要な数だけカードを作る------
      child: ListView.builder(
        padding: EdgeInsets.zero, //ListView自身の余白はいらない
        itemCount: selectedDayHabits.length, //作る数をカウント
        //データ１件分(habit_card)
        itemBuilder: (context, index) {
          return HabitCard(
            //habit:はhabitっていう変数に値渡しますという意味
            habit: selectedDayHabits[index],

            // 今日の達成状態を渡す
            isDone:
                selectedDayHabits[index].completionHistory[dateKey] ?? false,

            //チェックボタン
            onChanged: () {
              setState(() {
                // 達成状態を切り替える
                final habit = selectedDayHabits[index];

                // 今日の達成状態を反転
                habit.completionHistory[dateKey] =
                    !(habit.completionHistory[dateKey] ?? false);
              });

              // 変更後の状態を保存
              HabitStorage.saveHabits(habits);
            },
          );
        },
      ),
    );
  }
}
