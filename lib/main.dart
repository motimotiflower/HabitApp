//アプリを起動する場所

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart'; //flutterの基本的なライブラリ

//Firebaseを使うためのライブラリ
import 'package:firebase_core/firebase_core.dart';
import 'package:habitapp/firebase_options.dart';

import 'package:habitapp/auth/auth_page.dart';
import 'package:habitapp/auth/auth_service.dart';
import 'package:habitapp/main/main_page.dart'; //habit_pageをつかえるように
import 'package:habitapp/user/user_profile_storage.dart';
import 'package:habitapp/user/user_setup_page.dart';
import 'package:habitapp/notifications/notification_service.dart';
import 'package:habitapp/z_habit/habit_storage.dart';
import 'package:habitapp/z_task/task_storage.dart';
import 'package:habitapp/debug/debug_seed_service.dart';

Future<void> main() async {
  //非同期の初期化処理を行う前にFlutterを準備
  WidgetsFlutterBinding.ensureInitialized();

  //Firebaseを初期化
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await NotificationService.initialize();

  //デバッグ中でデータが空なら確認用データを用意
  await DebugSeedService.seedIfNeeded();

  //保存済みの全体設定を含めて通知予定を作り直す
  await NotificationService.syncAll(
    await HabitStorage.loadHabits(),
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

      //ログイン状態に応じて最初の画面を切り替える
      home: const _AuthGate(),
    );
  }
}

//Firebaseのログイン状態を監視する入口
class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        //未ログインなら認証画面へ
        if (snapshot.data == null) {
          return const AuthPage();
        }

        //ログイン後は今まで通り名前設定を確認
        return const _ProfileGate();
      },
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
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return _name == null ? const UserSetupPage() : const MainPage();
  }
}
