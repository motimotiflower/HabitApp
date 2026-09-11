//習慣を表示するページ
import 'package:flutter/material.dart';
import 'package:habitapp/models/habit.dart';
import 'package:habitapp/z_habit/widgets/habit_card.dart';
import 'package:habitapp/main/widgets/main_content.dart';
import 'package:habitapp/z_habit/habit_storage.dart';

//習慣画面を表すWidget======================================
class HabitPage extends StatefulWidget {
  const HabitPage({super.key});

  // HabitPageとHabitPageStateを結び付ける
  @override
  State<HabitPage> createState() => HabitPageState();
}

//HabitPageの値や見た目の管理(ここ限定）=======================
class HabitPageState extends State<HabitPage> {
  //変数=====================================

  //選択中の曜日
  int selectedDayIndex = DateTime.now().weekday - 1;

  //指定した日が含まれる週の月曜日を取得
  static DateTime _getMonday(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  //現在表示している週の月曜日
  DateTime displayedMonday = _getMonday(DateTime.now());

  //習慣一覧
  List<Habit> habits = [
    Habit(title: "読書", icon: Icons.sunny),
    Habit(title: "タスク", icon: Icons.abc),
  ];

  //データの追加=================================
  void addHabit(Habit habit) {
    setState(() {
      habits.add(habit);
    });

    //追加後の習慣一覧を保存
    HabitStorage.saveHabits(habits);
  }

  //表示する曜日を変更=============================
  void selectDay(int index) {
    setState(() {
      selectedDayIndex = index;
    });
  }

  //表示する週を変更===============================
  //MainPageの週移動ボタンから呼ばれる
  void changeDisplayedWeek(DateTime monday) {
    setState(() {
      displayedMonday = monday;
    });
  }

  //保存データの読み込み===========================
  @override
  void initState() {
    super.initState();

    //HabitPageが最初に作られた時に保存データを読み込む
    reloadHabits();
  }

  Future<void> reloadHabits() async {
    //保存されている習慣一覧を取得
    final loadedHabits = await HabitStorage.loadHabits();

    //読み込み中にWidgetが破棄されていたら終了
    if (!mounted) return;

    setState(() {
      habits = loadedHabits;
    });
  }

  //画面を作る処理=================================
  @override
  Widget build(BuildContext context) {
    //変数----------------------------------------

    //曜日一覧
    const days = ["月", "火", "水", "木", "金", "土", "日"];

    //現在選択している曜日
    final selectedDay = days[selectedDayIndex];

    //選択した曜日に実行する習慣だけ取得
    final selectedDayHabits = habits.where((habit) {
      return habit.days.contains(selectedDay);
    }).toList();

    //表示中の週から、選択した曜日の日付を取得
    //例：表示週が9/7(月)で火曜日を選択 → 9/8
    final selectedDate = displayedMonday.add(Duration(days: selectedDayIndex));

    //達成履歴で使用する日付キーを作成
    //例：2026-09-07
    final dateKey =
        '${selectedDate.year}-'
        '${selectedDate.month.toString().padLeft(2, '0')}-'
        '${selectedDate.day.toString().padLeft(2, '0')}';

    //画面========================================
    return MainContent(
      overlap: 10,

      //習慣一覧
      child: ListView.builder(
        //ListView自身の余白はいらない
        padding: EdgeInsets.zero,

        //表示する習慣の数
        itemCount: selectedDayHabits.length,

        //習慣1件分のカードを作成
        itemBuilder: (context, index) {
          //現在表示しているHabit
          final habit = selectedDayHabits[index];

          return HabitCard(
            //HabitCardに習慣データを渡す
            habit: habit,

            //選択した日の達成状態
            //記録がまだなければ未達成(false)
            isDone: habit.completionHistory[dateKey] ?? false,

            //チェックボタンが押された時
            onChanged: () {
              setState(() {
                //選択した日の達成状態を反転
                habit.completionHistory[dateKey] =
                    !(habit.completionHistory[dateKey] ?? false);
              });

              //変更後の達成状態を保存
              HabitStorage.saveHabits(habits);
            },
          );
        },
      ),
    );
  }
}
