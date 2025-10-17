# Trust and Safety チームへの連絡方法

**最終更新**: 2025年10月17日

---

## 📧 Trust and Safety チームからのメールが見つからない場合

OAuth審査を申請後、通常は以下のメールが届きます：

```
差出人: Google Trust & Safety Team
件名: Your OAuth Application Review
または
件名: OAuth 同意画面の審査状況
```

### メールが見つからない理由

1. **まだ審査を申請していない**
   - 「アプリを公開」ボタンをクリックしていない
   - OAuth同意画面のステータスが「テスト中」のまま

2. **メールがスパムフォルダに入っている**
   - Gmailの「迷惑メール」フォルダを確認
   - 「プロモーション」タブを確認

3. **自動審査中**
   - 申請後、初期の自動チェック段階（1-3日）
   - この段階ではメールが来ない場合がある

4. **別のメールアドレスに届いている**
   - OAuth同意画面に設定した「開発者連絡先メール」を確認
   - Google Cloud Console のプロジェクトオーナーのメールを確認

---

## 🔍 現在の審査ステータスを確認

### Google Cloud Console で確認

```
1. Google Cloud Console にアクセス
   https://console.cloud.google.com/

2. プロジェクト「waqu-repo-2025」を選択

3. 「APIとサービス」→「OAuth同意画面」

4. 「公開ステータス」を確認:

   ステータス別の状況:
   
   📝 テスト中 (Testing)
   → まだ審査を申請していない
   → 「アプリを公開」ボタンをクリックして申請
   
   ⏳ 確認待ち (Pending verification)
   → 審査中
   → 通常4-6週間かかる
   → メールは審査開始時または承認/却下時に届く
   
   ✅ 本番環境 (Published)
   → 審査承認済み
   → メールは既に届いているはず
   
   ❌ 却下 (Rejected)
   → 審査で却下された
   → 理由と修正方法がメールまたは画面に表示される
```

---

## 📞 Trust and Safety チームへの連絡方法

### 方法1: Google Cloud Console のサポート（推奨）

```
1. Google Cloud Console にアクセス
   https://console.cloud.google.com/

2. 右上の「？」アイコン（ヘルプ）をクリック

3. 「サポート」または「Contact Support」を選択

4. 「OAuth同意画面の審査について」を選択

5. 問い合わせフォームに記入:

   件名:
   OAuth Verification Status Inquiry for Project waqu-repo-2025

   本文:
   Hello,
   
   I have submitted my OAuth consent screen for verification, but I have
   not received any email from the Trust and Safety team. Could you please
   provide the current status of my application?
   
   Project ID: waqu-repo-2025
   Application Name: 水質検査報告アプリ waqu_repo
   Submission Date: [申請日を記入]
   
   Thank you.

6. 「送信」をクリック
```

### 方法2: OAuth同意画面の「お問い合わせ」

```
1. OAuth同意画面ページを開く

2. ページ下部の「お問い合わせ」または「Contact Us」リンクをクリック

3. 問い合わせフォームに記入（上記と同様の内容）
```

### 方法3: Google Workspace サポート（Workspace契約がある場合）

```
もしGoogle Workspaceを契約している場合:

1. Google Workspace Admin Console にアクセス
   https://admin.google.com/

2. 「サポート」→「お問い合わせ」

3. 「OAuth審査について」と記載して問い合わせ
```

### 方法4: OAuth Developer Support フォーム

```
Google の OAuth Developer Support フォーム:
https://support.google.com/code/contact/oauth_app_verification

記入項目:
- Email address: [あなたのメールアドレス]
- Project ID: waqu-repo-2025
- Client ID: [OAuth クライアントID]
- Issue description: 
  I have not received any email regarding my OAuth verification
  submission. Please advise on the current status.
```

---

## 📝 問い合わせ時に記載すべき情報

### 必須情報

```
1. Project ID
   waqu-repo-2025

2. Application Name
   水質検査報告アプリ waqu_repo
   (Water Quality Reporter)

3. OAuth Client ID
   [Google Cloud Console → 認証情報 → OAuth 2.0 クライアントID で確認]

4. 申請日
   [「アプリを公開」ボタンをクリックした日]

5. 現在のステータス
   [OAuth同意画面で確認したステータス]

6. 質問内容
   - メールが届いていない
   - 審査の現在の状況を知りたい
   - 追加情報が必要か確認したい
```

### 問い合わせテンプレート（英語）

```
Subject: OAuth Verification Status Inquiry for Project waqu-repo-2025

Dear Google Trust and Safety Team,

I have submitted my OAuth consent screen for verification for the
following project, but I have not received any email regarding the
review status. Could you please provide an update?

Project Details:
- Project ID: waqu-repo-2025
- Application Name: 水質検査報告アプリ waqu_repo (Water Quality Reporter)
- OAuth Client ID: [あなたのClient ID]
- Submission Date: [申請日]
- Current Status: Pending Verification (or Testing)
- Requested Scope: https://www.googleapis.com/auth/gmail.send

Questions:
1. What is the current status of my OAuth verification?
2. Have I missed any required information or documents?
3. Is there anything I need to provide to proceed with the review?

App Homepage: https://netplan.co.jp/library/waqu_repo/
Privacy Policy: https://netplan.co.jp/library/waqu_repo/privacy/

Thank you for your assistance.

Best regards,
[あなたの名前]
```

### 問い合わせテンプレート（日本語）

