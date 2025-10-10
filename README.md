# 水質報告アプリ (Water Quality Reporter)

水道施設の残留塩素濃度を測定し、メール報告を自動化するFlutterアプリです。

## 📱 概要

このアプリは水道関連業務において、日々の残留塩素濃度測定結果を指定されたメールアドレスに自動送信する機能を提供します。

### 主な機能
- 📊 残留塩素濃度の入力・送信
- 📧 測定結果の自動メール送信
- 🔧 個人用Google Apps Script連携
- 🧪 デバッグモード（テスト送信）
- 📋 送信履歴の管理
- ⚙️ 詳細な設定管理

## 🎯 対象ユーザー

- 水道施設の管理者
- 水質検査担当者
- 日々の水質データを報告する必要がある方

## 🏗️ システム構成

```
[Flutter アプリ] → [個人のGoogle Apps Script] → [Gmail] → [報告先]
```

各利用者は自分専用のGoogle Apps Scriptを作成し、アプリから送信されるデータを受け取ってメール送信を行います。

## 📂 プロジェクト構成

```
wq_report/
├── lib/                    # Dartソースコード
│   ├── main.dart          # アプリエントリポイント
│   ├── screens/           # 画面UI
│   │   ├── home_screen.dart       # メイン画面
│   │   ├── settings_screen.dart   # 設定画面
│   │   └── history_screen.dart    # 履歴画面
│   ├── services/          # ビジネスロジック
│   │   ├── email_service.dart     # メール送信サービス
│   │   ├── settings_service.dart  # 設定管理サービス
│   │   └── history_service.dart   # 履歴管理サービス
│   └── config/           # 設定ファイル
│       └── keys.dart     # 定数定義
├── gas/                   # Google Apps Script
│   ├── Code.gs           # メイン処理ファイル
│   ├── appsscript.json   # プロジェクト設定
│   └── README.md         # GAS設定説明
├── test/                 # テストファイル
├── DEPLOY.md            # デプロイメント手順書
└── README.md           # このファイル
```

## 🚀 セットアップ

### 開発者向け

1. **Flutter環境のセットアップ**
   ```bash
   flutter doctor
   ```

2. **依存関係のインストール**
   ```bash
   flutter pub get
   ```

3. **アプリの実行**
   ```bash
   flutter run
   ```

### 利用者向け

**📋 [DEPLOY.md](./DEPLOY.md) を参照**

利用者はGoogle Apps Scriptの設定とアプリの初期設定が必要です。詳細な手順は `DEPLOY.md` に記載されています。

## 🧪 テスト

### テストの実行
```bash
# 全テストの実行
flutter test

# 特定のテストファイルの実行
flutter test test/settings_test.dart
```

### テスト構成
- **Unit Tests**: サービスクラスの単体テスト
- **Widget Tests**: UI部品のテスト
- **Integration Tests**: 画面遷移・総合テスト

## 📊 技術仕様

### 開発環境
- **Flutter**: 3.24.0+
- **Dart**: 3.5.0+
- **Target Platform**: Android

### 主要依存関係
- `http`: Google Apps Script通信
- `shared_preferences`: ローカルデータ保存
- `intl`: 日付・時刻フォーマット

### データ管理
- **設定データ**: SharedPreferences (JSON形式)
- **履歴データ**: SharedPreferences (JSON形式、35日間保持)
- **送信管理**: 日次送信制限 (デバッグモードは除外)

## 🔧 主要機能詳細

### 1. メール送信機能
- Google Apps Script経由でGmail送信
- HTMLメール + プレーンテキスト対応
- 送信失敗時のエラーハンドリング

### 2. デバッグモード
- テスト用メールアドレスへの送信
- 日次制限の回避
- 履歴にデバッグフラグ記録

### 3. 設定管理
- GAS WebアプリURL設定
- 送信先メールアドレス設定
- 地点番号設定
- バリデーション機能

### 4. 履歴管理
- 送信成功/失敗の記録
- デバッグ送信の識別
- 古いデータの自動削除 (35日)

## 🔐 セキュリティ考慮事項

- Google Apps ScriptのWebアプリURLは個人専用
- メールアドレスの入力バリデーション
- 通信エラー時の適切なエラーハンドリング
- デバッグモードでの誤送信防止

## 📈 将来の拡張予定

- iOS対応
- 複数地点の同時管理
- データのクラウド同期
- レポート機能の強化
- 基準値を超えた場合のアラート機能

## 📄 ライセンス

このプロジェクトは個人・組織での利用を想定しています。
商用利用については別途ご相談ください。

## 🤝 コントリビューション

1. このリポジトリをフォーク
2. 機能ブランチを作成 (`git checkout -b feature/AmazingFeature`)
3. 変更をコミット (`git commit -m 'Add some AmazingFeature'`)
4. ブランチにプッシュ (`git push origin feature/AmazingFeature`)
5. Pull Requestを作成

## 📞 サポート

- **デプロイメント**: [DEPLOY.md](./DEPLOY.md) を参照
- **GAS設定**: [gas/README.md](./gas/README.md) を参照
- **技術的な問題**: Issues セクションで報告

---

**💧 水質管理業務の効率化にお役立てください！**
