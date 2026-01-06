# Astro サイト用 Markdown ファイル

HTMLファイルをAstro対応のMarkdown形式に変換しました。

## 📁 作成ファイル

1. **`webdocs/index.md`** - アプリ紹介ページ
2. **`webdocs/privacy-policy.md`** - プライバシーポリシー

---

## 🎨 Astroでの使用方法

### 方法1: Markdownファイルとして直接使用

```bash
# Astroプロジェクトにコピー
cp webdocs/index.md your-astro-project/src/pages/waqu/index.md
cp webdocs/privacy-policy.md your-astro-project/src/pages/waqu/privacy-policy.md
```

**アクセスURL**:
- https://yourdomain.com/waqu/
- https://yourdomain.com/waqu/privacy-policy/

---

### 方法2: Astro Content Collections を使用

#### ステップ1: Content Collections設定

```typescript
// src/content/config.ts
import { defineCollection, z } from 'astro:content';

const waquCollection = defineCollection({
  type: 'content',
  schema: z.object({
    title: z.string(),
    description: z.string(),
    pubDate: z.date().optional(),
  }),
});

export const collections = {
  'waqu': waquCollection,
};
```

#### ステップ2: ファイル配置

```bash
mkdir -p your-astro-project/src/content/waqu/
cp webdocs/index.md your-astro-project/src/content/waqu/index.md
cp webdocs/privacy-policy.md your-astro-project/src/content/waqu/privacy-policy.md
```

#### ステップ3: ページ作成

```astro
---
// src/pages/waqu/[...slug].astro
import { getCollection } from 'astro:content';

export async function getStaticPaths() {
  const waquPages = await getCollection('waqu');
  return waquPages.map(page => ({
    params: { slug: page.slug },
    props: { page },
  }));
}

const { page } = Astro.props;
const { Content } = await page.render();
---

<html>
  <head>
    <title>{page.data.title}</title>
    <meta name="description" content={page.data.description} />
  </head>
  <body>
    <article>
      <Content />
    </article>
  </body>
</html>
```

---

## 🎯 Astro用レイアウト例

### 基本レイアウト

```astro
---
// src/layouts/WaquLayout.astro
interface Props {
  title: string;
  description?: string;
}

const { title, description } = Astro.props;
---

<!DOCTYPE html>
<html lang="ja">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>{title}</title>
  {description && <meta name="description" content={description} />}
  <style>
    body {
      font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
      line-height: 1.6;
      color: #333;
      max-width: 800px;
      margin: 0 auto;
      padding: 20px;
    }
    
    h1 {
      color: #2196F3;
      border-bottom: 3px solid #2196F3;
      padding-bottom: 10px;
    }
    
    h2 {
      color: #1976D2;
      margin-top: 30px;
      padding-left: 10px;
      border-left: 4px solid #2196F3;
    }
    
    table {
      width: 100%;
      border-collapse: collapse;
      margin: 20px 0;
    }
    
    th, td {
      border: 1px solid #ddd;
      padding: 12px;
      text-align: left;
    }
    
    th {
      background-color: #2196F3;
      color: white;
    }
    
    code {
      background-color: #f4f4f4;
      padding: 2px 6px;
      border-radius: 3px;
      font-family: monospace;
    }
    
    a {
      color: #2196F3;
      text-decoration: none;
    }
    
    a:hover {
      text-decoration: underline;
    }
  </style>
</head>
<body>
  <main>
    <slot />
  </main>
</body>
</html>
```

### 使用例

```markdown
---
title: "プライバシーポリシー"
description: "水質検査報告アプリのプライバシーポリシー"
layout: ../../layouts/WaquLayout.astro
---

# プライバシーポリシー

本文...
```

---

## 🔧 カスタムコンポーネント例

### Noteコンポーネント（:::note[重要] の代替）

```astro
---
// src/components/Note.astro
interface Props {
  type?: 'info' | 'warning' | 'tip';
  title?: string;
}

const { type = 'info', title } = Astro.props;

const colors = {
  info: { bg: '#E3F2FD', border: '#2196F3' },
  warning: { bg: '#FFF3E0', border: '#FF9800' },
  tip: { bg: '#E8F5E9', border: '#4CAF50' },
};

const color = colors[type];
---

<div class="note" style={`background-color: ${color.bg}; border-left: 4px solid ${color.border};`}>
  {title && <strong>{title}</strong>}
  <slot />
</div>

<style>
  .note {
    padding: 15px;
    border-radius: 4px;
    margin: 15px 0;
  }
  
  .note strong {
    display: block;
    margin-bottom: 5px;
  }
</style>
```

