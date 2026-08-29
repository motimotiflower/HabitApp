//各ページの土台
//背景や各ページ、ナビゲーションバーをもっている
import 'package:flutter/material.dart';
import 'package:habitapp/z_habit/sheets/add_habit_sheet.dart';
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

  //HabitPageを指定するためのKey
  final GlobalKey<HabitPageState> _habitPageKey = GlobalKey<HabitPageState>();

  // 表示するページ一覧
  late final List<PageInfo> _pages;

  @override
  void initState() {
    super.initState();

    _pages = [
      PageInfo(title: "Home", page: HomePage()),
      PageInfo(
        title: "Habit",
        page: HabitPage(key: _habitPageKey),
        showCalendar: true,
      ),
      PageInfo(title: "Task", page: TaskPage()),
      PageInfo(title: "Memo", page: MemoPage()),
    ];
  }

  //追加画面===============================
  void _openAddSheet() {
    //Habitの追加画面
    if (_currentIndex == 1) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),

        builder: (context) {
          return SizedBox(
            height: MediaQuery.of(context).size.height * 0.80,
            child: AddHabitSheet(
              onAddHabit: (habit) {
                _habitPageKey.currentState?.addHabit(habit);
              },
            ),
          );
        },
      );

      //Taskの追加画面はあとで作る
    } else if (_currentIndex == 2) {
      //Memoの追加画面はあとで作る
    } else if (_currentIndex == 3) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          //背景========================================
          MainBackground(
            title: _pages[_currentIndex].title,
            showCalendar: _pages[_currentIndex].showCalendar,
          ),

          // currentIndexに応じたページを表示============
          _pages[_currentIndex].page,
        ],
      ),

      //追加ボタン========================================
      floatingActionButton:
          _currentIndex !=
              0 //Home画面以外に表示
          ? FloatingActionButton(
              onPressed: _openAddSheet,
              child: const Icon(Icons.add),
            )
          : null,

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
