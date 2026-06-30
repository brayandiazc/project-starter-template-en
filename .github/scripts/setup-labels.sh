#!/bin/bash

# Script to create labels on GitHub using the gh CLI.
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

# ── Automatic labels (used by labeler.yml) ───────────────────────────────────
echo -e "\n${GREEN}Automatic labels (labeler)${NC}"
create_label "documentation" "0075CA" "Documentation changes"
create_label "frontend"      "0052CC" "UI / client changes"
create_label "styles"        "BFD4F2" "CSS / styling changes"
create_label "backend"       "006B75" "Server / API / logic changes"
create_label "database"      "5319E7" "Migrations, schema, or seeds"
create_label "testing"       "FBCA04" "Test changes"
create_label "dependencies"  "0366D6" "Dependency updates"
create_label "config"        "D4C5F9" "Configuration changes"
create_label "ci-cd"         "F9D0C4" "CI/CD, workflow, and Docker changes"
create_label "github"        "333333" "GitHub template and config changes"

# ── Manual labels ────────────────────────────────────────────────────────────
echo -e "\n${GREEN}Manual labels${NC}"
create_label "bug"              "D73A4A" "Something isn't working correctly"
create_label "enhancement"      "A2EEEF" "New feature or improvement"
create_label "breaking change"  "B60205" "Changes that break compatibility"
create_label "needs review"     "FBCA04" "Requires review"
create_label "work in progress" "FEF2C0" "Work in progress"
create_label "ready for merge"  "0E8A16" "Approved and ready to merge"
create_label "blocked"          "B60205" "Blocked by dependencies"
create_label "help wanted"      "008672" "External help needed"
create_label "good first issue" "7057FF" "Good for new contributors"
create_label "duplicate"        "CFD3D7" "Duplicate issue or PR"
create_label "invalid"          "E4E669" "Not valid or not applicable"
create_label "wontfix"          "FFFFFF" "This will not be worked on"
create_label "question"         "D876E3" "Request for information"

echo -e "\n${GREEN}Labels configured successfully!${NC}"
echo -e "\nView labels at: ${BLUE}https://github.com/$REPO/labels${NC}\n"
