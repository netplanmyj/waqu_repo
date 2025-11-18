# 自前ドメインでの公開ガイド

このガイドでは、GitHub Pagesの代わりに自前のドメインでHTMLファイルを公開する方法を説明します。

---

## ✅ 自前ドメイン公開のメリット

### OAuth審査での優位性
- ✅ **プロフェッショナルな印象**: `yourdomain.com`は`github.io`より信頼性が高い
- ✅ **長期的なコミットメント**: 独自ドメインは真剣なアプリ開発を示す
- ✅ **審査承認率の向上**: Google審査担当者に良い印象を与える

### ユーザー体験の向上
- ✅ **覚えやすいURL**: `example.com/waqu/privacy-policy.html`
- ✅ **ブランド統一**: 他のサービスと同じドメイン
- ✅ **信頼性**: 独自ドメインは安心感を与える

### 運用の柔軟性
- ✅ **自由なサブディレクトリ構成**
- ✅ **他のサービスとの統合が容易**
- ✅ **サーバー設定の完全なコントロール**

---

## 📁 推奨ディレクトリ構成

### パターン1: サブディレクトリ方式（推奨）

```
https://yourdomain.com/
├── index.html                        ← メインサイト
├── about.html
├── contact.html
└── waqu/                             ← 水質検査報告アプリ専用コーナー
    ├── index.html                    ← アプリ紹介ページ
    ├── privacy-policy.html           ← プライバシーポリシー
    └── terms.html                    ← 利用規約（任意）
```

**OAuth審査で使用するURL**:
```
アプリホームページ: https://yourdomain.com/waqu/
プライバシーポリシー: https://yourdomain.com/waqu/privacy-policy.html
```

### パターン2: サブドメイン方式

```
https://waqu.yourdomain.com/
├── index.html                        ← アプリ紹介ページ
├── privacy-policy.html               ← プライバシーポリシー
└── terms.html                        ← 利用規約（任意）
```

**OAuth審査で使用するURL**:
```
アプリホームページ: https://waqu.yourdomain.com/
プライバシーポリシー: https://waqu.yourdomain.com/privacy-policy.html
```

### パターン3: 専用ドメイン

```
https://waqu-app.com/
├── index.html                        ← アプリ紹介ページ
├── privacy-policy.html               ← プライバシーポリシー
└── terms.html                        ← 利用規約（任意）
```

**OAuth審査で使用するURL**:
```
アプリホームページ: https://waqu-app.com/
プライバシーポリシー: https://waqu-app.com/privacy-policy.html
```

---

## 🔧 HTMLファイルの設定

### ✅ 現在のHTMLファイルは修正不要

作成済みの `index.html` と `privacy-policy.html` は**相対パス**を使用しているため、**そのままアップロード可能**です。

#### index.html の内部リンク
```html
<!-- 相対パスなので、どのディレクトリでも動作 -->
<a href="privacy-policy.html" class="btn">プライバシーポリシー</a>
```

#### 確認済み事項
- ✅ 相対パス使用（絶対パスなし）
- ✅ 外部リンクは完全URL
- ✅ どのディレクトリ構成でも動作

---

## 🌐 サーバー別のアップロード方法

### 方法1: レンタルサーバー（さくら、ロリポップ等）

#### ファイル配置
```bash
# FTPまたはSFTPでアップロード
/public_html/
└── waqu/
    ├── index.html
    └── privacy-policy.html
```

#### アクセスURL
```
https://yourdomain.com/waqu/
https://yourdomain.com/waqu/privacy-policy.html
```

#### .htaccess設定（推奨）
```apache
# /public_html/waqu/.htaccess

# UTF-8エンコーディング
AddDefaultCharset UTF-8

# MIMEタイプ設定
AddType text/html .html

# キャッシュ設定
<FilesMatch "\.(html)$">
    Header set Cache-Control "max-age=3600, public"
</FilesMatch>

# HTTPS強制（SSL証明書が有効な場合）
RewriteEngine On
RewriteCond %{HTTPS} off
RewriteRule ^(.*)$ https://%{HTTP_HOST}%{REQUEST_URI} [L,R=301]
```

---

### 方法2: AWS S3 + CloudFront

#### S3バケット作成
```bash
aws s3 mb s3://yourdomain-waqu
aws s3 website s3://yourdomain-waqu --index-document index.html
```

#### ファイルアップロード
```bash
aws s3 sync docs/ s3://yourdomain-waqu/ --acl public-read
```

#### CloudFront設定
- SSL証明書: AWS Certificate Manager
- オリジンドメイン: S3バケット
- カスタムドメイン: `waqu.yourdomain.com`

---

### 方法3: Netlify（推奨：簡単・無料）

