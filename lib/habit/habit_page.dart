//習慣を表示するページ
import 'package:flutter/material.dart';
import 'package:habitapp/models/habit.dart';
import 'package:habitapp/habit/widgets/habit_card.dart';

//習慣画面を表すWidget======================================
class HabitPage extends StatefulWidget {
  const HabitPage({super.key});

  // HabitPageと_HabitPageStateを結び付ける
  @override
  State<HabitPage> createState() => _HabitPageState();
}

//HabitPageの値や見た目の管理(ここ限定）=======================
class _HabitPageState extends State<HabitPage> {
  //変数
  List<Habit> habits = [
    //habit(モデル)
    Habit(title: "読書", icon: Icons.sunny),
    Habit(title: "タスク", icon: Icons.abc),
  ];

  //画面を作る処理==================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //AppBar-------------------
      appBar: AppBar(title: Text("習慣")),

      //一覧----------------------
      body: Padding(
        padding: const EdgeInsets.all(16),

        child: ListView.builder(
          //必要な数だけカードを作る
          itemCount: habits.length, //作る数をカウント
          //データ１件分(habit_card)
          itemBuilder: (context, index) {
            return HabitCard(
              //habit:はhabitっていう変数に値渡しますという意味
              habit: habits[index],

              //チェックボタン
              onChanged: () => setState(() {
                habits[index].isDone = !habits[index].isDone;
              }),
            );
          },
        ),
      ),

      //追加ボタン-------------------
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          //押された時の処理
        },

        child: Icon(Icons.add), //プラスアイコン
      ),
    );
  }
}
