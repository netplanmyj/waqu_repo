# OAuth審査 ホームページ要件への対応

**最終更新**: 2025年10月17日  
**審査フィードバック対応**: ホームページの要件

---

## 🎯 審査で指摘された問題

```
アプリが ホームページの要件 を満たしていません。次の問題を解決してください。
ホームページでアプリの目的が説明されていません。
```

---

## 📝 問題の原因分析

### 1. アプリ名称の不統一

以下のようにアプリ名がバラバラでした：

❌ **修正前の不統一な名称**:
- waqu-repo-2025 (Firebase プロジェクト名)
- 水質検査報告アプリ (ドキュメント)
- waqu repo (スペース付き)

✅ **正式名称（統一後）**:
- **水質検査報告アプリ `waqu_repo`**
- 英語表記: **Water Quality Reporter**

### 2. アプリの目的説明が不十分

修正前のホームページには：
- ❌ 簡単な機能説明のみ
- ❌ なぜGmail APIが必要かの説明なし
- ❌ 業務上の課題と解決策の説明なし
- ❌ 使用するスコープの具体的な説明なし

---

## ✅ 実施した対応

### 1. アプリ名の統一

すべてのドキュメントで名称を統一しました：

**統一後の名称**:
```
日本語: 水質検査報告アプリ waqu_repo
英語: Water Quality Reporter
パッケージ名: waqu_repo
```

**修正したファイル**:
- [x] `docs/index.md` - ホームページ
- [x] `docs/privacy-policy.md` - プライバシーポリシー
- [x] `pubspec.yaml` - アプリ設定（確認済み）
- [ ] Google Cloud Console - OAuth同意画面（要更新）

### 2. ホームページの改善（docs/index.md）

#### 追加した重要セクション:

##### **「アプリの目的」セクション**
```markdown
## アプリの目的

水質検査報告アプリ waqu_repo は、日本の水道施設で働く作業員が、
水道法に基づく残留塩素濃度の測定結果を施設管理者にメール報告する
ための業務用Androidアプリケーションです。

### 解決する課題
- 手動でのメール作成が手間で時間がかかる
- 報告フォーマットが統一されず、ミスが発生しやすい
- 外出先からの報告が困難
- 送信履歴の管理ができない

### なぜGmail APIを使用するのか
1. 責任追跡と監査証跡
2. セキュリティ（OAuth 2.0認証）
3. 送信確認（Gmailの送信済みフォルダ）
4. 法令遵守（水道法に基づく報告義務）
```

##### **「使用する権限とその理由」セクション**
```markdown
## 使用する権限とその理由

### Gmail API (gmail.send)

使用目的:
- 作業員のGmailアカウントから施設管理者へ測定報告メールを送信

使用しないスコープ:
- ❌ メール読み取り (gmail.readonly)
- ❌ メール変更 (gmail.modify)
- ❌ 連絡先アクセス
- ❌ その他のGoogleサービス

データフロー:
1. 作業員が測定値を入力
2. アプリが測定結果をフォーマット
3. Gmail API (gmail.send) で作業員のGmailから送信
4. 施設管理者がメールを受信
5. 送信履歴を端末内に保存
```

##### **「技術仕様」セクション**
```markdown
## 技術仕様

- プラットフォーム: Android
- 開発言語: Dart / Flutter
- 認証: Google OAuth 2.0
- 使用API: Gmail API (gmail.send スコープのみ)
- データ保存: 端末内ローカルストレージ
- バックエンド: Firebase Functions (メール中継のみ)
```

---

## 📋 Google Cloud Console での更新が必要な項目

### OAuth同意画面の設定

以下の項目を更新してください：

#### 1. アプリ名の統一

```
現在の設定を確認:
Google Cloud Console → プロジェクト waqu-repo-2025 → 
APIとサービス → OAuth同意画面

更新すべき項目:
- アプリ名: 水質検査報告アプリ waqu_repo
  または
  Water Quality Reporter

注意: プロジェクト名 (waqu-repo-2025) は変更不要
     これはFirebaseの内部名称です
```

#### 2. アプリの説明

```
アプリの説明欄に以下を記載（英語推奨）:

Water Quality Reporter (waqu_repo) is a business application for 
water facility workers in Japan to report daily residual chlorine 
measurement results to facility managers via email, as required by 
Japan's Water Supply Act.

The app uses Gmail API (gmail.send scope only) to send formatted 
measurement reports from workers' own Gmail accounts to designated 
recipients, ensuring accountability and regulatory compliance.
```

#### 3. アプリのホームページ

```
URL: https://netplan.co.jp/library/waqu_repo/

確認事項:
✅ URLが正しく設定されている
✅ ページが公開されている
✅ アプリの目的が明確に説明されている
✅ Gmail APIの使用理由が説明されている
```

#### 4. プライバシーポリシーURL

```
URL: https://netplan.co.jp/library/waqu_repo/privacy/

確認事項:
✅ URLが正しく設定されている
✅ ページが公開されている
✅ アプリ名が統一されている（更新済み）
```

---

## 🔄 再申請の手順

### ステップ1: ホームページの更新を確認

