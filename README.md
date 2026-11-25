# astropaper

An R Markdown output format that renders documents with the
[AstroPaper](https://github.com/satnaing/astro-paper) look: Tailwind typography,
Google Sans Code, KaTeX math, an optional table of contents and a `min-light`
code palette.

## Install

```r
# from a local checkout
install.packages("astropaper", repos = NULL, type = "source")
# or
devtools::install_local("path/to/astropaper")
```

## Use

```yaml
---
title: "My post"
output: astropaper::astropaper
---
```

Or as a function:

```r
rmarkdown::render("post.Rmd", output_format = astropaper::astropaper())
```

RStudio users get the format under *File > New File > R Markdown > From
Template > AstroPaper HTML*.

Useful arguments:

```r
astropaper(
  toc = TRUE,
  toc_depth = 3,
  self_contained = TRUE,   # single portable HTML file
  highlight = NULL,        # NULL = bundled min-light theme
  css = "extra.css"        # appended after the bundled stylesheet
)
```

## Customise

| Want to change | Where |
|---|---|
| Colours, fonts, spacing tokens | `inst/css/src/theme.css`, then rebuild |
| Prose typography | `inst/css/src/typography.css`, then rebuild |
| Page structure | `inst/templates/astropaper.html` |
| Code colours | `inst/themes/astropaper.theme` (a pandoc highlight theme) |

Rebuild the stylesheet after editing `inst/css/src/`:

```sh
npm install --no-save tailwindcss @tailwindcss/typography
tools/build-css.sh
```

The compiled `inst/css/astropaper.compiled.css` is what the package ships, so
end users never need Node.

## Notes

- Fonts (Google Sans Code) and KaTeX are loaded from CDNs at view time. With
  `self_contained = TRUE`, pandoc warns that it cannot fetch them; the links
  are kept and the document still renders when online.
- Math uses KaTeX; `math_method` is passed through to
  `rmarkdown::html_document()`.
- `html_document()` is exported as an alias; `library(astropaper)` masks
  `rmarkdown::html_document()`, so prefer the `astropaper::` prefix.
