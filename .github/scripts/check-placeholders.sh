#!/usr/bin/env bash
# check-placeholders.sh — verifies the template's `[LIKE_THIS]` placeholders.
#
# Two auto-detected modes:
#   - TEMPLATE mode (TEMPLATE-USAGE.md exists): every placeholder used in the repo
#     must be documented in the TEMPLATE-USAGE.md catalog (§3), either literally or
#     covered by a wildcard such as `[COMMAND_*]`.
#   - INSTANCE mode (TEMPLATE-USAGE.md was deleted): no placeholder may be left
#     unfilled, except in the intentional skeletons and except the ones marked as
#     PENDING (see below).
#
# Pending placeholders: when instantiating there is data that legitimately cannot be
# inferred (a security mailbox, a URL that does not exist yet). The rule is "do not
# invent data", so those are left — but marked:
#
#     - **Security email**: [SECURITY_EMAIL] <!-- pending: no mailbox yet -->
#
# A placeholder with a pending mark on its line —or on the immediately following one,
# because Prettier splits lines inside code fences— does not fail; the rest do.
# The mark is accepted in the three comment syntaxes that appear in the repo, because
# placeholders also live inside ```bash fences and in .env.example, where an HTML
# comment would show up literally:
#
#     [SECURITY_EMAIL] <!-- pending: no mailbox -->     markdown
#     [TEST_COMMAND]    # pending: scaffolding missing  bash, .env
#     [VIEWS_PATH]      // pending                      js/ts
# That is how what you decided to leave is told apart from what you forgot, which was
# the contradiction between "do not invent data" and "none may be left".
#
# Usage:
#   bash .github/scripts/check-placeholders.sh [repo-root]
#   bash .github/scripts/check-placeholders.sh --fillable-paths [root]
#
# Requires: git, perl. Exits 1 if it finds problems.
set -euo pipefail

MARK=0
PATHS=0
case "${1:-}" in
  --mark) MARK=1; shift ;;
  # --fillable-paths: prints, one per line, the paths where a placeholder IS a value
  # to substitute. It scopes the kickoff's fill pass instead of walking the whole
  # repository.
  #
  # It exists because the scope of that pass was already defined here —in SKIP— and
  # nobody read it: the global pass corrupted the fixtures of this very test bench
  # and filled in the internal templates under docs/, which exist precisely to keep
  # their placeholders.
  #
  # The information was not missing; a single definition both sides used was. This is
  # that definition: if SKIP changes, the list changes.
  --fillable-paths) PATHS=1; shift ;;
esac

ROOT="${1:-.}"
cd "$ROOT"

CATALOG="TEMPLATE-USAGE.md"

# Paths skipped in both modes:
#   - skeletons that keep placeholders on purpose (doc templates);
#   - .github/scripts/ and .github/workflows/ (code, not documentation);
#   - CHANGELOG.md: it is a historical record, not a form. An entry that *mentions* a
#     placeholder ("the block with [DATABASE] is removed") is not a gap to fill, and
#     rewriting the past to silence a check would be the opposite of what a changelog
#     is for.
# The rest of .github/ IS checked: skipping it whole left the [REPOSITORY_URL] of
# ISSUE_TEMPLATE/config.yml unfilled forever — broken links in every instance's own
# GitHub UI.
SKIP='^(\.github/scripts/|\.github/workflows/|CHANGELOG\.md$|docs/conventions/_template\.md|docs/decisions/0000-template\.md)'

# "Meta" mentions about the placeholder system itself (they are not placeholders to
# fill), and the title prefixes of the issue templates ("[BUG] …"), which survive
# instantiation by design. A single list (META_ALT) feeds the three filters that use
# it — keeping a copy already produced a false "pending" count in the summary.
META_ALT='PLACEHOLDER|PLACEHOLDERS|BRACKETS_IN_UPPERCASE|BUG|FEATURE|TASK'
META="^(${META_ALT})\$"

# Extracts [UPPERCASE] placeholders from a file, ignoring markdown links
# `[TEXT](target)` thanks to the negative lookahead.
extract() {
  perl -CSD -ne 'while (/\[([A-ZÁÉÍÓÚÑ0-9_\/]{2,})\](?!\()/g) { print "$ARGV:$.: [$1]\n" }' "$1"
}

