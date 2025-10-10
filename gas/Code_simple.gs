/**
 * 水質報告メール送信用 Google Apps Script（シンプル版）
 * 
 * このスクリプトは水質報告アプリからのGETリクエストを受け取り、
 * 指定されたメールアドレスに水質データをシンプルなメール送信します。
 * 
 * 現在の動作版をベースに不要なdoPost()を削除し、
 * デバッグモード対応を追加したバージョンです。
 */

/**
 * GET リクエスト用（Flutter アプリからのリクエスト対応）
 * @param {Object} e - リクエストパラメータ
 * @returns {Object} - JSON レスポンス
 */
function doGet(e) {
  try {
    // パラメータの取得
    const monthDay = e.parameter.monthDay;
    const time = e.parameter.time;
    const chlorine = e.parameter.chlorine;
    const locationNumber = e.parameter.locationNumber || "18";
    const recipientEmail = e.parameter.recipientEmail;
    const debugMode = e.parameter.debugMode === 'true';
    
    // 必須パラメータのチェック
    if (!monthDay || !time || !chlorine || !recipientEmail) {
      return ContentService
        .createTextOutput(JSON.stringify({
          status: "error",
          message: "必要なパラメータが不足しています",
          timestamp: new Date().toISOString()
        }))
        .setMimeType(ContentService.MimeType.JSON);
    }
    
    // メール件名（デバッグモード対応）
    const subject = debugMode ? 
      `[テスト送信] 毎日検査報告（地点${locationNumber}）` :
      `毎日検査報告（地点${locationNumber}）`;
    
    // メール本文
    let body = `地点: ${locationNumber}\n` +
               `月日: ${monthDay}\n` +
               `測定時刻: ${time}\n` +
               `残留塩素: ${chlorine}\n`;
    
    // デバッグモードの場合はテスト送信の旨を追記
    if (debugMode) {
      body += `\n※ これはテスト送信です ※\n`;
    }
    
    // メール送信
    GmailApp.sendEmail(recipientEmail, subject, body);
    
    // 成功レスポンス
    return ContentService
      .createTextOutput(JSON.stringify({
        status: "success",
        message: "Email sent successfully",
        timestamp: new Date().toISOString()
      }))
      .setMimeType(ContentService.MimeType.JSON);
      
  } catch (error) {
    // エラーレスポンス
    return ContentService
      .createTextOutput(JSON.stringify({
        status: "error",
        message: error.toString(),
        timestamp: new Date().toISOString()
      }))
      .setMimeType(ContentService.MimeType.JSON);
  }
}

/**
 * テスト用関数 - 手動実行でメール送信をテストできます
 * 
 * 使用方法:
 * 1. 下記のrecipientを自分のメールアドレスに変更
 * 2. Google Apps Scriptエディタで関数を選択して「実行」ボタンをクリック
 * 3. 権限の許可を求められた場合は許可する
 * 4. 指定したメールアドレスにテストメールが送信される
 */
function testEmailSend() {
  // テスト用のパラメータを設定
  const testParams = {
    parameter: {
      monthDay: "1025",
      time: "1030", 
      chlorine: "0.45",
      locationNumber: "01",
      recipientEmail: "test@example.com", // ★ここを自分のメールアドレスに変更★
      debugMode: "true"
    }
  };
  
  console.log('テスト送信を開始します...');
  console.log('送信パラメータ:', testParams.parameter);
  
  // doGet関数を直接呼び出してテスト
  const result = doGet(testParams);
  const responseText = result.getContent();
  const response = JSON.parse(responseText);
  
  if (response.status === "success") {
    console.log('✅ テスト成功:', response.message);
    console.log('📧 メールを確認してください: ' + testParams.parameter.recipientEmail);
  } else {
    console.log('❌ テスト失敗:', response.message);
  }
  
  return response;
}