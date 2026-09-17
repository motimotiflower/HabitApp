//Firebase Authenticationの処理をまとめる
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  //現在ログインしているユーザー
  static User? get currentUser => _auth.currentUser;

  //ログイン状態の変化を監視
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  //メールアドレスとパスワードで新規登録
  static Future<UserCredential> signUp({
    required String email,
    required String password,
  }) {
    return _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  //メールアドレスとパスワードでログイン
  static Future<UserCredential> signIn({
    required String email,
    required String password,
  }) {
    return _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  //ログアウト
  static Future<void> signOut() => _auth.signOut();
}
