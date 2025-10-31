#!/bin/bash

# Xcode Cloud用のビルド直前スクリプト
# デバッグ情報の出力

set -e

echo "🔍 Pre-Xcodebuild Debug Information"
echo "📂 Current directory: $(pwd)"
echo ""

# GoogleService-Info.plistの存在確認
if [ -f "ios/Runner/GoogleService-Info.plist" ]; then
    echo "✅ GoogleService-Info.plist exists"
    echo "📄 File size: $(wc -c < ios/Runner/GoogleService-Info.plist) bytes"
else
    echo "❌ GoogleService-Info.plist NOT FOUND"
    echo "📂 Contents of ios/Runner/:"
    ls -la ios/Runner/ || echo "Directory not accessible"
fi

echo ""
echo "📦 Flutter version:"
flutter --version || echo "Flutter not found"

echo ""
echo "🍎 CocoaPods version:"
pod --version || echo "CocoaPods not found"

echo ""
echo "✅ Pre-Xcodebuild script completed"
