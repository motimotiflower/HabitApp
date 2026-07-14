import 'package:flutter/material.dart';

//各ページから値を受け取るコンストラクタ====================
class AppNavigationBar extends StatelessWidget {
  const AppNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  //変数
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: onTap, //ボタンを押された時の処理(外で処理)
      //ボタンを追加========================================
      destinations: [
        //ホーム
        NavigationDestination(
          label: "Home",
          icon: Icon(Icons.home_outlined), //選択されていないときのアイコン
          selectedIcon: Icon(Icons.home), //選択中のアイコン
        ),

        //習慣
        NavigationDestination(
          label: "Habit",
          icon: Icon(Icons.auto_awesome_outlined),
          selectedIcon: Icon(Icons.auto_awesome),
        ),

        //タスク
        NavigationDestination(
          label: "Task",
          icon: Icon(Icons.check_circle_outline),
          selectedIcon: Icon(Icons.check_circle),
        ),

        //メモ
        NavigationDestination(
          label: "Memo",
          icon: Icon(Icons.edit_note_outlined),
          selectedIcon: Icon(Icons.edit_note),
        ),
      ],
    );
  }
}
