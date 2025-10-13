import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import {google} from "googleapis";

// Firebase Admin SDKの初期化
admin.initializeApp();

// Gmail APIを使ったメール送信のCallable Function
export const sendWaterQualityEmail = functions.https.onCall(
  async (data: any, context: any) => {
    try {
      // 認証チェック
      if (!context.auth) {
        throw new functions.https.HttpsError(
          "unauthenticated",
          "認証が必要です"
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

      if (!monthDay || !time || !chlorine || !recipientEmail || !accessToken) {
        throw new functions.https.HttpsError(
          "invalid-argument",
          "必要なパラメータが不足しています"
        );
      }

      // Gmail APIクライアントの設定
      const oauth2Client = new google.auth.OAuth2();
      oauth2Client.setCredentials({
        access_token: accessToken,
      });

      const gmail = google.gmail({version: "v1", auth: oauth2Client});

      // メール件名の設定（デバッグモード対応）
      const subject = debugMode ?
        `[テスト送信] 毎日検査報告（地点${locationNumber || "01"})` :
        `毎日検査報告（地点${locationNumber || "01"})`;

      // メール本文の作成
      let body = `地点: ${locationNumber || "01"}\n` +
                 `月日: ${monthDay}\n` +
                 `測定時刻: ${time}\n` +
                 `残留塩素: ${chlorine}\n`;

      // デバッグモードの場合はテスト送信の旨を追記
      if (debugMode) {
        body += `\n※ これはテスト送信です ※\n`;
      }

      // メール送信用のリクエストデータを作成
      const emailLines = [
        `To: ${recipientEmail}`,
        `Subject: ${subject}`,
        "",
        body,
      ];
      const email = emailLines.join("\n");

      // Base64エンコード
      const encodedEmail = Buffer.from(email)
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

      functions.logger.info("メール送信成功", {
        messageId: response.data.id,
        recipient: recipientEmail,
        debugMode: debugMode,
        userId: context.auth.uid,
      });

      return {
        status: "success",
        message: "メールが正常に送信されました",
        messageId: response.data.id,
        timestamp: new Date().toISOString(),
      };
    } catch (error: any) {
      functions.logger.error("メール送信エラー", {
        error: error.message,
        userId: context.auth?.uid,
        data: data,
      });

      // エラーの種類に応じて適切なエラーメッセージを返す
      if (error.code === 401) {
        throw new functions.https.HttpsError(
          "permission-denied",
          "認証トークンが無効です。再ログインしてください。"
        );
      } else if (error.code === 403) {
        throw new functions.https.HttpsError(
          "permission-denied",
          "Gmail送信権限がありません。認証時に権限を許可してください。"
        );
      } else if (error.message.includes("quota")) {
        throw new functions.https.HttpsError(
          "resource-exhausted",
          "送信制限に達しました。しばらく時間をおいてから再試行してください。"
        );
      } else {
        throw new functions.https.HttpsError(
          "internal",
          `メール送信に失敗しました: ${error.message}`
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