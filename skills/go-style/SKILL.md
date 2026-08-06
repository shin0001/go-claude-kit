---
name: go-style
description: Estilo Go idiomatico (Effective Go + Google Style resumidos). Use ao escrever ou revisar qualquer codigo Go.
---

# go-style

## Erros
- Envolver com contexto da operacao: `fmt.Errorf("open config: %w", err)`. Sem "failed to" repetido em cada nivel.
- Sentinelas: `var ErrNotFound = errors.New(...)`; checar com `errors.Is/As`, nunca comparar string.
- Tipos de erro custom so quando o caller precisa de dados estruturados.
- panic: apenas main/init ou bug impossivel. Lib nunca panica.
- Nao logar E retornar o mesmo erro (log duplicado). Logue na borda (handler), retorne no meio.

## API e tipos
- Aceite interfaces, retorne structs. Interface definida no pacote consumidor, nao no produtor.
- Interfaces pequenas (1-3 metodos). `io.Reader` > `*os.File` em assinaturas.
- Zero-value util: `var b bytes.Buffer` funciona; construtor `NewX` so quando ha invariantes.
- `context.Context` primeiro parametro de tudo que faz I/O. Nunca guardar ctx em struct.
- Exportar o minimo. `internal/` para tudo que nao e API publica.

## Codigo
- Early return; happy path sem indentacao. Sem `else` apos return.
- Nomes curtos em escopo curto (`i`, `r`, `srv`); descritivos em escopo longo. Sem stutter: `user.New`, nao `user.NewUser`.
- Receiver: ponteiro se muta ou struct grande; consistente no tipo todo.
- Sem naked returns. Sem `init()` com logica. Sem variavel global mutavel.
- slog para logs estruturados (stdlib >= 1.21). Nao fmt.Println em servidor.

## Layout
- `cmd/<bin>/main.go` fino: parse config, monta deps, chama `run(ctx) error`.
- `internal/` por dominio (ex: `internal/order`), nao por camada tecnica generica.
- Sem `pkg/` novo por default. Sem package `utils`/`common`/`helpers`.
