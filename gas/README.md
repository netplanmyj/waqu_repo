# Google Apps Script 設定ファイル

このディレクトリには、水質報告アプリ用のGoogle Apps Scriptコードが含まれています。

## ファイル構成

- `Code.gs` - メイン処理ファイル（水質報告メール送信機能）
- `appsscript.json` - プロジェクト設定ファイル
- `README.md` - このファイル

## 機能概要

- 水質報告アプリからのGETリクエストを受信
- 指定されたメールアドレスに水質データをメール送信
- デバッグモード対応（テスト送信）
- doPost()関数は削除済み（doGet()のみ使用）

## デプロイ方法

詳細な手順については、ルートディレクトリの `DEPLOY.md` を参照してください。

## API仕様

### リクエストパラメータ（GET）

| パラメータ | 必須 | 説明 | 例 |
|----------|------|------|-----|
| monthDay | ✓ | 月日（MMDD形式） | "1025" |
| time | ✓ | 時刻（HHMM形式） | "1030" |
| chlorine | ✓ | 塩素濃度 | "0.45" |
| locationNumber | ✓ | 地点番号 | "01" |
| recipientEmail | ✓ | 送信先メールアドレス | "report@example.com" |
| debugMode | × | デバッグモード | "true" または "false" |

### レスポンス形式

成功時：
```json
{
  "status": "success",
  "message": "メールが正常に送信されました",
  "timestamp": "2024-10-25T01:30:00.000Z"
}
```

エラー時：
```json
{
  "status": "error",
  "message": "エラーメッセージ",
  "timestamp": "2024-10-25T01:30:00.000Z"
}
```

## テスト方法

1. Google Apps Script エディタで `testEmailSend` 関数を実行
2. 関数内の `recipientEmail` を実際のテスト用アドレスに変更してから実行
3. メールが正常に送信されることを確認

## 注意事項

- Gmailの送信制限に注意（1日100通まで）
- 本番環境では適切な送信先アドレスを設定してください
- デバッグモードでのテスト送信を活用してください