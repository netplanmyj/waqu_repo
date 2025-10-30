# Xcode Cloud CI Scripts

## 概要

このディレクトリには、Xcode Cloud（Apple公式CI/CD）用のカスタムビルドスクリプトが含まれています。

## スクリプト

### `ci_post_clone.sh`

リポジトリクローン後に自動実行されるスクリプト。以下の処理を行います：

1. **Flutter SDK のインストール**
   - Xcode CloudにはFlutterが含まれていないため、stable版をクローン

2. **Firebase設定ファイルの注入**
   - 環境変数 `IOS_GOOGLE_SERVICE_INFO_PLIST` から `GoogleService-Info.plist` を生成
   - Base64デコードして `ios/Runner/` に配置

3. **依存関係のインストール**
   - `flutter pub get`: Dart/Flutter パッケージ
   - `pod install`: CocoaPods（iOS ネイティブ依存関係）

## Xcode Cloud の設定

### 1. 環境変数の設定

App Store Connect → Xcode Cloud → Workflows → Environment で以下を設定：

#### `IOS_GOOGLE_SERVICE_INFO_PLIST`
- **Type**: Secret
- **Value**: `ios/Runner/GoogleService-Info.plist` のBase64エンコード値

取得方法：
```bash
cat ios/Runner/GoogleService-Info.plist | base64 | pbcopy
```

### 2. Workflow の確認

Xcode Cloudは自動的に `ios/ci_scripts/ci_post_clone.sh` を検出・実行します。
手動設定は不要です。

## ローカルでのテスト

スクリプトをローカルで実行してテスト可能：

```bash
# 環境変数を設定
export CI_WORKSPACE="$HOME/xcode-cloud-test"
export CI_PRIMARY_REPOSITORY_PATH="$(pwd)"
export IOS_GOOGLE_SERVICE_INFO_PLIST="$(cat ios/Runner/GoogleService-Info.plist | base64)"

# スクリプト実行
./ios/ci_scripts/ci_post_clone.sh
```

## トラブルシューティング

### エラー: `Generated.xcconfig not found`
- 原因: `flutter pub get` が実行されていない
- 解決: スクリプトが正しく実行されているか確認

### エラー: `Pods-Runner-frameworks not found`
- 原因: `pod install` が実行されていない
- 解決: CocoaPodsのインストール処理を確認

### エラー: `GoogleService-Info.plist not found`
- 原因: 環境変数 `IOS_GOOGLE_SERVICE_INFO_PLIST` が設定されていない
- 解決: Xcode Cloud の Environment Variables で設定

## 参考資料

- [Xcode Cloud Custom Build Scripts](https://developer.apple.com/documentation/xcode/writing-custom-build-scripts)
- [Flutter on Xcode Cloud](https://docs.flutter.dev/deployment/cd#xcode-cloud)
