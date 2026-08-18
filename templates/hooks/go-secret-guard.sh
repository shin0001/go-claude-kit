#!/usr/bin/env bash
# PostToolUse(Edit|Write): blocks (exit 2) if the edit introduced a secret pattern.
set -u
INPUT=$(cat)
if command -v jq >/dev/null 2>&1; then
  FILE=$(printf '%s' "$INPUT" | jq -r '.tool_input.file_path // empty')
else
  FILE=$(printf '%s' "$INPUT" | grep -o '"file_path"[^,}]*' | head -1 | sed 's/.*: *"\(.*\)"/\1/')
fi
[ -z "${FILE:-}" ] || [ ! -f "$FILE" ] && exit 0
case "$FILE" in
  */testdata/*|*.md) exit 0 ;;
esac

HITS=$(grep -nE \
  -e '-----BEGIN (RSA |EC |OPENSSH )?PRIVATE KEY' \
  -e 'AKIA[0-9A-Z]{16}' \
  -e 'ghp_[A-Za-z0-9]{36}' \
  -e 'sk-[A-Za-z0-9_-]{20,}' \
  -e '(api[_-]?key|apikey|secret|token|passw(or)?d)[[:space:]]*[:=][[:space:]]*"[^"$]{12,}"' \
  "$FILE" 2>/dev/null | grep -v 'gcksafe')

if [ -n "$HITS" ]; then
  echo "POSSIBLE SECRET in $FILE — move to env/secret manager, or mark the line with // gcksafe if it's a proven dummy:" >&2
  echo "$HITS" | head -5 >&2
  exit 2
fi
exit 0
