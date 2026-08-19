#!/usr/bin/env bash
# Validates the kit's own structure. Run locally and in CI. Exit != 0 on any failure.
set -u
cd "$(dirname "$0")/.."
FAIL=0
err() { echo "FAIL: $*"; FAIL=1; }

# JSON
for f in .claude-plugin/*.json templates/*.json; do
  python3 -c "import json;json.load(open('$f'))" 2>/dev/null || err "invalid JSON: $f"
done

# Shell syntax
for f in templates/hooks/*.sh scripts/*.sh; do
  bash -n "$f" || err "bash syntax: $f"
done

# Frontmatter: agents need name+description+model; skills need name+description; commands need description
check_fm() { head -20 "$1" | grep -q "^$2:" || err "$1 missing frontmatter field: $2"; }
for f in agents/*.md; do check_fm "$f" name; check_fm "$f" description; check_fm "$f" model; done
for f in skills/*/SKILL.md; do check_fm "$f" name; check_fm "$f" description; done
for f in commands/*.md; do check_fm "$f" description; done

# Token budget guards
LINES=$(wc -l < templates/CLAUDE.base.md)
[ "$LINES" -le 90 ] || err "CLAUDE.base.md has $LINES lines (max 90 — generated file must stay <= 50)"
for f in skills/*/SKILL.md; do
  L=$(wc -l < "$f"); [ "$L" -le 70 ] || err "$f has $L lines (max 70 — skills must stay terse)"
done

# Hook scripts referenced by settings must exist in templates
for h in go-postedit go-secret-guard go-stop-check; do
  [ -f "templates/hooks/$h.sh" ] || err "missing hook: $h.sh"
  grep -rq "$h.sh" templates/settings.*.json || err "$h.sh not referenced by any settings template"
done

[ "$FAIL" -eq 0 ] && echo "kit OK" || exit 1
