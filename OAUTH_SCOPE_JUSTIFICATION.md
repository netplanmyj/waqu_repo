# OAuth スコープ使用理由の詳細説明

**最終更新**: 2025年10月17日  
**審査フィードバック対応**: 最小スコープのリクエスト要件

---

## 🎯 審査で指摘された問題

```
提供された理由では、リクエストした OAuth スコープが必要な理由が
十分に説明されていません。
```

### 対応方針
Googleが求める説明内容：
1. **なぜこのスコープが必要なのか**（代替手段がない理由）
2. **ユーザーにとっての価値**（業務上の必要性）
3. **最小権限の原則**（gmail.sendのみで他のスコープは不要）
4. **具体的な使用シナリオ**（実際の業務フロー）

---

## 📝 改善版：OAuth スコープ使用理由（英語版）

### 提出用テキスト（コピー&ペースト用）

```
WHY GMAIL.SEND SCOPE IS ESSENTIAL

Our app serves water facility workers in Japan who must submit 
daily residual chlorine measurement reports to their supervisors. 
This is a regulatory requirement under Japan's Water Supply Act.

BUSINESS REQUIREMENT:
- Workers measure residual chlorine levels at water facilities
- They must report results daily via email to facility managers
- Reports include: location ID, measured values, timestamp, worker name
- Email delivery is the required communication method in this industry

WHY GMAIL API IS NECESSARY:

1. PROFESSIONAL EMAIL REQUIREMENT
   Workers must send reports from their official Gmail accounts 
   (not anonymous/app-generated accounts) for accountability and 
   audit trail purposes.

2. NO ALTERNATIVE SOLUTIONS
   - SMTP clients require password storage (security risk)
   - Third-party email services cannot send from user's Gmail
   - mailto: links don't support automated report formatting
   - Backend email relay loses sender identity and accountability

3. GMAIL.SEND IS THE MINIMAL SCOPE
   We only need to SEND emails. We specifically:
   - Do NOT read emails (no gmail.readonly)
   - Do NOT modify emails (no gmail.modify)
   - Do NOT access contacts (no contacts scope)
   - Do NOT access Drive or Calendar
   
   gmail.send is the most restrictive scope that meets our need.

4. USER CONTROL AND TRANSPARENCY
   - Users explicitly tap "Send Report" button
   - They see recipient address before sending
   - They can review send history
   - They can revoke access anytime
   - Email is sent from their own Gmail account (visible in Sent folder)

5. DATA PRIVACY
   - No email content is stored on our servers
   - Firebase Functions only relay the message (no logging)
   - All measurement data stays on user's device
   - No third parties access the email content

SPECIFIC USE CASE EXAMPLE:
1. Worker measures residual chlorine: 0.5 mg/L
2. Worker opens app and enters measurement
3. Worker taps "Send Report" button
4. App uses gmail.send to send from worker@company.com to manager@company.com
5. Email appears in worker's Gmail Sent folder
6. Manager receives report with worker's verified identity

This workflow ensures regulatory compliance, maintains accountability,
and protects user privacy while using the absolute minimum Gmail API 
permission required.

App Homepage: https://netplan.co.jp/library/waqu_repo/
Privacy Policy: https://netplan.co.jp/library/waqu_repo/privacy/
Demo Video: [YouTube URL will be added after upload]
```

---

## 📝 改善版：OAuth スコープ使用理由（日本語版）

### 参考用（審査は英語で提出推奨）

