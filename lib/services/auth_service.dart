import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:flutter/foundation.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'profile',
      'https://www.googleapis.com/auth/gmail.send', // Gmail送信権限
    ],
  );

  // 現在のユーザーを取得
  static User? get currentUser => _auth.currentUser;

  // 認証状態のストリーム
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Google認証でサインイン
  static Future<UserCredential?> signInWithGoogle() async {
    try {
      // Google Sign-Inフローを開始
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // ユーザーがサインインをキャンセルした場合
        return null;
      }

      // Google認証の詳細を取得
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Firebase認証用のクレデンシャルを作成
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Firebase Authにサインイン
      final userCredential = await _auth.signInWithCredential(credential);

      debugPrint('✅ Google認証成功: ${userCredential.user?.email}');
      return userCredential;
    } catch (e) {
      debugPrint('❌ Google認証エラー: $e');
      throw Exception('Google認証に失敗しました: $e');
    }
  }

  // Gmail APIアクセス用のクレデンシャルを取得
  static Future<auth.AccessCredentials?> getGmailCredentials() async {
    try {
      final GoogleSignInAccount? account = _googleSignIn.currentUser;
      if (account == null) {
        debugPrint('❌ Googleアカウントにサインインしていません');
        return null;
      }

      final GoogleSignInAuthentication googleAuth =
          await account.authentication;

      if (googleAuth.accessToken == null) {
        debugPrint('❌ アクセストークンが取得できませんでした');
        return null;
      }

      // googleapis_authのAccessCredentialsを作成
      final credentials = auth.AccessCredentials(
        auth.AccessToken(
          'Bearer',
          googleAuth.accessToken!,
          DateTime.now().add(const Duration(hours: 1)), // 1時間の有効期限
        ),
        null, // リフレッシュトークンは必要に応じて設定
        ['https://www.googleapis.com/auth/gmail.send'],
      );

      debugPrint('✅ Gmail APIクレデンシャル取得成功');
      return credentials;
    } catch (e) {
      debugPrint('❌ Gmail APIクレデンシャル取得エラー: $e');
      return null;
    }
  }

  // サインアウト
  static Future<void> signOut() async {
    try {
      await Future.wait([_auth.signOut(), _googleSignIn.signOut()]);
      debugPrint('✅ サインアウト成功');
    } catch (e) {
      debugPrint('❌ サインアウトエラー: $e');
      throw Exception('サインアウトに失敗しました: $e');
    }
  }

  // 認証状態を確認
  static bool get isSignedIn => currentUser != null;

  // ユーザー情報を取得
  static String? get userEmail => currentUser?.email;
  static String? get userName => currentUser?.displayName;
  static String? get userPhotoUrl => currentUser?.photoURL;

  // Gmail送信権限があるかチェック
  static Future<bool> hasGmailPermission() async {
    try {
      final credentials = await getGmailCredentials();
      return credentials != null;
    } catch (e) {
      debugPrint('❌ Gmail権限チェックエラー: $e');
      return false;
    }
  }

  // 権限を再取得（スコープが不足している場合）
  static Future<bool> requestGmailPermission() async {
    try {
      // 一度サインアウトして再認証
      await _googleSignIn.signOut();
      final result = await signInWithGoogle();
      return result != null;
    } catch (e) {
      debugPrint('❌ Gmail権限再取得エラー: $e');
      return false;
    }
  }
}
