//アプリを起動する場所

import 'package:flutter/material.dart'; //flutterの基本的なライブラリ

//Firebaseを使うためのライブラリ
import 'package:firebase_core/firebase_core.dart';
import 'package:habitapp/firebase_options.dart';

import 'package:habitapp/user/auth_gate.dart';
import 'package:habitapp/notifications/notification_service.dart';
import 'package:habitapp/z_habit/habit_storage.dart';
import 'package:habitapp/z_task/task_storage.dart';

Future<void> main() async {
  //非同期の初期化処理を行う前にFlutterを準備
  WidgetsFlutterBinding.ensureInitialized();

  //Firebaseを初期化
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await NotificationService.initialize();

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

      //Firebaseのログイン状態から最初の画面を決める
      home: const AuthGate(),
    );
  }
}
