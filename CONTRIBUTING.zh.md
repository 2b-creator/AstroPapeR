# 为 AstroPapeR 做贡献

感谢你愿意花时间参与。本文说明这个包是怎么组织的、怎么在本地跑起来，以及一个
好的 pull request 长什么样。

> English version: [CONTRIBUTING.md](CONTRIBUTING.md)

## 可以做哪些贡献

- **Bug 报告** —— 一个能复现问题的最小 `.Rmd` 加上完整的 `sessionInfo()`，比一大段
  描述有用得多。
- **功能请求** —— 先讲使用场景，再讲建议的接口。
- **文档** —— 英文和中文两版都是一等公民，任何一边的修正都欢迎。
- **截图** —— gallery 里的图来自 `doc/sample.Rmd`，更好的裁剪或补充示例都很有用。

## 动手之前

- 除了改错别字，先开一个 issue。一个简短的讨论比一个被拒的 PR 便宜得多。
- 一个 PR 只做一件事。把重构和功能混在一起会让 review 很难受。
- 提交即表示你同意你的工作按本包的 MIT 许可发布。

## 开发环境

需要：

| 工具 | 用途 | 备注 |
|---|---|---|
| R | 运行和测试包 | 建议 4.2+；在 4.6 上测过 |
| pandoc | 渲染与代码高亮 | 2.0+；RStudio 自带的版本就够 |
| Node.js | 重新构建 Tailwind 样式表 | 20+；只有改 CSS 时才需要 |
| npm | 安装 Tailwind CLI 和 typography 插件 | 随 Node 一起装 |

```r
install.packages(c("devtools", "rmarkdown", "knitr", "testthat"))
```

```sh
git clone git@github.com:2b-creator/AstroPapeR.git
cd AstroPapeR
```

直接加载源码树，不用安装：

```r
pkgload::load_all()
```

`load_all()` 会让 `system.file()` 指向源码里的 `inst/`，所以改完模板、高亮主题或
编译后的 CSS，下一次渲染就会生效。

要改样式表，先装依赖：

```sh
npm install --no-save tailwindcss @tailwindcss/typography
```

## 仓库结构

```
R/astropaper.R                输出格式函数
inst/templates/astropaper.html pandoc 模板（页面结构）
inst/themes/astropaper.theme   pandoc 高亮主题（JSON）
inst/css/src/                  Tailwind 源码，不要直接改产物
inst/css/astropaper.compiled.css  生成物，会被提交
inst/rmarkdown/templates/      RStudio「From Template」入口
doc/                          指南与示例文档
gallery/                      README 用到的截图
tests/testthat/               包测试
tools/build-css.sh            CSS 构建脚本
```

R 包名是 `astropaper`，GitHub 仓库名是 `AstroPapeR`。这个不一致是刻意的：仓库名是
品牌，包名必须是合法的 R 标识符。

## 改动指南

### R 代码

- 导出的函数用 roxygen 注释，然后重新生成：

  ```sh
  Rscript -e 'roxygen2::roxygenise()'
  ```

  `NAMESPACE` 和 `man/` 都是生成物，不要手改。
- R 源码保持纯 ASCII。非 ASCII 文本放到 `inst/` 或 `doc/` 里。
- 保持 `theme = NULL`：没有它，Bootstrap 会悄悄盖掉主题。

### 样式

- 改 `inst/css/src/`，永远不要直接改 `inst/css/astropaper.compiled.css`。
- 重新构建，并且把**源码和产物一起提交**：

  ```sh
  tools/build-css.sh
  ```

- 只有 `@source` 里列出的文件会被扫描，决定哪些工具类进样式表。写进模板的类会
  自动被收录；写在用户文档里的不会。
- 加 token 要改两处：在 `@theme inline` 里注册，在 `:root` 里给值。

### 模板

- 保留必需的 pandoc 变量：`$body$`、`$for(css)$`、`$header-includes$`、
  `$if(math)$$math$$endif$`。
- 用 `toc: true` / `toc: false`、有 `copyright` / 无 `copyright` 各测一遍。
- 跟随现有的 Tailwind 写法习惯（工具类排序由 Astro 那边的
  `prettier-plugin-tailwindcss` 负责，这里只要可读）。

### 高亮主题

`inst/themes/astropaper.theme` 是一个 pandoc 样式文件。可以从内置配色起步：

```sh
pandoc --print-highlight-style pygments > inst/themes/astropaper.theme
```

然后调整 `text-styles`。各类 token 的键名可以用
`pandoc --print-highlight-style default` 查看。

### 文档

- `doc/customize.md`（英文）和 `doc/customize.zh.md`（中文）是一对。改了其中一份，
  另一份也要跟着改，或者开 issue 让人来翻译。
- 两份文件顶部互相链接，别把链接删了。
- 指南描述的是当前行为；如果改了 `R/astropaper.R` 的默认值，两份指南和 README
  都要同步。

### Gallery

`gallery/` 里的图是 `doc/sample.Rmd` 在 2 倍设备像素比下的截图。主题改动之后：

```sh
Rscript -e 'rmarkdown::render("doc/sample.Rmd", output_dir = tempdir())'
```

用浏览器打开生成的 HTML，等 KaTeX 和 Web 字体加载完，再截整页。目前是一张封面
（`sample-cover.png`）加每个章节一张（`sample-*.png`）。

## 测试

跑一遍 CI 会跑的检查：

```sh
R CMD build .
R CMD check --no-manual astropaper_0.1.0.tar.gz
```

`R CMD check` 会执行 `tests/testthat/`：渲染自带的 skeleton，并断言主题的类和高亮
token 都在。请保持它是绿的。

另外一定要手动 knit 一遍 `doc/sample.Rmd` 看效果——自动化测试看不出布局坏了。

knit 本身必须能离线完成。只有**查看**输出时才需要联网，因为 KaTeX 和字体是从 CDN
加载的。

## 代码风格

- 两空格缩进，LF 换行，不用 tab，不要行尾空格。
- R 代码：签名过长时一行一个参数，用 `<-` 赋值，外部函数显式写 `包::函数`。
- 文案：标题用句式大小写；Markdown 源文件里一句话一行也欢迎（diff 更可读）。
- 围栏代码块一律带语言标记。

## 提交信息与 pull request

- 用祈使句：`add sample document`，不要 `added sample document`。
- 短前缀可选：`feat:`、`fix:`、`docs:`、`chore:`。
- 不要在 PR 里改版本号；版本由维护者在发版时更新。
- 视觉改动请附前后对比截图。
- 写明你要关闭的 issue（`Closes #12`）。

## 发布清单（维护者）

1. 改 `DESCRIPTION` 里的 `Version`。
2. 文档有改动就 `Rscript -e 'roxygen2::roxygenise()'`。
3. 样式源码有改动就 `tools/build-css.sh`。
4. `R CMD build . && R CMD check --no-manual astropaper_<version>.tar.gz`。
5. `git tag -a v<version> -m "v<version>" && git push --tags`。
6. 在 GitHub 建 Release，把对应的变更条目贴进去。
7. 用户通过 `devtools::install_github("2b-creator/AstroPapeR")` 升级。

## 提问

如果本文有任何不清楚的地方，开 issue 就行。改进这份文档本身也是一种贡献。