- [x] `docs/index.md` を更新（完了）
- [ ] Astroサイトにデプロイ
- [ ] https://netplan.co.jp/library/waqu_repo/ で確認
- [ ] アプリの目的が明確に表示されているか確認
- [ ] Gmail APIの使用理由が説明されているか確認

### ステップ2: Google Cloud Console の更新

```
1. Google Cloud Console にアクセス
   https://console.cloud.google.com/

2. プロジェクト「waqu-repo-2025」を選択

3. 「APIとサービス」→「OAuth同意画面」

4. 「編集」をクリック

5. 以下を更新:
   □ アプリ名: 水質検査報告アプリ waqu_repo
   □ アプリの説明: 上記の英語説明文を貼り付け
   □ アプリのホームページURL: 確認
   □ プライバシーポリシーURL: 確認

6. 「保存」をクリック
```

### ステップ3: スコープ使用理由の更新（前回のフィードバック対応）

```
1. 「スコープ」セクションに移動

2. gmail.send の「編集」をクリック

3. 「理由」フィールドに OAUTH_SCOPE_JUSTIFICATION.md の
   改善版テキストを貼り付け

4. 「保存」をクリック
```

### ステップ4: 再申請

```
1. すべての変更を保存

2. 「確認のため送信」または「再申請」ボタンをクリック

3. 追加フォームに記入:
   - YouTube動画URL: [デモ動画のURL]
   - アプリの説明: 上記の説明文を記載
   - スコープ使用理由: OAUTH_SCOPE_JUSTIFICATION.md の内容

4. 送信

5. 申請完了メールを受信

6. 再申請日を記録: _______________
```

---

## 📊 ホームページ要件チェックリスト

### Googleが求める要件

- [x] **アプリの目的が明確に説明されている**
  - 水道法に基づく測定報告業務用アプリであることを説明
  
- [x] **なぜGmail APIが必要かを説明**
  - 責任追跡、セキュリティ、法令遵守の観点から説明
  
- [x] **使用するスコープを明示**
  - gmail.send のみ使用
  - 他のスコープは使用しないことを明記
  
- [x] **データフローを説明**
  - 測定値入力 → メール送信 → 履歴保存の流れを図示
  
- [x] **プライバシー保護を説明**
  - データは端末内のみに保存
  - サーバーにはメール内容を保存しない
  
- [x] **技術仕様を記載**
  - Android、Flutter、OAuth 2.0、Firebase Functions
  
- [x] **アプリ名の統一**
  - 水質検査報告アプリ waqu_repo で統一

---

## 💡 審査を通すためのポイント

### 1. 明確な業務目的

✅ **良い例（現在のホームページ）**:
```
日本の水道施設で働く作業員が、水道法に基づく残留塩素濃度の
測定結果を施設管理者にメール報告するための業務用アプリ
```

❌ **悪い例**:
```
水質をチェックするアプリ（目的が曖昧）
```

### 2. Gmail API使用の必然性

✅ **良い例（現在のホームページ）**:
```
作業員の公式Gmailアカウントから送信することで、
責任追跡と監査証跡を確保
```

❌ **悪い例**:
```
メール送信が便利だから（代替手段を検討していない）
```

### 3. 最小権限の明示

✅ **良い例（現在のホームページ）**:
```
gmail.send スコープのみ使用
メール読み取り、変更は一切行いません
```

❌ **悪い例**:
```
Gmail APIを使います（どのスコープか不明）
```

### 4. データプライバシー

✅ **良い例（現在のホームページ）**:
```
測定データは端末内のみに保存
メール内容はサーバーに保存されません
Firebase Functionsは中継のみ（ログなし）
```

❌ **悪い例**:
```
データは安全です（具体性がない）
```

---

## 🎯 次のアクション

### 今日中に実施

1. [ ] Astroサイトに更新版をデプロイ
2. [ ] https://netplan.co.jp/library/waqu_repo/ で表示確認
3. [ ] Google Cloud Console でアプリ名・説明を更新

### 明日実施

1. [ ] スコープ使用理由を更新（OAUTH_SCOPE_JUSTIFICATION.md の内容）
2. [ ] デモ動画の準備状況を確認
3. [ ] 再申請

### デプロイ後の確認項目

```bash
# ホームページの確認
curl https://netplan.co.jp/library/waqu_repo/ | grep "アプリの目的"

確認ポイント:
✅ タイトルに「水質検査報告アプリ waqu_repo」が表示される
✅ 「アプリの目的」セクションが表示される
✅ 「なぜGmail APIを使用するのか」が表示される
✅ 「使用する権限とその理由」が表示される
✅ データフロー図が表示される
```

---

## 📁 関連ドキュメント

- `OAUTH_SCOPE_JUSTIFICATION.md` - スコープ使用理由の詳細
- `OAUTH_REVIEW_CHECKLIST.md` - 審査進捗チェックリスト
- `OAUTH_VERIFICATION.md` - OAuth審査の全体像
- `docs/index.md` - ホームページ（更新済み）
- `docs/privacy-policy.md` - プライバシーポリシー（更新済み）

---

**ホームページの改善により、審査要件を満たしました。**

次は Google Cloud Console でアプリ名と説明を更新し、再申請してください。
