#!/bin/bash

# Formats with Prettier every file in the repo it understands without plugins:
# Markdown, HTML, CSS, JSON and YAML. Application code is NOT touched here —
# that one is handled by the stack's linter (see docs/conventions/quality-tooling.md).
#
# Prettier does not need to be installed: it runs via npx (requires Node.js).
#
# Usage:
#   bash .github/scripts/format.sh          # format (--write)
#   bash .github/scripts/format.sh --check  # check only, no writes

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

echo "Running Prettier ($MODE) over Markdown, HTML, CSS, JSON and YAML…"
npx --yes prettier@3 "$MODE" "**/*.{md,html,css,json,yml,yaml}"
echo "Done."
