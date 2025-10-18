# Play Store 素材準備状況

**更新日**: 2025年10月18日

## ✅ 完了済み

### リリースビルド
- [x] キーストア作成 (`~/waqu-release-key.jks`)
- [x] AABファイル生成 (`app-release.aab`, 44.1MB)

### アプリアイコン
- [x] 512x512 アイコン (`assets/icon/icon.png`)
- [x] 適応型アイコン設定完了

### ドキュメント
- [x] プライバシーポリシー (https://netplan.co.jp/library/waqu_repo/privacy/)
- [x] アプリホームページ (https://netplan.co.jp/library/waqu_repo/)

---

## 📝 準備中

### スクリーンショット（最低2枚必須）
- [ ] ホーム画面（メール送信画面）
- [ ] 設定画面
- [ ] 送信履歴画面
- [ ] サインイン画面（オプション）

**保存先**: `playstore_assets/screenshots/`  
**撮影ガイド**: `SCREENSHOT_GUIDE.md`

### フィーチャーグラフィック（1024x500）
- [ ] デザイン案作成
- [ ] 画像作成

**保存先**: `playstore_assets/feature_graphic.png`

---

## 🎯 次のアクション

### 今すぐ実施
1. **スクリーンショット撮影**
   - アプリを実機またはエミュレーターで起動
   - 各画面をキャプチャ（最低2枚）
   - `playstore_assets/screenshots/` に保存

2. **フィーチャーグラフィック作成**（オプションだが推奨）
   - サイズ: 1024 x 500 px
   - ツール: Canva, Figma, Adobe Express
   - 内容: アプリロゴ + キャッチフレーズ

### Google Play Console設定
3. **Developer Account登録**（未登録の場合）
   - URL: https://play.google.com/console/signup
   - 登録料: $25

4. **ストアリスティング作成**
   - アプリ名、説明文入力
   - カテゴリ選択（ビジネス）
   - 素材アップロード

5. **審査申請**

---

## 📊 進捗状況

```
リリースビルド準備:    100% ✅
ビジュアル素材準備:     30% 🔄
ストア情報準備:         50% 🔄
Play Console設定:        0% ⏸️
審査申請:                0% ⏸️
```

**推定残り時間**: 2-3時間（素材作成 + Console設定）

---

## 📁 ファイル構成

```
waqu_repo/
├── build/app/outputs/bundle/release/
│   └── app-release.aab          ✅ 完了
├── assets/icon/
│   ├── icon.png                 ✅ 完了
│   └── icon_foreground.png      ✅ 完了
├── playstore_assets/
│   ├── SCREENSHOT_GUIDE.md      ✅ 作成済み
│   ├── screenshots/             📝 準備中
│   │   ├── screenshot_01_home.png
│   │   ├── screenshot_02_settings.png
│   │   └── screenshot_03_history.png
│   └── feature_graphic.png      📝 準備中
└── PLAYSTORE.md                 ✅ 完了
```

---

**次は、スクリーンショットを撮影しましょう！**

アプリを起動して、`SCREENSHOT_GUIDE.md` の手順に従って撮影してください。
