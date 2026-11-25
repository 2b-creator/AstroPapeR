# AstroPapeR

一种 R Markdown 输出格式，可渲染出具有 [AstroPaper](https://github.com/satnaing/astro-paper) 外观的文档：Tailwind 排版、Google Sans Code、KaTeX 数学公式、可选的目录以及 `min-light` 代码配色。

## Gallery

![AstroPapeR sample](../gallery/sample-cover.png)

| | |
|---|---|
| ![Text](../gallery/sample-text.png) | ![Math](../gallery/sample-math.png) |
| ![Code](../gallery/sample-code.png) | ![Plot](../gallery/sample-plot.png) |

## 安装

```r
install.packages("devtools")
library(devtools)
install_github("2b-creator/AstroPapeR")
```

## 使用

```yaml
---
title: "My post"
output: astropaper::astropaper
---
```

或作为函数使用：

```r
rmarkdown::render("post.Rmd", output_format = astropaper::astropaper())
```

RStudio 用户可以在 *File > New File > R Markdown > From Template > AstroPaper HTML* 下找到该格式。

常用参数：

```r
astropaper(
  toc = TRUE,
  toc_depth = 3,
  self_contained = TRUE,   # 单个可移植的 HTML 文件
  highlight = NULL,        # NULL = 内置 min-light 主题
  css = "extra.css"        # 追加在内置样式表之后
)
```

## 自定义

| 想要更改 | 位置 |
|---|---|
| 颜色、字体、间距令牌 | `inst/css/src/theme.css`，然后重新构建 |
| 正文排版 | `inst/css/src/typography.css`，然后重新构建 |
| 页面结构 | `inst/templates/astropaper.html` |
| 代码配色 | `inst/themes/astropaper.theme`（一个 pandoc 高亮主题） |

编辑 `inst/css/src/` 后重新构建样式表：

```sh
npm install --no-save tailwindcss @tailwindcss/typography
tools/build-css.sh
```

包发布的是编译后的 `inst/css/astropaper.compiled.css`，因此最终用户无需安装 Node。

## 说明

- 字体（Google Sans Code）和 KaTeX 在查看时从 CDN 加载。使用 `self_contained = TRUE` 时，pandoc 会警告无法获取这些资源；链接会被保留，文档在联网时仍可正常渲染。
- 数学公式使用 KaTeX；`math_method` 会传递给 `rmarkdown::html_document()`。
- `html_document()` 作为别名导出；`library(astropaper)` 会遮蔽 `rmarkdown::html_document()`，因此建议使用 `astropaper::` 前缀。