//ログイン・新規登録画面
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:habitapp/auth/auth_service.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isSignUp = false;
  bool _loading = false;
  String? _errorMessage;

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = 'メールアドレスとパスワードを入力してください');
      return;
    }

    await _runAuth(() async {
      if (_isSignUp) {
        await AuthService.signUp(email: email, password: password);
      } else {
        await AuthService.signIn(email: email, password: password);
      }
    });
  }

  //Googleアカウントでログイン
  Future<void> _signInWithGoogle() async {
    await _runAuth(AuthService.signInWithGoogle);
  }

  //認証中のローディングとエラー表示を共通化
  Future<void> _runAuth(Future<void> Function() action) async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      await action();
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = _messageFor(e.code));
    } catch (e) {
      if (!mounted) return;

      //Googleのアカウント選択を閉じた場合はエラー扱いにしない
      if (e.toString().toLowerCase().contains('cancel')) return;

      setState(() => _errorMessage = '認証に失敗しました。もう一度お試しください');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _messageFor(String code) {
    switch (code) {
      case 'invalid-email':
        return 'メールアドレスの形式を確認してください';
      case 'weak-password':
        return 'パスワードは6文字以上にしてください';
      case 'email-already-in-use':
        return 'このメールアドレスはすでに登録されています';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'メールアドレスまたはパスワードが違います';
      case 'operation-not-allowed':
        return 'Firebase Consoleでログイン方法を確認してください';
      case 'network-request-failed':
        return 'ネットワーク接続を確認してください';
      case 'popup-closed-by-user':
      case 'cancelled-popup-request':
        return 'Googleログインがキャンセルされました';
      default:
        return '認証に失敗しました（$code）';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF7F9FF),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                children: [
                  const Icon(
                    Icons.auto_awesome_rounded,
                    size: 58,
                    color: Color(0xff526FC5),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    _isSignUp ? 'アカウントを作成' : 'おかえりなさい',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff263A70),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isSignUp
                        ? '端末を変えてもデータを使えるようにします'
                        : 'HabitAppにログインしてください',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Color(0xff81889B)),
                  ),
                  const SizedBox(height: 28),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                    decoration: InputDecoration(
                      labelText: 'メールアドレス',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    autofillHints: _isSignUp
                        ? const [AutofillHints.newPassword]
                        : const [AutofillHints.password],
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) {
                      if (!_loading) _submit();
                    },
                    decoration: InputDecoration(
                      labelText: 'パスワード',
                      helperText: _isSignUp ? '6文字以上' : null,
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 14),
                    Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.redAccent),
                    ),
                  ],
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xff526FC5),
                      ),
                      onPressed: _loading ? null : _submit,
                      child: _loading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(_isSignUp ? '新規登録' : 'ログイン'),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Row(
                    children: [
                      Expanded(child: Divider()),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          'または',
                          style: TextStyle(color: Color(0xff81889B)),
                        ),
                      ),
                      Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: OutlinedButton.icon(
                      onPressed: _loading ? null : _signInWithGoogle,
                      icon: const Text(
                        'G',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff4285F4),
                        ),
                      ),
                      label: const Text('Googleでログイン'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: _loading
                        ? null
                        : () {
                            setState(() {
                              _isSignUp = !_isSignUp;
                              _errorMessage = null;
                            });
                          },
                    child: Text(
                      _isSignUp
                          ? 'アカウントをお持ちの方はログイン'
                          : '初めての方は新規登録',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
