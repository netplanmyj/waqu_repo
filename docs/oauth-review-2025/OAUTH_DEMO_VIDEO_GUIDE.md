# OAuth審査用デモ動画作成ガイド

OAuth同意画面の審査に必要なデモ動画の撮影・編集・提出方法の完全ガイドです。

---

## 📋 動画の要件

### Google OAuth審査での動画要件

| 項目 | 要件 |
|-----|------|
| **形式** | MP4, MOV, AVI |
| **長さ** | 1-2分（推奨: 1分30秒） |
| **解像度** | 720p以上（推奨: 1080p） |
| **音声** | 不要（画面収録のみでOK） |
| **公開設定** | YouTube限定公開（Unlisted） |
| **言語** | 英語または日本語（英語推奨） |

### 必須シーン

```
✅ OAuth同意画面の表示（最重要）
✅ Gmail送信の実行
✅ 送信されたメールの確認
✅ アプリの主要機能デモ
```

---

## 🎯 動画構成（5シーン、合計1分30秒）

### シーン1: イントロ＋サインイン（15秒）

#### 撮影内容
1. **タイトル画面表示**（3秒）
   ```
   画面テキスト:
   "Water Quality Reporter Demo"
   "OAuth Gmail API Integration"
   ```

2. **アプリ起動**（2秒）
   - ホーム画面からアプリアイコンをタップ
   - アプリが起動

3. **Google Sign-In**（10秒）
   - 「Googleでサインイン」ボタンをタップ
   - **OAuth同意画面を表示**（最重要！）
   - 権限要求の内容を表示:
     ```
     このアプリは以下の権限を要求しています：
     ✓ Gmailからメールを送信
     ```
   - 「許可」をタップ
   - サインイン完了

#### 画面テキストオーバーレイ
```
"1. Google Sign-In with OAuth Consent"
"Requesting Gmail Send Permission"
```

---

### シーン2: アプリ設定（20秒）

#### 撮影内容
1. **設定画面を開く**（3秒）
   - 画面下部の「設定」タブをタップ
   - 設定画面が表示

2. **送信先メールアドレス設定**（7秒）
   - 送信先メールアドレスを入力
   - 例: `recipient@example.com`
   - 地点番号を入力（例: `01`）

3. **設定保存**（5秒）
   - 「保存」ボタンをタップ
   - 保存成功のメッセージ表示

4. **設定確認**（5秒）
   - 保存された設定が表示されることを確認

#### 画面テキストオーバーレイ
```
"2. Configure Email Settings"
"Set Recipient Email Address"
```

---

### シーン3: メール送信（メイン機能）（30秒）

#### 撮影内容
1. **ホーム画面に戻る**（2秒）
   - 「ホーム」タブをタップ

2. **測定データ入力**（10秒）
   - 日付選択（例: 2025年10月16日）
   - 時刻選択（例: 10:30）
   - 残留塩素濃度入力（例: 0.5 mg/L）

3. **Gmail API経由で送信**（8秒）
   - 「送信」ボタンをタップ
   - **送信処理中のローディング表示**
   - 送信成功のメッセージ表示
   - 「メールを送信しました」

4. **1日1回制限の確認**（10秒）
   - もう一度「送信」ボタンをタップ
   - 「本日は既に送信済みです」メッセージ表示
   - 1日1回の制限機能を確認

#### 画面テキストオーバーレイ
```
"3. Send Email via Gmail API"
"Entering Water Quality Data"
"Sending Email..."
"Email Sent Successfully"
"Daily Send Limit Enforced"
```

---

### シーン4: 送信履歴の確認（15秒）

#### 撮影内容
1. **履歴画面を開く**（3秒）
   - 「履歴」タブをタップ
   - 送信履歴一覧が表示

2. **履歴詳細を確認**（7秒）
   - 最新の履歴をタップ
   - 送信内容の詳細表示:
     - 送信日時
     - 地点番号
     - 残留塩素濃度
     - デバッグバッジ（テスト送信の場合）