# PROSE gaps: `[A paragraph describing…]`, `[NAME / GOAL]`, `[What it represents]`.
# They do not follow the [UPPERCASE_NO_SPACES] convention and so the pattern above did
# not see them: a roadmap left entirely unfilled passed green, and in a freshly
# instantiated repository there were 160 of these that nobody counted.
#
# They are only checked in INSTANCE mode: in template mode they are legitimate —the
# skeleton is made of them— and cataloging them one by one would make no sense.
#
# What legitimately carries brackets is excluded:
#   [text](link)      markdown links          → lookahead (?!\()
#   - [ ] / - [x]     task checkboxes         → they must not open the line as such
#   [!NOTE]           GitHub admonitions      → they start with !
#   ```…```           code blocks             → what is inside is quoted code, not prose
# That last one is not a detail: normal Mermaid syntax uses brackets for its nodes
# —`A["Host"]`, `Start([Entry])`— and the template recommends Mermaid diagrams in
# architecture.md, database.md and screens.md, so without this exclusion the clash was
# guaranteed in every instance and pushed people to deform the diagrams (rounded nodes
# just to please the check). [UPPERCASE] placeholders are NOT exempted:
# extract_without_pending() still looks inside the fences, because a [TEST_COMMAND] in
# a ```bash block IS a value to substitute.
extract_prose() {
  perl -CSD -e '
    my $f = shift;
    open my $fh, "<:encoding(UTF-8)", $f or exit 0;
    my @l = <$fh>;
    close $fh;
    my $fence = 0;
    for my $i (0 .. $#l) {
      my $line = $l[$i];
      if ($line =~ /^\s*(?:```|~~~)/) { $fence = !$fence; next; }
      next if $fence;
      next if $line =~ m{(?:<!--|\#|//)\s*pending}i;
      next if defined $l[$i + 1] && $l[$i + 1] =~ m{^\s*(?:<!--|\#|//)\s*pending}i;
      # Drop task checkboxes before looking at anything else.
      $line =~ s/^(\s*[-*]\s*)\[[ xX]\]/$1/;
      # And drop inline code: `[data-theme="dark"]` is a quoted example, not a gap to
      # fill. Same for any selector or fragment between backticks.
      $line =~ s/`[^`]*`//g;
      while ($line =~ /\[([^\]\[]{3,})\](?!\()/g) {
        my $t = $1;
        next if $t =~ /^!/;                      # [!NOTE], [!WARNING]
        next if $t !~ /[a-záéíóúñ]/;             # UPPERCASE only: extract() sees those
        next if $t =~ /^(Unreleased|\d+\.\d+\.\d+)$/;  # Keep a Changelog syntax
        next if $t =~ /=/;                       # selectors like [data-theme="dark"]
        printf "%s:%d: [%s]\n", $f, $i + 1, $t;
      }
    }
  ' "$1"
}

# Same, but skipping the placeholders deliberately marked as pending.
#
# The mark counts on the SAME line or on the IMMEDIATELY FOLLOWING one. The second is
# not laxity: `pre-commit` formats with Prettier, which inside a ```html fence splits
# the line and leaves the comment below —
#
#     <meta content="[OG_IMAGE_URL]" /> <!-- pending: image missing -->
#   becomes
#     <meta content="[OG_IMAGE_URL]" />
#     <!-- pending: image missing -->
#
# — so demanding the same line meant that marking it properly and committing broke the
# check, advising you to do exactly what you had already done. The following line is
# accepted only if the comment OPENS it (nothing but whitespace before): that way a
# marker placed for another placeholder does not excuse this one by proximity.
extract_without_pending() {
  perl -CSD -e '
    my $f = shift;
    open my $fh, "<:encoding(UTF-8)", $f or exit 0;
    my @l = <$fh>;
    close $fh;
    for my $i (0 .. $#l) {
      next if $l[$i] =~ m{(?:<!--|\#|//)\s*pending}i;
      next if defined $l[$i + 1] && $l[$i + 1] =~ m{^\s*(?:<!--|\#|//)\s*pending}i;
      while ($l[$i] =~ /\[([A-ZÁÉÍÓÚÑ0-9_\/]{2,})\](?!\()/g) {
        printf "%s:%d: [%s]\n", $f, $i + 1, $1;
      }
    }
  ' "$1"
}

# `git ls-files` lists what git TRACKS, not what is on disk: during a prune, a file
# deleted with `rm` (and not `git rm`) still shows up here and perl failed to open it,
# spitting its raw error while the summary reported everything as checked.
files() {
  # --others --exclude-standard adds what EXISTS but git does not track yet, honoring
  # .gitignore: when adopting the template in an existing project dozens of documents
  # are copied without committing, and without this the check ignored them and answered
  # "none left" exactly when the question was "what do I still have to fill in?".
  # config.yml is included explicitly: it is not .md, but it carries [REPOSITORY_URL]
  # and it is what GitHub shows as contact links under "New issue".
  git ls-files --cached --others --exclude-standard '*.md' '.env.example' '.github/ISSUE_TEMPLATE/config.yml' \
    | sort -u | grep -Ev "$SKIP" | while IFS= read -r f; do
      [ -f "$f" ] && printf '%s\n' "$f"
    done || true
}

# ── --fillable-paths: the scope of the fill pass, and nothing else ───────────
# It uses files(), so it comes from the SAME SKIP list the two check modes use. It
# prints nothing else —no header, no summary— so it can be piped directly:
# `... --fillable-paths | xargs perl -pi -e '...'`.
if [ "$PATHS" -eq 1 ]; then
  files
  exit 0
fi

if [ -f "$CATALOG" ]; then
  # ── TEMPLATE mode: catalog consistency ─────────────────────────────────────
  # Wildcards documented in the catalog, in their two forms — because the naming
  # convention differs by language and both are legitimate:
  #   `[COMMAND_*]` → prefix  COMMAND_
  #   `[*_COMMAND]` → suffix  _COMMAND
  # Supporting only one of them forced writing out fifty entries by hand in the
  # variant that used the other, and a catalog nobody can keep up to date stops
  # being a catalog.
  wildcards="$(perl -CSD -ne 'while (/\[([A-ZÁÉÍÓÚÑ0-9_\/]+_)\*\]/g) { print "p$1\n" }' "$CATALOG" | sort -u)"
  wildcards="$wildcards
$(perl -CSD -ne 'while (/\[\*(_[A-ZÁÉÍÓÚÑ0-9_\/]+)\]/g) { print "s$1\n" }' "$CATALOG" | sort -u)"

  missing=0
  placeholders="$(
    files | grep -v "^$CATALOG$" | while IFS= read -r f; do extract "$f"; done \
      | sed -E 's/^.*\[([^]]+)\]$/\1/' | sort -u
  )"

  while IFS= read -r p; do
    [ -z "$p" ] && continue
    printf '%s' "$p" | grep -Eq "$META" && continue
    grep -qF "[$p]" "$CATALOG" && continue
    covered=0
    while IFS= read -r w; do
      [ -z "$w" ] && continue
      case "$w" in
        p*) case "$p" in "${w#p}"*) covered=1 ;; esac ;;
        s*) case "$p" in *"${w#s}") covered=1 ;; esac ;;
      esac
    done <<<"$wildcards"
    [ "$covered" -eq 1 ] && continue
    echo "❌ [$p] is used in the repo but is not in the $CATALOG catalog (§3)."
    missing=1
  done <<<"$placeholders"

  if [ "$missing" -ne 0 ]; then
    echo "→ Add the missing placeholders to the $CATALOG catalog."
    exit 1
  fi
  echo "✅ Placeholders: every one in use is documented in the catalog."
else
  # ── INSTANCE mode: no placeholder may be left unfilled ─────────────────────
  # PROJECT-level pending items: a piece of data missing everywhere at once (the
  # client's mailbox, the domain not yet bought) is not marked line by line — that is
  # dozens of comments for a single unanswered question, and in files published as
  # product pages it would put HTML comments in front of users. They are declared once
  # in `.pending`, at the root:
  #
  #     SUPPORT_EMAIL=the client has not given the mailbox yet
  #
  # They are listed separately in the summary, which is where they are useful: in one
  # place, to claim them from whoever owes them.
  globals=""
  if [ -f .pending ]; then
    globals="$(sed -n 's/^\([A-ZÁÉÍÓÚÑ0-9_]\{2,\}\)=.*/\1/p' .pending | sort -u)"
  fi

  leftovers="$(files | while IFS= read -r f; do extract_without_pending "$f"; done || true)"
  # The issue/PR templates are forms whose prose gaps ("[e.g. iPhone 13]") are for
  # whoever reports, not for whoever instantiates: out of the prose check (the
  # [UPPERCASE] one does apply — REPOSITORY_URL lives there).
  prose="$(files | grep -Ev '^\.github/(ISSUE_TEMPLATE|PULL_REQUEST_TEMPLATE)' \
    | while IFS= read -r f; do extract_prose "$f"; done || true)"
  # It filters by the extracted entry (`file:line: [NAME]`), not by the document line:
  # if one line had two placeholders and only one were global, the other must still fail.
  while IFS= read -r g; do
    [ -z "$g" ] && continue
    leftovers="$(printf '%s' "$leftovers" | grep -v "\[$g\]\$" || true)"
  done <<<"$globals"
  # Here too, meta mentions do not count as pending.
  leftovers="$(printf '%s' "$leftovers" | grep -Ev "\[(${META_ALT})\]" || true)"

  # --mark: adopting this check in a project that already exists turns red, all at
  # once, every gap nobody demanded until now —160 in a real repository—. Nobody marks
  # them one by one; leaving CI red is not an option either, because a permanent red
  # stops being looked at.
  #
  # This marks them in a single pass, SAYING they are unreviewed. It does not fill them
  # in nor hide them: they keep being listed on every run, which is exactly what makes
  # them annoying until somebody writes them.
  #
  # It only touches PROSE gaps. [UPPERCASE] placeholders are values that must be
  # substituted, and marking those in bulk would indeed be hiding them.
  if [ "$MARK" -eq 1 ]; then
    if [ -z "$prose" ]; then
      echo "✅ No prose gaps to mark."
      exit 0
    fi
    printf '%s\n' "$prose" | perl -ne '
      next unless /^(.+?):(\d+): /;
      push @{$spots{$1}}, $2;
      END {
        for my $f (sort keys %spots) {
          open my $in, "<:encoding(UTF-8)", $f or next;
          my @l = <$in>;
          close $in;
          my %n = map { $_ => 1 } @{$spots{$f}};
          for my $i (keys %n) {
            next unless defined $l[$i - 1];
            chomp(my $t = $l[$i - 1]);
            $l[$i - 1] = "$t <!-- pending: inherited when adopting the check, unreviewed -->\n";
          }
          open my $out, ">:encoding(UTF-8)", $f or next;
          print $out @l;
          close $out;
          printf "   · %s (%d)\n", $f, scalar keys %n;
        }
      }
    '
    n_m="$(printf '%s' "$prose" | grep -c . || true)"
    echo "✅ Marked $n_m gap(s) as inherited and unreviewed."
    echo "→ Commit this SEPARATELY, before adopting the check. They keep being listed on"
    echo "  every run until somebody writes them: that is the point."
    exit 0
  fi

  # Prose gaps are listed apart: they are of a different nature —paragraphs to write,
  # not values to substitute— and mixing them would make the output unreadable.
  if [ -n "$prose" ]; then
    n_prose="$(printf '%s' "$prose" | grep -c . || true)"
    echo "❌ $n_prose documentation gap(s) still unwritten:"
    printf '%s\n' "$prose" | head -20 | sed 's/^/   · /'
    [ "${n_prose:-0}" -gt 20 ] && echo "   … and $((n_prose - 20)) more."
    echo "→ Write them, or mark them with '<!-- pending: why -->' on their line or the"
    echo "  next one, or delete the section if it does not apply to this product."
  fi

  if [ -n "$leftovers" ]; then
    echo "❌ Placeholders left unfilled:"
    printf '%s\n' "$leftovers"
    echo "→ Fill them in, or mark them as a conscious decision with a"
    echo "  '<!-- pending: why -->' comment on the same line or the next one,"
    echo "  or delete the document if it does not apply."
    echo "  (In .env.example and in code blocks the mark uses '#' or '//'.)"
    exit 1
  fi

  [ -n "$prose" ] && exit 1

  # The marked ones ARE listed, so they do not become permanent out of inertia.
  # The filter uses the whole $META: without BUG|FEATURE|TASK here, every clean
  # instance reported "3 marked" forever — a permanent false count.
  pending="$(files | while IFS= read -r f; do extract "$f"; done || true)"
  pending="$(printf '%s' "$pending" | grep -Ev "\[(${META_ALT})\]" || true)"
  n="$(printf '%s' "$pending" | grep -c . || true)"

  if [ "${n:-0}" -gt 0 ]; then
    echo "✅ Placeholders: none forgotten. $n marked as pending:"
    printf '%s\n' "$pending" | sed 's/^/   · /'
  else
    echo "✅ Placeholders: none left unfilled."
  fi

  if [ -n "$globals" ]; then
    echo "   Project-level pending items declared in .pending:"
    sed -n 's/^\([A-ZÁÉÍÓÚÑ0-9_]\{2,\}\)=\(.*\)/   · \1 — \2/p' .pending
  fi
fi
