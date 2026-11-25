# Contributing to AstroPapeR

Thanks for taking the time to contribute. This document explains how the package
is put together, how to run it locally, and what a good pull request looks like.

## Ways to contribute

- **Bug reports** — a minimal `.Rmd` that reproduces the problem plus the full
  `sessionInfo()` output is worth more than a paragraph of description.
- **Feature requests** — describe the use case first, the proposed API second.
- **Documentation** — the English and Chinese guides are both first-class; fixes
  to either are welcome.
- **Screenshots** — the gallery is generated from `doc/sample.Rmd`; better
  crops or extra examples are useful.

## Before you start

- For anything larger than a typo, open an issue first. A short thread is cheaper
  than a rejected PR.
- Keep pull requests focused: one concern per PR. Mixed refactor + feature PRs
  are hard to review.
- By contributing you agree that your work is released under the package's MIT
  license.

## Development setup

You need:

| Tool | Purpose | Notes |
|---|---|---|
| R | Running and testing the package | 4.2+ recommended; tested on 4.6 |
| pandoc | Rendering and highlighting | 2.0+; RStudio ships a suitable build |
| Node.js | Rebuilding the Tailwind stylesheet | 20+; only needed when editing CSS |
| npm | Installing the Tailwind CLI and typography plugin | comes with Node |

```r
install.packages(c("devtools", "rmarkdown", "knitr", "testthat"))
```

```sh
git clone git@github.com:2b-creator/AstroPapeR.git
cd AstroPapeR
```

Load the source tree without installing:

```r
pkgload::load_all()
```

`load_all()` makes `system.file()` resolve to `inst/` in the checkout, so edits
to the template, the highlight theme or the compiled CSS take effect on the next
render.

For stylesheet work:

```sh
npm install --no-save tailwindcss @tailwindcss/typography
```

## Repository layout

```
R/astropaper.R                 the output format function
inst/templates/astropaper.html pandoc template (page structure)
inst/themes/astropaper.theme   pandoc highlight theme (JSON)
inst/css/src/                  Tailwind sources, do not edit the compiled file
inst/css/astropaper.compiled.css  generated, committed
inst/rmarkdown/templates/      RStudio "From Template" entry
doc/                           guides and the example document
gallery/                       screenshots used by the README
tests/testthat/                package tests
tools/build-css.sh             CSS build script
```

The R package is called `astropaper`; the GitHub repository is `AstroPapeR`. That
mismatch is intentional — the repository name is branding, the package name has
to be a valid R identifier.

## Making changes

### R code

- Document exported functions with roxygen comments and regenerate:

  ```sh
  Rscript -e 'roxygen2::roxygenise()'
  ```

  `NAMESPACE` and `man/` are generated; never edit them by hand.
- Keep R sources ASCII-only. Non-ASCII text belongs in `inst/` or `doc/`.
- Preserve the `theme = NULL` contract: without it, Bootstrap silently overrides
  the theme.

### Styles

- Edit `inst/css/src/`, never `inst/css/astropaper.compiled.css`.
- Rebuild and commit **both** the source and the compiled file:

  ```sh
  tools/build-css.sh
  ```

- Only files listed in `@source` are scanned for utility classes. If you add
  classes to the template, they are picked up automatically; classes written in
  user documents are not.
- Adding a token means two edits: register it under `@theme inline` and give it a
  value under `:root`.

### Template

- Keep the required pandoc variables intact: `$body$`, `$for(css)$`,
  `$header-includes$`, `$if(math)$$math$$endif$`.
- Test with both `toc: true` and `toc: false`, and with and without `copyright`.
- Match the surrounding Tailwind conventions (utility order is handled by
  `prettier-plugin-tailwindcss` in the Astro source, not here — keep it readable).

### Highlight theme

`inst/themes/astropaper.theme` is a pandoc style file. To start from a built-in
palette:

```sh
pandoc --print-highlight-style pygments > inst/themes/astropaper.theme
```

Then adjust `text-styles`. Token keys are documented by
`pandoc --print-highlight-style default`.

### Documentation

- `doc/customize.md` (English) and `doc/customize.zh.md` (Chinese) are a pair.
  When you change one, change the other, or open an issue asking for the
  translation.
- Both files link to each other at the top. Keep those links.
- The guides describe the current behaviour; if you change a default in
  `R/astropaper.R`, update both guides and the README.

### Gallery

The images in `gallery/` are screenshots of `doc/sample.Rmd` at 2× device pixel
ratio. After changing the theme:

```sh
Rscript -e 'rmarkdown::render("doc/sample.Rmd", output_dir = tempdir())'
```

Open the resulting HTML in a browser, wait until KaTeX and the web font have
finished loading, and capture the full page. A cover (`sample-cover.png`) plus
one image per section (`sample-*.png`) is the current set.

## Testing

Run the same checks CI would run:

```sh
R CMD build .
R CMD check --no-manual astropaper_0.1.0.tar.gz
```

`R CMD check` runs `tests/testthat/`, which renders the bundled skeleton and
asserts that the theme's classes and highlighted tokens are present. Keep it
green.

Also knit `doc/sample.Rmd` and eyeball the result — automated tests cannot see a
broken layout.

The knit itself must work offline. Only the *viewing* of the output needs a
network connection, because KaTeX and the font are loaded from CDNs.

## Style guide

- Two-space indentation, LF line endings, no tabs, no trailing whitespace.
- R code: one argument per line when the signature is long, `<-` for assignment,
  explicit `package::function` calls.
- Prose: sentence case for headings, one sentence per line in Markdown sources is
  welcome (it keeps diffs readable).
- Fenced code blocks always carry a language tag.

## Commit messages and pull requests

- Use the imperative mood: `add sample document`, not `added sample document`.
- A short prefix is welcome but not required: `feat:`, `fix:`, `docs:`,
  `chore:`.
- Do not bump the version in a pull request; the maintainer does that at release
  time.
- Describe visual changes with a before/after screenshot.
- Mention the issue you are closing (`Closes #12`).

## Release checklist (maintainer)

1. Bump `Version` in `DESCRIPTION`.
2. `Rscript -e 'roxygen2::roxygenise()'` if any documentation changed.
3. `tools/build-css.sh` if any style source changed.
4. `R CMD build . && R CMD check --no-manual astropaper_<version>.tar.gz`.
5. `git tag -a v<version> -m "v<version>" && git push --tags`.
6. Create a GitHub release and paste the relevant changelog entries.
7. Users upgrade with `devtools::install_github("2b-creator/AstroPapeR")`.

## Questions

Open an issue if anything here is unclear. Improving this document is itself a
valid contribution.