3. **履歴管理機能**（5秒）
   - 履歴を長押し
   - 削除オプション表示
   - キャンセル

#### 画面テキストオーバーレイ
```
"4. View Send History"
"Data Stored Locally on Device"
```

---

### シーン5: 実際のメール確認（15秒）

#### 撮影内容
1. **Gmailアプリを開く**（3秒）
   - ホーム画面からGmailアプリをタップ

2. **送信済みメールボックス**（7秒）
   - 「送信済み」フォルダを開く
   - 水質報告メールが表示されることを確認

3. **メール内容確認**（5秒）
   - メールを開く
   - 件名: 「水質報告 地点01 2025-10-16」
   - 本文:
     ```
     地点番号: 01
     測定日: 2025年10月16日
     測定時刻: 10:30
     残留塩素濃度: 0.5 mg/L
     ```
   - **送信者が自分のGmailアカウント**であることを確認

#### 画面テキストオーバーレイ
```
"5. Verify Sent Email in Gmail"
"Email Sent from User's Own Account"
"Using Gmail API gmail.send Scope"
```

---

## 🛠️ 撮影準備

### 必要な機材・ソフト

#### Android画面録画

**方法1: Android標準機能**（推奨）
```
手順:
1. クイック設定パネルを開く
2. 「スクリーンレコード」をタップ
3. 録画開始

メリット:
✅ 無料
✅ 追加アプリ不要
✅ 高品質（1080p）
```

**方法2: ADB経由**
```bash
# PCから録画（より高品質）
adb shell screenrecord /sdcard/demo.mp4

# 録画停止（Ctrl+C）

# PCに転送
adb pull /sdcard/demo.mp4
```

#### 動画編集ソフト

**無料ソフト（推奨）**:
- **DaVinci Resolve**（Mac/Windows/Linux）
  - プロ仕様、無料版でも十分
  - テキストオーバーレイ機能あり
  
- **iMovie**（Mac）
  - 簡単操作
  - テキスト追加が容易

**オンライン編集**:
- **Clipchamp**（Microsoft）
  - ブラウザで完結
  - テキスト追加可能

---

## 📝 撮影スクリプト

### 事前準備チェックリスト

```
□ アプリをアンインストール（クリーンな状態で撮影）
□ テスト用Googleアカウント準備
  - メールアドレス: waqu.demo@gmail.com（デモ専用、推奨）
  - または既存アカウント（後で編集時にモザイク処理）
  - パスワード: 準備済み
□ 送信先メールアドレス準備
  - demo@example.com（架空のアドレスでOK）
  - または recipient@example.com
□ Firebase Functionsがデプロイ済み
□ Android端末のバッテリー充電済み
□ 画面の明るさを最大に設定
□ 通知をOFFにする（Do Not Disturb）
□ Wi-Fi接続確認
```

### 撮影手順書

```
【準備】
1. アプリをアンインストール
2. 通知をOFF、機内モードOFF、Wi-Fi ON
3. 画面の明るさを最大に
4. バッテリー十分か確認

【シーン1: サインイン】
1. ホーム画面を表示（3秒待機）
2. 画面録画開始
3. アプリアイコンをタップ
4. 「Googleでサインイン」をタップ
5. OAuth同意画面が表示されるまで待つ（重要！）
6. 権限要求の内容を確認（2秒）
7. 「許可」をタップ
8. サインイン完了まで待つ

【シーン2: 設定】
9. 「設定」タブをタップ
10. 送信先メールアドレスを入力
11. 地点番号を入力
12. 「保存」をタップ
13. 保存成功メッセージを確認（2秒）

【シーン3: メール送信】
14. 「ホーム」タブをタップ
15. 日付を選択
16. 時刻を選択
17. 残留塩素濃度を入力
18. 「送信」ボタンをタップ
19. 送信成功メッセージを確認（3秒）
20. もう一度「送信」をタップ
21. 「本日は既に送信済み」メッセージを確認（3秒）

【シーン4: 履歴】
22. 「履歴」タブをタップ
23. 最新の履歴をタップ
24. 詳細内容を確認（3秒）
25. 長押しして削除オプション表示
26. キャンセル

【シーン5: Gmail確認】
27. ホームボタンでホーム画面に戻る
28. Gmailアプリを開く
29. 「送信済み」フォルダを開く
30. 水質報告メールをタップ
31. メール内容を確認（5秒）
32. 送信者が自分のアカウントであることを確認
33. 画面録画停止
```

