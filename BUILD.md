# APKビルド手順書

この手順書では、水質報告アプリのAndroid APKファイルをビルドする方法を説明します。

## 🛠️ 事前準備

### 必要な環境
- **Flutter SDK**: 3.24.0以上
- **Dart SDK**: 3.5.0以上
- **Android Studio**: 最新版
- **JDK**: 11以上

### 環境確認
```bash
flutter doctor
```

すべての項目にチェックマークが付いていることを確認してください。

## 📱 APKビルド手順

### ステップ1: プロジェクトのクローン

```bash
git clone <repository-url>
cd wq_report
```

### ステップ2: 依存関係のインストール

```bash
flutter pub get
```

### ステップ3: アプリの動作確認

```bash
# デバッグ版で動作確認
flutter run
```

### ステップ4: リリース用APKのビルド

```bash
# リリース用APKビルド
flutter build apk --release
```

ビルドが完了すると、以下の場所にAPKファイルが生成されます：
```
build/app/outputs/flutter-apk/app-release.apk
```

### ステップ5: APKファイルの確認

生成されたAPKファイルの詳細を確認：

```bash
# APKファイルのサイズと場所を確認
ls -la build/app/outputs/flutter-apk/
```

## 📦 配布用APKの準備

### APKファイルの名前変更

わかりやすい名前に変更：

```bash
cp build/app/outputs/flutter-apk/app-release.apk wq_report_v1.0.0.apk
```

### APKファイルの動作テスト

1. **Androidデバイスでのテスト**
   - APKファイルをAndroidデバイスに転送
   - 「提供元不明のアプリ」のインストールを許可
   - APKをインストールして動作確認

2. **主な確認項目**
   - アプリが正常に起動する
   - 設定画面で各項目が入力できる
   - デバッグモードでのテスト送信が成功する

## 🔧 トラブルシューティング

### よくある問題と解決方法

#### 1. ビルドエラー: "Flutter SDK not found"
```bash
# Flutter SDKのパスを確認
flutter doctor -v

# パスが正しく設定されていない場合
export PATH="$PATH:`pwd`/flutter/bin"
```

#### 2. ビルドエラー: "Android SDK not found"
```bash
# Android SDKのパスを設定
export ANDROID_HOME=/path/to/android/sdk
export PATH=$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools
```

#### 3. ビルドエラー: "Gradle build failed"
```bash
# Gradleキャッシュをクリア
flutter clean
flutter pub get
flutter build apk --release
```

#### 4. APKのサイズが大きい
```bash
# アーキテクチャ別にビルド（サイズ削減）
flutter build apk --split-per-abi --release
```

これにより、以下のファイルが生成されます：
- `app-arm64-v8a-release.apk` (64bit ARM)
- `app-armeabi-v7a-release.apk` (32bit ARM)
- `app-x86_64-release.apk` (64bit x86)

## 📋 ビルド設定のカスタマイズ

### アプリバージョンの変更

`pubspec.yaml`ファイルを編集：

```yaml
version: 1.0.0+1
```

### アプリ名の変更

`android/app/src/main/AndroidManifest.xml`を編集：

```xml
<application
    android:label="水質報告アプリ"
    ...>
```

### アプリアイコンの変更

1. `android/app/src/main/res/`の各ディレクトリにアイコンファイルを配置
2. または`flutter_launcher_icons`パッケージを使用

## 🚀 配布準備

### 配布用ファイル構成

```
wq_report-release/
├── wq_report_v1.0.0.apk    # メインAPKファイル
├── INSTALL.md              # インストール手順書
├── DEPLOY.md               # GAS設定手順書
├── gas/                    # GASコードファイル
│   ├── Code.gs
│   ├── appsscript.json
│   └── README.md
└── README.md               # プロジェクト概要
```

### インストール手順書の作成

利用者向けのAPKインストール手順を作成：

```markdown
# Android APKインストール手順

1. APKファイルをダウンロード
2. Androidデバイスで「提供元不明のアプリ」を許可
3. APKファイルをタップしてインストール
4. DEPLOY.mdに従ってGASを設定
5. アプリで初期設定を完了
```

## 📊 配布戦略

### 配布方法の選択肢

1. **直接配布**
   - APKファイルを直接配布
   - 最もシンプルで確実

2. **GitHubリリース**
   - GitHub Releasesページで配布
   - バージョン管理が容易

3. **組織内配布**
   - 社内サーバーでの配布
   - アクセス制御が可能

### セキュリティ考慮事項

- APKファイルの署名確認
- 配布チャネルの信頼性
- 定期的なセキュリティ更新

## 🔄 継続的ビルド

### 自動ビルドの設定

GitHub Actionsを使用した自動ビルドの例：

```yaml
name: Build APK
on:
  push:
    tags:
      - 'v*'

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v2
    - uses: actions/setup-java@v1
      with:
        java-version: '11'
    - uses: subosito/flutter-action@v1
      with:
        flutter-version: '3.24.0'
    - run: flutter pub get
    - run: flutter build apk --release
    - uses: actions/upload-artifact@v2
      with:
        name: release-apk
        path: build/app/outputs/flutter-apk/app-release.apk
```

---

**✅ APKビルド完了！**

これで水質報告アプリの配布用APKファイルが準備できました。