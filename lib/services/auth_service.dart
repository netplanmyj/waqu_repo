import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';

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

  // Apple認証でサインイン
  static Future<UserCredential?> signInWithApple() async {
    try {
      // ランダムな文字列を生成（セキュリティのため）
      final rawNonce = _generateNonce();
      final nonce = _sha256ofString(rawNonce);

      // Apple Sign-Inリクエストを作成
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      // Firebase認証用のクレデンシャルを作成
      final oauthCredential = OAuthProvider(
        "apple.com",
      ).credential(idToken: appleCredential.identityToken, rawNonce: rawNonce);

      // Firebase Authにサインイン
      final userCredential = await _auth.signInWithCredential(oauthCredential);

      // 初回サインイン時に表示名を設定
      if (appleCredential.givenName != null &&
          appleCredential.familyName != null) {
        final displayName =
            '${appleCredential.familyName} ${appleCredential.givenName}';
        await userCredential.user?.updateDisplayName(displayName);
      }

      return userCredential;
    } catch (e) {
      debugPrint('❌ Apple認証エラー: $e');
      throw Exception('Apple認証に失敗しました: $e');
    }
  }

  // ランダムな文字列を生成
  static String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(
      length,
      (_) => charset[random.nextInt(charset.length)],
    ).join();
  }

  // SHA256ハッシュを生成
  static String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
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

  // アカウント削除
  static Future<void> deleteAccount() async {
    try {
      final user = currentUser;
      if (user == null) {
        throw Exception('ユーザーが見つかりません');
      }

      // Google Sign-Inアカウントの切断（該当する場合）
      try {
        await _googleSignIn.disconnect();
      } catch (e) {
        debugPrint('⚠️ Google Sign-In切断エラー（無視）: $e');
        // Googleでサインインしていない場合はエラーが出るが無視
      }

      // Firebase Authenticationからアカウント削除
      await user.delete();

      debugPrint('✅ アカウントを削除しました');
    } catch (e) {
      debugPrint('❌ アカウント削除エラー: $e');
      throw Exception('アカウント削除に失敗しました: $e');
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
