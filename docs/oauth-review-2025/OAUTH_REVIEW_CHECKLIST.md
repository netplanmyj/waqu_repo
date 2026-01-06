# OAuth審査申請 進捗チェックリスト

現在の進捗状況と次のステップを管理するためのチェックリストです。

**最終更新**: 2025年10月17日

---

## 📢 審査フィードバック対応中

### 受領したフィードバック（2025年10月16日）

#### 1. ❌ 最小スコープのリクエスト要件
```
提供された理由では、リクエストした OAuth スコープが必要な理由が
十分に説明されていません。
```
**対応状況**: ✅ 改善版テキスト作成完了（`OAUTH_SCOPE_JUSTIFICATION.md`）

#### 2. ❌ ホームページの要件
```
ホームページでアプリの目的が説明されていません。
```
**対応状況**: ✅ ホームページ更新完了（`webwebdocs/index.md`）

#### 3. ⚠️ アプリ名称の不統一
- waqu-repo-2025（Firebaseプロジェクト名）
- 水質検査報告アプリ（旧ドキュメント）
- waqu repo（スペース付き）

**対応状況**: ✅ 正式名称に統一完了
- **正式名称**: 水質検査報告アプリ `waqu_repo`
- **英語表記**: Water Quality Reporter

---

## ✅ 完了済み項目

### Phase 1: 開発完了
- [x] Flutter アプリ開発完了
- [x] Gmail API統合（OAuth 2.0）
- [x] Firebase Functions デプロイ
- [x] Google Sign-In 実装
- [x] メール送信機能実装
- [x] 送信履歴管理実装
- [x] 1日1回送信制限実装
- [x] デバッグモード実装
- [x] flutter analyze クリーン
- [x] 全テスト合格

### Phase 2: ドキュメント整備
- [x] PRIVACY_POLICY.md 作成
- [x] OAUTH_VERIFICATION.md 作成
- [x] プライバシーポリシー公開・更新
  - **URL**: https://netplan.co.jp/library/waqu_repo/privacy/
  - **公開日**: 2025年10月16日
  - **更新日**: 2025年10月17日（アプリ名統一）
- [x] アプリホームページ公開・更新
  - **URL**: https://netplan.co.jp/library/waqu_repo/
  - **公開日**: 2025年10月16日
  - **更新日**: 2025年10月17日（アプリ目的・Gmail API使用理由を追加）
- [x] 独自ドメイン使用（推奨事項クリア）
- [x] アプリ名統一
  - **正式名称**: 水質検査報告アプリ `waqu_repo`
  - **英語表記**: Water Quality Reporter

### Phase 3: 審査準備
- [x] プライバシーポリシー要件確認
- [x] OAuth同意画面設定
- [x] Gmail APIスコープ設定（`gmail.send`）
- [x] アプリ情報整理
- [x] スコープ使用理由の改善版作成（`OAUTH_SCOPE_JUSTIFICATION.md`）
- [x] ホームページ要件対応（`OAUTH_HOMEPAGE_REQUIREMENTS.md`）

---

## 🎯 最優先タスク（今週中）

### ❗ デモ動画作成・提出

#### ステップ1: 撮影準備（今日）

**📝 重要ガイド**:
- `OAUTH_TEST_USERS_GUIDE.md` - テストユーザー追加方法
- `DEMO_VIDEO_PRIVACY_GUIDE.md` - プライバシー保護方法

- [ ] **テスト用Googleアカウント準備**
  - メールアドレス: waqu.demo@gmail.com（推奨）
  - アカウント名: Demo User
  - パスワード: 準備済み
  - プロフィール写真: デフォルト

- [ ] **OAuth同意画面でテストユーザー追加**
  - Google Cloud Console にアクセス
  - プロジェクト: waqu-repo-2025
  - OAuth同意画面 → テストユーザー
  - 「+ ADD USERS」をクリック
  - waqu.demo@gmail.com を追加
  - 「SAVE」をクリック

- [ ] **送信先メールアドレス準備**
  - 受信用アドレス: demo@example.com（架空でOK）

