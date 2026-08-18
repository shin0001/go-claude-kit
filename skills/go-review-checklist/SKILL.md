---
name: go-review-checklist
description: Full Go code review checklist used by the go-reviewer agent and /go-review command.
---

# go-review-checklist

Severity order. Report format: `file:line [SEV] problem -> fix`.

## BLOCKER
- Error ignored (`_ = f()` without justification) or swallowed in a branch.
- Data race, goroutine leak, potential channel deadlock.
- Unclosed resource: Body, Rows, file, tx without deferred Rollback.
- SQL by concatenation; secret/credential in code; unvalidated external input.
- HTTP/DB client without timeout.
- Breaking change to exported API without versioning.

## WARN
- Error without `%w` when the caller may need `errors.Is/As`.
- Oversized interface (>3 methods) or defined at the producer without need.
- Missing test for a new error path; test with sleep/real network.
- Dead code, needless export, unjustified new dependency.
- Complexity: >50-line function doing 3 things; nesting >3 levels.
- Log + return of the same error (duplication).
- Non-English identifier/error/log. Comment narrating the obvious (ask removal). Generic `types.go`/`models.go` in new code.

## NIT
- Stuttering name, else after return, import order.
- Capitalized error message or trailing punctuation.

## Don't comment on
- Style gofumpt/golangci-lint already catches. Personal preference without impact.
