#!/bin/bash

# Formats all of the repo's Markdown files with Prettier.
# Does not require installing Prettier: it runs it via npx (needs Node.js).
#
# Usage:
#   bash .github/scripts/format-markdown.sh          # formats (--write)
#   bash .github/scripts/format-markdown.sh --check   # only verifies, doesn't write

set -e

MODE="--write"
if [ "$1" = "--check" ]; then
	MODE="--check"
fi

if ! command -v npx &> /dev/null; then
	echo "Error: Node.js (npx) is required to run Prettier." >&2
	echo "Install it from https://nodejs.org/" >&2
	exit 1
fi

echo "Running Prettier ($MODE) on the Markdown files…"
npx --yes prettier@3 "$MODE" "**/*.md"
echo "Done."
