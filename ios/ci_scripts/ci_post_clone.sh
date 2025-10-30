#!/bin/bash

# Xcode Cloud用のビルド前スクリプト
# Flutter環境のセットアップとFirebase設定ファイルの注入

set -e

echo "🚀 Starting Xcode Cloud post-clone script..."

# Flutterのインストール（Xcode Cloudにはデフォルトで含まれていない）
if ! command -v flutter > /dev/null 2>&1; then
    echo "📦 Installing Flutter..."
    cd "$CI_WORKSPACE"
    git clone https://github.com/flutter/flutter.git -b stable --depth 1
    export PATH="$PATH:$CI_WORKSPACE/flutter/bin"
    
    # Flutterのインストール確認
    flutter --version || {
        echo "❌ Flutter installation failed"
        exit 1
    }
else
    echo "✅ Flutter already installed"
fi

# プロジェクトディレクトリに移動
cd "$CI_PRIMARY_REPOSITORY_PATH"

# Firebase設定ファイルの注入（環境変数から）
# Xcode CloudのEnvironment Variablesで設定する必要があります
if [ -n "$IOS_GOOGLE_SERVICE_INFO_PLIST" ]; then
    echo "🔑 Injecting GoogleService-Info.plist from environment..."
    echo "$IOS_GOOGLE_SERVICE_INFO_PLIST" | base64 --decode > ios/Runner/GoogleService-Info.plist
    echo "✅ iOS GoogleService-Info.plist created"
else
    echo "⚠️  IOS_GOOGLE_SERVICE_INFO_PLIST environment variable not found"
    echo "⚠️  Build may fail without Firebase configuration"
fi

# Flutter依存関係のインストール
echo "📦 Installing Flutter dependencies..."
flutter pub get

# CocoaPods依存関係のインストール
echo "🍎 Installing CocoaPods dependencies..."
cd ios
pod install
cd ..

echo "✅ Post-clone script completed successfully!"
