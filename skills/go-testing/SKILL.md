---
name: go-testing
description: Go testing patterns - table-driven, parallelism, mocks, integration. Use when writing or fixing tests.
---

# go-testing

## Base pattern
- Table-driven with named subtests:
```go
tests := []struct{ name string; in X; want Y; wantErr error }{...}
for _, tt := range tests {
    t.Run(tt.name, func(t *testing.T) { t.Parallel(); ... })
}
```
- `t.Helper()` in every assert helper. `t.Cleanup` > defer for teardown.
- Always cover: happy path, expected error, zero-value/empty, boundary.
- `got`/`want` in that order: `got %v, want %v`.

## Rules
- Unit tests: no network, no disk, no sleep. Time via injection (`func() time.Time` or clock interface).
- Mock = hand-written implementation of the small interface in the `_test.go` itself. Mock generators only if deps policy allows.
- Determinism: never depend on map order; sort before comparing.
- `t.Parallel()` by default; drop it only with real shared state.
- Integration: build tag `//go:build integration` + `make test-integration` target. testcontainers only in pragmatic profile.
- Run `-race` on any code with goroutines. CI always `-race -count=1`.
- Coverage: pragmatic target ~80% in `internal/`; don't chase 100% in main/wiring.

## Comparison
- stdlib: `reflect.DeepEqual` or field-by-field. `go-cmp`/`testify` only in pragmatic profile.
- Golden files in `testdata/` for large outputs; `-update` flag to regenerate.
