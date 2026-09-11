//データ１件の表示
import 'package:flutter/material.dart';
import 'package:habitapp/models/habit.dart';

class HabitCard extends StatelessWidget {
  //コンストラクタ ==========================
  const HabitCard({
    super.key,
    required this.habit, //このクラスのhabitに値入れる
    required this.isDone,
    required this.onChanged,
  });

  //変数====================================
  final Habit habit; //データの型
  final bool isDone; // 表示する日の達成状態
  final VoidCallback onChanged; //押された時に実行する関数を受け取る

  //========================================
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.all(12),

      //見た目の設定--------------------------
      decoration: BoxDecoration(
        color: const Color(0xffF2F4FC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xffCDD5F0), width: 0.4),
      ),

      /*表示--------------------------------
      1つの項目 アイコン _ タイトル
                          説明    
      */
      child: Row(
        //行
        children: [
          Icon(habit.icon, color: const Color(0xff526FC5)),
          const SizedBox(width: 16), //空白
          Text(habit.title), //タイトル
          const Spacer(), //空白
          Checkbox(
            value: isDone,
            onChanged: (value) {
              onChanged();
            },
          ),
        ],
      ),
    );
  }
}
