# Lumina Labs

AI 前沿文章中文摘译站 — 自动采集 + 机器翻译 + 人工质检 → GitHub Pages。

- 站点：<https://darkhucx.github.io/Lumina-Labs/>
- 内容流水线在 dk-kanban（私有），本仓只是**发布站**：只装主题、`_config.yml`、Action 和 `_posts/`。
- 隐私：草稿 / rejected / archived 的笔记**从不**进本公开仓；只有 `status: published` 的篇目经 `publish.sh` 同步进来。

## 发布流程（人工 push = 质检闸）

1. 在 Obsidian vault 里质检，通过的把 frontmatter 改 `status: published`。
2. 跑 `./publish.sh`：读 vault、只挑 published、重映射成 `_posts/YYYY-MM-DD-slug.md`。
3. `git add _posts && git commit && git push`。
4. GitHub Action 自动 `jekyll build` 并部署 Pages。

## 本地预览（Docker，无需装 ruby）

系统 ruby 太旧，用官方 `jekyll/jekyll` 镜像经 colima 跑：

```sh
make build    # 一次性构建到 _site/
make serve    # 实时预览 http://localhost:4000
```

## 主题

复古像素风：[NES.css](https://nostalgic-css.github.io/NES.css/)（MIT）+ Press Start 2P 字体做 chrome；
中文正文用系统可读字体（像素字体无 CJK 字形，只用于站名/标签等装饰）。
