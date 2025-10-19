#!/usr/bin/env python3
"""
フィーチャーグラフィック生成スクリプト
Play Store用の 1024 x 500 px の画像を生成
"""

from PIL import Image, ImageDraw, ImageFont
import os

# 設定
ICON_PATH = "../assets/icon/icon.png"
OUTPUT_PATH = "feature_graphic.png"
WIDTH = 1024
HEIGHT = 500
BACKGROUND_COLOR = (33, 150, 243)  # 青色（マテリアルデザイン）
TEXT_COLOR = (255, 255, 255)  # 白色

# アプリ情報
APP_NAME = "水質検査報告アプリ"
SUBTITLE = "残留塩素測定を効率化"


def create_feature_graphic():
    """フィーチャーグラフィックを生成"""

    # 背景画像を作成
    img = Image.new('RGB', (WIDTH, HEIGHT), BACKGROUND_COLOR)
    draw = ImageDraw.Draw(img)

    # アイコンを読み込み
    try:
        icon = Image.open(ICON_PATH)
        # アイコンのサイズを調整（300x300程度）
        icon = icon.resize((300, 300), Image.Resampling.LANCZOS)

        # アイコンを左側に配置
        icon_x = 80
        icon_y = (HEIGHT - 300) // 2

        # アイコンに透明度がある場合の処理
        if icon.mode == 'RGBA':
            img.paste(icon, (icon_x, icon_y), icon)
        else:
            img.paste(icon, (icon_x, icon_y))
    except Exception as e:
        print(f"アイコンの読み込みエラー: {e}")
        # アイコンなしでも続行
        icon_x = 0

    # テキストの配置位置
    text_x = icon_x + 320
    text_y_center = HEIGHT // 2

    # フォント設定（システムフォントを使用）
    try:
        # macOSの日本語フォント
        font_large = ImageFont.truetype(
            "/System/Library/Fonts/ヒラギノ角ゴシック W6.ttc", 70)
        font_small = ImageFont.truetype(
            "/System/Library/Fonts/ヒラギノ角ゴシック W3.ttc", 40)
    except Exception:
        try:
            # 別のmacOSフォント
            font_large = ImageFont.truetype(
                "/System/Library/Fonts/Hiragino Sans GB.ttc", 70)
            font_small = ImageFont.truetype(
                "/System/Library/Fonts/Hiragino Sans GB.ttc", 40)
        except Exception:
            # デフォルトフォント
            msg = "警告: システムフォントが見つかりません。"
            print(f"{msg}デフォルトフォントを使用します。")
            font_large = ImageFont.load_default()
            font_small = ImageFont.load_default()

    # アプリ名を描画
    draw.text((text_x, text_y_center - 50), APP_NAME,
              font=font_large, fill=TEXT_COLOR)

    # サブタイトルを描画
    draw.text((text_x, text_y_center + 40), SUBTITLE,
              font=font_small, fill=TEXT_COLOR)

    # 保存
    img.save(OUTPUT_PATH, 'PNG', quality=95)
    print(f"✅ フィーチャーグラフィックを生成しました: {OUTPUT_PATH}")
    print(f"   サイズ: {WIDTH} x {HEIGHT} px")

    # ファイルサイズを確認
    file_size = os.path.getsize(OUTPUT_PATH)
    print(f"   ファイルサイズ: {file_size / 1024:.1f} KB")

    if file_size > 1024 * 1024:
        print("⚠️  警告: ファイルサイズが1MBを超えています（Play Storeの制限）")


if __name__ == "__main__":
    print("🎨 フィーチャーグラフィックを生成中...")
    create_feature_graphic()
    print("✅ 完了！")
