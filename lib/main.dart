//アプリを起動する場所

import 'package:flutter/material.dart';    //flutterの基本的なライブラリ
import 'package:habitapp/habit/habit_page.dart';  //habit_pageをつかえるように

void main() {
  runApp(const MyApp());
}

// アプリ全体を表すクラス====================================
// StatelessWidgetは「状態を持たない画面」
class MyApp extends StatelessWidget {

  // コンストラクタ(constつけて安全に再利用可能)
  const MyApp({super.key});

  // Widgetの見た目を作るメソッド
  @override
  Widget build(BuildContext context) {
    return MaterialApp(

      title: 'Habit App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 134, 116, 116)),
      ),

      //最初の画面
      home: const HabitPage()

    );
  }

}