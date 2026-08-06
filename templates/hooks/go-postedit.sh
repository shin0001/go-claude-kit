#!/usr/bin/env bash
# PostToolUse(Edit|Write): formata e veta apenas o arquivo .go tocado. Rapido e silencioso quando ok.
set -u
INPUT=$(cat)
if command -v jq >/dev/null 2>&1; then
  FILE=$(printf '%s' "$INPUT" | jq -r '.tool_input.file_path // empty')
else
  FILE=$(printf '%s' "$INPUT" | grep -o '"file_path"[^,}]*' | head -1 | sed 's/.*: *"\(.*\)"/\1/')
fi
[ -z "${FILE:-}" ] && exit 0
case "$FILE" in *.go) ;; *) exit 0 ;; esac
[ -f "$FILE" ] || exit 0

if command -v gofumpt >/dev/null 2>&1; then gofumpt -w "$FILE"; else gofmt -w "$FILE"; fi
command -v goimports >/dev/null 2>&1 && goimports -w "$FILE"

PKG=$(dirname "$FILE")
VET=$(go vet "./$PKG/..." 2>&1)
if [ $? -ne 0 ]; then
  # exit 2 => stderr volta para o Claude corrigir imediatamente
  echo "go vet falhou em $PKG:" >&2
  echo "$VET" | head -20 >&2
  exit 2
fi
exit 0