- [ ] **アプリで動作確認**
  - waqu.demo@gmail.com でサインイン
  - OAuth同意画面が表示される
  - 「許可」をタップできる
  - メール送信が成功する

- [ ] **アプリを最新版にビルド**
- [ ] **Firebase Functions 動作確認**

- [ ] **撮影環境準備**
  - 撮影デバイス: □ 実機（推奨） □ エミュレーター
  - 機種/バージョン: _______________

- [ ] **Android端末の設定**（実機の場合）
  - [ ] 通知をOFF（Do Not Disturb）
  - [ ] 画面明るさ最大
  - [ ] Wi-Fi接続確認
  - [ ] バッテリー充電済み
  - [ ] 画面録画機能の確認

#### ステップ2: 撮影（今日または明日）
- [ ] シーン1: サインイン＋OAuth同意画面（15秒）
- [ ] シーン2: 設定画面（20秒）
- [ ] シーン3: メール送信（30秒）
- [ ] シーン4: 送信履歴（15秒）
- [ ] シーン5: Gmail確認（15秒）
- [ ] 合計時間: 1分30秒以内

**撮影ガイド**: `OAUTH_DEMO_VIDEO_GUIDE.md` 参照

#### ステップ3: 編集（撮影後1-2日）
- [ ] イントロ追加（3秒）
  - タイトル: "Water Quality Reporter - OAuth Demo"
- [ ] テキストオーバーレイ追加
  - シーン1: "1. Google Sign-In with OAuth Consent"
  - シーン2: "2. Configure Email Settings"
  - シーン3: "3. Send Email via Gmail API"
  - シーン4: "4. View Send History"
  - シーン5: "5. Verify Sent Email in Gmail"
- [ ] アウトロ追加（2秒）
  - URL表示: https://netplan.co.jp/library/waqu_repo/
  - URL表示: https://netplan.co.jp/library/waqu_repo/privacy/
- [ ] 不要部分のカット
- [ ] 最終確認（画質、長さ、内容）

**編集ツール**:
- DaVinci Resolve（無料、推奨）
- iMovie（Mac）
- Clipchamp（オンライン）

#### ステップ4: YouTube公開（編集完了後）
- [ ] YouTubeアカウントにログイン
- [ ] 動画アップロード
  - タイトル: "Water Quality Reporter - OAuth Gmail API Demo"
  - 説明文: アプリ情報、URL記載
  - 公開範囲: **限定公開（Unlisted）**
  - タグ: gmail api, oauth, water quality, flutter, android
- [ ] サムネイル設定（任意）
- [ ] YouTube URL取得
  - URL: ______________________________

**重要**: 「非公開（Private）」にしないこと！審査担当者がアクセスできなくなります。

---

## 🔄 OAuth審査の再申請準備

**審査フィードバック対応**: 2025年10月16-17日

### 📋 再申請前チェックリスト

#### 1. ホームページの更新とデプロイ

- [x] `docs/index.md` の更新
  - アプリ名を「水質検査報告アプリ waqu_repo」に統一
  - 「アプリの目的」セクション追加
  - 「なぜGmail APIを使用するのか」セクション追加
  - 「使用する権限とその理由」セクション追加
  - データフロー図追加
  - 技術仕様追加

- [ ] Astroサイトへデプロイ
  - 更新版を本番環境にデプロイ
  - URL: https://netplan.co.jp/library/waqu_repo/

- [ ] デプロイ後の確認
  - [ ] アプリ名が統一されている
  - [ ] アプリの目的が明確に説明されている
  - [ ] Gmail APIの使用理由が説明されている
  - [ ] データフロー図が表示される

#### 2. Google Cloud Console の更新

詳細: `OAUTH_HOMEPAGE_REQUIREMENTS.md` 参照

- [ ] **アプリ名の統一**
  - Google Cloud Console → waqu-repo-2025 → OAuth同意画面
  - アプリ名: 水質検査報告アプリ waqu_repo
    または Water Quality Reporter

- [ ] **アプリの説明を更新**（英語推奨）
  ```
  Water Quality Reporter (waqu_repo) is a business application 
  for water facility workers in Japan to report daily residual 
  chlorine measurement results to facility managers via email, 
  as required by Japan's Water Supply Act.
  
  The app uses Gmail API (gmail.send scope only) to send 
  formatted measurement reports from workers' own Gmail accounts 
  to designated recipients, ensuring accountability and 
  regulatory compliance.
  ```