---

## 🎨 動画編集

### テキストオーバーレイの追加

各シーンに以下のテキストを追加：

```
【シーン1】
タイトル: "1. Google Sign-In with OAuth Consent"
サブタイトル: "Requesting Gmail Send Permission"
表示時間: 0:00-0:15

【シーン2】
タイトル: "2. Configure Email Settings"
サブタイトル: "Set Recipient Email Address"
表示時間: 0:15-0:35

【シーン3】
タイトル: "3. Send Email via Gmail API"
サブタイトル: "Using gmail.send Scope"
表示時間: 0:35-1:05

【シーン4】
タイトル: "4. View Send History"
サブタイトル: "Data Stored Locally"
表示時間: 1:05-1:20

【シーン5】
タイトル: "5. Verify Sent Email in Gmail"
サブタイトル: "Email Sent from User's Own Account"
表示時間: 1:20-1:35
```

### テキストスタイル

```
フォント: Arial Bold
サイズ: 48pt（タイトル）、32pt（サブタイトル）
色: 白
背景: 黒（透明度50%）
位置: 画面下部
```

### イントロ・アウトロ

**イントロ（3秒）**:
```
背景: グラデーション（#667eea → #764ba2）
テキスト:
  "Water Quality Reporter"
  "OAuth Gmail API Demo"
  "For Google OAuth Verification"
```

**アウトロ（2秒）**:
```
背景: グラデーション（#667eea → #764ba2）
テキスト:
  "Thank you for reviewing"
  "App Homepage: https://netplan.co.jp/library/waqu_repo/"
  "Privacy Policy: https://netplan.co.jp/library/waqu_repo/privacy/"
```

---

## 📤 YouTube アップロード

### アップロード設定

1. **YouTubeにログイン**
   - テスト用アカウントまたは本番アカウント

2. **動画をアップロード**
   ```
   タイトル:
   Water Quality Reporter - OAuth Gmail API Demo
   
   説明文:
   This demo video shows how the Water Quality Reporter app 
   uses Gmail API with gmail.send scope for OAuth verification.
   
   Features demonstrated:
   1. Google Sign-In with OAuth consent screen
   2. Email configuration settings
   3. Sending emails via Gmail API
   4. Send history management
   5. Verification of sent emails in Gmail
   
   App Homepage: https://netplan.co.jp/library/waqu_repo/
   Privacy Policy: https://netplan.co.jp/library/waqu_repo/privacy/
   
   For Google OAuth Verification Review.
   ```

3. **公開設定**
   ```
   公開範囲: 限定公開（Unlisted）
   
   重要: 「非公開（Private）」にしないこと
   → Google審査担当者がアクセスできなくなる
   ```

4. **サムネイル**
   ```
   画像サイズ: 1280 x 720 px
   内容: アプリアイコン + "OAuth Demo"
   ```

5. **タグ**
   ```
   gmail api, oauth, water quality, flutter, android
   ```

---

## 🔗 OAuth審査での使用

### Google Cloud Console設定

1. **OAuth同意画面**に移動
   - https://console.cloud.google.com/apis/credentials/consent

2. **「アプリのホームページ」**
   ```
   https://netplan.co.jp/library/waqu_repo/
   ```

3. **「プライバシーポリシーURL」**
   ```
   https://netplan.co.jp/library/waqu_repo/privacy/
   ```

4. **「本番環境に公開」を申請**
   - 「確認のため送信」をクリック

