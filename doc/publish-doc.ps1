<#
.SYNOPSIS
    把 doc\ 里的文章原稿同步到 source\_posts\（以 doc\ 为唯一事实源）。

.DESCRIPTION
    - doc\*.md 是原稿；source\_posts\ 只是发布副本，由本脚本单向覆盖生成。
    - 文件名前缀的日期（2026-09-15-标题.md）只用于排序，同步时会去掉，
      文章的 URL 日期由 front-matter 里的 date 决定。
    - 默认只新增/覆盖，不删除任何东西；要清理已删除的文章用 -Prune。

.EXAMPLE
    .\doc\publish-doc.ps1
    同步 doc\ 下全部文章。

.EXAMPLE
    .\doc\publish-doc.ps1 -Name 我的新文章
    只同步一篇（写文件名或去掉日期后的名字都行）。

.EXAMPLE
    .\doc\publish-doc.ps1 -DryRun
    只看会发生什么，不写任何文件。

.EXAMPLE
    .\doc\publish-doc.ps1 -Prune
    同步，并列出 source\_posts\ 里 doc\ 已经没有的文章，确认后删除。
#>
[CmdletBinding()]
param(
    [string]$Name,
    [switch]$Prune,
    [switch]$Force,
    [switch]$DryRun
)

$ErrorActionPreference = 'Stop'

# ---------- 定位 Hexo 根目录 ----------
$root = Split-Path -Parent $PSScriptRoot
$docDir = Join-Path $root 'doc'
$postDir = Join-Path $root 'source\_posts'

if (-not (Test-Path (Join-Path $root '_config.yml')) -or -not (Test-Path $postDir)) {
    throw "在 $root 没找到 Hexo 站点（缺 _config.yml 或 source\_posts）。本脚本需放在 <博客根目录>\doc\ 下。"
}

# ---------- 工具函数 ----------
function Get-Slug([string]$fileName) {
    $slug = [System.IO.Path]::GetFileNameWithoutExtension($fileName)
    $stripped = $slug -replace '^\d{4}-\d{2}-\d{2}[-_ ]+', ''
    if ([string]::IsNullOrWhiteSpace($stripped)) { return $slug }
    return $stripped
}

function Get-DocArticles {
    Get-ChildItem -LiteralPath $docDir -File -Filter '*.md' |
        Where-Object { $_.Name -notlike '_*' -and $_.Name -ne 'README.md' }
}

# ---------- 收集原稿 ----------
$sources = @(Get-DocArticles)
if ($Name) {
    $want = Get-Slug $Name
    $sources = @($sources | Where-Object { (Get-Slug $_.Name) -eq $want })
    if ($sources.Count -eq 0) { throw "doc\ 里没有找到文章：$Name" }
}

$items = foreach ($src in $sources) {
    $dest = Join-Path $postDir "$(Get-Slug $src.Name).md"
    $state = if (-not (Test-Path -LiteralPath $dest)) { 'add' }
    elseif ((Get-FileHash -LiteralPath $src.FullName).Hash -ne (Get-FileHash -LiteralPath $dest).Hash) { 'update' }
    else { 'same' }
    [pscustomobject]@{ Name = $src.Name; Src = $src.FullName; Dest = $dest; State = $state }
}
$items = @($items)

# 两个原稿会映射到同一个发布文件名时直接报错，避免互相覆盖
$clash = @($items | Group-Object Dest | Where-Object { $_.Count -gt 1 })
if ($clash.Count -gt 0) {
    $detail = ($clash | ForEach-Object { "  $(Split-Path -Leaf $_.Name)  ← " + (($_.Group | ForEach-Object { $_.Name }) -join ', ') }) -join "`n"
    throw "以下原稿会生成同一个发布文件名，请改名后重试：`n$detail"
}

# 没写 front-matter 的原稿提醒一下（Hexo 会用文件名当标题）
foreach ($it in $items) {
    if ((Get-Content -LiteralPath $it.Src -TotalCount 1) -ne '---') {
        Write-Warning "$($it.Name) 第一行不是 ---，可能缺少 front-matter"
    }
}

# ---------- 清理列表 ----------
$orphans = @()
if ($Prune) {
    $docSlugs = @(Get-DocArticles | ForEach-Object { Get-Slug $_.Name })
    $orphans = @(Get-ChildItem -LiteralPath $postDir -File -Filter '*.md' |
        Where-Object { $docSlugs -notcontains (Get-Slug $_.Name) })
}

# ---------- 执行 ----------
Write-Host "doc\ 原稿 $($items.Count) 篇  →  source\_posts\" -ForegroundColor Cyan
foreach ($it in ($items | Where-Object State -eq 'add')) {
    Write-Host "  + 新增  $($it.Name)  →  $(Split-Path -Leaf $it.Dest)" -ForegroundColor Green
    if (-not $DryRun) { Copy-Item -LiteralPath $it.Src -Destination $it.Dest -Force }
}
foreach ($it in ($items | Where-Object State -eq 'update')) {
    Write-Host "  ~ 更新  $($it.Name)  →  $(Split-Path -Leaf $it.Dest)" -ForegroundColor Yellow
    if (-not $DryRun) { Copy-Item -LiteralPath $it.Src -Destination $it.Dest -Force }
}
foreach ($it in ($items | Where-Object State -eq 'same')) {
    Write-Host "  = 未变  $($it.Name)" -ForegroundColor DarkGray
}

if ($Prune) {
    Write-Host ""
    if ($orphans.Count -eq 0) {
        Write-Host "  没有需要清理的文章" -ForegroundColor DarkGray
    }
    else {
        Write-Host "以下文件只在 source\_posts\ 里，doc\ 已无对应原稿：" -ForegroundColor Magenta
        $orphans | ForEach-Object { Write-Host "  - $($_.Name)" -ForegroundColor Magenta }
        $go = $Force
        if (-not $go) {
            try {
                $ans = Read-Host "确认删除这 $($orphans.Count) 个文件？(y/N)"
                $go = ($ans -eq 'y' -or $ans -eq 'Y')
            }
            catch {
                Write-Host "  当前不是交互式终端，无法询问；已跳过清理（确实要删请加 -Force）" -ForegroundColor DarkGray
                $go = $false
            }
        }
        if (-not $go) {
            Write-Host "  已跳过清理" -ForegroundColor DarkGray
        }
        elseif ($DryRun) {
            Write-Host "  （DryRun：未真正删除）" -ForegroundColor DarkGray
        }
        else {
            $orphans | ForEach-Object {
                Remove-Item -LiteralPath $_.FullName -Force
                Write-Host "  - 已删除 $($_.Name)" -ForegroundColor Red
            }
        }
    }
}

Write-Host ""
if ($DryRun) {
    Write-Host "DryRun 模式：没有写入任何文件。" -ForegroundColor Cyan
    return
}

Write-Host "下一步：" -ForegroundColor Cyan
Write-Host "  pnpm exec hexo clean; pnpm exec hexo server    # 本地预览 http://localhost:4000"
Write-Host '  git add .; git commit -m "新文章：标题"; git push   # 推送后约 1 分钟上线'
