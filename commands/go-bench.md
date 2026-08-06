---
description: Roda benchmarks e compara com baseline via benchstat
argument-hint: [pacote] [nome do bench]
---

Delegar ao agent **go-tester**:
1. `go test -bench='${2:-.}' -benchmem -count=6 -run='^$' ./${1:-...} | tee /tmp/bench.new`
2. Existe `/tmp/bench.old` ou `docs/bench-baseline.txt`? => `benchstat <baseline> /tmp/bench.new` (instalar: `go install golang.org/x/perf/cmd/benchstat@latest`). Senao: salvar novo como baseline e avisar.
3. Reportar SO deltas significativos (p<0.05): `Bench: -12% tempo, +0% alloc`. Ruido => dizer "sem mudanca significativa" e parar.
4. Regressao relevante: sugerir profile — `go test -bench=X -cpuprofile=cpu.out ./pkg && go tool pprof -top cpu.out` — mas nao rodar sem pedir.
