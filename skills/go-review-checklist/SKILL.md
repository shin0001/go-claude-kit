---
name: go-review-checklist
description: Checklist completo de code review Go usado pelo agent go-reviewer e pelo comando /go-review.
---

# go-review-checklist

Ordem de severidade. Reportar formato: `arquivo:linha [SEV] problema -> fix`.

## BLOCKER
- Erro ignorado (`_ = f()` sem justificativa) ou engolido em branch.
- Data race, goroutine leak, channel deadlock potencial.
- Recurso sem fechar: Body, Rows, arquivo, tx sem Rollback no defer.
- SQL por concatenacao; segredo/credencial no codigo; input externo sem validacao.
- Client HTTP/DB sem timeout.
- Quebra de compatibilidade de API exportada sem versionamento.

## WARN
- Erro sem `%w` quando caller pode precisar de `errors.Is/As`.
- Interface grande (>3 metodos) ou definida no produtor sem necessidade.
- Teste ausente para caminho de erro novo; teste com sleep/rede real.
- Codigo morto, export desnecessario, dependencia nova nao justificada.
- Complexidade: funcao >50 linhas fazendo 3 coisas; aninhamento >3 niveis.
- Log + return do mesmo erro (duplicacao).

## WARN (adicional)
- Identificador/erro/log fora do ingles. Comentario narrando o obvio (pedir remocao). `types.go`/`models.go` generico em codigo novo.

## NIT
- Nome com stutter, else apos return, ordem de imports.
- Mensagem de erro capitalizada ou com pontuacao final.

## Nao comentar
- Estilo que gofumpt/golangci-lint ja pega. Preferencia pessoal sem impacto.
