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
    
    # リトライロジック付きGitクローン
    MAX_RETRIES=3
    RETRY_DELAY=5
    for ((i=1; i<=MAX_RETRIES; i++)); do
        echo "🔄 Attempting to clone Flutter (attempt $i/$MAX_RETRIES)..."
        if git clone https://github.com/flutter/flutter.git -b stable --depth 1; then
            echo "✅ Flutter cloned successfully"
            break
        else
            if [ $i -lt $MAX_RETRIES ]; then
                echo "⚠️  Clone failed, retrying in ${RETRY_DELAY}s..."
                sleep $RETRY_DELAY
                RETRY_DELAY=$((RETRY_DELAY * 2))
            else
                echo "❌ Flutter installation failed after $MAX_RETRIES attempts"
                exit 1
            fi
        fi
    done
    
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
    # 実ファイルを生成（Xcodeプロジェクトに登録済み）
    echo "$IOS_GOOGLE_SERVICE_INFO_PLIST" | base64 --decode > ios/Runner/GoogleService-Info.plist
    echo "✅ iOS GoogleService-Info.plist injected"
else
    echo "⚠️  IOS_GOOGLE_SERVICE_INFO_PLIST environment variable not found"
    echo "⚠️  Build may fail without Firebase configuration"
fi

# Flutter依存関係のインストール（リトライロジック付き）
echo "📦 Installing Flutter dependencies..."
MAX_PUB_RETRIES=3
for ((i=1; i<=MAX_PUB_RETRIES; i++)); do
    echo "🔄 flutter pub get (attempt $i/$MAX_PUB_RETRIES)..."
    if flutter pub get; then
        echo "✅ Dependencies installed successfully"
        break
    else
        if [ $i -lt $MAX_PUB_RETRIES ]; then
            echo "⚠️  pub get failed, retrying in 10s..."
            sleep 10
        else
            echo "❌ Failed to install dependencies after $MAX_PUB_RETRIES attempts"
            exit 1
        fi
    fi
done

# iOSエンジンのプリキャッシュ（リトライロジック付き）
echo "📥 Precaching iOS engine artifacts..."
MAX_CACHE_RETRIES=3
for ((i=1; i<=MAX_CACHE_RETRIES; i++)); do
    echo "🔄 flutter precache (attempt $i/$MAX_CACHE_RETRIES)..."
    if flutter precache --ios; then
        echo "✅ iOS artifacts precached successfully"
        break
    else
        if [ $i -lt $MAX_CACHE_RETRIES ]; then
            echo "⚠️  precache failed, retrying in 10s..."
            sleep 10
        else
            echo "⚠️  precache failed but continuing (may not be critical)"
        fi
    fi
done

# CocoaPods依存関係のインストール
echo "🍎 Installing CocoaPods dependencies..."
cd ios
pod install --repo-update || pod install
cd ..

# Flutter build準備（Xcode Cloudのビルドエラー対策）
echo "🔨 Preparing Flutter build for Xcode Cloud..."
flutter build ios --release --no-codesign

echo "✅ Post-clone script completed successfully!"
