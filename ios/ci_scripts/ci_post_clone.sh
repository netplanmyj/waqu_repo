#!/bin/bash

# Xcode Cloud用のビルド前スクリプト
# Flutter環境のセットアップとFirebase設定ファイルの注入

set -e

echo "🚀 Starting Xcode Cloud post-clone script..."

# 環境変数のデバッグ
echo "📍 CI_WORKSPACE: ${CI_WORKSPACE:-'(not set)'}"
echo "📍 CI_PRIMARY_REPOSITORY_PATH: ${CI_PRIMARY_REPOSITORY_PATH:-'(not set)'}"
echo "📍 Current directory: $(pwd)"

# ワークスペースのパスを決定（フォールバック処理）
if [ -z "$CI_WORKSPACE" ]; then
    echo "⚠️  CI_WORKSPACE not set, using /tmp as fallback"
    WORKSPACE_DIR="/tmp/xcode-cloud-workspace"
    mkdir -p "$WORKSPACE_DIR"
else
    WORKSPACE_DIR="$CI_WORKSPACE"
fi

# プロジェクトディレクトリを決定
if [ -z "$CI_PRIMARY_REPOSITORY_PATH" ]; then
    echo "⚠️  CI_PRIMARY_REPOSITORY_PATH not set, using current directory"
    PROJECT_DIR="$(pwd)"
else
    PROJECT_DIR="$CI_PRIMARY_REPOSITORY_PATH"
fi

# Flutter SDKのパスを設定
FLUTTER_ROOT="$WORKSPACE_DIR/flutter"
FLUTTER_BIN="$FLUTTER_ROOT/bin/flutter"

echo "📂 Flutter will be installed to: $FLUTTER_ROOT"

# Flutterのインストール（Xcode Cloudにはデフォルトで含まれていない）
if [ ! -d "$FLUTTER_ROOT" ]; then
    echo "📦 Installing Flutter..."
    cd "$WORKSPACE_DIR"
    git clone https://github.com/flutter/flutter.git -b stable --depth 1
    
    # Flutterのインストール確認
    if [ -f "$FLUTTER_BIN" ]; then
        "$FLUTTER_BIN" --version
        echo "✅ Flutter installed successfully"
    else
        echo "❌ Flutter installation failed - binary not found at $FLUTTER_BIN"
        exit 1
    fi
else
    echo "✅ Flutter already installed at $FLUTTER_ROOT"
fi

# PATHに追加
export PATH="$FLUTTER_ROOT/bin:$PATH"

# プロジェクトディレクトリに移動
cd "$PROJECT_DIR"
echo "📂 Working in: $(pwd)"

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

# iOSエンジンのプリキャッシュ（CocoaPodsに必要）
echo "📥 Precaching iOS engine artifacts..."
flutter precache --ios

# CocoaPods依存関係のインストール
echo "🍎 Installing CocoaPods dependencies..."
cd ios
pod install
cd ..

# Flutter build準備（Xcode Cloudのビルドエラー対策）
echo "🔨 Preparing Flutter build for Xcode Cloud..."
flutter build ios --release --no-codesign

echo "✅ Post-clone script completed successfully!"