- [ ] **スコープ使用理由の更新**
  - `OAUTH_SCOPE_JUSTIFICATION.md` の改善版テキストを使用
  - gmail.send スコープの「理由」フィールドに貼り付け

- [ ] **ホームページURLの確認**
  - URL: https://netplan.co.jp/library/waqu_repo/
  - アクセス可能であることを確認

- [ ] **プライバシーポリシーURLの確認**
  - URL: https://netplan.co.jp/library/waqu_repo/privacy/
  - アクセス可能であることを確認

#### 3. デモ動画の準備（最優先）

- [ ] テストユーザー追加
- [ ] デモ動画撮影
- [ ] YouTube公開（限定公開）
- [ ] URL取得

#### 4. 再申請

- [ ] すべての変更を保存
- [ ] 「確認のため送信」または「再申請」ボタンをクリック
- [ ] 追加フォームに記入
  - YouTube動画URL
  - アプリの説明（上記の英語説明文）
  - スコープ使用理由（改善版テキスト）
- [ ] 送信
- [ ] 申請完了メールを受信
- [ ] 再申請日を記録: _______________

---

## 🔄 OAuth審査の再申請（スコープ理由の改善）- 参考

**審査フィードバック日**: 2025年10月16日  
**問題**: リクエストした OAuth スコープが必要な理由が十分に説明されていません

### 🎯 対応方法

詳細な改善版の説明文を作成しました：
- **ファイル**: `OAUTH_SCOPE_JUSTIFICATION.md`
- **内容**: 業務要件、代替手段がない理由、最小権限の原則、具体的使用シナリオ

### ステップ1: スコープ使用理由の更新（最優先）

- [ ] `OAUTH_SCOPE_JUSTIFICATION.md` を開く
- [ ] 「改善版：OAuth スコープ使用理由（英語版）」のテキストをコピー
- [ ] Google Cloud Console にアクセス
  - https://console.cloud.google.com/
- [ ] プロジェクト「waqu-repo-2025」を選択
- [ ] 「APIとサービス」→「OAuth同意画面」
- [ ] 「スコープ」セクションで gmail.send の「編集」をクリック
- [ ] 「理由」フィールドに改善版テキストを貼り付け
- [ ] 「保存」をクリック

### ステップ2: その他の必須情報を確認

- [ ] アプリ名: Water Quality Reporter
- [ ] アプリホームページ: https://netplan.co.jp/library/waqu_repo/
- [ ] プライバシーポリシーURL: https://netplan.co.jp/library/waqu_repo/privacy/
- [ ] ユーザーサポートメール: 設定済み確認
- [ ] デモ動画URL: YouTube（限定公開）で準備

### ステップ3: 追加資料の準備（推奨）

- [ ] データフロー図の作成（`OAUTH_SCOPE_JUSTIFICATION.md` 参照）
- [ ] スクリーンショットの準備:
  - OAuth同意画面（gmail.sendスコープ表示）
  - メール送信画面
  - Gmail送信済みフォルダ

### ステップ4: 再申請

- [ ] すべての変更を保存
- [ ] 「確認のため送信」または「再申請」ボタンをクリック
- [ ] 追加フォームに記入（YouTube URL、追加説明）
- [ ] 送信
- [ ] 申請完了メールを受信
- [ ] 再申請日を記録: _______________

---

## 📝 OAuth審査申請（初回申請用・参考）

### Google Cloud Console 設定

#### ステップ1: OAuth同意画面の最終確認
- [ ] Google Cloud Console にアクセス
  - https://console.cloud.google.com/
- [ ] プロジェクト選択: `waqu-repo` または対象プロジェクト
- [ ] 「APIとサービス」→「OAuth同意画面」

#### ステップ2: 必須情報の入力・確認
- [ ] **アプリ名**: Water Quality Reporter（または正式名）
- [ ] **ユーザーサポートメール**: _______________
- [ ] **アプリのロゴ**: 任意（推奨: 512x512 px）
- [ ] **アプリのホームページ**:
  ```
  https://netplan.co.jp/library/waqu_repo/
  ```
