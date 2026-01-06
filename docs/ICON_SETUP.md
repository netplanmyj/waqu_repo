# アプリアイコン自動生成セットアップ

このドキュメントでは、`flutter_launcher_icons` パッケージを使用してアプリアイコンを自動生成する手順を説明します。

## 📋 前提条件

- アイコン画像ファイルが準備済みであること
- Flutter開発環境がセットアップ済みであること

## 🎯 必要なアイコンファイル

以下のファイルを準備してください：

```
assets/
└── icon/
    ├── icon.png              # 1024x1024px（推奨）
    ├── icon_foreground.png   # 432x432px（Android適応型用）
    └── icon_background.png   # 432x432px（Android適応型用、または単色指定）
```

## 🛠️ セットアップ手順

### ステップ1: パッケージの追加

`pubspec.yaml` の `dev_dependencies` セクションに追加：

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0
  flutter_launcher_icons: ^0.14.1  # 追加
```

### ステップ2: アイコン設定の追加

`pubspec.yaml` の末尾に以下の設定を追加：

```yaml
# Flutter Launcher Icons設定
flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/icon/icon.png"
  
  # Android適応型アイコン設定
  adaptive_icon_foreground: "assets/icon/icon_foreground.png"
  adaptive_icon_background: "#2196F3"  # または "assets/icon/icon_background.png"
  
  # Android設定
  android_gravity: "center"
  android_min_sdk_android: 21
  
  # iOS設定  
  ios_content_rendering: "original"
  remove_alpha_ios: true
```

### ステップ3: assetsディレクトリの作成

```bash
mkdir -p assets/icon
```

### ステップ4: アイコン画像の配置

作成したアイコン画像を `assets/icon/` ディレクトリに配置します。

### ステップ5: パッケージのインストール

```bash
flutter pub get
```

### ステップ6: アイコンの生成

```bash
flutter pub run flutter_launcher_icons
```

## 📱 生成されるファイル

### Android

以下のディレクトリにアイコンが自動生成されます：

```
android/app/src/main/res/
├── mipmap-hdpi/ic_launcher.png       (72x72)
├── mipmap-mdpi/ic_launcher.png       (48x48)
├── mipmap-xhdpi/ic_launcher.png      (96x96)
├── mipmap-xxhdpi/ic_launcher.png     (144x144)
├── mipmap-xxxhdpi/ic_launcher.png    (192x192)
├── mipmap-hdpi/ic_launcher_foreground.png
├── mipmap-mdpi/ic_launcher_foreground.png
├── mipmap-xhdpi/ic_launcher_foreground.png
├── mipmap-xxhdpi/ic_launcher_foreground.png
├── mipmap-xxxhdpi/ic_launcher_foreground.png
└── values/ic_launcher_background.xml (背景色)
```

### iOS

```
ios/Runner/Assets.xcassets/AppIcon.appiconset/
├── Icon-App-20x20@1x.png
├── Icon-App-20x20@2x.png
├── Icon-App-29x29@1x.png
├── ...
└── Icon-App-1024x1024@1x.png
```

## 🎨 設定オプション詳細

### 基本設定

| オプション | 説明 | 値の例 |
|----------|------|--------|
| `android` | Android用アイコン生成 | `true` / `false` |
| `ios` | iOS用アイコン生成 | `true` / `false` |
| `image_path` | マスターアイコンパス | `"assets/icon/icon.png"` |

### Android適応型アイコン

| オプション | 説明 | 値の例 |
|----------|------|--------|
| `adaptive_icon_foreground` | 前景画像パス | `"assets/icon/icon_foreground.png"` |
| `adaptive_icon_background` | 背景（色またはパス） | `"#2196F3"` または `"assets/icon/bg.png"` |
| `android_gravity` | アイコンの配置 | `"center"` / `"fill"` |

### iOS設定

| オプション | 説明 | 値の例 |
|----------|------|--------|
| `remove_alpha_ios` | 透過チャンネル削除 | `true` (推奨) |
| `ios_content_rendering` | レンダリングモード | `"original"` / `"template"` |

## ✅ 動作確認

### Android

1. エミュレータまたは実機を起動
2. アプリをインストール：
   ```bash
   flutter run
   ```
3. ホーム画面でアイコンを確認
4. 長押しして適応型アイコンの動きを確認

### iOS

1. シミュレータまたは実機を起動
2. アプリをインストール：
   ```bash
   flutter run
   ```
3. ホーム画面でアイコンを確認

## 🔧 トラブルシューティング

### アイコンが反映されない（Android）

```bash
# キャッシュをクリア
flutter clean
flutter pub get
flutter pub run flutter_launcher_icons

