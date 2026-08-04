import 'package:flutter/material.dart';
import 'package:habitapp/models/habit.dart';

class AddHabitSheet extends StatefulWidget {
  //コンストラクタ ==========================
  const AddHabitSheet({super.key, required this.onAddHabit});

  final void Function(Habit) onAddHabit;

  @override
  State<AddHabitSheet> createState() {
    return _AddHabitSheetState();
  }
}

class _AddHabitSheetState extends State<AddHabitSheet> {
  //変数-------------------------------------
  static const days = ["月", "火", "水", "木", "金", "土", "日"];
  final selectedDays = <String>[];
  final titleController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16, //キーボードの高さ取得
      ),

      //スクロールできるようにする
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            //上のバー-------------------------
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 20),
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            //--------------------
            const Text("追加"),
            const SizedBox(height: 16),

            const Text("タイトル"),
            const SizedBox(height: 8),

            //文字の入力-----------------------------
            TextField(
              controller: titleController, //ほかの画面に文字を渡すために記憶
              autofocus: true,

              decoration: InputDecoration(
                hintText: '習慣を入力',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),

            //曜日--------------------
            const Text("曜日"),
            Wrap(
              spacing: 4,
              runSpacing: 0,
              children: [
                //毎日---------------------------------
                OutlinedButton(
                  //見た目
                  style: OutlinedButton.styleFrom(
                    foregroundColor: selectedDays.length == days.length
                        ? Colors.white
                        : Colors.transparent,
                  ),

                  //ボタンを押したら
                  onPressed: () {
                    setState(() {
                      //すでにチェックがあれば消す
                      if (selectedDays.length == days.length) {
                        selectedDays.clear();
                      }
                      //チェックを入れたらリセットしてすべて選択
                      else {
                        selectedDays.clear();
                        selectedDays.addAll(days);
                      }
                    });
                  },
                  child: const Text("毎日"),
                ),

                //曜日ごとのボタン----------------------
                for (final day in days)
                  OutlinedButton(
                    //ボタンの見た目
                    style: OutlinedButton.styleFrom(
                      backgroundColor: selectedDays.contains(day)
                          ? Colors.white
                          : Colors.transparent,
                    ),

                    //ボタンを押したら
                    onPressed: () {
                      setState(() {
                        if (selectedDays.contains(day)) {
                          selectedDays.remove(day);
                        } else {
                          selectedDays.add(day);
                        }
                      });
                    },
                    child: Text(day),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            //保存ボタン
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  //入力判定
                  if (titleController.text.trim().isEmpty) return;

                  //渡す値
                  final habit = Habit(
                    title: titleController.text.trim(),
                    icon: Icons.check,
                    isDone: false,
                  );

                  widget.onAddHabit(habit);
                  Navigator.pop(context);
                },
                child: const Text("保存"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
