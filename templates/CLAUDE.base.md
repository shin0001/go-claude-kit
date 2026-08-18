<!-- Template composed by /go-init. [[...]] blocks are chosen per profile; the rest is fixed. Target: final CLAUDE.md <= 50 lines. -->

# {{PROJECT}}

{{ONE_LINE_DESCRIPTION}}

## Commands
- `make build` / `make test` / `make lint` / `make cover`
- Single package test: `go test ./internal/x/... -run TestName -v`
- {{EXTRA_COMMANDS}}

## Architecture
{{MAX_3_LINES_WITH_FILE_POINTERS}}

## Rules
- Chat replies: user's language. Code: always English (identifiers, errors, logs, comments). Comments only for non-obvious "why"; readability comes from names and short functions.
- Files: type lives with its behavior (`order.go` holds `Order` + methods). No `types.go`/`models.go`. Split by responsibility when cohesion demands.
- Errors: wrap with `%w` + operation context. No panic outside main.
- `context.Context` first arg for I/O. Every goroutine has an owner and an exit.
- Tests table-driven; unit tests without network/disk/sleep. `-race` on concurrent code.
- Secrets never in code (hook blocks). Code exposed to external input: go-security skill. go.mod changed => `make vuln`.
- Don't refactor code unrelated to the task.
- If the user corrects the same thing twice: suggest `/go-learn` (1 line, don't push).
- Details: go-style, go-testing, go-concurrency, go-security skills (load on demand).

[[MODE_AUTOPILOT]]
## Mode: autopilot
- Default flow: /go-plan -> /go-implement -> /go-review -> /go-test. Chain without asking between stages.
- Delegate exploration to go-explorer; tests to go-tester (don't run long suites in the main session).
- May edit, build and test directly. NEVER: git push, touch applied migrations, touch .env.
- When done: summarized diff + test results. Don't narrate step by step.
[[/MODE_AUTOPILOT]]

[[MODE_COPILOT]]
## Mode: copilot
- Small, surgical changes. Propose the diff BEFORE applying when touching >1 file.
- Never create files/packages without confirming. No commands beyond build/test of the touched package.
- Ask when the requirement is ambiguous; don't assume.
- Short answers: code + 1-2 sentences. No tutorials.
[[/MODE_COPILOT]]

[[DEPS_MINIMAL]]
## Dependencies: minimal
- stdlib first, always. New dependency = forbidden without my explicit approval.
- Allowed without asking: `golang.org/x/*`.
- If stdlib can't solve it, STOP and propose: problem, stdlib option discarded and why, suggested lib.
[[/DEPS_MINIMAL]]

[[DEPS_PRAGMATIC]]
## Dependencies: pragmatic
- Curated (use without asking): {{STACK_CURATED_LIBS}}, `golang.org/x/*`, `google/go-cmp`.
- Off-list: propose with a 1-line justification before adding.
- Always `go mod tidy` after changing deps; check license and active maintenance.
[[/DEPS_PRAGMATIC]]

[[STACK]]
## Stack
{{STACK_LINES}}
[[/STACK]]

## Project learnings
@.claude/learned.md
