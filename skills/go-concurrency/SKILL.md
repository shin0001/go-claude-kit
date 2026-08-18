---
name: go-concurrency
description: Safe Go concurrency - goroutines, channels, context, errgroup. Use when writing/reviewing concurrent code.
---

# go-concurrency

## Golden rules
- Every goroutine needs: (1) an owner that waits for it, (2) an exit path via ctx/close. No fire-and-forget.
- Whoever creates the channel closes the channel. Receivers never close.
- Don't communicate by sharing memory; share by communicating. But: simple counter/cache = mutex, not channel.
- `go vet` + `-race` always. A detected race is a real bug, never "flaky".

## Patterns
- Bounded fan-out with aggregated error: `golang.org/x/sync/errgroup` + `g.SetLimit(n)`.
- Cancellation: propagate ctx; check `ctx.Err()` in long loops; `select { case <-ctx.Done(): return ctx.Err() ... }`.
- Per-operation timeout: `context.WithTimeout` at the caller, not inside the function.
- Worker pool only under real load; until then, errgroup covers it.
- `sync.Once` for lazy init; `sync.WaitGroup` when there's no error to propagate.

## Pitfalls
- Loop variable captured in goroutine (fine >= go1.22, but be explicit).
- `time.Tick` leaks; use `time.NewTicker` + `defer Stop()`.
- Mutex copied by value (embed `*sync.Mutex` or pointer receiver).
- Unbuffered channel publish without a guaranteed receiver = deadlock.
- HTTP handler spawning a goroutine that uses `r.Context()` after return.
