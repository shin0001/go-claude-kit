#!/usr/bin/env bash
# Stop (so autopilot): sanity barato antes de encerrar o turno. go build e cacheado => rapido.
set -u
cd "${CLAUDE_PROJECT_DIR:-.}" || exit 0
OUT=$(go build ./... 2>&1)
if [ $? -ne 0 ]; then
  echo "Build quebrado — corrija antes de encerrar:" >&2
  echo "$OUT" | head -20 >&2
  exit 2
fi
exit 0
