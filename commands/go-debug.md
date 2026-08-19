---
description: Systematic bug fix - reproduce with a failing test first, isolate, minimal fix, regression-proof
argument-hint: <bug description, error message or issue link>
---

Bug: "$ARGUMENTS". Discipline: no fix before a red test.

1. **Reproduce**: write the minimal failing test that captures the bug (autopilot: via go-implementer; copilot: in-session, show before saving). Can't reproduce => say what was tried, ask for more context. STOP here until red.
2. **Isolate**: go-explorer to map the code path. Regression suspected => `git log -S '<symbol>' --oneline -10` or offer `git bisect run go test -run TestX ./pkg` (autopilot may run it; max 10 steps).
3. **Fix**: minimal change that turns the test green. No opportunistic refactoring — note `// TODO(user):` and move on.
4. **Verify**: go-tester on the touched package with `-race`, then full suite. The repro test stays as a regression test (name it `TestBug<short-desc>` or reference the issue).
5. Report: root cause in 1-2 lines, fix location, test added. If the root cause reveals a pattern worth remembering => suggest `/go-learn`.
