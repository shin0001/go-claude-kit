---
name: go-style
description: Estilo Go idiomatico (Effective Go + Google Style resumidos). Use ao escrever ou revisar qualquer codigo Go.
---

# go-style

## Idioma e comentarios
- Codigo 100% em ingles — identificadores, mensagens de erro, logs, nomes de teste, comentarios — independente do idioma da conversa.
- Comentario so quando explica um PORQUE nao obvio (workaround, invariante, decisao contra o intuitivo). Nunca narrar o que o codigo ja diz (`// increment counter` = deletar).
- Godoc apenas em API exportada, e so se agrega alem da assinatura. Frase comeca com o nome: `// Order represents...`.
- Legibilidade vem do codigo, nao do comentario: nome que elimina o comentario > comentario. Funcao curta com nome claro > bloco comentado.
- TODO com dono/contexto: `// TODO(user): reason`. Sem codigo comentado morto.

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
- `internal/` por dominio (ex: `internal/order`), nao por camada tecnica (`models`, `services`, `utils`, `common` = proibido).
- Sem `pkg/` novo por default.

## Arquivos dentro do pacote
- Tipo vive junto do comportamento: struct + construtor + metodos no arquivo nomeado pelo conceito (`order.go` tem `Order`). NUNCA `types.go`/`models.go` genericos.
- Pacote pequeno = 1 arquivo, e esta otimo. Nao criar estrutura antecipada.
- Cresceu: dividir por responsabilidade, nao por especie nem tamanho — ex: `order.go` (dominio), `store.go` (persistencia), `http.go` (transport). Nome do arquivo responde "o que tem aqui".
- Excecoes aceitas ao "nao agrupar por especie": `errors.go` (sentinelas do pacote), `doc.go` (godoc do pacote), arquivos gerados (`*_gen.go`, separados e nunca editados a mao).
- Gatilho p/ dividir e coesao (rolar o arquivo procurando coisas nao relacionadas), nao contagem de linhas.
