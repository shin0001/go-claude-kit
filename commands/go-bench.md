---
description: Runs benchmarks and compares against a baseline via benchstat
argument-hint: [package] [bench name]
---

Delegate to the **go-tester** agent:
1. `go test -bench='${2:-.}' -benchmem -count=6 -run='^$' ./${1:-...} | tee /tmp/bench.new`
2. `/tmp/bench.old` or `docs/bench-baseline.txt` exists? => `benchstat <baseline> /tmp/bench.new` (install: `go install golang.org/x/perf/cmd/benchstat@latest`). Otherwise: save new as baseline and say so.
3. Report ONLY significant deltas (p<0.05): `Bench: -12% time, +0% alloc`. Noise => say "no significant change" and stop.
4. Relevant regression: suggest profiling — `go test -bench=X -cpuprofile=cpu.out ./pkg && go tool pprof -top cpu.out` — but don't run it unasked.
