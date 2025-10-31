#!/bin/bash

# Xcode Cloud用のビルド後スクリプト
# ビルド結果の詳細を出力

echo "🔍 Post-Xcodebuild Debug Information"
echo ""

# ビルド結果の確認
if [ -d "/Volumes/workspace/build.xcarchive" ]; then
    echo "✅ Archive created successfully"
    echo "📦 Archive contents:"
    ls -la /Volumes/workspace/build.xcarchive/Products/Applications/ || echo "No applications found"
else
    echo "❌ Archive NOT created"
fi

echo ""
echo "📊 Build result bundle:"
if [ -d "/Volumes/workspace/resultbundle.xcresult" ]; then
    echo "✅ Result bundle exists"
    
    # xcresultツールで詳細なエラーを抽出
    if command -v xcrun &> /dev/null; then
        echo ""
        echo "🔍 Extracting build errors..."
        xcrun xcresulttool get --format json --path /Volumes/workspace/resultbundle.xcresult > /tmp/build_result.json 2>&1 || true
        
        # エラーメッセージを検索
        if [ -f /tmp/build_result.json ]; then
            echo "📄 Searching for errors in result bundle..."
            grep -i "error" /tmp/build_result.json | head -20 || echo "No errors found in JSON"
        fi
    fi
else
    echo "❌ Result bundle NOT found"
fi

echo ""
echo "✅ Post-Xcodebuild script completed"
