---
description: Evaluates adding a dependency according to the project policy
argument-hint: <library import path>
---

Lib: "$ARGUMENTS". Read the dependency policy in CLAUDE.md.

1. **minimal**: show how to solve with stdlib/x. Only if unviable, present the lib with its cost: transitives (estimated via `go mod graph`), maintenance, license. User decides.
2. **pragmatic**: on the curated list => `go get` + `go mod tidy` directly. Off-list => 3 lines: what it solves, stdlib alternative discarded and why, repo health (web-search if needed). Wait for OK.

Never add a dep without the gate above. After adding: record it in the CLAUDE.md curated list.
