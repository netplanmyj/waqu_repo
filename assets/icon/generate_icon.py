#!/usr/bin/env python3
"""
水質報告アプリ - アイコン生成スクリプト
シンプルな水滴モチーフのアイコンを生成します
"""

from PIL import Image, ImageDraw
import os


def create_water_drop_icon(
    size, output_path, has_background=True, background_color="#2196F3"
):
    """
    水滴モチーフのアイコンを生成

    Args:
        size: 画像サイズ（正方形）
        output_path: 出力ファイルパス
        has_background: 背景を含むか（Falseの場合は透過）
        background_color: 背景色（16進数）
    """
    # RGBに変換
    bg_r = int(background_color[1:3], 16)
    bg_g = int(background_color[3:5], 16)
    bg_b = int(background_color[5:7], 16)

    # 画像作成
    if has_background:
        img = Image.new('RGB', (size, size), (bg_r, bg_g, bg_b))
    else:
        img = Image.new('RGBA', (size, size), (0, 0, 0, 0))

    draw = ImageDraw.Draw(img)

    # 水滴の描画パラメータ
    center_x = size // 2
    center_y = size // 2
    drop_width = size // 3  # 水滴の幅
    drop_height = int(drop_width * 1.4)  # 水滴の高さ（縦長）

    # 水滴の色（白）
    drop_color = (255, 255, 255) if has_background else (255, 255, 255, 255)

    # 水滴の形を描画（簡易版：楕円 + 三角）
    # 上部の楕円
    oval_top = center_y - drop_height // 2
    oval_bottom = center_y + drop_height // 4
    oval_left = center_x - drop_width // 2
    oval_right = center_x + drop_width // 2

    draw.ellipse(
        [oval_left, oval_top, oval_right, oval_bottom],
        fill=drop_color,
        outline=drop_color
    )

    # 下部の三角（尖った部分）
    triangle_points = [
        (center_x, center_y + drop_height // 2),  # 下の尖り
        (oval_left, oval_bottom),  # 左上
        (oval_right, oval_bottom)  # 右上
    ]
    draw.polygon(triangle_points, fill=drop_color, outline=drop_color)

    # ハイライト（光沢効果）- 小さい楕円
    if has_background or not has_background:
        highlight_size = drop_width // 4
        highlight_x = center_x - drop_width // 6
        highlight_y = center_y - drop_height // 4

        highlight_color = (
            (255, 255, 255, 180) if not has_background else (255, 255, 255)
        )

        if has_background:
            # RGBモードの場合は明るいブルー
            highlight_color = (187, 222, 251)  # #BBDEFB

        draw.ellipse(
            [
                highlight_x - highlight_size // 2,
                highlight_y - highlight_size // 2,
                highlight_x + highlight_size // 2,
                highlight_y + highlight_size // 2
            ],
            fill=highlight_color
        )

    # 保存
    img.save(output_path)
    print(f"✅ 作成完了: {output_path} ({size}x{size}px)")


def main():
    """メイン処理"""
    print("🎨 水質報告アプリ - アイコン生成")
    print("=" * 50)

    # 出力ディレクトリ
    current_dir = os.path.dirname(os.path.abspath(__file__))

    # 1. マスターアイコン (1024x1024px)
    print("\n📐 マスターアイコン生成中...")
    create_water_drop_icon(
        size=1024,
        output_path=os.path.join(current_dir, "icon.png"),
        has_background=True,
        background_color="#2196F3"
    )

    # 2. フォアグラウンド (432x432px, 透過)
    print("\n📐 フォアグラウンドアイコン生成中...")
    create_water_drop_icon(
        size=432,
        output_path=os.path.join(current_dir, "icon_foreground.png"),
        has_background=False,
        background_color="#2196F3"
    )

    # 3. レガシーアイコン (512x512px) - Play Store用
    print("\n📐 レガシーアイコン生成中...")
    create_water_drop_icon(
        size=512,
        output_path=os.path.join(current_dir, "icon_legacy.png"),
        has_background=True,
        background_color="#2196F3"
    )

    print("\n" + "=" * 50)
    print("✨ すべてのアイコンを生成しました！")
    print("\n次のステップ:")
    print("1. 生成されたアイコンを確認")
    print("2. 必要に応じてデザインツールで調整")
    print("3. flutter pub get を実行")
    print("4. flutter pub run flutter_launcher_icons を実行")
    print("\n詳細は ICON_SETUP.md を参照してください。")


if __name__ == "__main__":
    main()
