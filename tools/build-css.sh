#!/usr/bin/env bash
# Rebuild the bundled stylesheet from inst/css/src/.
#
# Requires Node and the Tailwind CLI. From the package root:
#   npm install --no-save tailwindcss @tailwindcss/typography
#   tools/build-css.sh
set -euo pipefail
cd "$(dirname "$0")/.."
npx --yes @tailwindcss/cli@4.3.4 \
  -i inst/css/src/astropaper.css \
  -o inst/css/astropaper.compiled.css \
  --minify
