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

  // Google認証でサインイン（リトライロジック付き）
  static Future<UserCredential?> signInWithGoogle({
    int maxRetries = 3,
    Duration timeout = const Duration(seconds: 30),
  }) async {
    for (int attempt = 0; attempt < maxRetries; attempt++) {
      try {
        debugPrint('🔄 Google認証試行 ${attempt + 1}/$maxRetries');

        // Google Sign-Inフローを開始（タイムアウト付き）
        final GoogleSignInAccount? googleUser = await _googleSignIn
            .signIn()
            .timeout(
              timeout,
              onTimeout: () {
                throw Exception('Google Sign-Inがタイムアウトしました');
              },
            );

        if (googleUser == null) {
          // ユーザーがサインインをキャンセルした場合
          return null;
        }

        // Google認証の詳細を取得
        final GoogleSignInAuthentication googleAuth = await googleUser
            .authentication
            .timeout(
              timeout,
              onTimeout: () {
                throw Exception('認証情報の取得がタイムアウトしました');
              },
            );

        if (googleAuth.accessToken == null) {
          debugPrint('❌ アクセストークンがnullです');
          throw Exception('アクセストークンの取得に失敗しました');
        }

        // Firebase認証用のクレデンシャルを作成
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        // Firebase Authにサインイン（タイムアウト付き）
        final userCredential = await _auth
            .signInWithCredential(credential)
            .timeout(
              timeout,
              onTimeout: () {
                throw Exception('Firebase認証がタイムアウトしました');
              },
            );

        debugPrint('✅ Google認証成功');
        return userCredential;
      } catch (e) {
        debugPrint('❌ Google認証エラー (試行 ${attempt + 1}/$maxRetries): $e');

        // 最後の試行でない場合、または再試行可能なエラーの場合のみリトライ
        if (attempt < maxRetries - 1 && _isRetriableError(e)) {
          // 指数バックオフで待機（1秒, 2秒, 4秒, ...）
          final waitTime = Duration(seconds: 1 << attempt);
          debugPrint('⏳ ${waitTime.inSeconds}秒後に再試行します...');
          await Future.delayed(waitTime);
          continue;
        }

        // 再試行不可能なエラー、またはすべてのリトライが失敗した場合
        throw Exception('Google認証に失敗しました: $e');
      }
    }

    // すべての試行が失敗した場合（通常はここに到達しない）
    throw Exception('Google認証に失敗しました: 最大試行回数に達しました');
  }

  // Apple認証でサインイン
  static Future<UserCredential?> signInWithApple() async {
    try {
      debugPrint('🍎 Apple Sign-In を開始します...');

      // ランダムな文字列を生成（セキュリティのため）
      final rawNonce = _generateNonce();
      final nonce = _sha256ofString(rawNonce);
      debugPrint('✅ Nonce生成完了');

      // Apple Sign-Inリクエストを作成
      debugPrint('🔄 Apple IDクレデンシャルを取得中...');
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      debugPrint('✅ Apple IDクレデンシャル取得成功');
      debugPrint(
        '   - identityToken: ${appleCredential.identityToken?.isNotEmpty ?? false ? "存在" : "なし"}',
      );
      debugPrint(
        '   - authorizationCode: ${appleCredential.authorizationCode.isNotEmpty ? "存在" : "なし"}',
      );
      debugPrint('   - email: ${appleCredential.email ?? "未提供"}');
      debugPrint('   - userIdentifier: ${appleCredential.userIdentifier}');

      // Firebase認証用のクレデンシャルを作成
      debugPrint('🔄 Firebase OAuthクレデンシャルを作成中...');
      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        rawNonce: rawNonce,
        accessToken: appleCredential.authorizationCode, // ← これを追加
      );
      debugPrint('✅ OAuthクレデンシャル作成完了');

      // Firebase Authにサインイン
      debugPrint('🔄 Firebase Authにサインイン中...');
      final userCredential = await _auth.signInWithCredential(oauthCredential);
      debugPrint('✅ Firebase Authサインイン成功');

      // 初回サインイン時に表示名を設定
      if (appleCredential.givenName != null &&
          appleCredential.familyName != null) {
        final displayName =
            '${appleCredential.familyName} ${appleCredential.givenName}';
        await userCredential.user?.updateDisplayName(displayName);
        debugPrint('✅ 表示名を設定: $displayName');
      }

      debugPrint('🎉 Apple Sign-In完了: ${userCredential.user?.email}');
      return userCredential;
    } on FirebaseAuthException catch (e) {
      // Firebase認証エラーの詳細ログ
      debugPrint('❌ Firebase認証エラー:');
      debugPrint('   - code: ${e.code}');
      debugPrint('   - message: ${e.message}');
      debugPrint('   - plugin: ${e.plugin}');

      // よくあるエラーの説明
      if (e.code == 'invalid-credential') {
        debugPrint(
          '💡 ヒント: Firebase ConsoleとApple Developer Consoleの設定を確認してください',
        );
        debugPrint('   1. Firebase: Appleプロバイダーが有効か');
        debugPrint(
          '   2. Apple Developer: Service IDのReturn URLsがFirebase OAuth redirect URIと一致するか',
        );
        debugPrint(
          '   3. Firebase: Apple Key ID, Team ID, Private keyが正しく設定されているか',
        );
        debugPrint('   詳細: docs/APPLE_SIGNIN_SETUP.md を参照');
      } else if (e.code == 'user-disabled') {
        debugPrint('💡 ヒント: このユーザーアカウントは無効化されています');
      }

      throw Exception('Apple認証に失敗しました：[${e.code}] ${e.message}');
    } on SignInWithAppleAuthorizationException catch (e) {
      // Apple Sign-In固有のエラー
      debugPrint('❌ Apple Sign-Inエラー:');
      debugPrint('   - code: ${e.code}');
      debugPrint('   - message: ${e.message}');

      if (e.code == AuthorizationErrorCode.canceled) {
        debugPrint('💡 ユーザーがサインインをキャンセルしました');
        return null; // キャンセルは例外ではなくnullを返す
      } else if (e.code == AuthorizationErrorCode.failed) {
        debugPrint(
          '💡 ヒント: Apple Developer ConsoleでSign in with Apple capabilityが有効か確認してください',
        );
      }

      throw Exception('Apple認証に失敗しました：${e.message}');
    } catch (e, stackTrace) {
      // その他の予期しないエラー
      debugPrint('❌ Apple認証エラー（予期しないエラー）: $e');
      debugPrint('スタックトレース: $stackTrace');
      throw Exception('Apple認証に失敗しました：$e');
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

  // エラーが再試行可能かどうかを判定
  static bool _isRetriableError(dynamic error) {
    final errorString = error.toString().toLowerCase();
    // ネットワークエラー、タイムアウト、一時的なエラーは再試行可能
    return errorString.contains('network') ||
        errorString.contains('timeout') ||
        errorString.contains('interrupted') ||
        errorString.contains('unreachable') ||
        errorString.contains('connection') ||
        errorString.contains('network-request-failed');
  }

  // Gmail APIアクセス用のクレデンシャルを取得（リトライロジック付き）
  static Future<auth.AccessCredentials?> getGmailCredentials({
    int maxRetries = 3,
    Duration timeout = const Duration(seconds: 20),
  }) async {
    for (int attempt = 0; attempt < maxRetries; attempt++) {
      try {
        debugPrint('🔄 Gmail認証情報取得試行 ${attempt + 1}/$maxRetries');

        // currentUserがnullの場合、silentSignInを試行（タイムアウト付き）
        GoogleSignInAccount? account =
            _googleSignIn.currentUser ??
            await _googleSignIn.signInSilently().timeout(
              timeout,
              onTimeout: () => null,
            );

        // それでもnullの場合、例外をスロー（リトライロジックで対応）
        if (account == null) {
          throw Exception('Google Sign-In アカウントが見つかりません。再認証が必要です');
        }

        final GoogleSignInAuthentication googleAuth = await account
            .authentication
            .timeout(
              timeout,
              onTimeout: () {
                throw Exception('認証情報の取得がタイムアウトしました');
              },
            );

        if (googleAuth.accessToken == null) {
          debugPrint('❌ アクセストークンが取得できませんでした');

          // アクセストークンがnullの場合、再試行可能なエラーとして扱う
          if (attempt < maxRetries - 1) {
            final waitTime = Duration(milliseconds: 1000 * (attempt + 1));
            debugPrint('⏳ ${waitTime.inSeconds}秒後に再試行します...');
            await Future.delayed(waitTime);
            continue;
          }
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

        debugPrint('✅ Gmail認証情報取得成功');
        return credentials;
      } catch (e) {
        debugPrint(
          '❌ Gmail APIクレデンシャル取得エラー (試行 ${attempt + 1}/$maxRetries): $e',
        );

        // 最後の試行でない場合、再試行可能なエラーの場合のみリトライ
        if (attempt < maxRetries - 1 && _isRetriableError(e)) {
          final waitTime = Duration(milliseconds: 1000 * (attempt + 1));
          debugPrint('⏳ ${waitTime.inSeconds}秒後に再試行します...');
          await Future.delayed(waitTime);
          continue;
        }

        return null;
      }
    }

    // すべての試行が失敗した場合
    debugPrint('❌ Gmail認証情報取得失敗: 最大試行回数に達しました');
    return null;
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
