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
    //変数
    final screenWidth = MediaQuery.of(context).size.width;
    final dayButtonSize = (screenWidth - 32 - 48) / 7;

    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),

      //シートの見た目
      decoration: const BoxDecoration(
        color: Color(0xffFBFAFF),
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),

      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16, //キーボードの高さ取得
        ),

        child: Column(
          children: [
            //スクロールできるようにする
            Expanded(
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
                    const Text(
                      "追加",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    const Text("タイトル", style: TextStyle(fontSize: 20)),

                    const SizedBox(height: 8),

                    //文字の入力-----------------------------
                    TextField(
                      controller: titleController, //ほかの画面に文字を渡すために記憶
                      autofocus: true,

                      decoration: InputDecoration(
                        hintText: '習慣を入力',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    //曜日------------------------------------
                    const Text("曜日", style: TextStyle(fontSize: 20)),
                    const SizedBox(height: 12),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        //毎日---------------------------------
                        SizedBox(
                          width: 80,
                          height: 40,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              //枠の色
                              side: const BorderSide(color: Color(0xffC8D0E8)),

                              //背景
                              backgroundColor:
                                  selectedDays.length == days.length
                                  ? const Color(0xff7C8FD9)
                                  : const Color.fromARGB(255, 255, 255, 255),

                              //文字
                              foregroundColor:
                                  selectedDays.length == days.length
                                  ? Colors.white
                                  : const Color.fromARGB(255, 54, 73, 140),

                              //形
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),

                            onPressed: () {
                              setState(() {
                                if (selectedDays.length == days.length) {
                                  selectedDays.clear();
                                } else {
                                  selectedDays.clear();
                                  selectedDays.addAll(days);
                                }
                              });
                            },
                            child: const Text("毎日"),
                          ),
                        ),

                        const SizedBox(height: 12),

                        Wrap(
                          spacing: 8,
                          children: [
                            //曜日ごとのボタン----------------------
                            for (final day in days)
                              SizedBox(
                                width: dayButtonSize,
                                height: dayButtonSize,
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    //枠の色
                                    side: const BorderSide(
                                      color: Color(0xffC8D0E8),
                                    ),

                                    //背景
                                    backgroundColor: selectedDays.contains(day)
                                        ? const Color(0xff7C8FD9)
                                        : Colors.white,

                                    //文字の色
                                    foregroundColor: selectedDays.contains(day)
                                        ? Colors.white
                                        : const Color(0xff36498C),

                                    //丸
                                    shape: const CircleBorder(),

                                    //ズレ防止
                                    padding: EdgeInsets.zero,
                                    minimumSize: Size.zero,
                                  ),

                                  onPressed: () {
                                    setState(() {
                                      if (selectedDays.contains(day)) {
                                        selectedDays.remove(day);
                                      } else {
                                        selectedDays.add(day);
                                      }
                                    });
                                  },

                                  child: Align(
                                    alignment: Alignment.center,
                                    child: Text(
                                      day,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    //アイコン--------------------------------
                    const Text("アイコン", style: TextStyle(fontSize: 20)),
                    const SizedBox(height: 8),

                    //仮のアイコン
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: const [
                        CircleAvatar(child: Icon(Icons.menu_book)),
                        CircleAvatar(child: Icon(Icons.water_drop)),
                        CircleAvatar(child: Icon(Icons.fitness_center)),
                        CircleAvatar(child: Icon(Icons.self_improvement)),
                        CircleAvatar(child: Icon(Icons.favorite)),
                        CircleAvatar(child: Icon(Icons.star)),
                        CircleAvatar(child: Icon(Icons.music_note)),
                        CircleAvatar(child: Icon(Icons.nightlight_round)),
                      ],
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            //保存ボタン
            SizedBox(
              width: double.infinity,
              height: 64,
              child: ElevatedButton(
                onPressed: () {
                  //入力判定
                  if (titleController.text.trim().isEmpty) return;

                  //渡す値
                  final habit = Habit(
                    title: titleController.text.trim(),
                    icon: Icons.check,
                    days: List.from(selectedDays),
                    isDone: false,
                  );

                  widget.onAddHabit(habit);
                  Navigator.pop(context);
                },
                child: const Text("保存", style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
