---
title: 这是第一篇文章：把博客跑起来
date: 2025-12-01 10:00:00
tags:
  - Hexo
  - Butterfly
categories:
  - 博客
description: 用 Hexo + Butterfly 生成的第一篇示例文章，确认渲染效果用。
---

这是用 **Hexo + Butterfly** 生成的第一篇示例文章。确认下面的效果都正常之后，就可以把它删掉或者改成你自己的内容。

## 代码块效果

```javascript
// 语法高亮
const site = 'https://michalrees.github.io'
console.log(`博客地址是 ${site}`)
```

```bash
# 本地预览
hexo server
```

## 常用命令

| 命令 | 作用 |
|---|---|
| `hexo new "文章标题"` | 新建一篇文章 |
| `hexo server` | 本地预览（默认 http://localhost:4000） |
| `hexo clean && hexo generate` | 清缓存并重新生成静态文件 |
| `hexo deploy` | 部署到 GitHub Pages |

## 公式和流程图

按需在 `_config.butterfly.yml` 里打开 `math`（数学公式）、`mermaid`（流程图）等开关即可。

> 这篇文章的源文件在 `source/_posts/hello-world.md`，可以直接改。
