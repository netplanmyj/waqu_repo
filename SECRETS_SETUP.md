# GitHub Secrets セットアップガイド

## 概要

このプロジェクトでは、Firebase設定ファイル（APIキーを含む）をGitリポジトリに含めず、GitHub Secretsを使用してCI/CD環境に注入します。

## なぜGitHub Secretsを使うのか？

- **セキュリティ**: APIキーなどの機密情報をリポジトリに含めない
- **柔軟性**: 環境ごとに異なる設定を使用可能
- **安全性**: GitHub Security AlertsでAPIキー漏洩を検知されない

## 必要なSecrets

### 1. `GOOGLE_SERVICES_JSON` (Android用)

**ファイル**: `android/app/google-services.json`

#### 設定手順

1. Firebase Consoleから最新の`google-services.json`をダウンロード
2. Base64エンコード:
   ```bash
   cat android/app/google-services.json | base64 | pbcopy
   ```
   （macOSの場合 - クリップボードにコピーされます）

   Linuxの場合:
   ```bash
   cat android/app/google-services.json | base64 -w 0
   ```

3. GitHubリポジトリの設定:
   - Settings → Secrets and variables → Actions
   - "New repository secret" をクリック
   - Name: `GOOGLE_SERVICES_JSON`
   - Secret: （上記でコピーしたBase64文字列を貼り付け）
   - "Add secret" をクリック

### 2. `IOS_GOOGLE_SERVICE_INFO_PLIST` (iOS用)

**ファイル**: `ios/Runner/GoogleService-Info.plist`

#### 設定手順

1. Firebase Consoleから最新の`GoogleService-Info.plist`をダウンロード
2. Base64エンコード:
   ```bash
   cat ios/Runner/GoogleService-Info.plist | base64 | pbcopy
   ```
   （macOSの場合 - クリップボードにコピーされます）

   Linuxの場合:
   ```bash
   cat ios/Runner/GoogleService-Info.plist | base64 -w 0
   ```

3. GitHubリポジトリの設定:
   - Settings → Secrets and variables → Actions
   - "New repository secret" をクリック
   - Name: `IOS_GOOGLE_SERVICE_INFO_PLIST`
   - Secret: （上記でコピーしたBase64文字列を貼り付け）
   - "Add secret" をクリック

## ローカル開発環境のセットアップ

### 新しい開発者がプロジェクトをクローンした場合

1. Firebase Consoleにアクセス
2. プロジェクト設定 → 全般 → マイアプリ
3. Android版とiOS版の設定ファイルをダウンロード:
   - Android: `google-services.json` → `android/app/google-services.json`
   - iOS: `GoogleService-Info.plist` → `ios/Runner/GoogleService-Info.plist`

4. これらのファイルは`.gitignore`に含まれているため、Gitにコミットされません

## CI/CDでの動作確認

GitHub Actionsワークフロー（`.github/workflows/ci.yml`）では、以下のステップで自動的に設定ファイルが注入されます:

```yaml
- name: Setup Firebase config files
  env:
    GOOGLE_SERVICES_JSON: ${{ secrets.GOOGLE_SERVICES_JSON }}
    IOS_GOOGLE_SERVICE_INFO_PLIST: ${{ secrets.IOS_GOOGLE_SERVICE_INFO_PLIST }}
  run: |
    echo "$GOOGLE_SERVICES_JSON" | base64 -d > android/app/google-services.json
    echo "$IOS_GOOGLE_SERVICE_INFO_PLIST" | base64 -d > ios/Runner/GoogleService-Info.plist
```

## トラブルシューティング

### CIでエラーが出る場合

1. **Secretsが設定されているか確認**:
   - GitHubリポジトリ → Settings → Secrets and variables → Actions
   - `GOOGLE_SERVICES_JSON` と `IOS_GOOGLE_SERVICE_INFO_PLIST` が存在するか確認

2. **Base64エンコードが正しいか確認**:
   ```bash
   # デコードして内容を確認
   echo "YOUR_BASE64_STRING" | base64 -d
   ```

3. **ファイルが正しい場所に配置されているか確認**:
   - Android: `android/app/google-services.json`
   - iOS: `ios/Runner/GoogleService-Info.plist`

### ローカルでビルドできない場合

1. Firebase設定ファイルが存在するか確認:
   ```bash
   ls -la android/app/google-services.json
   ls -la ios/Runner/GoogleService-Info.plist
   ```

2. 存在しない場合は、Firebase Consoleから再ダウンロード

## セキュリティ上の注意

- **絶対にGitにコミットしないこと**: これらのファイルには機密情報（APIキー）が含まれています
- **定期的な更新**: APIキーを定期的にローテーション（無効化→新規作成）することを推奨
- **アクセス制限**: Firebase ConsoleでAPIキーに適切な制限を設定

## 参考資料

- [GitHub Encrypted secrets](https://docs.github.com/en/actions/security-guides/encrypted-secrets)
- [Firebase Console](https://console.firebase.google.com/)
- [Flutter Firebase Setup](https://firebase.google.com/docs/flutter/setup)
