import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import {google} from "googleapis";
import {CallableRequest} from "firebase-functions/v2/https";

// Firebase Admin SDKの初期化
admin.initializeApp();

// Gmail APIを使ったメール送信のCallable Function
export const sendWaterQualityEmail = functions.https.onCall(
    async (request: CallableRequest) => {
      try {
        // Firebase Functions v2では、requestオブジェクトを使用
        const data = request.data;
        const auth = request.auth;

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
          emailSubject, // 件名パラメータ追加
          debugMode = false,
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

        // OAuth2Clientの作成と設定
        const oauth2Client = new google.auth.OAuth2();
        oauth2Client.setCredentials({
          access_token: accessToken,
        });

        // Gmail APIクライアントの作成
        const gmail = google.gmail({version: "v1", auth: oauth2Client});

        // メール件名の設定（カスタム件名対応、デバッグモード対応）
        const baseSubject = emailSubject || "毎日検査報告"; // デフォルト件名
        const subject = debugMode ?
        `[テスト送信] ${baseSubject}` :
        baseSubject;

        // 件名をMIME-encoded-word形式でエンコード（日本語対応）
        const base64Subject = Buffer.from(subject).toString("base64");
        const encodedSubject = `=?UTF-8?B?${base64Subject}?=`;

        // メール本文の作成（半角スペース削除）
        let body = `地点:${locationNumber || "01"}\n` +
                 `月日:${monthDay}\n` +
                 `測定時刻:${time}\n` +
                 `残留塩素:${chlorine}\n`;

        // デバッグモードの場合はテスト送信の旨を追記
        if (debugMode) {
          body += "\n※ これはテスト送信です ※\n";
        }

        // RFC2822形式のメール作成
        const emailContent = [
          `From: ${senderEmail}`,
          `To: ${recipientEmail}`,
          `Subject: ${encodedSubject}`,
          "Content-Type: text/plain; charset=utf-8",
          "",
          body,
        ].join("\r\n");

        // Base64url エンコード
        const encodedEmail = Buffer.from(emailContent)
            .toString("base64")
            .replace(/\+/g, "-")
            .replace(/\//g, "_")
            .replace(/=+$/, "");

        // Gmail APIでメール送信
        const response = await gmail.users.messages.send({
          userId: "me",
          requestBody: {
            raw: encodedEmail,
          },
        });

        functions.logger.info("✅ メール送信成功", {
          messageId: response.data.id,
          recipient: recipientEmail,
        });

        return {
          status: "success",
          message: "メールが正常に送信されました",
          messageId: response.data.id,
          timestamp: new Date().toISOString(),
        };
      } catch (error: unknown) {
        // エラー情報をログ出力
        functions.logger.error("❌ メール送信エラー", {
          error: error instanceof Error ? error.message : String(error),
        });

        // GaxiosErrorなど、APIエラーの詳細情報を取得
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        const err = error as any;

        // エラーの種類に応じて適切なエラーメッセージを返す
        const statusCode = err.response?.status || err.code;

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
        } else if (err.message && err.message.includes("quota")) {
          throw new functions.https.HttpsError(
              "resource-exhausted",
              "Gmail API クォータ超過: 送信制限に達しました。"
          );
        } else {
          const errorMessage = err.message || "不明なエラー";
          throw new functions.https.HttpsError(
              "internal",
              `Gmail API メール送信失敗: ${errorMessage}`
          );
        }
      }
    }
);

// ヘルスチェック用のHTTP Function
export const healthCheck = functions.https.onRequest((req, res) => {
  res.json({
    status: "ok",
    timestamp: new Date().toISOString(),
    version: "1.0.0",
  });
});
