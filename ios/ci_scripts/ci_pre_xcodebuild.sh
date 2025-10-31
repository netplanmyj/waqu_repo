#!/bin/bash

# Xcode Cloud用のビルド直前スクリプト
# デバッグ情報の出力

set -e

echo "🔍 Pre-Xcodebuild Debug Information"
echo "📂 Current directory: $(pwd)"

# プロジェクトルートに移動
cd "$CI_PRIMARY_REPOSITORY_PATH" || cd ../..
echo "📂 Moved to: $(pwd)"
echo ""

# Flutter PATHの設定
WORKSPACE_DIR="${CI_WORKSPACE:-/tmp/xcode-cloud-workspace}"
export PATH="$WORKSPACE_DIR/flutter/bin:$PATH"

# GoogleService-Info.plistの存在確認
if [ -f "ios/Runner/GoogleService-Info.plist" ]; then
    echo "✅ GoogleService-Info.plist exists"
    echo "📄 File size: $(wc -c < ios/Runner/GoogleService-Info.plist) bytes"
else
    echo "❌ GoogleService-Info.plist NOT FOUND"
    echo "📂 Contents of ios/Runner/:"
    ls -la ios/Runner/ 2>&1 || echo "Directory not accessible"
    echo ""
    echo "📂 Checking environment variable:"
    if [ -n "$IOS_GOOGLE_SERVICE_INFO_PLIST" ]; then
        echo "✅ IOS_GOOGLE_SERVICE_INFO_PLIST is set (length: ${#IOS_GOOGLE_SERVICE_INFO_PLIST})"
    else
        echo "❌ IOS_GOOGLE_SERVICE_INFO_PLIST is NOT set"
    fi
fi

echo ""
echo "📦 Flutter version:"
flutter --version 2>&1 || echo "Flutter not found in PATH: $PATH"

echo ""
echo "🍎 CocoaPods version:"
pod --version || echo "CocoaPods not found"

echo ""
echo "✅ Pre-Xcodebuild script completed"