```
Gmail.send スコープが必須である理由

当アプリは、日本の水道施設で働く作業員が毎日の残留塩素測定結果を
上司に報告するために使用します。これは水道法に基づく法的要件です。

業務要件：
- 作業員が水道施設で残留塩素濃度を測定
- 測定結果を毎日メールで施設管理者に報告する義務
- 報告内容：地点ID、測定値、タイムスタンプ、作業員名
- 業界標準としてメール送信が必須

Gmail APIが必要な理由：

1. 公式メールアカウントからの送信が必須
   作業員は自身の公式Gmailアカウントから報告を送信する必要があります。
   これは責任追跡と監査証跡の観点から不可欠です。

2. 代替手段が存在しない
   - SMTPクライアント：パスワード保存が必要（セキュリティリスク）
   - サードパーティメールサービス：ユーザーのGmailから送信不可
   - mailto:リンク：自動レポート作成に対応していない
   - バックエンド中継：送信者のアイデンティティと責任追跡が失われる

3. gmail.sendは最小限のスコープ
   当アプリはメール送信のみ必要です。以下は使用しません：
   - メール閲覧（gmail.readonly）不要
   - メール変更（gmail.modify）不要
   - 連絡先アクセス（contacts）不要
   - DriveやCalendarアクセス不要
   
   gmail.sendは目的達成に必要な最も制限的なスコープです。

4. ユーザーの制御と透明性
   - ユーザーは明示的に「レポート送信」ボタンをタップ
   - 送信前に宛先アドレスを確認可能
   - 送信履歴を閲覧可能
   - いつでもアクセス権限を取り消し可能
   - メールは自身のGmailアカウントから送信（送信済みフォルダで確認可能）

5. データプライバシー
   - メール内容はサーバーに保存されない
   - Firebase Functionsはメッセージを中継するのみ（ログなし）
   - 測定データはすべてユーザー端末内に保存
   - 第三者はメール内容にアクセスできない

具体的な使用シナリオ：
1. 作業員が残留塩素を測定：0.5 mg/L
2. 作業員がアプリを開き測定値を入力
3. 作業員が「レポート送信」ボタンをタップ
4. アプリがgmail.sendを使用してworker@company.comからmanager@company.comへ送信
5. メールは作業員のGmail送信済みフォルダに表示
6. 管理者が作業員の検証済みアイデンティティ付きでレポートを受信

このワークフローにより、法令遵守、責任追跡、ユーザープライバシー保護を
実現しつつ、必要最小限のGmail API権限のみを使用します。

アプリホームページ: https://netplan.co.jp/library/waqu_repo/
プライバシーポリシー: https://netplan.co.jp/library/waqu_repo/privacy/
デモ動画: [YouTube URLを後で追加]
```

---

## 🎯 再申請時の追加提出資料

### 1. データフロー図（推奨）

```
ユーザーの操作フロー:

┌─────────────────┐
│  作業員         │
│  (Android端末)  │
└────────┬────────┘
         │
         │ 1. 測定値を入力
         │ 2. 「送信」タップ
         ↓
┌─────────────────────────┐
│  Water Quality Reporter │
│  (Flutter App)          │
└────────┬────────────────┘
         │
         │ 3. Gmail API (gmail.send)
         │    OAuth 2.0 認証済み
         ↓
┌─────────────────────────┐
│  Gmail API              │
│  (Google Servers)       │
└────────┬────────────────┘
         │
         │ 4. メール配信
         ↓
┌─────────────────┐
│  施設管理者     │
│  (メール受信)   │
└─────────────────┘

データフロー:
- 測定データ: 端末内のみ（SharedPreferences）
- メール内容: Gmail APIに直接送信（中間保存なし）
- アクセストークン: 端末内の安全なストレージ
```

### 2. スクリーンショット（推奨）

以下の画面をキャプチャして提出：

1. **OAuth同意画面**
   - 「gmail.send」スコープが明示されている画面
   - 「許可」ボタンがある画面

2. **メール送信画面**
   - 送信先アドレスが表示されている
   - 「送信」ボタンが明確
   - ユーザーが内容を確認できる

3. **送信履歴画面**
   - 送信日時、宛先が記録されている
   - ユーザーが過去の送信を確認できる

4. **Gmail送信済みフォルダ**
   - 実際にGmailの送信済みフォルダにメールがある
   - ユーザー自身のアカウントから送信されたことが確認できる

---

## 📋 再申請チェックリスト

### OAuth同意画面の再申請前に確認

- [ ] **スコープ使用理由を改善版に更新**
  - 上記の英語版テキストを使用
  - 業務要件を明確に説明
  - 代替手段がない理由を説明
  - 最小権限の原則を強調

- [ ] **デモ動画を確認**
  - OAuth同意画面が明確に表示されている
  - gmail.sendスコープが表示されている
  - メール送信の全プロセスが録画されている
  - Gmail送信済みフォルダでの確認シーンがある

- [ ] **プライバシーポリシーを再確認**
  - Gmail APIの使用目的が詳しく説明されている ✅
  - データフローが明確 ✅
  - ユーザーの権利が説明されている ✅
  - URL: https://netplan.co.jp/library/waqu_repo/privacy/

- [ ] **アプリホームページを再確認**
  - アプリの目的が明確 ✅
  - Gmail APIの使用目的が説明されている ✅
  - URL: https://netplan.co.jp/library/waqu_repo/

- [ ] **追加資料（任意だが推奨）**
  - データフロー図を作成
  - スクリーンショットを準備
  - 業界の標準的なワークフローを説明する文書

---

## 🔄 再申請の手順

### ステップ1: Google Cloud Console にアクセス

```
1. https://console.cloud.google.com/ にアクセス
2. プロジェクト「waqu-repo-2025」を選択
3. 「APIとサービス」→「OAuth同意画面」
```

### ステップ2: 審査フィードバックの確認

```
1. 「公開ステータス」タブを開く
2. 審査フィードバックを確認
3. 「編集」をクリック
```

### ステップ3: スコープ使用理由の更新

