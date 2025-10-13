import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:flutter/foundation.dart';
import 'dart:math';

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
      debugPrint('🔐 Google Sign-In開始...');
      debugPrint('📋 要求スコープ: ${_googleSignIn.scopes}');

      // Google Sign-Inフローを開始
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // ユーザーがサインインをキャンセルした場合
        debugPrint('⚠️ ユーザーがサインインをキャンセルしました');
        return null;
      }

      // Google認証の詳細を取得
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      debugPrint('✅ Google認証情報取得成功');
      debugPrint('🔑 アクセストークン: ${googleAuth.accessToken?.substring(0, 50)}...');

      // アクセストークンのスコープを確認するためのログ
      if (googleAuth.accessToken != null) {
        debugPrint('✨ アクセストークン取得成功（長さ: ${googleAuth.accessToken!.length}）');
      } else {
        debugPrint('❌ アクセストークンがnullです！');
      }

      // Firebase認証用のクレデンシャルを作成
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Firebase Authにサインイン
      final userCredential = await _auth.signInWithCredential(credential);

      debugPrint('✅ Firebase Auth認証成功: ${userCredential.user?.email}');
      debugPrint('🔄 Google Sign-In状態確認: ${_googleSignIn.currentUser?.email}');
      return userCredential;
    } catch (e) {
      debugPrint('❌ Google認証エラー: $e');
      throw Exception('Google認証に失敗しました: $e');
    }
  }

  // Gmail APIアクセス用のクレデンシャルを取得
  static Future<auth.AccessCredentials?> getGmailCredentials() async {
    try {
      GoogleSignInAccount? account = _googleSignIn.currentUser;

      // currentUserがnullの場合、silentSignInを試行
      if (account == null) {
        debugPrint('🔄 Google Sign-In状態を確認中...');
        account = await _googleSignIn.signInSilently();
      }

      // それでもnullの場合、明示的に再認証を促す
      if (account == null) {
        debugPrint('❌ Google Sign-In アカウントが見つかりません');
        debugPrint('📊 Firebase Auth状態: ${_auth.currentUser?.email}');
        debugPrint('💡 再認証が必要です。signInWithGoogle()を呼び出してください');
        return null;
      }

      // 必要なスコープをリクエスト（既に持っていない場合は自動的に要求される）
      const gmailScope = 'https://www.googleapis.com/auth/gmail.send';
      debugPrint('📋 Gmail送信スコープを確認中: $gmailScope');

      // Note: google_sign_inは自動的にスコープを管理するため、
      // 初期化時に指定したスコープが使用される

      final GoogleSignInAuthentication googleAuth =
          await account.authentication;

      if (googleAuth.accessToken == null) {
        debugPrint('❌ アクセストークンが取得できませんでした');
        return null;
      }

      debugPrint('✅ Google認証情報取得成功: ${account.email}');
      debugPrint(
        '🔑 アクセストークン(先頭50文字): ${googleAuth.accessToken!.substring(0, min(50, googleAuth.accessToken!.length))}...',
      );
      debugPrint('📏 アクセストークン全長: ${googleAuth.accessToken!.length}文字');

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
      debugPrint('🔄 Gmail権限を再取得します...');

      // Google Sign-Inを完全にクリア（disconnect）
      await _googleSignIn.disconnect();
      debugPrint('✅ Google Sign-In接続を切断しました');

      // Firebase Authからもサインアウト
      await _auth.signOut();
      debugPrint('✅ Firebase Authからサインアウトしました');

      // 少し待機（トークンキャッシュのクリアを確実にする）
      await Future.delayed(const Duration(milliseconds: 500));

      // 再認証
      debugPrint('🔐 再認証を開始します...');
      final result = await signInWithGoogle();

      if (result != null) {
        debugPrint('✅ Gmail権限の再取得に成功しました');
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
      debugPrint('🔄 アクセストークンをリフレッシュします...');

      final account = _googleSignIn.currentUser;
      if (account != null) {
        // 現在の認証情報をクリア
        await account.clearAuthCache();
        debugPrint('✅ 認証キャッシュをクリアしました');

        // 新しいトークンを取得
        final auth = await account.authentication;
        if (auth.accessToken != null) {
          debugPrint(
            '✅ 新しいアクセストークンを取得しました: ${auth.accessToken!.substring(0, 50)}...',
          );
        }
      }
    } catch (e) {
      debugPrint('❌ トークンリフレッシュエラー: $e');
    }
  }
}
