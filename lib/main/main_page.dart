//各ページの土台
//背景や各ページ、ナビゲーションバーをもっている
import 'package:flutter/material.dart';
import 'package:habitapp/z_habit/sheets/add_habit_sheet.dart';
import 'package:habitapp/z_task/sheets/add_task_sheet.dart';
import 'package:habitapp/z_home/home_page.dart';
import 'package:habitapp/z_habit/habit_page.dart';
import 'package:habitapp/z_task/task_page.dart';
import 'package:habitapp/z_memo/memo_page.dart';
import 'package:habitapp/z_memo/sheets/add_memo_room_sheet.dart';

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

  //ページ関係----------------------
  int _currentIndex = 0; // 現在選択中のページ

  //HomePageを指定するためのKey
  final GlobalKey<HomePageState> _homePageKey = GlobalKey<HomePageState>();

  //HabitPageを指定するためのKey
  final GlobalKey<HabitPageState> _habitPageKey = GlobalKey<HabitPageState>();

  //TaskPageを指定するためのKey
  final GlobalKey<TaskPageState> _taskPageKey = GlobalKey<TaskPageState>();

  //MemoPageを指定するためのKey
  final GlobalKey<MemoPageState> _memoPageKey = GlobalKey<MemoPageState>();

  //日付関係------------------------
  //カレンダーで選択中の曜日
  int _selectedDayIndex = DateTime.now().weekday - 1;

  //表示している週の月曜日
  DateTime _displayedMonday = _getMonday(DateTime.now());

  //指定した日が含まれる週の月曜日を取得
  static DateTime _getMonday(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  // 表示するページ一覧====================
  late final List<PageInfo> _pages;

  @override
  void initState() {
    super.initState();

    _pages = [
      PageInfo(title: "Home", page: HomePage(key: _homePageKey)),
      PageInfo(
        title: "Habit",
        page: HabitPage(key: _habitPageKey),
        showCalendar: true,
      ),
      PageInfo(
        title: "Task",
        page: TaskPage(key: _taskPageKey),
      ),
      PageInfo(title: "Memo", page: MemoPage(key: _memoPageKey)),
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

      //Taskの追加画面
    } else if (_currentIndex == 2) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,

        builder: (context) {
          return SizedBox(
            height: MediaQuery.of(context).size.height * 0.80,
            child: AddTaskSheet(
              onAddTask: (task) {
                _taskPageKey.currentState?.addTask(task);

                //Homeの「今日のタスク」にも反映
                _homePageKey.currentState?.reload();
              },
            ),
          );
        },
      );

      //Memo部屋の追加画面
    } else if (_currentIndex == 3) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,

        builder: (context) {
          return SizedBox(
            height: MediaQuery.of(context).size.height * 0.68,
            child: AddMemoRoomSheet(
              onAdd: (memo) {
                _memoPageKey.currentState?.addMemo(memo);

                //Homeのピン留めメモ表示も最新化
                _homePageKey.currentState?.reload();
              },
            ),
          );
        },
      );
    }
  }

  //前の週へ=================================
  void _goToPreviousWeek() {
    setState(() {
      //表示週を7日前にする
      _displayedMonday = _displayedMonday.subtract(const Duration(days: 7));
    });

    //HabitPageにも変更を伝える
    _habitPageKey.currentState?.changeDisplayedWeek(_displayedMonday);
  }

  //次の週へ=================================
  void _goToNextWeek() {
    setState(() {
      //表示週を7日後にする
      _displayedMonday = _displayedMonday.add(const Duration(days: 7));
    });

    //HabitPageにも変更を伝える
    _habitPageKey.currentState?.changeDisplayedWeek(_displayedMonday);
  }

  //今日に戻る=================================
  void _goToToday() {
    final now = DateTime.now();

    setState(() {
      //今週に戻す
      _displayedMonday = _getMonday(now);

      //今日の曜日を選択
      _selectedDayIndex = now.weekday - 1;
    });

    //HabitPageにも変更を伝える
    _habitPageKey.currentState?.changeDisplayedWeek(_displayedMonday);

    _habitPageKey.currentState?.selectDay(_selectedDayIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _currentIndex == 0
          //Homeはヘッダーも含めてページ全体を一緒にスクロールする
          ? _pages[_currentIndex].page
          : Stack(
              children: [
                //背景========================================
                MainBackground(
                  title: _pages[_currentIndex].title,
                  showCalendar: _pages[_currentIndex].showCalendar,
                  selectedDayIndex: _selectedDayIndex,

                  //現在表示している週
                  displayedMonday: _displayedMonday,

                  //週移動
                  onPreviousWeek: _goToPreviousWeek,
                  onNextWeek: _goToNextWeek,

                  //今日に戻る
                  onToday: _goToToday,

                  onDaySelected: (index) {
                    //Habitページの時だけ曜日変更を伝える
                    if (_currentIndex == 1) {
                      setState(() {
                        _selectedDayIndex = index;
                      });

                      _habitPageKey.currentState?.selectDay(index);
                    }
                  },
                ),

                //currentIndexに応じたページを表示============
                _pages[_currentIndex].page,
              ],
            ),

      //追加ボタン========================================
      floatingActionButton:
          _currentIndex !=
              0 //Home画面以外に表示
          ? FloatingActionButton(
              //共通の追加ボタンを青系に統一
              backgroundColor: const Color(0xff526FC5),
              foregroundColor: Colors.white,
              onPressed: _openAddSheet,
              child: const Icon(Icons.add),
            )
          : null,

      //共通のナビゲーションバー=======================
      bottomNavigationBar: AppNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index; //インデックスの更新
          });

          //画面を開いた時に保存データと同期する
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (index == 0) {
              _homePageKey.currentState?.reload();
            } else if (index == 1) {
              _habitPageKey.currentState?.reloadHabits();
            } else if (index == 2) {
              _taskPageKey.currentState?.reloadTasks();
            } else if (index == 3) {
              _memoPageKey.currentState?.reloadMemos();
            }
          });
        },
      ),
    );
  }
}
