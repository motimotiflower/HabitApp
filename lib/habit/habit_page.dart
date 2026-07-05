//習慣を表示するページ
import 'package:flutter/material.dart';

//習慣画面を表すWidget
class HabitPage extends StatefulWidget {
  const HabitPage({super.key});

  // HabitPageと_HabitPageStateを結び付ける
  @override
  State<HabitPage> createState() => _HabitPageState();
}

//HabitPageの値や見た目の管理(ここ限定）
class _HabitPageState extends State<HabitPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //中身を書く
      appBar: AppBar(title: Text("習慣")),

      //一覧=====================================
      body: Padding(
        padding: EdgeInsets.all(16),
        child: ListView(
          //1つの項目 アイコン テキスト
          //                  テキスト
          children:[
            Container(
              margin:EdgeInsets.only(bottom:12),
              padding: EdgeInsets.all(16),
              
              //1項目の見た目
              decoration: BoxDecoration(
                color:Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color.fromARGB(255, 172, 154, 154),
                  width: 1,
                ),
              ),

              child:Row(
                children: [
                  Icon(Icons.abc),
                  SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [Text("data"), Text("a")],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      //===============================
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          //押された時の処理
        },

        child: Icon(Icons.add), //プラスアイコン
      ),
    );
  }
}
