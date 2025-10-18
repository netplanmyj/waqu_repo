# Play Store 掲載準備 - 完了状況

**更新日**: 2025年10月18日  
**ステータス**: Play Console設定準備完了 ✅

---

## ✅ 完了済み

### 1. リリースビルド
- [x] キーストア作成 (`~/waqu-release-key.jks`)
- [x] SHA-1 フィンガープリント取得
- [x] Firebase に SHA-1 登録
- [x] Google Cloud Console に SHA-1 登録
- [x] `google-services.json` 更新
- [x] リリースビルド生成
  - **AAB**: `build/app/outputs/bundle/release/app-release.aab` (44.1MB)
  - **APK**: `build/app/outputs/flutter-apk/app-release.apk` (50.4MB)
- [x] Google Sign-In 動作確認済み ✅

### 2. ビジュアル素材
- [x] アプリアイコン (512x512) - `assets/icon/icon.png`
- [x] スクリーンショット (4枚) - `playstore_assets/screenshots/`
  - `1-signin.png` (205KB) - サインイン画面
  - `2-home.png` (146KB) - ホーム画面
  - `3-settings.png` (226KB) - 設定画面
  - `4-history.png` (122KB) - 送信履歴画面

### 3. ドキュメント
- [x] プライバシーポリシー
  - URL: https://netplan.co.jp/library/waqu_repo/privacy/
- [x] アプリホームページ
  - URL: https://netplan.co.jp/library/waqu_repo/

---

## 📝 準備中（オプション）

### フィーチャーグラフィック
- [ ] デザイン作成 (1024 x 500 px)
- [ ] 保存先: `playstore_assets/feature_graphic.png`

**注**: フィーチャーグラフィックはオプションですが、推奨されています。

---

## 🎯 次のステップ：Google Play Console 設定

### ステップ1: Developer Account 登録（未登録の場合）
- URL: https://play.google.com/console/signup
- 登録料: $25（一度だけ）

### ステップ2: 新しいアプリ作成

**基本情報**:
```
アプリ名: 水質検査報告アプリ
デフォルトの言語: 日本語（日本）
アプリまたはゲーム: アプリ
無料または有料: 無料
```

### ステップ3: ストアリスティング

#### アプリの詳細
**アプリ名** (30文字以内):
```
水質検査報告アプリ
```

**簡単な説明** (80文字以内):
```
水道施設の残留塩素測定値を管理者にメールで報告するビジネスアプリです。
```

**詳細な説明** (4000文字以内):
```
【概要】
水質検査報告アプリ（waqu_repo）は、水道施設の作業員が毎日の残留塩素測定結果を施設管理者にメールで報告するための業務用アプリケーションです。水道法に基づく日常的な水質管理業務を効率化します。

【主な機能】
• 残留塩素測定値の入力と送信
• Gmailアカウントを使用した安全なメール送信
• 送信履歴の確認
• 1日1回の送信制限（誤送信防止）
• デバッグモード（テスト用）

【対象ユーザー】
• 水道施設の作業員
• 簡易水道管理者
• ビル・マンション管理者

【使用方法】
1. Googleアカウントでサインイン
2. 設定画面で送信先メールアドレスを登録
3. 測定時刻と残留塩素値を入力
4. 送信ボタンをタップ
5. 指定したメールアドレスに測定報告が送信されます

【セキュリティとプライバシー】
• データはデバイス内にのみ保存
• Gmail APIを使用した安全な送信
• 送信スコープのみ使用（メール読み取りなし）
• プライバシーポリシー: https://netplan.co.jp/library/waqu_repo/privacy/

【必要な権限】
• インターネット接続（メール送信）
• Googleアカウント認証（Gmail API使用）

【サポート】
お問い合わせ: https://netplan.co.jp/library/waqu_repo/
```

#### グラフィック
- **アプリアイコン**: `assets/icon/icon.png` ✅
- **スクリーンショット**: `playstore_assets/screenshots/` ✅
  - 1-signin.png
  - 2-home.png
  - 3-settings.png
  - 4-history.png
- **フィーチャーグラフィック**: （オプション）

#### カテゴリ
```
カテゴリ: ビジネス
タグ: 業務効率化, 水質管理, 報告ツール
```

#### 連絡先
```
メール: （あなたのメールアドレス）
ウェブサイト: https://netplan.co.jp/library/waqu_repo/
プライバシーポリシー: https://netplan.co.jp/library/waqu_repo/privacy/
```

### ステップ4: コンテンツレーティング
```
対象年齢: 18歳以上（業務用）
広告: なし
アプリ内購入: なし
```

### ステップ5: データセーフティ
```
収集するデータ:
• メールアドレス（送信先設定用）
• 測定データ（残留塩素値、測定時刻）

保存場所: デバイスのローカルストレージのみ
共有: なし（Gmailでの送信を除く）
暗号化: SharedPreferencesを使用
削除: アプリアンインストール時に自動削除
```

### ステップ6: リリース
1. 「本番」トラックを選択
2. 「リリースを作成」をクリック
3. AABファイルをアップロード
   - ファイル: `build/app/outputs/bundle/release/app-release.aab`
4. リリースノートを入力:
   ```
   初回リリース
   
   主な機能：
   • 残留塩素測定値のメール送信
   • 送信履歴の確認
   • 1日1回の送信制限
   ```
5. 「審査に提出」をクリック

---

## ⏰ タイムライン

```
今日 (10/18):
✅ リリースビルド完成
✅ Google Sign-In 動作確認
✅ スクリーンショット撮影完了

次のステップ:
□ Google Play Console でアプリ作成
□ ストアリスティング入力
□ AAB アップロード
□ 審査申請

審査期間:
通常 1-3日（最大7日）

公開:
審査承認後、数時間以内に Play Store に表示
```

---

## 📊 進捗状況

```
リリースビルド:      100% ✅
ビジュアル素材:       80% ✅ (フィーチャーグラフィックはオプション)
ドキュメント:        100% ✅
Play Console設定:     0% ⏸️
審査申請:             0% ⏸️
```

---

## 🎉 本日の成果

1. リリース用キーストア作成
2. SHA-1 を Firebase / Google Cloud に登録
3. Google Sign-In をリリースビルドで動作確認
4. Play Store用スクリーンショット 4枚撮影完了
5. リリースビルド (AAB) 準備完了

**残り作業**: Play Console でのアプリ登録と審査申請のみ！

---

## 📞 次回のアクション

1. **Google Play Developer Account 登録**（未登録の場合）
2. **Play Console でアプリ作成**
3. **ストアリスティング入力**（上記のテキストを使用）
4. **AAB アップロード**
5. **審査申請**

**準備ができたら、いつでもサポートします！** 🚀
