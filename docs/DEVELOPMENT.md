# 開発手順ガイド

このドキュメントでは、水質検査報告アプリの開発手順と品質維持のガイドラインを記載します。

## 目次

1. [開発フロー](#開発フロー)
2. [GitHub CLIの使用方法](#github-cliの使用方法)
3. [コード品質維持](#コード品質維持)
4. [テストガイドライン](#テストガイドライン)
5. [PR作成手順](#pr作成手順)
6. [トラブルシューティング](#トラブルシューティング)

## 開発フロー

### 1. Issue の作成

新機能や修正を開始する前に、GitHub Issue を作成します。

```bash
gh issue create --title "Fix #XXX: 機能名" --body "## 概要\n修正内容\n\n## 詳細\n"
```

### 2. フィーチャーブランチの作成

`main` ブランチから新しいブランチを作成します。

```bash
git checkout main
git pull origin main
git checkout -b fix/issue-XXX-機能名
```

ブランチ命名規則:

- 新機能: `feature/機能名`
- バグ修正: `fix/issue-XXX-内容`
- リファクタリング: `refactor/対象`
- ドキュメント: `docs/内容`

### 3. 開発・テスト

コードを実装しながら、随時テストを実行します。

```bash
# コード解析
flutter analyze

# フォーマット
dart format .

# テスト実行
flutter test

# 特定のテストのみ実行
flutter test test/widget_test.dart
```

### 4. コミット

小さく、意味のある単位でコミットします。

```bash
git add .
git commit -m "fix: 修正内容

- 詳細1
- 詳細2"
```

コミットメッセージ規則:

- `feat:` 新機能
- `fix:` バグ修正
- `refactor:` リファクタリング
- `test:` テスト追加・修正
- `docs:` ドキュメント更新
- `style:` コードフォーマット
- `chore:` ビルド・設定変更

## GitHub CLIの使用方法

### PR 作成

```bash
git push -u origin ブランチ名
gh pr create --title "Fix #XXX: 機能名" --body "本文"
```

### 日本語を含むメッセージ作成時の注意

ターミナルの `-m` フラグや `--body` フラグに日本語を直接渡すと文字化けする可能性があります。特にバックスラッシュ (`\`) やバッククォート (`` ` ``) を含む場合は必ず失敗します。

#### 推奨方法 1: ファイルから読み込む（日本語対応）

```bash
# PR本文ファイルを作成
cat > /tmp/pr_body.txt << 'EOF'
## 概要
Firebase認証のネットワークエラーに対する安定性を向上させました。

## 変更内容
- リトライロジックの実装
- タイムアウト設定の追加
EOF

# ファイルから読み込み
gh pr create --title "Fix #140: ネットワークエラーの安定性向上" --body-file /tmp/pr_body.txt
```

#### 推奨方法 2: GitHub UI から直接作成

- `git push` 後、ブラウザで GitHub を開く
- "Compare & pull request" ボタンから作成
- 日本語フォーム入力で文字化けなし

### レビューコメントの確認

GitHub Copilot がコードレビューを実行した場合、以下のコマンドで確認できます。

```bash
# PR番号を指定してレビューコメントを取得（JSON形式）
gh api repos/{owner}/{repo}/pulls/{pr_number}/comments

# 実際の使用例
gh api repos/netplanmyj/waqu_repo/pulls/141/comments

# レビュー全体を取得
gh api repos/netplanmyj/waqu_repo/pulls/141/reviews

# jqで整形して読みやすく表示
gh api repos/netplanmyj/waqu_repo/pulls/141/comments | jq '.[] | {path: .path, line: .line, body: .body}'
```

**出力例:**

```json
{
  "path": "lib/services/auth_service.dart",
  "line": 50,
  "body": "このコードはより簡潔に書けます"
}
```

## コード品質維持

### 警告の解消

必須: すべての警告を解消してから PR を作成してください。

```bash
# 警告チェック
flutter analyze

# 期待される出力
# "No issues found!"
```

### コードフォーマット

Flutter の標準フォーマッタを使用します。

```bash
# 全ファイルをフォーマット
dart format .

# 特定のファイルをフォーマット
dart format lib/services/auth_service.dart
```

## テストガイドライン

### テスト実行コマンド

```bash
# 全テスト実行
flutter test

# 特定のテストのみ実行
flutter test test/widget_test.dart
```

### テスト作成ガイドライン

1. 各機能に対応するテストファイルを作成
   - `lib/services/auth_service.dart` → `test/auth_service_test.dart`

2. テストケースの構成

```dart
group('AuthService', () {
  test('Google認証の初期状態確認', () {
    // テストコード
  });
  
  test('エラーハンドリング確認', () {
    // テストコード
  });
});
```

3. テスト内容
   - 初期状態の確認
   - 正常系の動作確認
   - 異常系・エッジケースの確認

## PR作成手順

### チェックリスト

PR を作成する前に、以下を確認してください。

- [ ] `flutter analyze` でエラー・警告なし
- [ ] `flutter test` で全テストパス
- [ ] コードはフォーマット済み (`dart format`)
- [ ] コミットメッセージは規約に従っている
- [ ] Issue番号を記載（`Fixes #XX` または `Closes #XX`）

### PR テンプレート

```markdown
## 概要
修正内容の簡潔な説明

## 変更内容

### 1. リトライロジックの実装
- 詳細1
- 詳細2

### 2. タイムアウト設定
- 詳細1
- 詳細2

## 期待される効果
- 効果1
- 効果2

## テスト
- [ ] ネットワーク不安定時のテスト
- [ ] タイムアウト発生時の確認

Closes #XXX
```

## トラブルシューティング

### flutter analyze に警告が多い

```bash
# 警告の詳細を確認
flutter analyze --verbose

# 特定のファイルのみ解析
flutter analyze lib/services/auth_service.dart
```

### テストが失敗する

```bash
# 詳細なエラーログを表示
flutter test --reporter expanded
```

### ビルドが失敗する

```bash
# 依存関係を再取得
flutter clean
flutter pub get

# キャッシュをクリア
flutter pub cache repair
```

### GitHub CLI コマンドが文字化けする

- 日本語を含むメッセージの場合、ファイルから読み込む方法を使用してください
- 詳細は [GitHub CLIの使用方法](#github-cliの使用方法) を参照

## 参考資料

- [Dart コーディング規約](https://dart.dev/guides/language/effective-dart)
- [Flutter 公式ドキュメント](https://flutter.dev/docs)
- [GitHub CLI 公式ドキュメント](https://cli.github.com/manual)
- [Conventional Commits](https://www.conventionalcommits.org/)

---

**最終更新: 2026年1月22日**
