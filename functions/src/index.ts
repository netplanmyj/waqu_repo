import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import {google} from "googleapis";

// Firebase Admin SDKの初期化
admin.initializeApp();

// Gmail APIを使ったメール送信のCallable Function
export const sendWaterQualityEmail = functions.https.onCall(
    async (request: any) => {
      try {
        // Firebase Functions v2では、requestオブジェクトを使用
        const data = request.data;
        const auth = request.auth;
        
        // 認証情報をログ出力
        functions.logger.info("🔍 認証情報確認", {
          hasAuth: !!auth,
          authUid: auth?.uid,
          authEmail: auth?.token?.email,
          timestamp: new Date().toISOString(),
        });

        // 認証チェック
        if (!auth) {
          functions.logger.error("認証エラー: ユーザーが認証されていません");
          throw new functions.https.HttpsError(
              "unauthenticated",
              "この機能を使用するにはログインが必要です"
          );
        }

        // 必須パラメータのチェック
        const {
          monthDay,
          time,
          chlorine,
          locationNumber,
          recipientEmail,
          debugMode,
          accessToken,
        } = data;

        if (!monthDay || !time || !chlorine ||
            !recipientEmail || !accessToken) {
          throw new functions.https.HttpsError(
              "invalid-argument",
              "必要なパラメータが不足しています"
          );
        }

        // 送信者のメールアドレスを取得（認証コンテキストから）
        const senderEmail = auth.token.email;
        
        if (!senderEmail) {
          throw new functions.https.HttpsError(
              "unauthenticated",
              "送信者のメールアドレスを取得できませんでした"
          );
        }

        functions.logger.info("Gmail API 準備開始", {
          senderEmail: senderEmail,
          recipientEmail: recipientEmail,
          accessTokenLength: accessToken?.length,
        });

        // OAuth2Clientの作成と設定
        const oauth2Client = new google.auth.OAuth2();
        oauth2Client.setCredentials({
          access_token: accessToken,
        });

        functions.logger.info("OAuth2Client作成完了");

        // Gmail APIクライアントの作成
        const gmail = google.gmail({version: "v1", auth: oauth2Client});

        functions.logger.info("Gmail APIクライアント作成完了");

        // メール件名の設定（デバッグモード対応）
        const subject = debugMode ?
        `[テスト送信] 毎日検査報告（地点${locationNumber || "01"})` :
        `毎日検査報告（地点${locationNumber || "01"})`;

        // 件名をMIME-encoded-word形式でエンコード（日本語対応）
        const encodedSubject = `=?UTF-8?B?${Buffer.from(subject).toString("base64")}?=`;

        // メール本文の作成
        let body = `地点: ${locationNumber || "01"}\n` +
                 `月日: ${monthDay}\n` +
                 `測定時刻: ${time}\n` +
                 `残留塩素: ${chlorine}\n`;

        // デバッグモードの場合はテスト送信の旨を追記
        if (debugMode) {
          body += "\n※ これはテスト送信です ※\n";
        }

        // RFC2822形式のメール作成
        const emailContent = [
          `From: ${senderEmail}`,
          `To: ${recipientEmail}`,
          `Subject: ${encodedSubject}`,
          `Content-Type: text/plain; charset=utf-8`,
          ``,
          body,
        ].join("\r\n");

        // Base64url エンコード
        const encodedEmail = Buffer.from(emailContent)
            .toString("base64")
            .replace(/\+/g, "-")
            .replace(/\//g, "_")
            .replace(/=+$/, "");

        functions.logger.info("メール送信開始", {
          from: senderEmail,
          to: recipientEmail,
          subject: subject,
          encodedEmailLength: encodedEmail.length,
        });

        // Gmail APIでメール送信
        const response = await gmail.users.messages.send({
          userId: "me",
          requestBody: {
            raw: encodedEmail,
          },
        });

        functions.logger.info("✅ Gmail API メール送信成功", {
          messageId: response.data.id,
          recipient: recipientEmail,
          debugMode: debugMode,
          userId: auth.uid,
          labelIds: response.data.labelIds,
          threadId: response.data.threadId,
        });

        return {
          status: "success",
          message: "メールが正常に送信されました",
          messageId: response.data.id,
          timestamp: new Date().toISOString(),
        };
      } catch (error: any) {
        // エラー情報を詳細に出力
        functions.logger.error("========================================");
        functions.logger.error("❌ Gmail API メール送信エラー");
        functions.logger.error("エラーメッセージ:", error.message);
        functions.logger.error("エラーコード:", error.code);
        functions.logger.error("エラー名:", error.name);
        functions.logger.error("エラータイプ:", typeof error);
        
        // GaxiosError (Google APIs エラー) の詳細情報
        if (error.response) {
          functions.logger.error("--- レスポンス情報 ---");
          functions.logger.error("ステータス:", error.response.status);
          functions.logger.error("ステータステキスト:", 
            error.response.statusText);
          
          if (error.response.data) {
            try {
              const dataStr = JSON.stringify(error.response.data, null, 2);
              functions.logger.error("レスポンスデータ:", dataStr);
              
              // Gmail APIのエラー詳細
              if (error.response.data.error) {
                functions.logger.error("Gmail API エラー詳細:", {
                  code: error.response.data.error.code,
                  message: error.response.data.error.message,
                  status: error.response.data.error.status,
                  details: error.response.data.error.details,
                });
              }
            } catch (e) {
              functions.logger.error("レスポンスデータ(stringify失敗):", 
                error.response.data);
            }
          }
          
          if (error.response.headers) {
            functions.logger.error("レスポンスヘッダー:", 
              JSON.stringify(error.response.headers, null, 2));
          }
        }
        
        if (error.config) {
          functions.logger.error("--- リクエスト情報 ---");
          functions.logger.error("URL:", error.config.url);
          functions.logger.error("メソッド:", error.config.method);
          functions.logger.error("ベースURL:", error.config.baseURL);
          
          // 認証ヘッダーの存在確認（値は出力しない）
          if (error.config.headers) {
            functions.logger.error("Authorizationヘッダー存在:", 
              !!error.config.headers.Authorization);
          }
        }
        
        functions.logger.error("スタックトレース:", error.stack);
        functions.logger.error("========================================");

        // エラーの種類に応じて適切なエラーメッセージを返す
        const statusCode = error.response?.status || error.code;
        
        if (statusCode === 401) {
          throw new functions.https.HttpsError(
              "unauthenticated",
              "Gmail API認証エラー: アクセストークンが無効または期限切れです。" +
              "再度ログインしてください。"
          );
        } else if (statusCode === 403) {
          throw new functions.https.HttpsError(
              "permission-denied",
              "Gmail送信権限がありません。" +
              "Googleアカウントの認証時にGmail送信スコープを許可してください。"
          );
        } else if (statusCode === 429) {
          throw new functions.https.HttpsError(
              "resource-exhausted",
              "送信制限に達しました。しばらく時間をおいてから再試行してください。"
          );
        } else if (error.message.includes("quota")) {
          throw new functions.https.HttpsError(
              "resource-exhausted",
              "Gmail API クォータ超過: 送信制限に達しました。"
          );
        } else {
          throw new functions.https.HttpsError(
              "internal",
              `Gmail API メール送信失敗: ${error.message}`
          );
        }
      }
    }
);

// ヘルスチェック用のHTTP Function
export const healthCheck = functions.https.onRequest((req: any, res: any) => {
  res.json({
    status: "ok",
    timestamp: new Date().toISOString(),
    version: "1.0.0",
  });
});
