import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import {google} from "googleapis";

// Firebase Admin SDKの初期化
admin.initializeApp();

// Gmail APIを使ったメール送信のCallable Function
export const sendWaterQualityEmail = functions.https.onCall(
    async (data: any, context: any) => {
      try {
        // 認証状態をログ出力
        functions.logger.info("認証コンテキスト確認", {
          hasAuth: !!context.auth,
          authUid: context.auth?.uid,
          authEmail: context.auth?.token?.email,
        });

        // 認証チェック (デバッグのため完全に無効化)
        functions.logger.info("認証チェックを無効化してテスト実行中 - Version 2.0", {
          hasAuth: !!context.auth,
          authUid: context.auth?.uid,
          dataReceived: Object.keys(data),
          deployTime: "2025-01-13T04:20:00",
        });

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

        // OAuth2クライアントでGmail APIを設定（正しい方法で実装）
        functions.logger.info("OAuth2認証でGmail API設定開始", {
          accessTokenLength: accessToken?.length,
          accessTokenPrefix: accessToken?.substring(0, 20) + "...",
        });

        // OAuth2クライアントを作成し、アクセストークンを設定
        const oauth2Client = new google.auth.OAuth2();
        oauth2Client.setCredentials({
          access_token: accessToken,
        });

        // Gmail APIクライアントを作成
        const gmail = google.gmail({version: "v1", auth: oauth2Client});

        // Gmail API認証テスト & 送信者メールアドレス取得
        let senderEmail: string;
        try {
          functions.logger.info("Gmail API認証テスト開始 - プロフィール取得");
          const profile = await gmail.users.getProfile({userId: "me"});
          senderEmail = profile.data.emailAddress || "";
          functions.logger.info("Gmail API認証成功", {
            emailAddress: senderEmail,
            profileMessagesTotal: profile.data.messagesTotal,
          });

          if (!senderEmail) {
            throw new Error("送信者のメールアドレスを取得できませんでした");
          }
        } catch (profileError: any) {
          functions.logger.error("Gmail APIプロフィール取得エラー", {
            error: profileError.message,
            code: profileError.code,
            status: profileError.status,
            details: profileError.details,
          });
          throw new functions.https.HttpsError(
              "unauthenticated",
              `Gmail認証に失敗しました: ${profileError.message}`
          );
        }

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
          body += "\n※ これはテスト送信です ※\n";
        }

        // メール送信用のリクエストデータを作成（RFC2822形式）
        const emailContent = [
          `From: ${senderEmail}`,
          `To: ${recipientEmail}`,
          `Subject: ${subject}`,
          `Content-Type: text/plain; charset=utf-8`,
          "",
          body,
        ].join("\n");

        // Base64エンコード
        const encodedEmail = Buffer.from(emailContent)
            .toString("base64")
            .replace(/\+/g, "-")
            .replace(/\//g, "_")
            .replace(/=+$/, "");

        // Gmail APIでメール送信
        functions.logger.info("Gmail API メール送信開始", {
          recipient: recipientEmail,
          encodedEmailLength: encodedEmail.length,
        });

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
          errorCode: error.code,
          errorStatus: error.status,
          errorStack: error.stack,
          userId: context.auth?.uid,
          data: data,
        });

        // エラーの種類に応じて適切なエラーメッセージを返す
        if (error.code === 401 || error.status === 401) {
          throw new functions.https.HttpsError(
              "unauthenticated",
              "認証が必要です"
          );
        } else if (error.code === 403 || error.status === 403) {
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
