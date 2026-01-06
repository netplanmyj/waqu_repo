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

**OAuth同意画面の設定（現在アクセスできない場合は後回し可能）:**
- OAuth同意画面の設定は後でも可能です
- まずアプリをテストして、認証エラーが出た時点で設定することもできます
- Firebase Authenticationが正常に動作すれば、OAuth設定も自動的に処理される場合があります

### Step 3-A: OAuth設定の代替手順（推奨）

**認証情報の確認:**
1. Google Cloud Console → 「APIとサービス」→「認証情報」
2. 「OAuth 2.0 クライアント ID」が自動作成されているか確認
3. Firebase Authenticationを有効にすると自動的に作成される場合があります

**設定スキップして先に進む場合:**
- Firebase Authenticationの設定を完了
- google-services.jsonを配置
- SHA-1フィンガープリントを追加
- アプリをテスト実行
- 認証エラーが出た時点でOAuth設定を再確認

### Step 3-1: 設定確認手順

**Google Cloud Consoleでの確認:**
1. [Google Cloud Console](https://console.cloud.google.com/) を開く
2. 右上のプロジェクト選択で、Firebaseと同じプロジェクトが選択されていることを確認

**OAuth同意画面へのアクセス方法（複数の方法を試す）:**

**方法1: サイドメニューから**
- 左メニュー「APIとサービス」→「OAuth同意画面」をクリック

**方法2: 認証情報から**
- 左メニュー「APIとサービス」→「認証情報」をクリック
- ページ上部の「OAuth同意画面」タブをクリック

**方法3: 直接URLアクセス**
- ブラウザで以下にアクセス（プロジェクトIDを置き換え）:
  ```
  https://console.cloud.google.com/apis/credentials/consent?project=YOUR_PROJECT_ID
  ```

**指標やプロジェクト診断が表示される場合:**
- 間違ったページにいる可能性があります
- 左上のハンバーガーメニュー（≡）をクリック
- 「APIとサービス」の項目を探してクリック
- 「OAuth同意画面」を選択

**Gmail API確認:**
1. 左メニューから「APIとサービス」→「有効なAPI」をクリック
2. 「Gmail API」が一覧に表示されていることを確認

### Step 4: SHA-1フィンガープリントの追加

1. Flutterプロジェクトのルートディレクトリで以下を実行してSHA-1を取得:
```bash
# デバッグ用SHA-1の取得
keytool -list -v -alias androiddebugkey -keystore ~/.android/debug.keystore

# パスワードを聞かれたら「android」と入力
```

**または、Flutterコマンドを使用:**
```bash
flutter build apk --debug
cd android && ./gradlew signingReport
```

2. 出力から「SHA1:」で始まる行をコピー
3. Firebase Console → プロジェクト設定 → アプリ → Android アプリ
4. SHA証明書フィンガープリントを追加

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