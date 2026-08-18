---
name: go-style
description: Idiomatic Go style (Effective Go + Google Style distilled). Use when writing or reviewing any Go code.
---

# go-style

## Language and comments
- Code 100% in English — identifiers, error messages, logs, test names, comments — regardless of conversation language.
- Comment only to explain a non-obvious WHY (workaround, invariant, counter-intuitive decision). Never narrate what code already says (`// increment counter` = delete).
- Godoc only on exported API, and only if it adds beyond the signature. Sentence starts with the name: `// Order represents...`.
- Readability comes from code, not comments: a name that removes the comment > the comment. Short well-named function > commented block.
- TODO with owner/context: `// TODO(user): reason`. No dead commented-out code.

## Errors
- Wrap with operation context: `fmt.Errorf("open config: %w", err)`. No repeated "failed to" at every level.
- Sentinels: `var ErrNotFound = errors.New(...)`; check with `errors.Is/As`, never compare strings.
- Custom error types only when the caller needs structured data.
- panic: only main/init or impossible bugs. Libraries never panic.
- Don't log AND return the same error (double logging). Log at the edge (handler), return in the middle.

## API and types
- Accept interfaces, return structs. Interface defined in the consumer package, not the producer.
- Small interfaces (1-3 methods). `io.Reader` > `*os.File` in signatures.
- Useful zero-value: `var b bytes.Buffer` works; `NewX` constructor only for invariants.
- `context.Context` first parameter of everything doing I/O. Never store ctx in a struct.
- Export the minimum. `internal/` for everything that isn't public API.

## Code
- Early return; happy path unindented. No `else` after return.
- Short names in short scopes (`i`, `r`, `srv`); descriptive in long scopes. No stutter: `user.New`, not `user.NewUser`.
- Receiver: pointer if it mutates or struct is large; consistent across the type.
- No naked returns. No `init()` with logic. No mutable globals.
- slog for structured logs (stdlib >= 1.21). No fmt.Println in servers.

## Layout
- `cmd/<bin>/main.go` thin: parse config, wire deps, call `run(ctx) error`.
- `internal/` by domain (e.g. `internal/order`), not technical layer (`models`, `services`, `utils`, `common` = forbidden).
- No new `pkg/` by default.

## Files within a package
- Type lives with its behavior: struct + constructor + methods in the concept's file (`order.go` holds `Order`). NEVER generic `types.go`/`models.go`.
- Small package = 1 file, and that's fine. Don't build structure ahead of need.
- When it grows: split by responsibility, not by kind or size — e.g. `order.go` (domain), `store.go` (persistence), `http.go` (transport). Filename answers "what's in here".
- Accepted exceptions to "don't group by kind": `errors.go` (package sentinels), `doc.go` (package godoc), generated files (`*_gen.go`, separate, never hand-edited).
- Split trigger is cohesion (scrolling past unrelated things), not line count.