- [ ] **プライバシーポリシーURL**:
  ```
  https://netplan.co.jp/library/waqu_repo/privacy/
  ```
- [ ] **利用規約URL**: 任意（プライバシーポリシーと同一でも可）

#### ステップ3: スコープ設定確認
- [ ] 「スコープ」タブを開く
- [ ] 以下のスコープが登録されているか確認:
  ```
  https://www.googleapis.com/auth/gmail.send
  ```
- [ ] 他の不要なスコープがないか確認

#### ステップ4: テストユーザー設定（任意）
- [ ] テストユーザー追加
  - 開発用Googleアカウント
  - テスター用アカウント

#### ステップ5: 審査申請
- [ ] 「公開ステータス」を「本番環境」に変更
- [ ] 「確認のため送信」をクリック
- [ ] 追加情報フォームに記入:

**YouTube動画URL**:
```
https://www.youtube.com/watch?v=_______________
```

**アプリの説明（英語推奨）**:
```
This app helps water facility workers report residual chlorine 
measurements via email. It uses Gmail API's gmail.send scope 
to send reports from the user's own Gmail account to designated 
recipients.

The app:
- Does not read emails
- Does not modify emails  
- Only sends user-initiated measurement reports
- Stores data locally on device
- Uses Firebase Functions for secure email delivery

App Homepage: https://netplan.co.jp/library/waqu_repo/
Privacy Policy: https://netplan.co.jp/library/waqu_repo/privacy/
```

**Gmail APIの使用理由**:
```
Our app uses gmail.send scope to send water quality measurement 
reports from the user's Gmail account. Users can send reports 
to designated recipients (water facility managers) with measured 
residual chlorine data. This is essential for daily water quality 
monitoring in Japan's water supply facilities.
```

- [ ] 申請完了
- [ ] 確認メールを受信
- [ ] 申請日を記録: _______________

---

## ⏳ 審査待ち期間（4-6週間）

### この期間に実施すること

#### Play Store 準備
- [ ] Google Play Developer Account 登録
  - 登録料: $25（買い切り）
  - URL: https://play.google.com/console/signup
- [ ] ストア説明文作成
  - タイトル: 30文字以内
  - 簡単な説明: 80文字以内
  - 詳細な説明: 4000文字以内
- [ ] スクリーンショット撮影
  - 最低2枚、推奨8枚
  - サイズ: 各画面サイズに対応
- [ ] プロモーション画像作成
  - フィーチャーグラフィック: 1024 x 500 px
- [ ] アプリアイコン確認
  - 512 x 512 px（自動生成済み）

#### Android APK/AAB ビルド
- [ ] リリースキー生成
  ```bash
  keytool -genkey -v -keystore waqu-release-key.jks \
    -keyalg RSA -keysize 2048 -validity 10000 \
    -alias waqu-key-alias
  ```
- [ ] key.properties 設定
- [ ] build.gradle.kts 署名設定
- [ ] AAB ビルド
  ```bash
  flutter build appbundle --release
  ```
- [ ] ビルド成功確認

#### アプリ最終調整
- [ ] パフォーマンステスト
- [ ] UI/UX 改善
- [ ] バグ修正
- [ ] ドキュメント整備
- [ ] テスト実施（全10テスト）

---

## 📊 審査ステータス追跡

### 審査状況チェック

| 日付 | ステータス | 備考 |
|-----|----------|------|
| _____年__月__日 | 申請完了 | YouTube URL提出 |
| _____年__月__日 | 初回レビュー開始 | メール通知受信 |
| _____年__月__日 | 追加情報要求（もしあれば） | 対応内容：______ |
| _____年__月__日 | 最終審査 | - |
| _____年__月__日 | **承認** 🎉 | - |

### 審査結果の確認方法

```
Google Cloud Console:
1. 「APIとサービス」→「OAuth同意画面」
2. 「公開ステータス」を確認
   - 審査中: "Pending verification"
   - 承認: "Published"
   - 却下: "Rejected"（理由が表示される）

メール通知:
- 審査開始時
- 追加情報要求時
- 承認時
- 却下時（修正方法を含む）
```

