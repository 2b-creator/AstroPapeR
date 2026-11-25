# Customising AstroPapeR

This guide covers every layer you can change, from a five-second CSS override to
rewriting the pandoc template. It assumes you have the package checked out
locally and know how to knit an R Markdown file.

> 中文版: [customize.zh.md](customize.zh.md)

## Where things live

| What you want to change | Where it lives |
|---|---|
| One-off styling for a single document | `css:` in the document's YAML |
| Colours, fonts, spacing tokens | `inst/css/src/theme.css` |
| Prose typography (headings, links, tables, code blocks) | `inst/css/src/typography.css` |
| Page structure (title block, TOC, footer) | `inst/templates/astropaper.html` |
| Syntax highlighting colours | `inst/themes/astropaper.theme` |
| Defaults of the `astropaper()` function | `R/astropaper.R` |
| The compiled stylesheet that actually ships | `inst/css/astropaper.compiled.css` |

The styling is assembled in three layers:

1. **Design tokens** — CSS custom properties in `theme.css`, registered with
   Tailwind's `@theme` so they become utilities such as `bg-background` and
   `text-accent`.
2. **Component rules** — Tailwind typography plus the `.app-prose` overrides in
   `typography.css`, and a few pandoc-specific rules in `astropaper.css`.
3. **Markup** — utility classes written directly in the pandoc template.

