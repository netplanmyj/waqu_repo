# iOS版セットアップ手順

**目標**: App Storeでのリリース実績達成  
**戦略**: 無料・広告なし、最短ルートでの公開

---

## 前提条件

### 必須環境
- ✅ Apple Developer Program登録（$99/年）
- ✅ macOS環境（実機 or クラウド）
- ✅ Xcode最新版
- ✅ Flutter/Dart環境（既存）

### 現在の状態
- ✅ Android版コードはクロスプラットフォーム対応済み
- ✅ 使用パッケージ全てがiOS対応
- ✅ Platform固有のコードなし
- ✅ アイコン素材準備済み（`assets/icon/icon.png`）

---

## ステップ1: pubspec.yaml更新

### 変更内容

```yaml
# アプリアイコン自動生成設定
flutter_launcher_icons:
  android: true
  ios: true  # ← falseからtrueに変更
  image_path: "assets/icon/icon.png"
  
  # iOS設定を追加
  remove_alpha_ios: true
  ios_content_rendering: "original"
  
  # Android適応型アイコン（既存設定）
  adaptive_icon_foreground: "assets/icon/icon_foreground.png"
  adaptive_icon_background: "#2196F3"
  android_gravity: "center"
  android_min_sdk_android: 24
```

### 実行コマンド

```bash
# pubspec.yaml編集後
flutter pub get
flutter pub run flutter_launcher_icons

# 確認
ls -la ios/Runner/Assets.xcassets/AppIcon.appiconset/
```

---

## ステップ2: Firebase iOS設定

### 2-1. Firebase Console操作

1. https://console.firebase.google.com/ にアクセス
2. プロジェクト「waqu-repo」を選択
3. 「アプリを追加」→「iOS」を選択
4. **Bundle ID**: `jp.netplan.ios.waquRepo`（推奨）
   - Android版: `jp.netplan.android.waqu_repo`
   - iOS版: `jp.netplan.ios.waquRepo`（命名規則に準拠）
5. `GoogleService-Info.plist` をダウンロード

### 2-2. ファイル配置

```bash
# ダウンロードしたファイルを配置
cp ~/Downloads/GoogleService-Info.plist ios/Runner/
```

### 2-3. Xcodeで確認

```bash
# Xcodeでプロジェクトを開く
open ios/Runner.xcworkspace

# 確認項目:
# 1. GoogleService-Info.plist が Runner フォルダに存在
# 2. Target Membership で Runner にチェックが入っている
```

---

## ステップ3: Info.plist設定

### 3-1. Google Sign-In URL Scheme追加

`ios/Runner/Info.plist` に以下を追加:

```xml
<!-- 既存の </dict> の直前に追加 -->

<!-- Google Sign-In URL Scheme -->
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleTypeRole</key>
    <string>Editor</string>
    <key>CFBundleURLSchemes</key>
    <array>
      <!-- GoogleService-Info.plist の REVERSED_CLIENT_ID を記載 -->
      <string>com.googleusercontent.apps.XXXXXXXXXXX-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX</string>
    </array>
  </dict>
</array>

<!-- 権限の説明（任意だが推奨） -->
<key>NSPhotoLibraryUsageDescription</key>
<string>アプリアイコンの表示に使用します</string>
```

### 3-2. REVERSED_CLIENT_ID の取得方法

```bash
# GoogleService-Info.plist から取得
grep -A1 REVERSED_CLIENT_ID ios/Runner/GoogleService-Info.plist

# 出力例:
# <key>REVERSED_CLIENT_ID</key>
# <string>com.googleusercontent.apps.123456789012-abcdefghijklmnopqrstuvwxyz123456</string>
```

### 3-3. Bundle Identifier設定

Xcodeで設定:

1. `ios/Runner.xcworkspace` を開く
2. 左側のナビゲーターで「Runner」プロジェクトを選択
3. 「TARGETS」→「Runner」を選択
4. 「General」タブ
5. **Bundle Identifier**: `jp.netplan.ios.waquRepo` に設定

---

## ステップ4: ビルドとテスト

### 4-1. CocoaPods依存関係インストール

```bash
cd ios
pod install
cd ..
```

### 4-2. iOS Simulatorでテスト

```bash
# iPhone 15 Pro Simulatorで起動
flutter run -d 'iPhone 15 Pro'

# または利用可能なデバイス一覧から選択
flutter devices
flutter run -d <device_id>
```

