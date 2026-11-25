# 自定义 AstroPapeR

这份指南从「改一行 CSS」到「重写 pandoc 模板」逐层覆盖。前提是你已经把包
clone 到本地，并且知道怎么 knit 一个 R Markdown 文件。

> English version: [customize.md](customize.md)

## 东西都在哪

| 想改什么 | 改哪里 |
|---|---|
| 单篇文档的临时样式 | 文档 YAML 里的 `css:` |
| 颜色、字体、间距等 token | `inst/css/src/theme.css` |
| 正文排版（标题、链接、表格、代码块） | `inst/css/src/typography.css` |
| 页面结构（标题区、目录、页脚） | `inst/templates/astropaper.html` |
| 代码高亮配色 | `inst/themes/astropaper.theme` |
| `astropaper()` 的默认参数 | `R/astropaper.R` |
| 真正随包发布的成品样式 | `inst/css/astropaper.compiled.css` |

样式由三层拼起来：

1. **设计 token** —— `theme.css` 里的 CSS 变量，通过 Tailwind 的 `@theme`
   注册，于是有了 `bg-background`、`text-accent` 这些工具类。
2. **组件规则** —— `typography.css` 里的 Tailwind Typography 与 `.app-prose`
   覆盖，加上 `astropaper.css` 里少量针对 pandoc 产物的规则。
3. **标记** —— pandoc 模板里直接写的工具类。

