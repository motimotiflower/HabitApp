//データ１件の表示
import 'package:flutter/material.dart';
import 'package:habitapp/models/habit.dart';

class HabitCard extends StatelessWidget {
  //コンストラクタ ==========================
  const HabitCard({
    super.key,
    required this.habit, //このクラスのhabitに値入れる
    required this.onChanged,
  });

  //変数====================================
  final Habit habit; //データの型
  final VoidCallback onChanged; //押された時に実行する関数を受け取る

  //========================================
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.all(12),

      //見た目の設定--------------------------
      decoration: BoxDecoration(
        color: const Color.fromARGB(228, 233, 233, 244),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xffD0CAE8), width: 0.4),
      ),

      /*表示--------------------------------
      1つの項目 アイコン _ タイトル
                          説明    
      */
      child: Row(
        //行
        children: [
          Icon(habit.icon, color: const Color(0xffEBD3E3)),
          const SizedBox(width: 16), //空白
          Text(habit.title), //タイトル
          const Spacer(), //空白
          Checkbox(
            value: habit.isDone,
            onChanged: (value) {
              onChanged();
            },
          ),
        ],
      ),
    );
  }
}