### 4-3. テスト項目

- [ ] Google Sign-In が正常に動作
- [ ] メール送信が成功
- [ ] 設定の保存・読み込みが正常
- [ ] 履歴機能が正常
- [ ] UI表示が崩れていない

### 4-4. 実機テスト（推奨）

```bash
# 実機接続後
flutter run -d <iPhone_device_id>

# リリースビルドでテスト
flutter run --release -d <iPhone_device_id>
```

---

## ステップ5: App Store準備

### 5-1. スクリーンショット撮影

**必須サイズ**:
- 6.7インチ（iPhone 15 Pro Max等）: 1290 x 2796 px

**推奨枚数**: 3-5枚

**撮影画面例**:
1. ホーム画面（メール送信画面）
2. 設定画面（メール件名カスタマイズ）
3. 履歴画面
4. 送信中の状態
5. 送信完了の状態

```bash
# Simulatorで撮影
# Cmd + S でスクリーンショット
# 保存先: ~/Desktop
```

### 5-2. App Store掲載情報

**アプリ名** (30文字以内):
```
水質報告（Waqu）
```

**サブタイトル** (30文字以内):
```
水道業界向けメール送信ツール
```

**説明文** (4000文字以内):
```
【概要】
水質報告（Waqu）は、水道業界の業務効率化を支援する無料アプリです。
日々の水質検査報告をメールで簡単に送信できます。

【主な機能】
✅ Googleアカウントで簡単ログイン
✅ 水質データの入力と即座にメール送信
✅ メール件名のカスタマイズ
✅ 送信履歴の確認
✅ シンプルで使いやすいUI

【特徴】
- 完全無料・広告なし
- プライバシー保護（データは端末にのみ保存）
- オフライン対応（入力データはローカル保存）
- Android版との完全互換性

【対象ユーザー】
- 水道事業体の職員
- 水質検査業務担当者
- 水道施設管理者

【サポート】
ご質問やお問い合わせは、サポートURLからお気軽にご連絡ください。
```

**キーワード** (100文字以内、カンマ区切り):
```
水質,水道,報告,メール,業務,検査,自治体,公共,ユーティリティ
```

**カテゴリ**:
- プライマリ: Utilities
- セカンダリ: Productivity

**価格**: 無料

---

## ステップ6: App Store Connect設定

### 6-1. 新規App作成

1. https://appstoreconnect.apple.com/ にアクセス
2. 「マイApp」→「+」→「新規App」
3. 設定項目:
   - **プラットフォーム**: iOS
   - **名前**: 水質報告（Waqu）
   - **プライマリ言語**: 日本語
   - **Bundle ID**: jp.netplan.ios.waquRepo
   - **SKU**: waqu-repo-ios（任意の一意な識別子）
   - **ユーザーアクセス**: フルアクセス

### 6-2. App情報

- **プライバシーポリシーURL**: https://yourdon.com/waqu/privacy-policy.html
- **サポートURL**: https://yourdomain.com/waqu/
- **マーケティングURL**: https://github.com/netplanmyj/waqu_repo

### 6-3. 年齢制限

- **年齢レーティング**: 4+（すべての年齢層）

---

## ステップ7: ビルドとアップロード

### 7-1. リリースビルド

```bash
# Flutterでビルド
flutter build ios --release

# または Xcodeで Archive
open ios/Runner.xcworkspace
# Product → Archive
```

### 7-2. App Store Connect へアップロード

**方法1: Xcodeから**
```
1. Xcode → Window → Organizer
2. Archivesタブで最新のArchiveを選択
3. 「Distribute App」
4. 「App Store Connect」を選択
5. 「Upload」
6. 証明書とプロファイルを自動管理
```

**方法2: CLIから（Transporter使用）**
```bash
# .ipa ファイルをエクスポート後
# Transporter アプリでアップロード
open -a Transporter
```

### 7-3. TestFlight（任意だが推奨）

```
1. App Store Connect で「TestFlight」タブ
2. 「内部テスト」グループに自分を追加
3. iPhone に TestFlight アプリをインストール
4. 招待を受け取りアプリをテスト
5. バグがなければ審査提出へ
```

---

## ステップ8: 審査申請

### 8-1. App Store Connect で設定

1. **バージョン情報**
   - バージョン番号: 1.0.0
   - ビルド番号: 15（Android版と同じ）

