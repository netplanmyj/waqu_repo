import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import * as nodemailer from "nodemailer";

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
          timestamp: new Date().toISOString(),
        });

        // 認証チェック
        if (!context.auth) {
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
        const senderEmail = context.auth.token.email;
        
        if (!senderEmail) {
          throw new functions.https.HttpsError(
              "unauthenticated",
              "送信者のメールアドレスを取得できませんでした"
          );
        }

        functions.logger.info("メール送信準備", {
          senderEmail: senderEmail,
          recipientEmail: recipientEmail,
          accessTokenLength: accessToken?.length,
        });

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

        // Nodemailerのtransporterを作成（OAuth2認証）
        functions.logger.info("Nodemailer transporter作成開始");
        const transporter = nodemailer.createTransport({
          service: "gmail",
          auth: {
            type: "OAuth2",
            user: senderEmail,
            accessToken: accessToken,
          },
        });

        functions.logger.info("メール送信開始", {
          from: senderEmail,
          to: recipientEmail,
          subject: subject,
        });

        // メール送信
        let info;
        try {
          info = await transporter.sendMail({
            from: senderEmail,
            to: recipientEmail,
            subject: subject,
            text: body,
          });

          functions.logger.info("メール送信成功", {
            messageId: info.messageId,
            recipient: recipientEmail,
            debugMode: debugMode,
            userId: context.auth.uid,
            response: info.response,
          });
        } catch (sendError: any) {
          // メール送信エラーの詳細ログ
          functions.logger.error("========================================");
          functions.logger.error("❌ Nodemailer メール送信エラー");
          functions.logger.error("エラーメッセージ:", sendError.message);
          functions.logger.error("エラー名:", sendError.name);
          functions.logger.error("エラーコード:", sendError.code);
          functions.logger.error("エラースタック:", sendError.stack);
          functions.logger.error("送信先:", recipientEmail);
          functions.logger.error("送信元:", senderEmail);
          functions.logger.error("========================================");
          
          throw new functions.https.HttpsError(
              "internal",
              `メール送信に失敗しました: ${sendError.message}`
          );
        }

        return {
          status: "success",
          message: "メールが正常に送信されました",
          messageId: info.messageId,
          timestamp: new Date().toISOString(),
        };
      } catch (error: any) {
        // エラー情報を詳細に出力
        functions.logger.error("========================================");
        functions.logger.error("❌ 最終エラーハンドラー: メール送信処理失敗");
        functions.logger.error("エラーメッセージ:", error.message);
        functions.logger.error("エラーコード:", error.code);
        functions.logger.error("エラーステータス:", error.status);
        functions.logger.error("エラー名:", error.name);
        functions.logger.error("エラータイプ:", typeof error);
        
        if (error.response) {
          functions.logger.error("レスポンスステータス:", error.response.status);
          functions.logger.error("レスポンスステータステキスト:", 
            error.response.statusText);
          
          if (error.response.data) {
            try {
              const dataStr = JSON.stringify(error.response.data, null, 2);
              functions.logger.error("レスポンスデータ(全体):", dataStr);
              
              // エラーの詳細情報があれば個別に出力
              if (error.response.data.error) {
                functions.logger.error("エラー詳細:", 
                  JSON.stringify(error.response.data.error, null, 2));
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
          functions.logger.error("リクエスト設定:", {
            url: error.config.url,
            method: error.config.method,
            baseURL: error.config.baseURL,
          });
        }
        
        functions.logger.error("スタックトレース:", error.stack);
        functions.logger.error("========================================");

        // エラーの種類に応じて適切なエラーメッセージを返す
        if (error.code === 401 || error.status === 401) {
          throw new functions.https.HttpsError(
              "unauthenticated",
              "認証が必要です。Gmail APIの認証に失敗しました。"
          );
        } else if (error.code === 403 || error.status === 403) {
          throw new functions.https.HttpsError(
              "permission-denied",
              "Gmail送信権限がありません。認証時にGmail送信権限を許可してください。"
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
