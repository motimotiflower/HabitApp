//各ページの土台
import 'package:flutter/material.dart';
import 'package:habitapp/pages/home_page.dart';
import 'package:habitapp/pages/habit_page.dart';
import 'package:habitapp/pages/task_page.dart';
import 'package:habitapp/pages/memo_page.dart';

import 'package:habitapp/widgets/navigation_bar.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  // 現在選択中のページ
  int _currentIndex = 0;

  // 表示するページ一覧
  final List<Widget> _pages = const [
    HomePage(),
    HabitPage(),
    TaskPage(),
    MemoPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // currentIndexに応じたページを表示
      body: _pages[_currentIndex],

      // 共通のナビゲーションバー
      bottomNavigationBar: AppNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index; //インデックスの更新
          });
        },
      ),
    );
  }
}
