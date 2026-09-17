//Firebase Authenticationの処理をまとめる
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  static bool _googleInitialized = false;

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

  //Googleアカウントでログイン
  static Future<UserCredential> signInWithGoogle() async {
    final googleProvider = GoogleAuthProvider();

    //WebではFirebaseのポップアップ認証を使う
    if (kIsWeb) {
      return _auth.signInWithPopup(googleProvider);
    }

    //AndroidなどではGoogle Sign-InからIDトークンを受け取る
    if (!_googleInitialized) {
      await _googleSignIn.initialize();
      _googleInitialized = true;
    }

    final googleUser = await _googleSignIn.authenticate();
    final googleAuth = googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
    );

    return _auth.signInWithCredential(credential);
  }

  //ログアウト
  static Future<void> signOut() async {
    await _auth.signOut();

    //Google側の選択状態も解除する
    if (!kIsWeb && _googleInitialized) {
      await _googleSignIn.signOut();
    }
  }
}