---

## ⚠️ よくある却下理由と対策

### 却下理由1: プライバシーポリシー不備
```
問題: データ取り扱いの説明が不十分
対策: 
✅ すでに公開済み: https://netplan.co.jp/library/waqu_repo/privacy/
✅ Gmail APIスコープの詳細説明あり
✅ データフロー明記
✅ ユーザー権利の説明あり
```

### 却下理由2: デモ動画が不明瞭
```
問題: Gmail APIの使用目的が不明確
対策:
- OAuth同意画面を明確に表示
- メール送信の瞬間を録画
- 実際の送信メールを確認
- 各シーンにテキストオーバーレイ
```

### 却下理由3: スコープの正当性不足
```
問題: なぜgmail.sendが必要か説明不足
対策:
- 業務用途を明確に説明（水質報告）
- 代替手段がないことを示す
- ユーザーメリットを強調
```

### 却下理由4: ホームページ不備
```
問題: アプリ情報が不十分
対策:
✅ すでに公開済み: https://netplan.co.jp/library/waqu_repo/
推奨: スクリーンショット追加（審査中に対応可能）
```

---

## 🎉 審査承認後の作業

### ステップ1: OAuth同意画面の確認
- [ ] 公開ステータスが「Published」になっていることを確認
- [ ] 一般ユーザーがアプリを使用可能になったことを確認

### ステップ2: Play Store 公開
- [ ] Play Console にログイン
- [ ] 新しいアプリを作成
- [ ] ストア掲載情報入力
- [ ] AAB アップロード
- [ ] 審査申請
- [ ] 審査承認（1-3日）
- [ ] **一般公開** 🚀

### ステップ3: アプリホームページ更新
- [ ] ダウンロードリンク追加
  ```
  https://play.google.com/store/apps/details?id=jp.netplan.android.waqu_repo
  ```
- [ ] OAuth審査承認バッジ追加（任意）
- [ ] スクリーンショット追加

### ステップ4: ユーザーサポート体制
- [ ] お問い合わせフォーム動作確認
- [ ] サポートメール監視開始
- [ ] ユーザーレビュー監視

---

## 📅 タイムライン（想定）

```
Week 1 (今週):
- デモ動画撮影・編集
- YouTube公開
- OAuth審査申請

Week 2-7:
- OAuth審査待ち（4-6週間）
- Play Store 準備
- Android最終調整

Week 8:
- OAuth審査承認（予定）
- Play Store 審査申請

Week 9:
- Play Store 承認
- 一般公開 🎉
```

---

## 💡 ヒント

### デモ動画撮影のコツ
1. **OAuth同意画面を強調**（最重要）
2. **送信成功を明確に**（メッセージ表示）
3. **Gmailで確認**（実際のメールを見せる）
4. **テキストで補足**（各シーンにタイトル）

### 審査を早く通すために
1. **動画の品質を高める**（720p以上）
2. **説明文を詳しく**（英語推奨）
3. **プライバシーポリシーを充実**（✅完了）
4. **ホームページを整備**（✅完了）

### 追加情報要求に備えて
- スクリーンショットを事前準備
- アプリの詳細説明文を用意
- データフロー図を作成（任意）

---

## 🚀 次のアクション

### 今日中に実施
1. [ ] テスト用Googleアカウント準備
2. [ ] Android端末の設定確認
3. [ ] 撮影スクリプト確認（`OAUTH_DEMO_VIDEO_GUIDE.md`）

### 明日実施
1. [ ] デモ動画撮影（5シーン）
2. [ ] 動画編集開始

### 今週中に完了
1. [ ] YouTube公開
2. [ ] OAuth審査申請
3. [ ] 申請完了通知受信

---

**頑張ってください！デモ動画が鍵となります。**

ガイド参照:
- `OAUTH_DEMO_VIDEO_GUIDE.md` - 動画作成の詳細手順
- `OAUTH_VERIFICATION.md` - OAuth審査の全体像
- `PLAYSTORE.md` - Play Store公開準備
