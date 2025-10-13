# Firebase設定手順

## 1. Firebase Console設定

### Step 1: Firebase プロジェクトの作成・設定

1. [Firebase Console](https://console.firebase.google.com/) にアクセス
2. プロジェクトを作成（既存のプロジェクトがある場合はそれを使用）
3. Authentication → Sign-in method → Google を有効化

### Step 2: Android アプリの追加・設定

1. プロジェクト設定 → アプリの追加 → Android
2. Androidパッケージ名を設定: `com.example.waqu_repo`（実際のパッケージ名に合わせる）
3. `google-services.json` ファイルをダウンロード
4. `android/app/` フォルダに配置

### Step 3: Google Cloud Console設定

1. [Google Cloud Console](https://console.cloud.google.com/) で同じプロジェクトを開く
2. 「APIとサービス」→「ライブラリ」から「Gmail API」を検索
3. Gmail APIを有効化
4. 「認証情報」→「OAuth同意画面」を設定:
   - アプリケーション名: `水質報告アプリ`
   - ユーザーサポートメール: あなたのメールアドレス
   - スコープに `../auth/gmail.send` を追加
   - テストユーザーにあなたのGoogleアカウントを追加

### Step 4: SHA-1フィンガープリントの追加

1. ターミナルで以下を実行してSHA-1を取得:
```bash
cd android
./gradlew signingReport
```

2. Firebase Console → プロジェクト設定 → アプリ → Android アプリ
3. SHA証明書フィンガープリントを追加

## 2. Firebase設定ファイルのテンプレート

android/app/google-services.jsonが必要です。
実際のFirebaseプロジェクトから取得して配置してください。

## 3. 完了チェックリスト

- [ ] Firebase Authenticationが有効
- [ ] Google Sign-inプロバイダーが有効
- [ ] gmail.sendスコープが OAuth同意画面に設定済み
- [ ] テストユーザーが登録済み
- [ ] google-services.jsonファイルが配置済み
- [ ] Gmail APIが有効化済み
- [ ] SHA-1フィンガープリントが登録済み

## 次のステップ

Firebase Functions側の実装に進みます。