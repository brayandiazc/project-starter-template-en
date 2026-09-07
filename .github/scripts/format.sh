#!/bin/bash

# Formats with Prettier every file in the repo it understands without plugins:
# Markdown, HTML, CSS, JSON and YAML. Application code is NOT touched here —
# that one is handled by the stack's linter (see docs/conventions/quality-tooling.md).
#
# Prettier does not need to be installed: it runs via npx (requires Node.js).
#
# THE VERSION IS PINNED, and not for speed. A floating `prettier@3` resolves to a
# different minor depending on the day, and a formatter that changes version changes
# its output: the same file passes on one machine and fails in CI, or a PR that was
# not about that reformats half the repository. It is a reproducibility failure.
#
# The side effect is that it stops hurting: `npx` caches per exact specifier, so only
# the first call resolves. With `@3` every invocation resolved again, and `pre-commit`
# calls it four times — the whole `pre-push` ran into minutes and looked hung.
#
# To bump it: change this line, run the script, and commit the reformat separately.
# There is no rush —an old version formats like last year, it breaks nothing— but
# review it when a major ships.
PRETTIER="prettier@3.9.6"
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
npx --yes "$PRETTIER" "$MODE" "**/*.{md,html,css,json,yml,yaml}"
echo "Done."