```
件名: OAuth審査の状況確認（プロジェクト: waqu-repo-2025）

Google Trust and Safety チーム 御中

お世話になります。

以下のプロジェクトについて、OAuth同意画面の審査を申請いたしましたが、
審査状況に関するメールが届いておりません。現在の状況をご教示いただけ
ますでしょうか。

プロジェクト情報:
- プロジェクトID: waqu-repo-2025
- アプリケーション名: 水質検査報告アプリ waqu_repo (Water Quality Reporter)
- OAuth クライアントID: [あなたのClient ID]
- 申請日: [申請日]
- 現在のステータス: 確認待ち（または テスト中）
- リクエストしているスコープ: https://www.googleapis.com/auth/gmail.send

お伺いしたい点:
1. OAuth審査の現在の状況
2. 不足している情報やドキュメントの有無
3. 審査を進めるために追加で提供すべき情報の有無

アプリホームページ: https://netplan.co.jp/library/waqu_repo/
プライバシーポリシー: https://netplan.co.jp/library/waqu_repo/privacy/

お手数をおかけいたしますが、ご確認のほどよろしくお願いいたします。

[あなたの名前]
```

---

## ⏱️ 返信までの期間

### 一般的なタイムライン

```
問い合わせ送信:
↓
1-3営業日: 自動返信メール（チケット番号発行）
↓
3-5営業日: 担当者からの初回返信
↓
必要に応じて追加のやり取り
```

### 注意事項

```
⚠️ サポートの返信は英語の場合が多い
   → Google翻訳を活用

⚠️ 営業日ベース（土日祝日を除く）
   → 米国時間を考慮

⚠️ OAuth審査は時間がかかる
   → 通常4-6週間
   → 問い合わせても早くはならない場合が多い
```

---

## 🔍 よくある質問と回答

### Q1: 申請からどのくらいでメールが来ますか？

```
A: タイミングは以下の通り:

1. 申請直後（即座）
   → 自動確認メール「申請を受け付けました」
   
2. 審査開始時（3-7日後）
   → 「審査を開始しました」
   
3. 追加情報要求時（審査中）
   → 「追加情報が必要です」
   
4. 審査完了時（4-6週間後）
   → 「承認されました」または「却下されました」

メールが来ない場合:
- スパムフォルダを確認
- まだ申請していない可能性
- 自動審査中（メールなし）
```

### Q2: 申請したか確認する方法は？

```
A: OAuth同意画面のステータスを確認:

「テスト中」
→ まだ申請していない
→ 「アプリを公開」ボタンをクリックして申請

「確認待ち」または「Pending verification」
→ 申請済み、審査中
→ 4-6週間待つ
```

### Q3: 審査を早める方法はありますか？

```
A: 基本的に早める方法はありませんが、以下を確認:

✅ 全ての必須情報を提供している
   - プライバシーポリシー
   - アプリホームページ
   - デモ動画
   - スコープ使用理由

✅ フィードバックに迅速に対応
   - 追加情報要求のメールにすぐ返信

⚠️ 問い合わせしても審査は早くならない
   - 問い合わせは状況確認のみ
```

### Q4: メールの差出人を確認する方法は？

```
A: 以下の差出人から届く可能性:

From: noreply-apps-dev-apis@google.com
From: noreply@google.com
From: google-oauth-reviews@google.com

件名:
- OAuth Application Review
- OAuth 同意画面の審査状況
- Action Required: OAuth Verification
```

---

## 📋 チェックリスト：メールが見つからない場合

```
□ Gmailの「迷惑メール」フォルダを確認
□ Gmailの「プロモーション」タブを確認
□ 「すべてのメール」で検索
   検索キーワード: "oauth" "verification" "trust and safety"
□ OAuth同意画面のステータスを確認
□ 開発者連絡先メールアドレスを確認
□ Google Cloud Console のプロジェクトオーナーのメールを確認
□ まだ申請していないか確認（ステータスが「テスト中」）
□ 申請日から3日以上経過しているか確認
□ Google Cloud Console のサポートに問い合わせ
```

---

## 🎯 次のステップ

### 今すぐ実施

```
1. □ OAuth同意画面のステータスを確認
   https://console.cloud.google.com/apis/credentials/consent

2. □ ステータスが「テスト中」の場合
   → 「アプリを公開」ボタンをクリックして申請

3. □ ステータスが「確認待ち」の場合
   → メールを再度探す（迷惑メール、プロモーション）

4. □ メールが見つからない場合
   → Google Cloud Console のサポートに問い合わせ
```

### 問い合わせ時の準備

```
□ Project ID をコピー: waqu-repo-2025
□ OAuth Client ID をコピー
□ 申請日を確認
□ 現在のステータスを確認
□ 上記のテンプレートを使用して問い合わせ文を作成
```

---

## 💡 重要なポイント

```
✅ メールが来ないのは一般的
   - 自動審査中はメールが来ない場合がある
   - 審査期間は4-6週間と長い

✅ ステータスで確認
   - OAuth同意画面のステータスが最も正確
   - メールよりもステータスを信頼

✅ 焦らずに待つ
   - 審査は時間がかかる
   - 問い合わせても早くはならない

✅ 準備を進める
   - 待っている間に Play Store 準備を進める
   - デモ動画を完成させる
```

---

**まずは OAuth同意画面のステータスを確認してください。ステータスが「テスト中」の場合は、まだ申請していません。「確認待ち」の場合は審査中です。**

現在のステータスを教えていただければ、次の具体的なアクションをご案内します！
