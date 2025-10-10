/**
 * 水質報告メール送信用 Google Apps Script
 * 
 * このスクリプトは水質報告アプリからのGETリクエストを受け取り、
 * 指定されたメールアドレスに水質データをメール送信します。
 * 
 * 作成者: wq_report アプリ用
 * 更新日: 2024年
 */

/**
 * WebアプリのGETリクエストを処理するメイン関数
 * @param {Object} e - リクエストパラメータ
 * @returns {Object} - レスポンス
 */
function doGet(e) {
  try {
    // パラメータの取得
    const params = e.parameter;
    const monthDay = params.monthDay || '';
    const time = params.time || '';
    const chlorine = params.chlorine || '';
    const locationNumber = params.locationNumber || '';
    const recipientEmail = params.recipientEmail || '';
    const debugMode = params.debugMode === 'true';
    
    // 必須パラメータのチェック
    if (!monthDay || !time || !chlorine || !locationNumber || !recipientEmail) {
      return createErrorResponse('必須パラメータが不足しています');
    }
    
    // メール送信
    const result = sendWaterQualityEmail({
      monthDay: monthDay,
      time: time,
      chlorine: parseFloat(chlorine),
      locationNumber: locationNumber,
      recipientEmail: recipientEmail,
      debugMode: debugMode
    });
    
    if (result.success) {
      return createSuccessResponse('メールが正常に送信されました');
    } else {
      return createErrorResponse(result.message);
    }
    
  } catch (error) {
    console.error('GAS実行エラー:', error);
    return createErrorResponse('サーバー内部エラーが発生しました: ' + error.message);
  }
}

/**
 * 水質報告メールを送信する関数
 * @param {Object} data - 送信データ
 * @returns {Object} - 送信結果
 */
function sendWaterQualityEmail(data) {
  try {
    // 日付の整形
    const month = data.monthDay.substring(0, 2);
    const day = data.monthDay.substring(2, 4);
    const formattedDate = `${parseInt(month)}月${parseInt(day)}日`;
    
    // 時刻の整形
    const hour = data.time.substring(0, 2);
    const minute = data.time.substring(2, 4);
    const formattedTime = `${parseInt(hour)}時${parseInt(minute)}分`;
    
    // メール件名
    const subject = data.debugMode ? 
      `[テスト送信] 水質報告 - ${formattedDate} (地点${data.locationNumber})` :
      `水質報告 - ${formattedDate} (地点${data.locationNumber})`;
    
    // メール本文（プレーンテキストのみ）
    const body = createEmailBody({
      date: formattedDate,
      time: formattedTime,
      chlorine: data.chlorine,
      locationNumber: data.locationNumber,
      debugMode: data.debugMode
    });
    
    // メール送信
    GmailApp.sendEmail(data.recipientEmail, subject, body);
    
    return { success: true, message: 'メール送信完了' };
    
  } catch (error) {
    console.error('メール送信エラー:', error);
    return { success: false, message: 'メール送信に失敗しました: ' + error.message };
  }
}

/**
 * プレーンテキストのメール本文を作成
 * @param {Object} data - メールデータ
 * @returns {string} - メール本文
 */
function createEmailBody(data) {
  let body = `水質報告をお知らせします。

【測定日時】
${data.date} ${data.time}

【測定地点】
地点番号: ${data.locationNumber}

【測定結果】
残留塩素濃度: ${data.chlorine} mg/L

`;

  if (data.debugMode) {
    body += `
※ これはテスト送信です ※
デバッグモードで送信されました。

`;
  }

  body += `
【基準値参考】
- 水道法基準: 0.1 mg/L以上
- 推奨範囲: 0.1～1.0 mg/L

---
このメールは水質報告アプリから自動送信されました。
送信日時: ${new Date().toLocaleString('ja-JP')}
`;

  return body;
}

/**
 * 成功レスポンスを作成
 * @param {string} message - メッセージ
 * @returns {Object} - レスポンス
 */
function createSuccessResponse(message) {
  return ContentService
    .createTextOutput(JSON.stringify({
      status: 'success',
      message: message,
      timestamp: new Date().toISOString()
    }))
    .setMimeType(ContentService.MimeType.JSON);
}

/**
 * エラーレスポンスを作成
 * @param {string} message - エラーメッセージ
 * @returns {Object} - エラーレスポンス
 */
function createErrorResponse(message) {
  return ContentService
    .createTextOutput(JSON.stringify({
      status: 'error',
      message: message,
      timestamp: new Date().toISOString()
    }))
    .setMimeType(ContentService.MimeType.JSON);
}

/**
 * テスト用関数 - 手動実行でメール送信をテストできます
 * 
 * 使用方法:
 * 1. 下記のtestDataのrecipientEmailを自分のメールアドレスに変更
 * 2. Google Apps Scriptエディタで関数を選択して「実行」ボタンをクリック
 * 3. 権限の許可を求められた場合は許可する
 * 4. 指定したメールアドレスにテストメールが送信される
 */
function testEmailSend() {
  const testData = {
    monthDay: '1025',        // 10月25日
    time: '1030',           // 10時30分
    chlorine: 0.45,         // 残留塩素濃度 0.45mg/L
    locationNumber: '01',   // 地点番号
    recipientEmail: 'test@example.com', // ★ここを自分のメールアドレスに変更★
    debugMode: true         // テストモード
  };
  
  console.log('テスト送信を開始します...');
  console.log('送信データ:', testData);
  
  const result = sendWaterQualityEmail(testData);
  
  if (result.success) {
    console.log('✅ テスト成功:', result.message);
    console.log('📧 メールを確認してください: ' + testData.recipientEmail);
  } else {
    console.log('❌ テスト失敗:', result.message);
  }
  
  return result;
}