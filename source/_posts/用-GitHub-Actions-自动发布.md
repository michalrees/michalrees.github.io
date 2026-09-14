---
title: 用 GitHub Actions 自动发布
date: 2026-09-14 22:20:00
tags:
  - GitHub
  - 部署
categories:
  - 博客
---

这篇文章是**推送链路测试**:内容在本地写完只做 `git push`,由 GitHub Actions 在云端构建并发布,验证不需要本地的「生成 + 部署」两步。

## 为什么改成 Actions

之前是本地 `hexo generate` 出静态文件、再推到 `gh-pages` 分支,由 Pages 发布那个分支。这条路能跑通,但有两个麻烦:

1. 本地必须装好 Node 与 Hexo 依赖才能发布
2. Pages 的 legacy 构建会把仓库内容当 Jekyll 站点处理,容易踩到「主题找不到」之类的坑

改成 Actions 之后,推送即发布:`main` 上是源码,构建发生在 GitHub 的服务器上,发布源是 Actions 产物,不再经过 Jekyll。

## 日常流程

```bash
git add .
git commit -m "新文章"
git push
```

推完大约一分钟,线上就会更新。
