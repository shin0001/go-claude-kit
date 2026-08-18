---
description: Implements an approved plan (or direct task) according to the project mode
argument-hint: [plan path | task description]
---

Target: "$ARGUMENTS" (empty: most recent plan in `docs/plans/`).

**autopilot** mode (see CLAUDE.md):
1. Delegate to the **go-implementer** agent with the full plan.
2. When done, delegate to **go-tester** (with `-race` if concurrent code was touched).
3. Failures: send diagnosis back to implementer. Max 3 cycles; then stop and report.
4. `go.mod`/`go.sum` changed => `govulncheck ./...` (or delegate to **go-auditor** if the dep change was large).
5. Delegate the final diff to **go-reviewer**. BLOCKERs: fix and re-review once.
6. Final report: files, tests (pass/fail), remaining findings. Terse.
7. Retro (1 line, only if applicable): user correction or avoidable rework happened => suggest `/go-learn "<lesson>"`.

**copilot** mode:
1. Implement YOURSELF in the main session, step by step through the plan.
2. Show diff before applying when touching >1 file. Run only the touched package's tests.
3. Pause between larger steps for the user to validate.