### 使用例

```astro
---
import Note from '../../components/Note.astro';
---

<Note type="warning" title="重要">
  本アプリは、ユーザーのGmailアカウントを使用してメールを送信します。
</Note>
```

---

## 🎨 カスタムスタイリング

### グラデーション背景（index.html風）

```astro
---
// src/pages/waqu/index.astro
---

<div class="hero">
  <h1>💧 水質検査報告アプリ</h1>
  <p>水道施設の残留塩素濃度を簡単にメール報告</p>
</div>

<style>
  .hero {
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    color: white;
    text-align: center;
    padding: 60px 20px;
    border-radius: 12px;
    margin-bottom: 40px;
  }
  
  .hero h1 {
    font-size: 3em;
    margin: 0 0 20px 0;
  }
  
  .hero p {
    font-size: 1.3em;
    opacity: 0.9;
  }
</style>
```

---

## 📦 プラグイン推奨

### Astro統合

```bash
# Tailwind CSS（スタイリング）
npm install -D @astrojs/tailwind tailwindcss

# MDX（拡張Markdown）
npm install -D @astrojs/mdx

# Sitemap（SEO）
npm install -D @astrojs/sitemap
```

### astro.config.mjs

```javascript
import { defineConfig } from 'astro/config';
import tailwind from '@astrojs/tailwind';
import mdx from '@astrojs/mdx';
import sitemap from '@astrojs/sitemap';

export default defineConfig({
  site: 'https://yourdomain.com',
  integrations: [
    tailwind(),
    mdx(),
    sitemap(),
  ],
});
```

---

## 🔗 内部リンク修正

### Markdown内のリンク

現在のMarkdownファイルでは相対パス使用：

```markdown
[プライバシーポリシー](/waqu/privacy-policy)
```

### Astroのルーティングに合わせる

```markdown
<!-- Content Collectionsの場合 -->
[プライバシーポリシー](/waqu/privacy-policy/)

<!-- 静的ページの場合 -->
[プライバシーポリシー](/waqu/privacy-policy)
```

---

## ✅ チェックリスト

### ファイル配置
- [ ] `index.md` をAstroプロジェクトにコピー
- [ ] `privacy-policy.md` をAstroプロジェクトにコピー
- [ ] レイアウトファイル作成（オプション）
- [ ] カスタムコンポーネント作成（オプション）

### フロントマター確認
- [ ] `title` が正しい
- [ ] `description` が正しい
- [ ] `layout` パスが正しい（使用する場合）

### リンク確認
- [ ] 内部リンクが動作する
- [ ] 外部リンクが動作する
- [ ] 相対パスが正しい

### スタイル確認
- [ ] デスクトップ表示確認
- [ ] モバイル表示確認（レスポンシブ）
- [ ] テーブルが正しく表示
- [ ] コードブロックが正しく表示

---

## 🚀 デプロイ

```bash
# ビルド
npm run build

# プレビュー
npm run preview

# 本番デプロイ（Netlify, Vercel等）
git push origin main
```

---

## 📝 補足

### MDX を使用する場合

ファイル拡張子を `.mdx` に変更し、Astroコンポーネントを直接使用できます：

```mdx
---
title: "プライバシーポリシー"
---
import Note from '../../components/Note.astro';

# プライバシーポリシー

<Note type="warning" title="重要">
  本アプリは、ユーザーのGmailアカウントを使用してメールを送信します。
</Note>
```

### Markdocを使用する場合

```bash
npm install -D @astrojs/markdoc
```

カスタムタグで `:::note[重要]` のような構文をサポート可能。

---

## 💡 ヒント

1. **SEO対策**: フロントマターに `pubDate`、`author`、`tags` を追加
2. **OGP画像**: `image` フィールドでSNSシェア用画像設定
3. **目次生成**: `remark-toc` プラグイン使用
4. **構文ハイライト**: Shikiがデフォルトで有効

---

これで、Astroサイトに水質検査報告アプリのページを簡単に統合できます！