# 再ビルド
flutter run
```

### アイコンが反映されない（iOS）

```bash
# Xcodeのビルドキャッシュをクリア
cd ios
rm -rf Pods Podfile.lock
pod install
cd ..

# 再ビルド
flutter run
```

### 画像が見つからないエラー

```bash
# assetsディレクトリの確認
ls -la assets/icon/

# パスが正しいか確認
# pubspec.yaml のインデントが正しいか確認（スペース2つ）
```

### 適応型アイコンがおかしい

- フォアグラウンド画像のサイズが432x432pxか確認
- 透過背景になっているか確認（PNG形式）
- 重要な要素が中央の円形領域（直径288px）内に収まっているか確認

## 📊 セーフゾーン

Android適応型アイコンでは、以下の領域を考慮してデザインしてください：

```
432x432px 全体キャンバス
  ↓
288x288px 常に表示される円形領域（中央）
  ↓
108x108px 重要な要素を配置（超中央）
```

フォアグラウンド画像の中央 **288x288px** の円形領域内が、すべてのデバイスで表示される保証領域です。

## 🎨 カラーコード参考

水質検査報告アプリ用の推奨カラー：

```yaml
# プライマリブルー
adaptive_icon_background: "#2196F3"

# ダークブルー
adaptive_icon_background: "#1976D2"

# ライトブルー
adaptive_icon_background: "#64B5F6"

# グラデーション用（画像ファイルで対応）
# #2196F3 → #1976D2 の縦グラデーション
```

## 📝 設定ファイル例（完全版）

```yaml
# pubspec.yaml

name: waqu_repo
description: "Water Quality Reporter - 水質検査報告アプリ"
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: ^3.5.0

dependencies:
  flutter:
    sdk: flutter
  http: ^1.2.2
  shared_preferences: ^2.3.3
  intl: ^0.19.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0
  flutter_launcher_icons: ^0.14.1

flutter:
  uses-material-design: true
  
  # アイコンファイルをassetsとして登録（任意）
  assets:
    - assets/icon/

# アイコン生成設定
flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/icon/icon.png"
  adaptive_icon_foreground: "assets/icon/icon_foreground.png"
  adaptive_icon_background: "#2196F3"
  android_gravity: "center"
  android_min_sdk_android: 21
  remove_alpha_ios: true
```

## 🚀 次のステップ

アイコン生成が完了したら：

1. ✅ アイコンの動作確認
2. ✅ スクリーンショット撮影（Play Store用）
3. ✅ リリースビルドの作成
4. ✅ Play Storeへアップロード

詳細は `PLAYSTORE.md` を参照してください。

## 📚 参考リンク

- [flutter_launcher_icons パッケージ](https://pub.dev/packages/flutter_launcher_icons)
- [Android Adaptive Icons ガイド](https://developer.android.com/develop/ui/views/launch/icon_design_adaptive)
- [iOS App Icon ガイドライン](https://developer.apple.com/design/human-interface-guidelines/app-icons)

---

アイコン設定でお困りの場合は、`ICON_DESIGN.md` のデザインガイドも併せてご確認ください。
