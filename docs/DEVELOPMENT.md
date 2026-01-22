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

## リファクタリング基準

定期的にコード品質を維持するため、以下の基準に基づいてリファクタリングを実施してください。

### ファイルの行数制限

- **推奨**: 1ファイル 300行以内
- **最大**: 1ファイル 500行以内

500行を超えるファイルは分割を検討してください。

```bash
# ファイルの行数確認
wc -l lib/**/*.dart
```

### ネストの深さ

- **推奨**: 最大3階層以内
- **避けるべき**: 4階層以上のネスト

#### 改善例：早期リターン

**ネストが深い（悪い例）:**

```dart
void process() {
  if (condition1) {
    if (condition2) {
      if (condition3) {
        // 処理
      }
    }
  }
}
```

**ネストを減らしたコード（良い例）:**

```dart
void process() {
  if (!condition1) return;
  if (!condition2) return;
  if (!condition3) return;
  
  // 処理
}
```

### 関数の長さ

- **推奨**: 1関数 50行以内
- **最大**: 1関数 100行以内

長い関数は責任を分割してください。

### 複雑度の削減

以下の手法を活用してコードの複雑度を下げます：

1. **条件判定の抽出**
   ```dart
   // 複雑な条件は名前付きメソッドに抽出
   bool _isRetriableError(Exception e) {
     return e.toString().contains('network') || 
            e.toString().contains('timeout');
   }
   
   // 使用時
   if (_isRetriableError(e)) { ... }
   ```

2. **ループの抽出**
   ```dart
   // 複雑なループはメソッドに抽出
   List<String> _filterValidItems(List<String> items) {
     return items.where((item) => _isValid(item)).toList();
   }
   ```

3. **クラスの分割**
   - 単一責任の原則に従う
   - 責任が重なり合う場合は分割を検討

### 品質維持のチェックリスト

リファクタリング時の確認項目：

- [ ] `flutter analyze` でエラー・警告なし
- [ ] `flutter test` で全テストパス
- [ ] 変更前後で動作が変わらないこと
- [ ] コードレビュー済み
- [ ] ドキュメント更新済み

## 定期的なリファクタリングの実施

コード品質を継続的に維持するため、定期的にリファクタリングを実施してください。

### 実施タイミング

- **月1回程度**: 全体的なコード品質チェック
- **機能追加時**: 関連するコードのリファクタリング
- **バグ修正時**: 修正箇所周辺のコード改善

### 実施手順

1. **対象ファイルの特定**

```bash
# 行数が500行を超えるファイルを特定
find lib -name "*.dart" -exec wc -l {} + | sort -rn | awk '$1 > 500 {print}'

# 複雑度が高いと思われるメソッドをチェック
flutter analyze
```

2. **リファクタリング計画の作成**

   - 分割対象の機能を特定
   - 新しい補助クラスやメソッドの設計
   - テストの充実度を確認

3. **実装**

   - ブランチを作成: `git checkout -b refactor/機能名`
   - コードの分割や整理を実施
   - テストを確認: `flutter test`

4. **コミットとPR作成**

```bash
git add .
git commit -m "refactor: 機能名

- 改善内容1
- 改善内容2

Issue #XXX"

git push -u origin refactor/機能名
gh pr create --title "refactor: 機能名" --body-file pr_body.txt
```

### リファクタリングの例

**対象ファイル:**
- `lib/screens/home_screen.dart` (536行)
- `lib/screens/settings_screen.dart` (522行)

**実施方法:**
- 画面のビジネスロジックをサービスクラスに抽出
- UI構築用の補助メソッドに分割
- 状態管理をシンプル化

**結果期待:**
- 各ファイルが300行以下に削減
- テストの追加が容易に
- 再利用性の向上

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
