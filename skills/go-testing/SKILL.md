---
name: go-testing
description: Padroes de teste em Go - table-driven, paralelismo, mocks, integracao. Use ao escrever ou corrigir testes.
---

# go-testing

## Padrao base
- Table-driven com subtests nomeados:
```go
tests := []struct{ name string; in X; want Y; wantErr error }{...}
for _, tt := range tests {
    t.Run(tt.name, func(t *testing.T) { t.Parallel(); ... })
}
```
- `t.Helper()` em toda funcao auxiliar de assert. `t.Cleanup` > defer para teardown.
- Sempre cobrir: caminho feliz, erro esperado, zero-value/vazio, limite.
- `got`/`want` nessa ordem: `got %v, want %v`.

## Regras
- Unit test: sem rede, sem disco, sem sleep. Tempo via injecao (`func() time.Time` ou clock interface).
- Mock = implementacao manual da interface pequena no proprio `_test.go`. Gerador de mock so se politica de deps permitir.
- Determinismo: sem depender de ordem de map; ordenar antes de comparar.
- `t.Parallel()` por default; remover so quando ha estado compartilhado real.
- Integracao: build tag `//go:build integration` + target `make test-integration`. testcontainers so no perfil pragmatic.
- Rodar `-race` em qualquer codigo com goroutine. CI sempre `-race -count=1`.
- Cobertura: alvo pragmatico ~80% em `internal/`; nao perseguir 100% em main/wiring.

## Comparacao
- stdlib: `reflect.DeepEqual` ou comparar campos. `go-cmp`/`testify` so no perfil pragmatic.
- Golden files em `testdata/` para saidas grandes; flag `-update` para regenerar.
