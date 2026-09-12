//アプリを起動する場所

import 'package:flutter/material.dart'; //flutterの基本的なライブラリ
import 'package:habitapp/main/main_page.dart'; //habit_pageをつかえるように
import 'package:habitapp/user/user_profile_storage.dart';
import 'package:habitapp/user/user_setup_page.dart';
import 'package:habitapp/notifications/notification_service.dart';
import 'package:habitapp/z_habit/habit_storage.dart';
import 'package:habitapp/z_task/task_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.initialize();

  //保存済みの設定から通知予定を作り直す
  await NotificationService.syncHabits(
    await HabitStorage.loadHabits(),
  );
  await NotificationService.syncTasks(
    await TaskStorage.loadTasks(),
  );

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
        colorScheme: ColorScheme.fromSeed(
          //アプリ全体の基準色を青に統一
          seedColor: const Color(0xff526FC5),
        ),
      ),

      //最初の画面。初回だけ名前設定を表示
      home: const _ProfileGate(),
    );
  }
}


class _ProfileGate extends StatefulWidget {
  const _ProfileGate();

  @override
  State<_ProfileGate> createState() => _ProfileGateState();
}

class _ProfileGateState extends State<_ProfileGate> {
  String? _name;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final name = await UserProfileStorage.loadName();

    if (!mounted) return;

    setState(() {
      _name = name;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return _name == null
        ? const UserSetupPage()
        : const MainPage();
  }
}
