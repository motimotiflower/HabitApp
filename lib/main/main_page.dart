//各ページの土台
//背景や各ページ、ナビゲーションバーをもっている
import 'package:flutter/material.dart';
import 'package:habitapp/z_home/home_page.dart';
import 'package:habitapp/z_habit/habit_page.dart';
import 'package:habitapp/z_task/task_page.dart';
import 'package:habitapp/z_memo/memo_page.dart';

import 'package:habitapp/main/widgets/main_navigation_bar.dart';
import 'package:habitapp/main/widgets/main_background.dart';
import 'package:habitapp/models/page_info.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  //変数===================================
  // 現在選択中のページ
  int _currentIndex = 0;

  // 表示するページ一覧を型に入れる
  final List<PageInfo> _pages = [
    PageInfo(title: "Home", page: HomePage()),
    PageInfo(title: "Habit", page: HabitPage(), showCalendar: true),
    PageInfo(title: "Task", page: TaskPage()),
    PageInfo(title: "Memo", page: MemoPage()),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //=============================================
      body: Stack(
        children: [
          //背景
          MainBackground(
            title: _pages[_currentIndex].title,
            showCalendar: _pages[_currentIndex].showCalendar,
          ),

          // currentIndexに応じたページを表示
          _pages[_currentIndex].page,
        ],
      ),

      // 共通のナビゲーションバー=======================
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
