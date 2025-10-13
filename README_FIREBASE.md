# WAQU水質報告アプリ - Firebase Functions版

> **重要**: このブランチ（2-oauth）では、メール送信がGAS（Google Apps Script）からFirebase Functions + Gmail APIに移行されています。

## 🔥 主な変更点

### 1. Google認証の実装
- Firebase Authentication + Google Sign-Inを使用
- Gmail API送信権限（`gmail.send`スコープ）を含む認証フロー
- ユーザーのGoogleアカウントから直接メールを送信

### 2. Firebase Functionsによるメール送信
- Node.js/TypeScriptで実装されたサーバーレス関数
- Gmail APIを使用した安全なメール送信
- アクセストークンベースの認証

### 3. 簡素化されたユーザー体験
- **GASのデプロイ作業が不要**
- アプリ内でのGoogle認証のみで完結
- 設定画面からGAS URL設定を削除

## 🛠 開発者向け設定手順

### 前提条件
- Firebase CLIがインストール済み
- Node.js 20+
- Flutter SDK

### 1. Firebase プロジェクト設定

```bash
# Firebase CLIでログイン
firebase login

# プロジェクトを初期化（既存プロジェクトを使用）
firebase use your-firebase-project-id
```

### 2. Firebase Functions のデプロイ

```bash
# Functionsディレクトリに移動
cd functions

# 依存関係のインストール
npm install

# ビルド
npm run build

# デプロイ
firebase deploy --only functions
```

### 3. Google Cloud Console設定

1. [Google Cloud Console](https://console.cloud.google.com/)でプロジェクトを開く
2. Gmail APIを有効化
3. OAuth同意画面でgmail.sendスコープを追加
4. テストユーザーを登録

### 4. Android設定

```bash
# SHA-1フィンガープリントを取得
cd android
./gradlew signingReport
```

取得したSHA-1をFirebase ConsoleのAndroidアプリ設定に追加

### 5. google-services.jsonの配置

Firebase Consoleからダウンロードした`google-services.json`を`android/app/`に配置

## 📱 アプリの使用方法

### 初回起動時
1. アプリを起動
2. 「Googleでサインイン」をタップ
3. Googleアカウントを選択
4. Gmail送信権限を許可
5. 設定画面で送信先メールアドレスを設定

### 日常的な使用
1. 測定データを入力
2. 「水質報告メール送信」をタップ
3. 自動的にメールが送信される

## 🔍 技術仕様

### アーキテクチャ
```
Flutter App → Firebase Auth → Firebase Functions → Gmail API
```

### 主要パッケージ
- `firebase_core`: Firebase初期化
- `firebase_auth`: Google認証
- `google_sign_in`: Googleサインイン
- `cloud_functions`: Functions呼び出し
- `googleapis_auth`: Gmail APIアクセス

### セキュリティ
- OAuth 2.0による安全な認証
- アクセストークンの適切な管理
- Firebase Functionsでのサーバーサイド検証

## 🐛 トラブルシューティング

### よくある問題

#### 1. 認証エラー
```
Firebase Auth エラー: 認証に失敗しました
```
**解決方法**: 
- SHA-1フィンガープリントがFirebase Consoleに正しく登録されているか確認
- google-services.jsonが正しく配置されているか確認

#### 2. Gmail API権限エラー
```
permission-denied: Gmail送信権限がありません
```
**解決方法**:
- OAuth同意画面でgmail.sendスコープが追加されているか確認
- 一度サインアウトして再認証

#### 3. Firebase Functions呼び出しエラー
```
FirebaseFunctionsException: internal
```
**解決方法**:
- Firebase Functionsが正しくデプロイされているか確認
- Firebase Consoleでエラーログを確認

## 📁 プロジェクト構造

```
lib/
├── main.dart                          # アプリエントリーポイント（Firebase初期化）
├── services/
│   ├── auth_service.dart              # Google認証サービス
│   ├── firebase_email_service.dart    # Firebase Functions メール送信
│   ├── email_service.dart             # メール送信インターフェース
│   └── settings_service.dart          # 設定管理（Firebase版）
├── screens/
│   ├── home_screen.dart               # ホーム画面（認証状態対応）
│   └── firebase_settings_screen.dart  # 設定画面（Firebase版）
└── widgets/
    └── auth_wrapper.dart              # 認証状態管理ラッパー

functions/
├── src/
│   └── index.ts                       # Firebase Functions実装
├── package.json                       # Node.js依存関係
└── tsconfig.json                      # TypeScript設定
```

## 🚀 今後の計画

- [ ] エラーハンドリングの改善
- [ ] オフライン対応
- [ ] プッシュ通知機能
- [ ] データ同期機能

## 📄 ライセンス

このプロジェクトは MIT ライセンスの下で公開されています。