2. **スクリーンショット**
   - 6.7インチ: 3-5枚アップロード

3. **説明とキーワード**
   - ステップ5-2の内容を入力

4. **デモアカウント**（重要！）
   ```
   メールアドレス: waqu.reviewer@gmail.com
   パスワード: ReviewPass2024
   
   備考: Google Sign-In で認証してください。
   Firebase Authentication に事前登録済みです。
   ```

### 8-2. 審査申請

1. 「審査に提出」ボタンをクリック
2. Export Compliance の質問に回答
   - 暗号化の使用: Yes（HTTPS通信のため）
   - 暗号化の免除: Yes（標準的なHTTPSのみ）

3. **審査期間**: 通常1-2週間
   - 状態: 審査待ち → 審査中 → 承認 or リジェクト

### 8-3. リジェクト時の対応

**よくあるリジェクト理由**:

1. **デモアカウントが動作しない**
   → Firebase Authenticationに `waqu.reviewer@gmail.com` が登録されているか確認

2. **プライバシーポリシーURLが無効**
   → URLが有効でアクセス可能か確認

3. **アプリの説明が不明確**
   → 使用方法を具体的に記載

4. **最小機能要件を満たしていない**
   → 現在の機能で十分（メール送信、設定、履歴）

**対応手順**:
1. リジェクト理由を確認
2. 必要に応じて修正
3. 再ビルド・再アップロード
4. 「審査に再提出」

---

## ステップ9: 公開

### 9-1. 承認後の対応

```
承認通知受領
  ↓
「バージョンをリリース」をクリック
  ↓
App Store に公開（数時間以内）
  ↓
🎉 iOS版リリース完了！
```

### 9-2. 確認項目

- [ ] App Store でアプリが検索可能
- [ ] ダウンロード可能
- [ ] Google Sign-In が正常動作
- [ ] メール送信機能が正常
- [ ] 設定・履歴機能が正常

---

## トラブルシューティング

### 問題1: Google Sign-In が失敗する

**原因**: REVERSED_CLIENT_ID が正しく設定されていない

**解決策**:
```bash
# Info.plist を確認
cat ios/Runner/Info.plist | grep -A3 CFBundleURLSchemes

# GoogleService-Info.plist の REVERSED_CLIENT_ID と一致しているか確認
```

### 問題2: ビルドエラー「CocoaPods not installed」

**解決策**:
```bash
# CocoaPods をインストール
sudo gem install cocoapods

# 依存関係を再インストール
cd ios
pod install
cd ..
```

### 問題3: 審査で「Guideline 4.0 - Design」リジェクト

**原因**: アプリの機能が最小限すぎると判断された

**解決策**:
- 説明文でアプリの価値を明確に記載
- スクリーンショットで使用方法を具体的に示す
- 水道業界向けの専門ツールであることを強調

---

## コスト試算

### 初期費用
```
Apple Developer Program: $99（年間、初回）
Mac環境（選択肢）:
  - Mac mini: 約 $600-800
  - MacBook Air: 約 $1,000-1,200
  - クラウドMac (月額): $100-200
  - CI/CDサービス (月額): $0-100

合計: $699 - $1,299（Mac購入の場合）
```

### 年間ランニングコスト
```
Apple Developer Program: $99/年
Mac環境: $0（買い切りの場合）or $1,200-2,400/年（クラウド）
Firebase Functions: $0（無料枠内）
GitHub Actions: $0（Public repository）

合計: $99 - $2,499/年
```

---

## まとめ

### ✅ iOS版の利点

1. **技術的難易度は低い**: コードは既にiOS対応済み
2. **審査実績の獲得**: App Storeでの公開経験を得られる
3. **Android版との統一**: 無料・広告なしで一貫性
4. **市場の30%をカバー**: iOS使用の自治体にも対応可能

### ⚠️ 注意点

1. **初期投資必要**: 最低$699（Apple Developer + Mac環境）
2. **審査期間が長い**: 1-2週間（Android版の1-3日と比較）
3. **Mac環境必須**: Xcodeはmacでのみ動作

### 🎯 次のアクション

1. Apple Developer Program登録
2. Mac環境準備（実機購入 or クラウド契約）
3. このドキュメント通りに設定・ビルド・提出
4. 審査待ち（1-2週間）
5. 🎉 App Store公開！

**目標達成まで**: 約4-6週間（環境準備含む）
