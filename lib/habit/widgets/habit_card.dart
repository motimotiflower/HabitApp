//データ１件の表示
import 'package:flutter/material.dart';
import 'package:habitapp/models/habit.dart';

class HabitCard extends StatelessWidget {

  //コンストラクタ ==========================
  const HabitCard({
    super.key,
    required this.habit,  //このクラスのhabitに値入れる
  });

  //変数====================================
  final Habit habit;

  //========================================
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const  EdgeInsets.all(16),

      //見た目の設定--------------------------
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 46, 31, 31),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color.fromARGB(255, 172, 154, 154),
          width: 1,
        ),
      ),


      /*表示--------------------------------
      1つの項目 アイコン _ タイトル
                          説明    
      */
      child: Row(
        //行
        children: [
          const Icon(Icons.abc),
          const SizedBox(width: 16), //空白

          Column(
            //列
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(habit.title), //タイトル
              Text(habit.outline), //説明
            ],
          ),

        ],
      ),

    );
  }

}
