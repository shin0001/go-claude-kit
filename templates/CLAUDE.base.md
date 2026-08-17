<!-- Template composto pelo /go-init. Blocos entre [[...]] sao escolhidos conforme o perfil; o resto e fixo. Meta: CLAUDE.md final <= 50 linhas. -->

# {{PROJETO}}

{{DESCRICAO_1_LINHA}}

## Comandos
- `make build` / `make test` / `make lint` / `make cover`
- Teste de 1 pacote: `go test ./internal/x/... -run TestNome -v`
- {{COMANDOS_EXTRAS}}

## Arquitetura
{{MAPA_3_LINHAS_MAX_COM_PONTEIROS_DE_ARQUIVO}}

## Regras
- Codigo sempre em INGLES (identificadores, erros, logs, comentarios), mesmo com chat em outro idioma. Comentario so p/ 'porque' nao obvio; legibilidade vem de nomes e funcoes curtas.
- Arquivos: tipo junto do comportamento (`order.go` tem `Order` + metodos). Sem `types.go`/`models.go`. Dividir por responsabilidade quando a coesao pedir.
- Erros: wrap com `%w` + contexto da operacao. Sem panic fora de main.
- `context.Context` 1o arg em I/O. Toda goroutine tem dono e saida.
- Testes table-driven; unit sem rede/disco/sleep. `-race` em codigo concorrente.
- Segredos nunca no codigo (hook bloqueia). Codigo exposto a input externo: skill go-security. go.mod mudou => `make vuln`.
- Nao refatorar codigo nao relacionado a tarefa.
- Se o usuario corrigir a mesma coisa 2x: sugerir `/go-learn` (1 linha, nao insistir).
- Detalhes: skills go-style, go-testing, go-concurrency, go-security (carregar sob demanda).

[[MODO_AUTOPILOT]]
## Modo: autopilot
- Fluxo padrao: /go-plan -> /go-implement -> /go-review -> /go-test. Encadear sem pedir permissao entre etapas.
- Delegar exploracao ao agent go-explorer; testes ao go-tester (nao rodar suites longas na sessao principal).
- Pode editar, buildar e testar direto. NUNCA: git push, alterar migrations aplicadas, tocar .env.
- Ao terminar: diff resumido + resultado dos testes. Sem narrar passo a passo.
[[/MODO_AUTOPILOT]]

[[MODO_COPILOT]]
## Modo: copiloto
- Mudancas pequenas e cirurgicas. Propor diff ANTES de aplicar quando tocar >1 arquivo.
- Nunca criar arquivos/pacotes novos sem confirmar. Nao rodar comandos alem de build/test do pacote tocado.
- Perguntar quando o requisito for ambiguo; nao assumir.
- Respostas curtas: codigo + 1-2 frases. Sem tutorial.
[[/MODO_COPILOT]]

[[DEPS_MINIMAL]]
## Dependencias: minimalista
- stdlib primeiro, sempre. Nova dependencia = proibida sem aprovacao explicita minha.
- Permitidas sem perguntar: `golang.org/x/*`.
- Se stdlib nao resolve, PARE e proponha: problema, opcao stdlib descartada e por que, lib sugerida.
[[/DEPS_MINIMAL]]

[[DEPS_PRAGMATIC]]
## Dependencias: pragmatica
- Curadas (usar sem perguntar): {{LISTA_LIBS_DO_STACK}}, `golang.org/x/*`, `google/go-cmp`.
- Fora da lista: propor com 1 linha de justificativa antes de adicionar.
- Sempre `go mod tidy` apos mudar deps; verificar licenca e manutencao ativa.
[[/DEPS_PRAGMATIC]]

[[STACK]]
## Stack
{{STACK_LINHAS}}
[[/STACK]]

## Aprendizados deste projeto
@.claude/learned.md
