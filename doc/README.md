# doc —— 博客文章原稿库（唯一事实源）

这里存放**每一篇博客的 Markdown 原稿**，是你写文章的地方。

> `doc/` 在 Hexo 的 `source/` 之外，**不会被生成到网站**。
> 发布靠 `publish-doc.ps1` 单向同步到 `source/_posts/`。
> **规则：只改 `doc/` 里的原稿，`source/_posts/` 里的文件不要手改**（下次同步会被覆盖）。
>
> 全站日常操作（推送、验证线上、踩坑速查）见博客根目录的 [../日常使用.md](../日常使用.md)。

## 目录约定

| 文件 | 用途 |
|---|---|
| `_模板.md` | 空白模板，写新文章时复制它 |
| `publish-doc.ps1` | 同步脚本：`doc/*.md` → `source/_posts/*.md` |
| `README.md` | 本说明 |
| `你的文章.md` | 文章原稿（含已收录的 `个人简历.md`） |

原稿命名建议 `标题.md` 或 `2026-09-15-标题.md`：

- `_` 开头的文件（如 `_模板.md`）和 `README.md` **不会被同步**
- 文件名前缀的日期只用于自己排序，同步时会自动去掉；文章的 URL 日期由 front-matter 的 `date` 决定
- 文件名会成为文章的 URL（`permalink: :year/:month/:day/:title/`），所以**改文件名等于改链接**，发布后尽量别再改
- 两个原稿去掉日期后重名会报错（避免互相覆盖）

## 写一篇新文章

```powershell
cd E:\Haoran\Blog
Copy-Item "doc\_模板.md" "doc\我的新文章.md"
```

然后编辑 `doc\我的新文章.md`，填好 front-matter（`title` / `date` / `tags` / `description`）。

## 发布：同步 + 推送

```powershell
cd E:\Haoran\Blog

# 1. 同步原稿到发布目录
.\doc\publish-doc.ps1

# 2. 本地预览（可选，http://localhost:4000）
pnpm exec hexo clean
pnpm exec hexo server

# 3. 推送，GitHub Actions 自动构建，约 1 分钟上线
git add .
git commit -m "新文章：我的新文章"
git push
```

线上地址：<https://michalrees.github.io/>

### 脚本参数

| 参数 | 作用 |
|---|---|
| `-Name 我的新文章` | 只同步一篇（带不带日期前缀、带不带 `.md` 都行） |
| `-DryRun` | 只显示会发生什么，不写任何文件 |
| `-Prune` | 同步后列出 `source/_posts/` 里 `doc/` 已无对应原稿的文件，**确认后**删除 |
| `-Force` | 配合 `-Prune`，跳过确认（慎用） |

注意：`-Prune` 不认「只存在于 `source/_posts/`、从没进过 `doc/`」的文章——它们同样会被列为待删，
所以**新文章一定要先放进 `doc/`**。目前 `doc/` 已收录全部文章（含 `个人简历.md`），`-Prune` 可以放心用。

同步行为是幂等的：内容没变就显示 `= 未变` 并跳过，不会产生多余的 git 改动。

## Front-matter 字段速查

文件最上方 `---` 之间的部分叫 front-matter，用 YAML 写。模板里已备好常用字段，说明如下（依据 [Butterfly 官方文档](https://butterfly.js.org/posts/dc584b87/)）：

| 字段 | 说明 |
|---|---|
| `title` | **必需**，文章标题 |
| `date` | **必需**，创建时间，格式 `YYYY-MM-DD HH:mm:ss` |
| `updated` | 可选，更新时间；留空则按文件修改时间自动取 |
| `tags` | 可选，标签，多个用 `- ` 列表写 |
| `categories` | 可选，分类，同上 |
| `keywords` | 可选，SEO 关键词 |
| `description` | 可选，文章描述；首页卡片、搜索结果、SEO 都会用 |
| `top_img` | 可选，文章页顶部大图；留空用主题默认 |
| `cover` | 可选，缩略图；未设 `top_img` 时文章页顶部显示它 |
| `toc` | 可选，是否显示右侧目录（本站全局已开启） |
| `comments` | 可选，是否显示评论（本站未启用评论系统） |
| `copyright` | 可选，是否显示版权模块（本站全局已开启） |
| `mathjax` / `katex` | 可选，按需加载数学公式引擎 |
| `aside` | 可选，是否显示侧边栏 |
| `sticky` | 可选，置顶权重，数字越大越靠前（`个人简历` 用的 `sticky: 1`） |

## 本站当前的功能开关（2026-09 状态）

写文章时会受影响，记一下：

- **目录 TOC**：已开启，每篇文章右侧自动生成，标题用 `##`、`###` 即可
- **版权声明**：已开启，自动附加「CC BY-NC-SA 4.0」，无需手写
- **评论**：`comments.use` 为空，**未启用**，front-matter 里写 `comments` 也没用
- **数学公式**：`math.use` 为空，**当前不渲染公式**。要用公式需先在 `_config.butterfly.yml` 里把 `math.use` 设为 `katex`，文章里再用 `$...$` / `$$...$$`
- **Mermaid 流程图**：`mermaid.enable: false`，**未开启**，代码块写 mermaid 只会当普通代码显示
- **站内搜索**：`local_search`，标题、正文与 `description` 都会被检索到，所以 `description` 值得认真写
- **图片**：放在 `source/img/` 下，文章里用 `/img/xxx.png` 引用（开头带斜杠）
- **字数统计**：未安装 `hexo-wordcount`，不显示字数

## 关于模板的另一个入口

现在 `pnpm exec hexo new "标题"` 生成的骨架只含 `title`/`date`（来自 `scaffolds/post.md`）。
用本文件夹的流程时**不需要**跑 `hexo new`，直接复制 `_模板.md` 即可。
如果你仍想让 `hexo new` 产出同样的完整 front-matter，把 `_模板.md` 的内容（`title` 换成 `{{ title }}`、`date` 换成 `{{ date }}`）填进 `scaffolds/post.md`。
