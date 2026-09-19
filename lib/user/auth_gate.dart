import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:habitapp/core/cloud_backup_service.dart';
import 'package:habitapp/main/main_page.dart';
import 'package:habitapp/user/login_page.dart';
import 'package:habitapp/user/user_profile_storage.dart';
import 'package:habitapp/user/user_setup_page.dart';

// Firebaseのログイン状態に合わせて最初の画面を切り替える
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    // authStateChangesはログイン・ログアウトを自動で通知してくれる
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.data == null) {
          return const LoginPage();
        }

        return const _ProfileGate();
      },
    );
  }
}

// ログイン後、クラウド同期してから最初の画面を決める
class _ProfileGate extends StatefulWidget {
  const _ProfileGate();

  @override
  State<_ProfileGate> createState() => _ProfileGateState();
}

class _ProfileGateState extends State<_ProfileGate> {
  String? _name;
  bool _loading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      // 端末データがある場合は、初回ログインでも上書きされないよう先に確認
      final hasLocalData = await CloudBackupService.hasLocalData();

      if (hasLocalData) {
        // 今の端末データを優先してクラウドへ保存
        await CloudBackupService.backup();
      } else {
        // 新しい端末など、ローカルが空ならクラウドから復元
        await CloudBackupService.restore();
      }

      final name = await UserProfileStorage.loadName();

      if (!mounted) return;
      setState(() {
        _name = name;
        _loading = false;
      });
    } catch (e) {
      // Firestore側で失敗しても端末データはそのまま使える
      final name = await UserProfileStorage.loadName();

      if (!mounted) return;
      setState(() {
        _name = name;
        _errorMessage = 'クラウド同期に失敗しました';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      debugPrint(_errorMessage);
    }

    return _name == null ? const UserSetupPage() : const MainPage();
  }
}
