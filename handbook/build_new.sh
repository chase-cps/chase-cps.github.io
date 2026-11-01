#!/bin/sh
# Builds the handbook into ../new, the new website at chase-cps.github.io/new/,
# published as it is next to the old pages (until GitHub Pages is set to
# build the handbook itself, .github/workflows/pages.yml). Needs MkDocs:
#   pip install mkdocs==1.6.1 pymdown-extensions==10.21.3
set -e
cd "$(dirname "$0")"
SITE_URL=https://chase-cps.github.io/new/ mkdocs build --strict -d ../new
