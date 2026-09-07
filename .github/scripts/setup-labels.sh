#!/bin/bash

# Script to create labels on GitHub using the gh CLI.
# The labels are READ from the tables in ../LABELS.md — that file is the source of
# truth and there is no copy here: they used to be duplicated on both sides and had
# already drifted apart without anything noticing.
# Requires: GitHub CLI (gh) installed and authenticated.
# Usage: bash .github/scripts/setup-labels.sh

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}=== GitHub Label Configuration ===${NC}\n"

if ! command -v gh &> /dev/null; then
	echo -e "${YELLOW}Error: GitHub CLI (gh) is not installed.${NC}"
	echo "Install it from: https://cli.github.com/"
	exit 1
fi

if ! gh auth status &> /dev/null; then
	echo -e "${YELLOW}Error: You are not authenticated with the GitHub CLI.${NC}"
	echo "Run: gh auth login"
	exit 1
fi

REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner 2>/dev/null)

if [ -z "$REPO" ]; then
	echo -e "${YELLOW}Error: Could not detect the repository.${NC}"
	echo "Run this script from the repository directory."
	exit 1
fi

echo -e "${GREEN}Configuring labels for: $REPO${NC}\n"

create_label() {
  local name=$1
  local color=$2
  local description=$3
  echo -e "Creating label: ${BLUE}$name${NC}"
  gh label create "$name" --color "$color" --description "$description" --force 2>/dev/null || true
}

# ── Read the labels from the LABELS.md tables ────────────────────────────────
# Each row is `| `name` | `#HEX` | text |`; the third column acts as the
# description (GitHub truncates it to 100 characters, and so do we).
LABELS_MD="$(cd "$(dirname "$0")" && pwd)/../LABELS.md"

if [ ! -f "$LABELS_MD" ]; then
	echo -e "${YELLOW}Error: could not find $LABELS_MD (the source of truth for labels).${NC}"
	exit 1
fi

total=0
while IFS= read -r row; do
	name="$(sed -E 's/^\|[[:space:]]*`([^`]+)`.*/\1/' <<<"$row")"
	color="$(sed -E 's/.*`#([0-9A-Fa-f]{6})`.*/\1/' <<<"$row")"
	desc="$(awk -F'|' '{gsub(/^[ \t]+|[ \t]+$/, "", $4); print $4}' <<<"$row" | tr -d '\140' | cut -c1-100)"
	create_label "$name" "$color" "$desc"
	total=$((total + 1))
done < <(grep -E '^\| *`[^`]+` *\| *`#[0-9A-Fa-f]{6}` *\|' "$LABELS_MD")

if [ "$total" -eq 0 ]; then
	echo -e "${YELLOW}Error: no label row found in LABELS.md.${NC}"
	exit 1
fi

echo -e "\n${GREEN}$total labels configured successfully!${NC}"
echo -e "\nView labels at: ${BLUE}https://github.com/$REPO/labels${NC}\n"