```
1. 「スコープ」セクションまでスクロール
2. gmail.send スコープの横にある「編集」アイコンをクリック
3. 「理由」フィールドに改善版テキストを貼り付け
4. 「保存」をクリック
```

**貼り付けるテキスト**:
```
[上記の「改善版：OAuth スコープ使用理由（英語版）」の全文をコピー]
```

### ステップ4: その他の必須情報を確認

```
- アプリ名: Water Quality Reporter
- アプリホームページ: https://netplan.co.jp/library/waqu_repo/
- プライバシーポリシーURL: https://netplan.co.jp/library/waqu_repo/privacy/
- ユーザーサポートメール: [設定済みメールアドレス]
- 開発者連絡先メール: [設定済みメールアドレス]
```

### ステップ5: 再申請

```
1. すべての変更を保存
2. 「確認のため送信」または「再申請」ボタンをクリック
3. 追加のフォームがあれば記入:
   - YouTube動画URL: [デモ動画のURL]
   - 追加説明: [上記の改善版テキストを再度記載]
4. 送信
```

### ステップ6: 確認

```
1. 申請完了メールを受信
2. 公開ステータスが「Pending verification（審査中）」になっていることを確認
3. 審査開始日を記録: _____________
```

---

## 💡 審査を通すための追加ヒント

### 1. **具体性を重視**
```
❌ 悪い例: "This app sends emails."
✅ 良い例: "This app sends daily water quality reports from 
           workers to facility managers as required by 
           Japan's Water Supply Act."
```

### 2. **代替手段がない理由を明確に**
```
❌ 悪い例: "We use Gmail API because it's convenient."
✅ 良い例: "Gmail API is the only solution that allows 
           sending from user's own Gmail account while 
           maintaining sender identity and audit trail."
```

### 3. **最小権限を強調**
```
❌ 悪い例: "We use gmail.send scope."
✅ 良い例: "We use ONLY gmail.send scope. We do NOT request 
           gmail.readonly, gmail.modify, or any other scopes 
           beyond the absolute minimum required."
```

### 4. **ユーザー価値を示す**
```
❌ 悪い例: "Users can send emails."
✅ 良い例: "Workers can submit regulatory-required reports 
           directly from the field, reducing paperwork and 
           ensuring timely compliance with safety regulations."
```

### 5. **プライバシー保護を説明**
```
❌ 悪い例: "We don't store data."
✅ 良い例: "Email content goes directly to Gmail API without 
           server-side storage. Firebase Functions only relay 
           messages with no logging. All measurement data 
           stays on user's device."
```

---

## 📊 審査タイムライン（再申請後）

```
Day 1:    再申請送信
Day 2-3:  自動チェック（形式要件）
Day 4-7:  初回レビュー開始
Week 2-4: 詳細審査（デモ動画確認、ポリシー確認）
Week 4-6: 最終審査
Week 6:   承認 🎉（または追加質問）
```

---

## ⚠️ よくある追加質問と回答例

### Q1: "Why not use SMTP?"
```
A: SMTP requires storing user passwords or app-specific passwords, 
   which creates security risks. Gmail API uses OAuth 2.0, allowing 
   users to grant limited permission without sharing passwords. 
   Additionally, SMTP doesn't provide the audit trail and sender 
   verification that Gmail API offers.
```

### Q2: "Can you use a backend email service?"
```
A: Backend email services would send emails from our server's address, 
   not from the user's Gmail account. This breaks the accountability 
   chain required for regulatory compliance. Workers must send reports 
   from their official company Gmail accounts for audit purposes.
```

### Q3: "Why can't users just use the Gmail app?"
```
A: Manual email composition is error-prone and time-consuming. Workers 
   need to send formatted reports with specific data fields (location ID, 
   timestamp, measured values). Our app automates this formatting while 
   ensuring data accuracy and regulatory compliance.
```

### Q4: "Is this scope really the minimum?"
```
A: Yes. We only SEND emails (gmail.send). We do not:
   - Read emails (would require gmail.readonly)
   - Modify emails (would require gmail.modify)
   - Access contacts (would require contacts scope)
   - Access other Google services
   
   gmail.send is the most restrictive scope that enables our use case.
```

---

## 🎯 次のアクション

### 今日中に実施
1. [ ] 上記の改善版テキストを確認
2. [ ] Google Cloud Console にアクセス
3. [ ] スコープ使用理由を更新
4. [ ] デモ動画が要件を満たしているか確認

### 明日実施
1. [ ] データフロー図を作成（推奨）
2. [ ] スクリーンショットを準備（推奨）
3. [ ] 再申請

### 再申請後
1. [ ] 申請完了メールを確認
2. [ ] 審査ステータスを毎週確認
3. [ ] 追加質問に備える

---

**改善版の説明文により、審査承認の可能性が大幅に向上します。**

問題があれば、このドキュメントを参照して再申請してください。
