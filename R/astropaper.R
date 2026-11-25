#' AstroPaper-styled HTML documents
#'
#' A drop-in replacement for [rmarkdown::html_document()] that swaps Bootstrap
#' for the AstroPaper theme: Tailwind typography, Google Sans Code, an optional
#' table of contents, KaTeX math and a min-light syntax highlighting palette.
#'
#' @param ... Arguments passed on to [rmarkdown::html_document()].
#' @param css Character vector of additional CSS files, appended after the
#'   bundled stylesheet.
#' @param template Path to a pandoc HTML template. Defaults to the bundled
#'   `templates/astropaper.html`.
#' @param highlight Syntax highlighting style. Either the name of a pandoc
#'   style (`"pygments"`, `"tango"`, ...) or a path to a `.theme` file.
#'   Defaults to the bundled min-light palette.
#' @param self_contained Embed CSS, images and other local resources in the
#'   HTML file. Defaults to `TRUE`.
#' @param math_method How to render math. Defaults to `"katex"`.
#' @param toc Include a table of contents. Defaults to `TRUE`.
#' @param toc_depth Number of heading levels shown in the table of contents.
#' @param fig_width,fig_height,fig_retina Figure defaults for knitr.
#'
#' @return An R Markdown output format.
#'
#' @seealso [rmarkdown::html_document()]
#'
#' @examples
#' \dontrun{
#' rmarkdown::render("post.Rmd", output_format = astropaper::astropaper())
#' }
#' @export
astropaper <- function(...,
                       css = NULL,
                       template = NULL,
                       highlight = NULL,
                       self_contained = TRUE,
                       math_method = "katex",
                       toc = TRUE,
                       toc_depth = 3,
                       fig_width = 8,
                       fig_height = 4.5,
                       fig_retina = 2) {
  if (is.null(template)) {
    template <- astropaper_file("templates", "astropaper.html")
  }
  if (is.null(highlight)) {
    highlight <- astropaper_file("themes", "astropaper.theme")
  }

  rmarkdown::html_document(
    ...,
    template = template,
    css = c(astropaper_file("css", "astropaper.compiled.css"), css),
    theme = NULL,
    highlight = highlight,
    self_contained = self_contained,
    math_method = math_method,
    toc = toc,
    toc_depth = toc_depth,
    fig_width = fig_width,
    fig_height = fig_height,
    fig_retina = fig_retina
  )
}

#' @rdname astropaper
#'
#' @details `html_document()` is a convenience alias. Note that attaching the
#'   package with `library(astropaper)` masks
#'   [rmarkdown::html_document()], so prefer `astropaper::html_document()`.
#' @export
html_document <- function(...) {
  astropaper(...)
}

astropaper_file <- function(...) {
  system.file(..., package = "astropaper", mustWork = TRUE)
}
