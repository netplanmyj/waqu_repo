# Firebase iOS設定手順

**日時**: 2025年10月30日  
**Bundle ID**: `jp.netplan.ios.waquRepo`

---

## 🔥 Firebase Consoleでの操作手順

### ステップ1: Firebase Consoleにアクセス

1. https://console.firebase.google.com/ を開く
2. プロジェクト「**waqu-repo**」を選択

### ステップ2: iOSアプリを追加

1. プロジェクト概要画面で「**アプリを追加**」をクリック
2. 「**iOS**」アイコンを選択
3. 以下の情報を入力:

   ```
   Apple バンドル ID: jp.netplan.ios.waquRepo
   アプリのニックネーム: waqu_repo (iOS)
   App Store ID: (空欄でOK - 後で設定)
   ```

4. 「**アプリを登録**」をクリック

### ステップ3: GoogleService-Info.plist をダウンロード

1. `GoogleService-Info.plist` ファイルをダウンロード
2. ファイルを以下の場所に配置:

   ```bash
   # ダウンロードフォルダから移動
   cp ~/Downloads/GoogleService-Info.plist ios/Runner/
   ```

3. 配置確認:

   ```bash
   ls -la ios/Runner/GoogleService-Info.plist
   ```

### ステップ4: Firebase SDK（自動）

Flutter Firebaseパッケージが自動的に処理するため、手動での追加は不要です。

「**次へ**」をクリック → 「**コンソールに進む**」をクリック

---

## 📝 Info.plist設定

### REVERSED_CLIENT_ID の取得

`GoogleService-Info.plist` から `REVERSED_CLIENT_ID` を確認:

```bash
cd /Users/uedakazuaki/GitHub/Flutter/waqu_repo
grep -A1 REVERSED_CLIENT_ID ios/Runner/GoogleService-Info.plist
```

出力例:
```xml
<key>REVERSED_CLIENT_ID</key>
<string>com.googleusercontent.apps.123456789012-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx</string>
```

### Info.plist に URL Scheme を追加

`ios/Runner/Info.plist` を編集し、`</dict>` の直前に以下を追加:

```xml
<!-- Google Sign-In URL Scheme -->
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleTypeRole</key>
    <string>Editor</string>
    <key>CFBundleURLSchemes</key>
    <array>
      <!-- 上で取得した REVERSED_CLIENT_ID を記載 -->
      <string>com.googleusercontent.apps.123456789012-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx</string>
    </array>
  </dict>
</array>
```

---

## ✅ 設定完了の確認

### 1. ファイル配置確認

```bash
# GoogleService-Info.plist が存在すること
ls -la ios/Runner/GoogleService-Info.plist

# 出力例:
# -rw-r--r--  1 uedakazuaki  staff  856 Oct 30 15:30 ios/Runner/GoogleService-Info.plist
```

### 2. Info.plist確認

```bash
# CFBundleURLSchemes が設定されていること
grep -A5 CFBundleURLSchemes ios/Runner/Info.plist
```

### 3. ビルドテスト

```bash
# iOS Simulatorを起動
flutter emulators --launch apple_ios_simulator

# アプリをビルド
flutter run -d ios
```

---

## 🚨 トラブルシューティング

### 問題1: GoogleService-Info.plist が見つからない

**症状**:
```
Error: GoogleService-Info.plist file not found
```

**解決策**:
```bash
# ファイルが正しい場所にあるか確認
ls -la ios/Runner/GoogleService-Info.plist

# なければ再ダウンロードして配置
cp ~/Downloads/GoogleService-Info.plist ios/Runner/
```

---

### 問題2: Google Sign-In が失敗する

**症状**:
```
PlatformException(sign_in_failed, ...)
```

**解決策**:

1. **REVERSED_CLIENT_ID の確認**:
   ```bash
   grep -A1 REVERSED_CLIENT_ID ios/Runner/GoogleService-Info.plist
   ```

2. **Info.plist の確認**:
   ```bash
   grep -A5 CFBundleURLSchemes ios/Runner/Info.plist
   ```

3. **一致していることを確認**

---

### 問題3: Pod install でエラー

**症状**:
```
Error: CocoaPods not installed
```

**解決策**:
```bash
# CocoaPods をインストール
sudo gem install cocoapods

# 再度 pod install
cd ios
pod install
cd ..
```

---

## 📋 次のステップ

1. ✅ Firebase Console で iOS アプリ追加
2. ✅ GoogleService-Info.plist をダウンロード・配置
3. ✅ Info.plist に URL Scheme 追加
4. ⬜ iOS Simulator でテスト
5. ⬜ Google Sign-In 動作確認
6. ⬜ メール送信機能確認

---

**設定が完了したら、iOS Simulatorでアプリを起動してテストしてください！**
