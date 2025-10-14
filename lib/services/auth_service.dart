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

      if (googleAuth.accessToken == null) {
        debugPrint('❌ アクセストークンがnullです');
        throw Exception('アクセストークンの取得に失敗しました');
      }

      // Firebase認証用のクレデンシャルを作成
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Firebase Authにサインイン
      final userCredential = await _auth.signInWithCredential(credential);

      return userCredential;
    } catch (e) {
      debugPrint('❌ Google認証エラー: $e');
      throw Exception('Google認証に失敗しました: $e');
    }
  }

  // Gmail APIアクセス用のクレデンシャルを取得
  static Future<auth.AccessCredentials?> getGmailCredentials() async {
    try {
      // currentUserがnullの場合、silentSignInを試行
      GoogleSignInAccount? account =
          _googleSignIn.currentUser ?? await _googleSignIn.signInSilently();

      // それでもnullの場合、明示的に再認証を促す
      if (account == null) {
        debugPrint('❌ Google Sign-In アカウントが見つかりません。再認証が必要です');
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
          DateTime.now().toUtc().add(
            const Duration(hours: 1),
          ), // UTC時間で1時間の有効期限
        ),
        null, // リフレッシュトークンは必要に応じて設定
        ['https://www.googleapis.com/auth/gmail.send'],
      );

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
      // Google Sign-Inを完全にクリア（disconnect）
      await _googleSignIn.disconnect();

      // Firebase Authからもサインアウト
      await _auth.signOut();

      // 少し待機（トークンキャッシュのクリアを確実にする）
      await Future.delayed(const Duration(milliseconds: 500));

      // 再認証
      final result = await signInWithGoogle();

      if (result != null) {
        return true;
      } else {
        debugPrint('❌ 再認証がキャンセルされました');
        return false;
      }
    } catch (e) {
      debugPrint('❌ Gmail権限再取得エラー: $e');
      return false;
    }
  }

  // アクセストークンを強制的にリフレッシュ
  static Future<void> forceRefreshToken() async {
    try {
      final account = _googleSignIn.currentUser;
      if (account != null) {
        // 現在の認証情報をクリア
        await account.clearAuthCache();

        // 新しいトークンを取得
        await account.authentication;
      }
    } catch (e) {
      debugPrint('❌ トークンリフレッシュエラー: $e');
    }
  }
}
