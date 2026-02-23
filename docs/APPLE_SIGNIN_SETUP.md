# Apple Sign-In 設定手順

**日時**: 2025年1月  
**Bundle ID**: `jp.netplan.ios.waquRepo`  
**Firebase Project ID**: `waqu-repo`

---

## 🔍 Issue #149: Apple認証エラーの原因

**エラーメッセージ**:
```
Exception: Apple認証に失敗しました：[firebase_auth/invalid-credential] Invalid OAuth response from apple.com
```

**原因**: Firebase Console と Apple Developer Console の OAuth 設定の不整合

---

## ✅ 1. Firebase Console での Apple プロバイダー設定確認

### 手順

1. **Firebase Console にアクセス**
   - https://console.firebase.google.com/
   - プロジェクト「**waqu-repo**」を選択

2. **Authentication > Sign-in method を開く**
   - 左メニューから「Authentication」をクリック
   - 「Sign-in method」タブをクリック

3. **Apple プロバイダーの状態を確認**
   - 「Apple」が**有効（Enabled）**になっているか確認
   - 無効の場合、「Apple」をクリックして有効化

4. **OAuth redirect URI を確認/コピー**
   ```
   https://waqu-repo.firebaseapp.com/__/auth/handler
   ```
   - この URI は後で Apple Developer Console で使用します

5. **Service ID を確認**
   - Service ID は Bundle ID と同じ `jp.netplan.ios.waquRepo` を使用
   - または専用の Service ID を作成することも可能
   
   **推奨**: Bundle ID をそのまま使用

6. **保存**
   - 変更した場合は「保存」をクリック

---

## 🍎 2. Apple Developer Console での設定確認

### 手順1: Certificates, Identifiers & Profiles にアクセス

1. https://developer.apple.com/account/ にアクセス
2. 「**Certificates, Identifiers & Profiles**」をクリック

### 手順2: App ID の設定確認

1. 左メニューから「**Identifiers**」を選択
2. Bundle ID `jp.netplan.ios.waquRepo` を探してクリック
3. **Capabilities** の中で「**Sign in with Apple**」が有効になっているか確認
   - ✅ チェックが入っていない場合、チェックを入れる
   - 「**Edit**」をクリックして設定を確認
   - 「**Save**」をクリック

### 手順3: Service ID の作成/確認

#### Option A: Bundle ID をそのまま使用（推奨）

1. 左メニューから「**Identifiers**」を選択
2. 右上の「**+**」ボタンをクリック
3. 「**Services IDs**」を選択
4. 以下を入力:
   ```
   Description: waqu_repo Sign in with Apple
   Identifier: jp.netplan.ios.waquRepo
   ```
5. 「**Sign in with Apple**」にチェックを入れる
6. 「**Configure**」ボタンをクリック
7. **Web Authentication Configuration**:
   - **Primary App ID**: `jp.netplan.ios.waquRepo` を選択
   - **Domains and Subdomains**: 
     ```
     waqu-repo.firebaseapp.com
     ```
   - **Return URLs**:
     ```
     https://waqu-repo.firebaseapp.com/__/auth/handler
     ```
8. 「**Save**」→「**Continue**」→「**Register**」

#### Option B: 既存の Service ID を確認

1. 左メニューから「**Identifiers**」を選択
2. フィルターで「**Services IDs**」を選択
3. `jp.netplan.ios.waquRepo` を探してクリック
4. 「**Sign in with Apple**」の設定を確認:
   - **Domains and Subdomains**: `waqu-repo.firebaseapp.com`
   - **Return URLs**: `https://waqu-repo.firebaseapp.com/__/auth/handler`
5. 不一致がある場合、「**Configure**」で修正

### 手順4: Apple Key の確認

1. 左メニューから「**Keys**」を選択
2. 既存の「**Sign in with Apple** Key」があるか確認
3. ない場合、新規作成:
   - 右上の「**+**」ボタンをクリック
   - Key Name: `waqu_repo Apple Sign-In Key`
   - 「**Sign in with Apple**」にチェック
   - 「**Configure**」をクリック
   - Primary App ID: `jp.netplan.ios.waquRepo` を選択
   - 「**Save**」→「**Continue**」→「**Register**」
   - **Key ID** と `.p8` ファイルをダウンロード（重要！）

4. 既存の Key がある場合:
   - Key が有効期限内か確認
   - **Key ID** を控える

---

## 🔧 3. Firebase Console に Apple Key を設定

### 手順

1. **Firebase Console > Authentication > Sign-in method > Apple** を開く
2. **OAuth code flow configuration** セクション:
   - **Apple Key ID**: Apple Developer Console で作成した Key ID
   - **Team ID**: Apple Developer Program の Team ID
   - **Private key**: ダウンロードした `.p8` ファイルの内容
3. 「**保存**」をクリック

### Team ID の確認方法

1. https://developer.apple.com/account/ にアクセス
2. 右上の **Membership** セクションに **Team ID** が表示されます

---

## 🧪 4. 設定確認とテスト

### 確認チェックリスト

- [ ] Firebase Console: Apple provider が有効
- [ ] Firebase Console: OAuth redirect URI = `https://waqu-repo.firebaseapp.com/__/auth/handler`
- [ ] Apple Developer: App ID で Sign in with Apple が有効
- [ ] Apple Developer: Service ID が作成済み
- [ ] Apple Developer: Service ID の Return URLs が Firebase OAuth redirect URI と一致
- [ ] Apple Developer: Apple Key が作成済みで有効
- [ ] Firebase Console: Apple Key ID, Team ID, Private key が設定済み

### ローカルテスト

```bash
# iOS Simulator を起動
flutter emulators --launch apple_ios_simulator

# アプリをビルド
flutter run -d ios

# Apple Sign-In をテスト
# アプリ内で「Appleでサインイン」ボタンをタップ
```

### エラーログの確認

```bash
# auth_service.dart の debugPrint で出力されるログを確認
# "❌ Apple認証エラー:" で始まるログを探す
```

---

## 🚨 トラブルシューティング

### エラー: `invalid-credential`

**原因**: OAuth 設定の不整合

**解決策**:
1. Apple Developer Console の Return URLs が Firebase OAuth redirect URI と完全一致しているか確認
2. Firebase Console で Apple Key が正しく設定されているか確認
3. Service ID と Bundle ID が一致しているか確認

### エラー: `user-cancelled`

**原因**: ユーザーが認証をキャンセル

**解決策**: 正常な動作です（エラーハンドリングは実装済み）

### エラー: `sign_in_failed`

**原因**: Apple Sign-In capability が無効

**解決策**:
1. Apple Developer Console で App ID の Sign in with Apple capability を確認
2. Xcode で Signing & Capabilities に Sign in with Apple を追加

---

## 📋 次のステップ

1. ✅ この手順に従って Apple Developer Console を確認
2. ✅ Firebase Console の設定を確認
3. ✅ iOS Simulator でテスト
4. ✅ 実機でテスト
5. ⬜ App Store 提出

---

## 参考リンク

- [Firebase Apple Sign-In Setup](https://firebase.google.com/docs/auth/ios/apple)
- [Apple Developer Sign in with Apple](https://developer.apple.com/sign-in-with-apple/)
- [Flutter sign_in_with_apple package](https://pub.dev/packages/sign_in_with_apple)

---

**設定完了後、Issue #149 の修正を確認してください！**