三层最终编译成 `inst/css/astropaper.compiled.css`，包发布的就是这个文件。它是
**生成物**：改源码后不重新编译不会生效（见[重新编译样式表](#重新编译样式表)）。

## 第 1 层：不重新编译，临时加样式

只调一篇文档，就在旁边放个 CSS 文件，用 `css` 参数传进去：

```yaml
output:
  astropaper::astropaper:
    css: ["custom.css"]
```

```css
/* custom.css */
.app-prose h2 {
  letter-spacing: -0.01em;
}

.app-prose table {
  font-size: 0.9rem;
}
```

它会**追加在**内建样式表之后，所以同等优先级下你的规则会赢。路径相对于
`.Rmd` 所在目录解析。

如果改动要对所有文档生效，改源码再重编才是正路。

## 第 2 层：颜色与设计 token

`inst/css/src/theme.css` 分两块：Tailwind 注册与实际取值。

```css
@theme inline {
  --color-background: var(--background);
  --color-foreground: var(--foreground);
  --color-accent: var(--accent);
  --color-accent-foreground: var(--accent-foreground);
  --color-muted: var(--muted);
  --color-muted-foreground: var(--muted-foreground);
  --color-border: var(--border);
  --font-app: var(--font-google-sans-code);
}

:root,
[data-theme="light"] {
  --background: #fdfdfd;
  --foreground: #282728;
  --accent: #006cac;
  --accent-foreground: #ffffff;
  --muted: #e6e6e6;
  --muted-foreground: #6b7280;
  --border: #ece9e9;
}
```

把 `--accent` 改成 `#b91c1c`，所有强调色都会跟着变：标题、列表符号、引用块左边线、
表头分隔线、链接 hover 色。

token 和 Tailwind 工具类是一一对应的：

| Token | 工具类 |
|---|---|
| `--background` | `bg-background` |
| `--foreground` | `text-foreground` |
| `--accent` | `text-accent`、`bg-accent`、`border-accent` |
| `--muted` | `bg-muted` |
| `--muted-foreground` | `text-muted-foreground` |
| `--border` | `border-border` |

### 加一个自己的 token

注册和取值两半都要写，然后在模板或自己的 CSS 里用：

```css
@theme inline {
  --color-brand: var(--brand);
}

:root {
  --brand: #0f766e;
}
```

```css
.app-prose a {
  color: var(--brand);
}
```

因为注册过，`text-brand`、`bg-brand` 在模板里也是合法的工具类。

### 关于暗色

现在是纯亮色格式。`theme.css` 里还留着 `[data-theme="dark"]` 的暗色取值，
`astropaper.css` 里也定义了 `dark:` 变体，但模板不再设置 `data-theme`，而且
`html { color-scheme: light; }` 把渲染钉在了亮色。

要恢复暗色需要三件事：

1. 在模板的 `<html>` 上设置 `data-theme`（或像原 Astro 站点那样用脚本设置），
2. 页面里加一个切换控件，
3. 把 `color-scheme: light` 改回 `light dark`。

如果只想要一份永远深色的文档，把模板写成 `<html data-theme="dark">`，并把
`color-scheme` 改成 `dark` 即可。

## 第 3 层：排版

`inst/css/src/typography.css` 先加载 `@tailwindcss/typography`，再覆盖
`.app-prose`。里面全是 `@apply`，扩展起来很直接：

```css
.app-prose {
  @apply prose;

  h2 {
    @apply mt-14 border-b pb-2;
  }

  a {
    @apply text-accent no-underline hover:underline;
  }

  table {
    @apply text-sm;
  }
}
```

正文里常用的锚点：

| 选择器 | 覆盖范围 |
|---|---|
| `.app-prose h1`–`h4` | 各级标题 |
| `.app-prose p`、`li` | 正文 |
| `.app-prose blockquote` | 引用（callout 在这里就是普通引用） |
| `.app-prose pre` | 代码块（围栏代码和 knitr 输出） |
| `.app-prose code` | 行内代码 |
| `.app-prose .figure`、`.caption` | knitr 图片与图注 |
| `.app-prose nav#TOC` | 目录列表 |

想回到 Tailwind Typography 的原始效果，把 `.app-prose` 的覆盖删掉即可，插件提供的
`prose` 类仍然生效。

## 第 4 层：布局与页面结构

页面由 `inst/templates/astropaper.html` 定义，就是一个标准 pandoc 模板。真正
用到的变量只有这些：

| 变量 | 含义 |
|---|---|
| `$title$` | 文档标题 |
| `$date$` | 日期（有才输出） |
| `$for(author)$$author$$sep$, $endfor$` | 作者列表 |
| `$if(toc)$$table-of-contents$$endif$` | 目录块（需 `toc: true`） |
| `$body$` | 渲染后的正文 |
| `$if(copyright)$$copyright$$endif$` | 可选页脚 |
| `$for(css)$`、`$header-includes$`、`$if(math)$$math$$endif$` | pandoc 注入，别动 |

主体刻意保持极简：

```html
<body class="bg-background font-app text-foreground flex min-h-svh flex-col">
<main id="main-content" class="app-layout flex-1 py-10">
  <h1 class="text-accent text-2xl font-bold sm:text-3xl">$title$</h1>
  ...
  <article id="article" class="app-prose max-w-app mt-8">$body$</article>
</main>
```

### 改版心宽度

`app-layout` 和 `max-w-app` 定义在 `inst/css/src/astropaper.css`：

```css
@utility max-w-app {
  @apply max-w-3xl;   /* 48rem */
}
@utility app-layout {
  @apply max-w-app mx-auto w-full px-4;
}
```

把 `max-w-3xl` 换成 `max-w-4xl`，标题和正文会一起变宽。

### 加回页头 / 导航

模板以前带站点页头，为了文档自包含去掉了。要加就在 `<body>` 里、`<main>` 之前
贴一段：

```html
<header class="app-layout">
  <div class="border-border flex items-center justify-between border-b py-4">
    <a href="https://example.com" class="text-xl font-semibold">My notes</a>
    <nav class="text-muted-foreground flex gap-4 text-sm">
      <a href="https://example.com">Home</a>
      <a href="https://example.com/about">About</a>
    </nav>
  </div>
</header>
```

模板会被 CSS 构建扫描，所以下次跑 `tools/build-css.sh` 时，新用到的工具类会自动
进样式表。

### 改目录文案

`<summary>` 现在写的是 `目录`，改成任意文字即可：

```html
<summary class="text-foreground cursor-pointer text-sm font-semibold">Contents</summary>
```

### 单篇用别的模板

用 `template` 指向自己的文件：

```yaml
output:
  astropaper::astropaper:
    template: "my-template.html"
```

从自带模板复制（`system.file("templates/astropaper.html", package = "astropaper")`），
免得漏掉必需的变量。

## 代码高亮

高亮由 pandoc 的 skylighting 完成，不是纯 CSS。自带主题是
`inst/themes/astropaper.theme`，一个从 Shiki `min-light` 取的 JSON：

```json
{
  "text-color": "#212121",
  "background-color": null,
  "text-styles": {
    "Keyword": { "text-color": "#D32F2F", "background-color": null, "bold": false, "italic": false, "underline": false },
    "Comment": { "text-color": "#c2c3c5", "background-color": null, "bold": false, "italic": false, "underline": false }
  }
}
```

- `Comment` 是刻意的浅色（`#c2c3c5`）；嫌太淡就改成 `#8b949e` 之类。
- `text-color` 是代码的默认前景色，`background-color` 是代码块底色（`null`
  表示交给样式表决定）。

从任意内置主题生成一份起点：

```sh
pandoc --print-highlight-style pygments > inst/themes/astropaper.theme
```

或者单篇临时换内置主题，不动包：

```yaml
output:
  astropaper::astropaper:
    highlight: tango
```

`pandoc --list-highlight-styles` 可以列出所有名字。

有两件事 pandoc 做不到、必须上 Shiki：行级高亮（`{1,3-4}`）和 diff 标记
（`// [!code ++]`）。围栏块上的 `{.numberLines}` 是支持的。

## 字体

模板从 Google Fonts 加载 Google Sans Code，样式表把它映射到 `font-app`
工具类：

```html
<link href="https://fonts.googleapis.com/css2?family=Google+Sans+Code:ital,wght@0,300..700;1,300..700&display=swap" rel="stylesheet" />
```

```css
:root {
  --font-google-sans-code: "Google Sans Code", ui-monospace, SFMono-Regular, Menlo, monospace;
}
```

换字体要两处一起改。想要衬线正文字体：

```css
:root {
  --font-google-sans-code: "Source Serif 4", Georgia, serif;
}
```

```html
<link href="https://fonts.googleapis.com/css2?family=Source+Serif+4:opsz,wght@8..60,300..700&display=swap" rel="stylesheet" />
```

要离线安全的文档，就把 `woff2` 自托管，用 `@font-face` 代替 Google Fonts 链接。

## 重新编译样式表

`inst/css/astropaper.compiled.css` 是生成物。改完 `inst/css/src/`、模板或 token
之后都要重编：

```sh
cd ~/development/astropaper
npm install --no-save tailwindcss @tailwindcss/typography
tools/build-css.sh
```

脚本调用 Tailwind v4 CLI 并 `--minify`，产物写回 `inst/css/`。

### 扫描范围

`astropaper.css` 结尾是：

```css
@source "../../templates/astropaper.html";
```

只扫模板，所以只有模板里出现过的工具类会被编译。如果你在自己的 `.Rmd`（原始
HTML）里写 Tailwind class，样式表里**没有**这些类。把目录加进去再重编：

```css
@source "../../templates/astropaper.html";
@source "../../../your-posts/**/*.Rmd";
```

相对路径按 `inst/css/src/astropaper.css` 的位置调整。

### 验证构建

```sh
grep -c "bg-background" inst/css/astropaper.compiled.css   # 至少 1
```

如果是 0，说明 CLI 静默失败或者源码路径写错了。

## 改 R 侧的默认值

`astropaper()` 只是包了一层 `rmarkdown::html_document()` 并把 `theme` 设为
`NULL`。想要固定一组参数，写个本地 wrapper 就行，不必改包：

```r
my_report <- function(...) {
  astropaper::astropaper(
    ...,
    toc = FALSE,
    fig_width = 7,
    fig_height = 4,
    css = "brand.css"
  )
}
```

```yaml
output: my_report
```

真要改包的默认值，就动 `R/astropaper.R` 里的形参，再重新生成文档：

```sh
Rscript -e 'roxygen2::roxygenise()'
```

## 数学

数学由 KaTeX 通过 pandoc 的 `--katex` 渲染，`math_method = "katex"` 打开。
KaTeX 的 CSS/JS 从 CDN 加载，所以查看时需要联网。

要离线数学，就把 KaTeX 放进 `inst/`，并用本地的 `<link>`/`<script>` 替换模板
head 里 pandoc 注入的资源；代价是包大 1–2 MB。

## 测试你的改动

1. 动过样式就先重编 CSS。
2. 重装（或重新载入）包：

   ```sh
   R CMD INSTALL .
   # 开发时也可以：
   Rscript -e 'pkgload::load_all()'
   ```

3. knit `doc/sample.Rmd` 看效果。
4. 推送前跑检查：

   ```sh
   R CMD build .
   R CMD check --no-manual astropaper_0.1.0.tar.gz
   ```

`pkgload::load_all()` 会让 `system.file()` 指向源码里的 `inst/`，不用重装就能预览。

## 常见问题

| 症状 | 原因 |
|---|---|
| 改了颜色没反应 | 没重编 CSS，或者用的是旧的已安装版本 |
| `.Rmd` 里的 Tailwind class 没效果 | 类不在 `@source` 里；加上路径重编 |
| 公式显示成原始 `\(...\)` | KaTeX 没加载（断网或 CDN 被挡） |
| `Could not fetch resource ...` 警告 | pandoc 嵌入时抓不到 CDN 资源，无害 |
| 样式全没了 | 某处 `theme` 不是 `NULL`，Bootstrap 盖住了主题 |
| `library(astropaper)` 后 `html_document()` 坏了 | 它 mask 了 `rmarkdown::html_document()`，用 `astropaper::` |
| `R CMD check` 报顶层文件 NOTE | 按需把 `^gallery$`、`^doc$`、`^sample\.Rmd$` 加进 `.Rbuildignore` |

## 文档同步

这份指南放在 `doc/`，除非在 `.Rbuildignore` 里加 `^doc$`，否则会随包发布。
想留在仓库但不出现在 tarball 里，就加这一行。
