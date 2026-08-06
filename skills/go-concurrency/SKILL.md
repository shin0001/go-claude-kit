---
name: go-concurrency
description: Concorrencia segura em Go - goroutines, channels, context, errgroup. Use ao escrever/revisar codigo concorrente.
---

# go-concurrency

## Regras de ouro
- Toda goroutine precisa de: (1) dono que espera ela acabar, (2) caminho de saida via ctx/close. Sem fire-and-forget.
- Quem cria o channel fecha o channel. Receiver nunca fecha.
- Nao comunicar compartilhando memoria; compartilhar comunicando. Mas: contador/cache simples = mutex, nao channel.
- `go vet` + `-race` sempre. Race detectada = bug real, nunca "flaky".

## Padroes
- Fan-out com limite e erro agregado: `golang.org/x/sync/errgroup` + `g.SetLimit(n)`.
- Cancelamento: propagar ctx; checar `ctx.Err()` em loops longos; `select { case <-ctx.Done(): return ctx.Err() ... }`.
- Timeout por operacao: `context.WithTimeout` no caller, nao dentro da funcao.
- Worker pool so com carga real; antes disso, errgroup resolve.
- `sync.Once` p/ init lazy; `sync.WaitGroup` quando nao ha erro a propagar.

## Armadilhas
- Capturar variavel de loop em goroutine (ok >= go1.22, mas seja explicito).
- `time.Tick` vaza; usar `time.NewTicker` + `defer Stop()`.
- Mutex copiado por valor (embed `*sync.Mutex` ou receiver ponteiro).
- Channel sem buffer em publish sem receiver garantido = deadlock.
- HTTP handler que dispara goroutine usando `r.Context()` apos retorno.
