#!/usr/bin/env python3
"""
デベロッパーページヘッダー画像生成スクリプト（グラデーション版）
Play Store用の 4096 x 2304 px の画像を生成
"""

from PIL import Image, ImageDraw, ImageFont
import os

# 設定
ICON_PATH = "../assets/icon/netplan-logo.png"
OUTPUT_PATH = "developer_header_gradient.png"
WIDTH = 4096
HEIGHT = 2304
COLOR_START = (33, 150, 243)  # 青色（上部）
COLOR_END = (21, 101, 192)    # 濃い青（下部）
TEXT_COLOR = (255, 255, 255)  # 白色

# デベロッパー情報
DEVELOPER_NAME = "Netplan Matsuyama"
TAGLINE = "業務効率化を支援するアプリ開発"


def create_gradient_background(width, height, color_start, color_end):
    """グラデーション背景を作成"""
    img = Image.new('RGB', (width, height))
    draw = ImageDraw.Draw(img)

    # 垂直グラデーション
    for y in range(height):
        ratio = y / height
        r = int(color_start[0] * (1 - ratio) + color_end[0] * ratio)
        g = int(color_start[1] * (1 - ratio) + color_end[1] * ratio)
        b = int(color_start[2] * (1 - ratio) + color_end[2] * ratio)
        draw.line([(0, y), (width, y)], fill=(r, g, b))

    return img


def create_developer_header():
    """デベロッパーページヘッダー画像を生成"""

    # グラデーション背景を作成
    img = create_gradient_background(WIDTH, HEIGHT, COLOR_START, COLOR_END)
    draw = ImageDraw.Draw(img)

    # ロゴを読み込み
    try:
        icon = Image.open(ICON_PATH)
        # ロゴのサイズを調整（900x900に拡大）
        icon = icon.resize((900, 900), Image.Resampling.LANCZOS)

        # ロゴを左寄せに配置
        icon_x = 350
        icon_y = (HEIGHT - 900) // 2

        # ロゴに透明度がある場合の処理
        if icon.mode == 'RGBA':
            img.paste(icon, (icon_x, icon_y), icon)
        else:
            img.paste(icon, (icon_x, icon_y))
    except Exception as e:
        print(f"ロゴの読み込みエラー: {e}")
        # ロゴなしでも続行
        icon_x = 0

    # テキストの配置位置
    text_x = icon_x + 1000
    text_y_center = HEIGHT // 2

    # フォント設定（システムフォントを使用）
    try:
        # macOSの日本語フォント
        font_large = ImageFont.truetype(
            "/System/Library/Fonts/ヒラギノ角ゴシック W6.ttc", 200)
        font_small = ImageFont.truetype(
            "/System/Library/Fonts/ヒラギノ角ゴシック W3.ttc", 110)
    except Exception:
        try:
            # 別のmacOSフォント
            font_large = ImageFont.truetype(
                "/System/Library/Fonts/Hiragino Sans GB.ttc", 200)
            font_small = ImageFont.truetype(
                "/System/Library/Fonts/Hiragino Sans GB.ttc", 110)
        except Exception:
            # デフォルトフォント
            msg = "警告: システムフォントが見つかりません。"
            print(f"{msg}デフォルトフォントを使用します。")
            font_large = ImageFont.load_default()
            font_small = ImageFont.load_default()

    # デベロッパー名を描画
    draw.text((text_x, text_y_center - 130), DEVELOPER_NAME,
              font=font_large, fill=TEXT_COLOR)

    # タグラインを描画
    draw.text((text_x, text_y_center + 90), TAGLINE,
              font=font_small, fill=TEXT_COLOR)

    # 保存
    img.save(OUTPUT_PATH, 'PNG', quality=95, optimize=True)
    print(f"✅ デベロッパーヘッダー画像を生成しました: {OUTPUT_PATH}")
    print(f"   サイズ: {WIDTH} x {HEIGHT} px")

    # ファイルサイズを確認
    file_size = os.path.getsize(OUTPUT_PATH)
    print(f"   ファイルサイズ: {file_size / 1024:.1f} KB")

    if file_size > 1024 * 1024:
        print("⚠️  警告: ファイルサイズが1MBを超えています")


if __name__ == "__main__":
    print("🎨 デベロッパーヘッダー画像（グラデーション版）を生成中...")
    create_developer_header()
    print("✅ 完了！")