#### 手順
1. [Netlify](https://www.netlify.com/)にログイン
2. 「New site from Git」をクリック
3. GitHubリポジトリを選択
4. ビルド設定:
   ```
   Build command: (空欄)
   Publish directory: docs
   ```
5. カスタムドメイン設定:
   - Site settings → Domain management
   - Add custom domain: `waqu.yourdomain.com`
   - DNS設定（Aレコード or CNAMEレコード）

#### メリット
- ✅ 無料SSL証明書（Let's Encrypt）
- ✅ CDN対応（高速配信）
- ✅ Git連携（自動デプロイ）
- ✅ 簡単な設定

---

### 方法4: Vercel

#### 手順
1. [Vercel](https://vercel.com/)にログイン
2. 「Import Project」をクリック
3. GitHubリポジトリを選択
4. プロジェクト設定:
   ```
   Framework Preset: Other
   Root Directory: docs
   ```
5. カスタムドメイン設定

---

## 📝 OAuth審査用ドキュメントの更新

### OAUTH_VERIFICATION.md

自前ドメインを使用する場合、以下のセクションを更新：

```markdown
### 4. **アプリのホームページ**

#### 公開URL
```
✅ アプリホームページ: https://yourdomain.com/waqu/
✅ プライバシーポリシー: https://yourdomain.com/waqu/privacy-policy.html
```

#### 必須コンテンツ
✅ アプリの説明
✅ 主な機能
✅ スクリーンショット
✅ プライバシーポリシーへのリンク
✅ お問い合わせフォーム/メールアドレス
```

### README.md

```markdown
## 📄 法的文書

- [プライバシーポリシー（Web版）](https://yourdomain.com/waqu/privacy-policy.html)
- [プライバシーポリシー（Markdown版）](PRIVACY_POLICY.md)
- [OAuth認証審査](OAUTH_VERIFICATION.md)
- [Play Store公開](PLAYSTORE.md)
```

---

## 🔒 SSL証明書の設定

### なぜSSLが必須か

- ✅ **OAuth審査の要件**: GoogleはHTTPSを強く推奨
- ✅ **ユーザーの信頼**: 🔒マークが表示される
- ✅ **セキュリティ**: データ通信の暗号化

### SSL証明書の取得方法

#### 方法1: Let's Encrypt（無料）
```bash
# Certbotをインストール
sudo apt-get install certbot

# SSL証明書取得
sudo certbot certonly --webroot -w /var/www/html -d yourdomain.com
```

#### 方法2: レンタルサーバーの無料SSL
- さくらインターネット: Let's Encrypt無料
- ロリポップ: 独自SSL無料

#### 方法3: Netlify/Vercel（自動）
- デフォルトでHTTPS有効
- カスタムドメインでも自動SSL

---

## ✅ 公開前のチェックリスト

### ファイル確認
- [ ] `index.html` をアップロード
- [ ] `privacy-policy.html` をアップロード
- [ ] 文字エンコーディング: UTF-8
- [ ] ファイル権限: 644（読み取り可能）

### URL確認
- [ ] `https://yourdomain.com/waqu/` でアクセス可能
- [ ] `https://yourdomain.com/waqu/privacy-policy.html` でアクセス可能
- [ ] HTTPSで表示される（🔒マーク）
- [ ] スマートフォンでも正しく表示

### リンク確認
- [ ] index.html → privacy-policy.html リンク動作
- [ ] GitHubリポジトリへのリンク動作
- [ ] 外部リンク（Google、Firebase等）動作

### プライバシーポリシー内容確認
- [ ] お問い合わせ先が正しい（メールアドレス or フォームURL）
- [ ] 開発者名が正しい
- [ ] 日付が最新

### OAuth審査準備
- [ ] アプリホームページURL確定
- [ ] プライバシーポリシーURL確定
- [ ] OAUTH_VERIFICATION.md のURL更新
- [ ] README.md のURL更新

---

## 🚀 公開後の作業

### 1. OAuth同意画面の更新

Google Cloud Consoleで以下を更新：

```
【アプリのホームページ】
https://yourdomain.com/waqu/

【プライバシーポリシーURL】
https://yourdomain.com/waqu/privacy-policy.html
```

### 2. ドキュメント更新

以下のファイルでURLを更新：
- `OAUTH_VERIFICATION.md`
- `README.md`
- `PRIVACY_POLICY.md`（お問い合わせ先のURL）

### 3. Git Commit

```bash
git add OAUTH_VERIFICATION.md README.md PRIVACY_POLICY.md
git commit -m "Update URLs to use custom domain"
git push origin main
```

---

## 📊 GitHub Pages vs 自前ドメイン比較

| 項目 | GitHub Pages | 自前ドメイン |
|-----|-------------|------------|
| **コスト** | 無料 | 有料（ドメイン代） |
| **信頼性** | 中 | 高 |
| **OAuth審査** | 通る | より有利 |
| **カスタマイズ** | 制限あり | 自由 |
| **SSL証明書** | 自動 | 設定必要 |
| **独自ドメイン** | 設定可能 | 標準 |
| **セットアップ** | 簡単 | やや複雑 |

---

## 🎯 推奨構成

### 個人開発者・スタートアップ
```
Netlify + カスタムドメイン
- 無料SSL
- CDN高速配信
- Git連携
- 簡単セットアップ
```

### 企業・本格運用
```
AWS S3 + CloudFront + Route53
- スケーラビリティ
- 高可用性
- 詳細な設定可能
```

### 既存Webサイトあり
```
既存サーバーにサブディレクトリ追加
- 統一ドメイン
- ブランディング一貫性
- 管理が一元化
```

---

## 💡 ベストプラクティス

1. **HTTPS必須**: OAuth審査では必須要件
2. **レスポンシブデザイン**: スマホ対応確認
3. **ページ速度**: 読み込み速度を最適化
4. **アクセシビリティ**: 誰でも読みやすく
5. **定期更新**: プライバシーポリシーの見直し

---

## 🆘 トラブルシューティング

### 問題1: ページが表示されない
```
原因: ファイルパスが間違っている
解決: ファイル名の大文字小文字を確認
```

### 問題2: リンクが404エラー
```
原因: 相対パスが正しくない
解決: index.html と privacy-policy.html を同じディレクトリに配置
```

### 問題3: SSL証明書エラー
```
原因: 証明書が未設定 or 期限切れ
解決: Let's Encrypt等で証明書を取得・更新
```

---

## ✅ まとめ

自前ドメインでの公開は：
- ✅ **OAuth審査で有利**
- ✅ **ユーザーの信頼向上**
- ✅ **ブランディング強化**
- ✅ **現在のHTMLファイルをそのまま使用可能**

**推奨**: Netlify + カスタムドメイン（簡単・無料SSL・高速）