5. **追加情報フォーム**
   ```
   YouTube動画URL:
   https://www.youtube.com/watch?v=XXXXXXXXXXX
   
   説明（英語推奨）:
   This app helps water facility workers report residual 
   chlorine measurements via email. It uses Gmail API's 
   gmail.send scope to send reports from the user's own 
   Gmail account to designated recipients.
   
   The app:
   - Does not read emails
   - Does not modify emails
   - Only sends user-initiated measurement reports
   - Stores data locally on device
   - Uses Firebase Functions for secure email delivery
   ```

---

## ✅ チェックリスト

### 撮影前
- [ ] アプリを最新版にビルド
- [ ] テスト用Googleアカウント準備
- [ ] Firebase Functions デプロイ済み
- [ ] 撮影スクリプト確認
- [ ] Android端末の設定確認（通知OFF、明るさMAX）

### 撮影
- [ ] OAuth同意画面が明確に表示されている
- [ ] Gmail送信の瞬間が録画されている
- [ ] 送信されたメールが確認できている
- [ ] 全シーンが1分30秒以内に収まっている
- [ ] 画質が720p以上

### 編集
- [ ] テキストオーバーレイ追加
- [ ] イントロ・アウトロ追加
- [ ] URL表示（アプリホームページ、プライバシーポリシー）
- [ ] 不要な部分をカット
- [ ] 音声不要（無音でOK）

### YouTube公開
- [ ] タイトル設定
- [ ] 説明文記載（URL含む）
- [ ] 限定公開（Unlisted）に設定
- [ ] URLをコピー

### OAuth審査申請
- [ ] Google Cloud Consoleで申請
- [ ] YouTube URLを提出
- [ ] アプリホームページURL: https://netplan.co.jp/library/waqu_repo/
- [ ] プライバシーポリシーURL: https://netplan.co.jp/library/waqu_repo/privacy/
- [ ] 説明文提出

---

## 📊 審査期間

```
申請後:
Week 1-2: 初回レビュー
Week 3-4: 追加情報要求の可能性
Week 5-6: 最終審査
Week 7-8: 承認

平均: 4-6週間
```

---

## 🆘 トラブルシューティング

### 問題1: OAuth同意画面が表示されない

```
原因: 既にログイン済み
解決: 
1. アプリをアンインストール
2. Googleアカウントのアプリ権限を削除
   https://myaccount.google.com/permissions
3. 再度アプリをインストール
```

### 問題2: メール送信が失敗する

```
原因: Firebase Functions未デプロイ
解決:
cd functions
npm install
firebase deploy --only functions
```

### 問題3: 画面録画がカクカクする

```
原因: 端末のパフォーマンス不足
解決:
- 他のアプリを終了
- 解像度を720pに下げる
- ADB経由で録画（PCから）
```

---

## 💡 ヒント

### より良い動画にするために

1. **OAuth同意画面を強調**
   - この画面が最も重要
   - 2-3秒間表示して権限要求内容を見せる

2. **送信成功を明確に**
   - 「メールを送信しました」メッセージを表示
   - Gmailで実際のメールを確認

3. **データフローを示す**
   - アプリ → Firebase Functions → Gmail API
   - ユーザー自身のアカウントから送信

4. **プライバシーを強調**
   - データは端末内に保存
   - 第三者に送信しない

---

## 🚀 次のステップ

1. **今日中に撮影**
   - 撮影スクリプトに従って録画
   - 1-2回のテイクで完成させる

2. **明日編集**
   - テキストオーバーレイ追加
   - イントロ・アウトロ追加

3. **YouTube公開**
   - 限定公開でアップロード
   - URLを取得

4. **OAuth審査申請**
   - Google Cloud Consoleで申請
   - YouTubeURL、アプリホームページURL、プライバシーポリシーURLを提出

5. **審査待ち**（4-6週間）
   - この間にPlay Store準備
   - Android版の最終調整

---

**頑張ってください！この動画がOAuth審査の鍵となります。**