All three compile down to `inst/css/astropaper.compiled.css`, which is what the
package ships. That file is **generated**: editing the sources has no effect
until you rebuild it (see [Rebuilding the stylesheet](#rebuilding-the-stylesheet)).

## Level 1: extra CSS without rebuilding

If you only need to tweak one document, drop a CSS file next to it and pass it
through the `css` argument:

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

The file is appended **after** the bundled stylesheet, so equal-specificity
rules win. Paths are resolved relative to the directory of the `.Rmd`.

For a change that should apply to every document, editing the sources and
rebuilding is the better option.

## Level 2: colours and other design tokens

`inst/css/src/theme.css` holds two blocks: the Tailwind registration and the
actual values.

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

Change `--accent` to `#b91c1c` and every accent-coloured element follows: the
document title, list markers, blockquote borders, the table header rule and the
link hover colour.

The tokens map to Tailwind utilities one-to-one:

| Token | Utilities |
|---|---|
| `--background` | `bg-background` |
| `--foreground` | `text-foreground` |
| `--accent` | `text-accent`, `bg-accent`, `border-accent` |
| `--muted` | `bg-muted` |
| `--muted-foreground` | `text-muted-foreground` |
| `--border` | `border-border` |

### Adding your own token

Add both halves — the registration and the value — then use the utility
anywhere in the template or in your own CSS:

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

Because the token is registered, `text-brand`, `bg-brand` and friends become
valid utilities inside the template as well.

### A note on dark mode

The format is light-only. `theme.css` still carries the dark palette under
`[data-theme="dark"]`, and `astropaper.css` defines the `dark:` variant, but the
template never sets `data-theme` and `html { color-scheme: light; }` pins the
rendering.

To bring dark mode back you need three pieces:

1. a `data-theme` attribute on `<html>` in the template (or a script that sets
   it, like the original Astro site does),
2. a toggle control in the page,
3. `color-scheme: light dark` instead of `light`.

If you only want a permanently dark document, set `<html data-theme="dark">` in
the template and switch `color-scheme` to `dark`.

## Level 3: typography

`inst/css/src/typography.css` loads `@tailwindcss/typography` and then overrides
`.app-prose`. Every rule there is a plain `@apply`, so it is easy to extend:

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

Useful anchors inside the article:

| Selector | Covers |
|---|---|
| `.app-prose h1`–`h4` | Headings |
| `.app-prose p`, `li` | Body copy |
| `.app-prose blockquote` | Quotes (callouts are plain quotes here) |
| `.app-prose pre` | Code blocks (fenced and knitr output) |
| `.app-prose code` | Inline code |
| `.app-prose .figure`, `.caption` | knitr figures and captions |
| `.app-prose nav#TOC` | Table of contents list |

If you prefer the stock Tailwind Typography look, delete the `.app-prose`
overrides; the `prose` class from the plugin still applies.

## Level 4: layout and page structure

The page is defined by `inst/templates/astropaper.html`, a standard pandoc
template. Only these variables matter:

| Variable | Meaning |
|---|---|
| `$title$` | Document title |
| `$date$` | Date, if supplied |
| `$for(author)$$author$$sep$, $endfor$` | Author list |
| `$if(toc)$$table-of-contents$$endif$` | TOC block (requires `toc: true`) |
| `$body$` | Rendered document |
| `$if(copyright)$$copyright$$endif$` | Optional footer |
| `$for(css)$`, `$header-includes$`, `$if(math)$$math$$endif$` | Injected by pandoc; leave them alone |

The body is intentionally minimal:

```html
<body class="bg-background font-app text-foreground flex min-h-svh flex-col">
<main id="main-content" class="app-layout flex-1 py-10">
  <h1 class="text-accent text-2xl font-bold sm:text-3xl">$title$</h1>
  ...
  <article id="article" class="app-prose max-w-app mt-8">$body$</article>
</main>
```

### Change the page width

`app-layout` and `max-w-app` are defined in `inst/css/src/astropaper.css`:

```css
@utility max-w-app {
  @apply max-w-3xl;   /* 48rem */
}
@utility app-layout {
  @apply max-w-app mx-auto w-full px-4;
}
```

Change `max-w-3xl` to `max-w-4xl` and both the title and the article widen
together.

### Add a header or navigation bar

The template used to carry a site header; it was removed to keep documents
self-contained. Paste a header inside `<body>`, before `<main>`:

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

Because the template is scanned during the CSS build, the new utilities are
picked up the next time you run `tools/build-css.sh`.

### Change the TOC label

The summary currently reads `目录`. Replace it with any label:

```html
<summary class="text-foreground cursor-pointer text-sm font-semibold">Contents</summary>
```

### Use a different template for one document

Pass `template` to point at your own file:

```yaml
output:
  astropaper::astropaper:
    template: "my-template.html"
```

Start from the bundled one (`system.file("templates/astropaper.html", package = "astropaper")`)
so the required variables stay in place.

## Syntax highlighting

Highlighting is done by pandoc's skylighting, not by CSS alone. The bundled
theme is `inst/themes/astropaper.theme`, a JSON file derived from Shiki's
`min-light` palette:

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

- `Comment` is intentionally pale (`#c2c3c5`); darken it to something like
  `#8b949e` if you find it too light.
- `text-color` sets the default foreground for code, `background-color` the
  block background (`null` means "let the stylesheet decide").

Regenerate a starting point from any built-in style:

```sh
pandoc --print-highlight-style pygments > inst/themes/astropaper.theme
```

Or use a built-in style name for a single document, without touching the
package:

```yaml
output:
  astropaper::astropaper:
    highlight: tango
```

`pandoc --list-highlight-styles` prints the available names.

Two details are out of scope for pandoc and require Shiki if you need them:
line-level highlighting (`{1,3-4}`) and diff markers (`// [!code ++]`).
`{.numberLines}` on a fenced block does work.

## Fonts

The template loads Google Sans Code from Google Fonts and the stylesheet maps it
to the `font-app` utility:

```html
<link href="https://fonts.googleapis.com/css2?family=Google+Sans+Code:ital,wght@0,300..700;1,300..700&display=swap" rel="stylesheet" />
```

```css
:root {
  --font-google-sans-code: "Google Sans Code", ui-monospace, SFMono-Regular, Menlo, monospace;
}
```

To use another typeface, change both places. For a serif body font:

```css
:root {
  --font-google-sans-code: "Source Serif 4", Georgia, serif;
}
```

```html
<link href="https://fonts.googleapis.com/css2?family=Source+Serif+4:opsz,wght@8..60,300..700&display=swap" rel="stylesheet" />
```

For an offline-safe document, self-host the `woff2` files and use `@font-face`
instead of the Google Fonts link.

## Rebuilding the stylesheet

`inst/css/astropaper.compiled.css` is generated. Rebuild it after any change to
`inst/css/src/`, the template, or the tokens.

```sh
cd ~/development/astropaper
npm install --no-save tailwindcss @tailwindcss/typography
tools/build-css.sh
```

The script runs the Tailwind v4 CLI with `--minify` and writes the compiled file
back into `inst/css/`.

### What gets scanned

`astropaper.css` ends with:

```css
@source "../../templates/astropaper.html";
```

Only the template is scanned, so only utilities that appear there are compiled.
If you write Tailwind classes in your own `.Rmd` (inside raw HTML), they will be
**missing** from the stylesheet. Add the directory and rebuild:

```css
@source "../../templates/astropaper.html";
@source "../../../your-posts/**/*.Rmd";
```

Adjust the relative path so it points at your sources from
`inst/css/src/astropaper.css`.

### Verify the build

```sh
grep -c "bg-background" inst/css/astropaper.compiled.css   # 1 or more
```

If the count is zero, the CLI failed silently or the source path is wrong.

## Changing the R defaults

`astropaper()` is a thin wrapper around `rmarkdown::html_document()` with
`theme = NULL`. If you always want the same options, define a local wrapper
rather than editing the package:

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

To change the package defaults themselves, edit the formals in `R/astropaper.R`
and regenerate the documentation:

```sh
Rscript -e 'roxygen2::roxygenise()'
```

## Math

Math is rendered by KaTeX through pandoc's `--katex`, enabled by
`math_method = "katex"`. The KaTeX CSS and JS are loaded from a CDN, so the
document needs a network connection to display formulas.

If you need offline math, vendor KaTeX into `inst/` and replace pandoc's
`--katex` assets with local `<link>`/`<script>` tags in the template's head.
That adds roughly 1–2 MB to the package.

## Testing your changes

1. Rebuild the CSS if you touched the styles.
2. Reinstall (or reload) the package:

   ```sh
   R CMD INSTALL .
   # or, during development:
   Rscript -e 'pkgload::load_all()'
   ```

3. Knit `doc/sample.Rmd` and look at the output.
4. Run the checks before pushing:

   ```sh
   R CMD build .
   R CMD check --no-manual astropaper_0.1.0.tar.gz
   ```

`pkgload::load_all()` makes `system.file()` resolve to `inst/` in the source
tree, so you can preview changes without reinstalling.

## Troubleshooting

| Symptom | Cause |
|---|---|
| Edited a colour, nothing changed | The compiled CSS was not rebuilt, or the installed copy is stale |
| Tailwind classes in my `.Rmd` do nothing | The class is not in `@source`; add the path and rebuild |
| Math shows as raw `\(...\)` text | KaTeX could not load (no network or blocked CDN) |
| `Could not fetch resource ...` warning | Pandoc cannot download the CDN assets while embedding; harmless |
| All styling gone | `theme` was left non-`NULL` somewhere, so Bootstrap overrides the theme |
| `library(astropaper)` broke `html_document()` | It masks `rmarkdown::html_document()`; use `astropaper::` |
| `R CMD check` NOTE about top-level files | Add `^gallery$`, `^doc$`, `^sample\.Rmd$` to `.Rbuildignore` as needed |

## Keeping documentation in sync

The package ships this guide in `doc/`, which is excluded from `R CMD build`
only if you add `^doc$` to `.Rbuildignore`. If you want `doc/` to stay in the
repository but out of the tarball, add that line; otherwise it ships as-is.
