## Test environments

* local: macOS Tahoe 26.5 (aarch64), R 4.6.1
* win-builder: not yet run
* R-hub: not yet run

## R CMD check results

0 errors | 0 warnings | 1 note

* checking CRAN incoming feasibility ... NOTE
  Maintainer: 'Timothy Starman <timothystarman2005@outlook.com>'
  New submission

This is the initial submission of the package.

## Notes

* Fonts (Google Sans Code) and KaTeX are loaded from CDNs when the resulting
  HTML document is viewed. Rendering itself is offline; tests use
  `self_contained = FALSE` so no download is attempted during checks.
* The bundled stylesheet is generated from the Tailwind sources in
  `inst/css/src/` and committed; Node is not required by the package.
* Third-party attribution is in `inst/NOTICE`.
