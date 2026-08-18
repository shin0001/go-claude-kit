#!/usr/bin/env bash
# Stop (autopilot only): cheap sanity before ending the turn. go build is cached => fast.
set -u
cd "${CLAUDE_PROJECT_DIR:-.}" || exit 0
OUT=$(go build ./... 2>&1)
if [ $? -ne 0 ]; then
  echo "Build broken — fix before ending the turn:" >&2
  echo "$OUT" | head -20 >&2
  exit 2
fi
exit 0
