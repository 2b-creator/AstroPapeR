test_that("astropaper() returns an rmarkdown output format", {
  fmt <- astropaper()
  expect_s3_class(fmt, "rmarkdown_output_format")
})

test_that("the skeleton renders to HTML with the bundled CSS", {
  skip_if_not(rmarkdown::pandoc_available())

  skeleton <- system.file(
    "rmarkdown", "templates", "astropaper", "skeleton", "skeleton.Rmd",
    package = "astropaper"
  )
  skip_if(skeleton == "")

  dir <- tempfile("astropaper-")
  dir.create(dir)
  file.copy(skeleton, file.path(dir, "skeleton.Rmd"))

  out <- rmarkdown::render(
    file.path(dir, "skeleton.Rmd"),
    output_dir = dir,
    quiet = TRUE
  )

  html <- paste(readLines(out, warn = FALSE), collapse = "\n")
  expect_match(html, "class=\"app-prose", fixed = TRUE)
  expect_match(html, "span class=\"kw\"|span class=\"fu\"", perl = TRUE)
})
