# GitHub Pagesセットアップガイド

プライバシーポリシーをGitHub Pagesで公開するための手順です。

## 📋 セットアップ手順

### Step 1: ファイルをGitHubにプッシュ

```bash
git add webdocs/
git add PRIVACY_POLICY.md OAUTH_VERIFICATION.md README.md
git commit -m "Add privacy policy and GitHub Pages setup"
git push origin main
```

### Step 2: GitHub Pagesを有効化

1. GitHubリポジトリページにアクセス
   - https://github.com/netplanmyj/waqu_repo

2. **Settings** タブをクリック

3. 左サイドバーの **Pages** をクリック

4. **Source** セクションで設定:
   - **Branch**: `main`
   - **Folder**: `/webdocs`
   - **Save** をクリック

5. 数分待つと、以下のURLで公開されます:
   ```
   https://netplanmyj.github.io/waqu_repo/
   ```

### Step 3: プライバシーポリシーのURL確認

公開後、以下のURLでアクセスできます：

- **ホームページ**: https://netplanmyj.github.io/waqu_repo/
- **プライバシーポリシー**: https://netplanmyj.github.io/waqu_repo/privacy-policy.html

## 🔍 OAuth審査での使用

### 1. OAuth同意画面の設定

Google Cloud Consoleで以下のURLを入力：

| 項目 | URL |
|-----|-----|
| アプリのホームページ | https://netplanmyj.github.io/waqu_repo/ |
| プライバシーポリシーURL | https://netplanmyj.github.io/waqu_repo/privacy-policy.html |

### 2. プライバシーポリシーの更新

`webdocs/privacy-policy.html`と`PRIVACY_POLICY.md`の以下の箇所を更新：

```html
<!-- webdocs/privacy-policy.html -->
<strong>開発者</strong>: [あなたの名前]<br>
<strong>メールアドレス</strong>: <a href="mailto:your-email@example.com">your-email@example.com</a>
```

```markdown
<!-- PRIVACY_POLICY.md -->
**開発者**: [あなたの名前]  
**メールアドレス**: [your-email@example.com]
```

### 3. ホームページの更新

`webdocs/index.html`の以下の箇所を更新：

```html
<p><strong>メールアドレス</strong>: <a href="mailto:your-email@example.com">your-email@example.com</a></p>
```

## ✅ 確認事項

- [ ] GitHub Pagesが正しく公開されている
- [ ] プライバシーポリシーが表示される
- [ ] 開発者情報（名前、メールアドレス）を更新した
- [ ] リンクが正しく動作する

## 🚀 次のステップ

1. プライバシーポリシーの内容を確認
2. 必要に応じて修正
3. OAuth審査申請で使用するURLをメモ
4. デモ動画の撮影準備

---

**注意**: GitHubリポジトリが**Public**になっている必要があります。Privateリポジトリではgithub.ioでの公開はできません。
