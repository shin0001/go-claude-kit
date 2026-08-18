---
description: Reviews changes via the go-reviewer agent (uncommitted by default)
argument-hint: [git range, e.g. main..HEAD]
---

Scope: `$ARGUMENTS` (empty => `git diff HEAD` + untracked .go).
Delegate to the **go-reviewer** agent. Relay the raw output (file:line format is already terse — don't reformat, don't summarize).
If there are BLOCKERs and mode is autopilot: offer to fix via go-implementer.
