# go-claude-kit

Plugin do Claude Code que gera, por projeto, um setup completo para backend Go: `CLAUDE.md`, agents com roteamento de modelo, skills de boas práticas, hooks de qualidade e um fluxo `plan → implement → review → test` — tudo calibrado por perfil (autopilot vs copiloto, minimal vs pragmatic) e otimizado para gastar o mínimo de tokens/limite de uso.

## Idioma

Tudo que **entra em contexto** (skills, agents, comandos, template do CLAUDE.md, mensagens de erro dos hooks) está em **inglês**: tokeniza 20–35% mais barato e melhora a aderência dos agents em Haiku. Tudo que **só humano lê** (este README) fica em português. Isso não muda a conversa: o Claude responde no idioma do chat — a primeira regra do CLAUDE.md gerado ancora exatamente isso ("chat no idioma do usuário; código em inglês").

## Instalação

Publique este repositório no seu GitHub (ex: `shin0001/go-claude-kit`) e:

```bash
claude plugin marketplace add shin0001/go-claude-kit
claude plugin install go-claude-kit@go-claude-kit
```

Alternativa sem plugin: copie `commands/`, `agents/` e `skills/` para `~/.claude/` (uso pessoal em todos os projetos) ou `.claude/` do projeto.

Recomendado no ambiente: `gofumpt`, `goimports`, `golangci-lint`, `jq`.

Caveman (opcional, ver seção abaixo):

```bash
claude plugin marketplace add JuliusBrussee/caveman
claude plugin install caveman@caveman
```

## Uso

Em qualquer projeto Go (novo ou existente):

```
/go-init
```

O Claude detecta o que já existe (go.mod, layout, Makefile), faz 3–4 perguntas e gera:

| Arquivo | O quê |
|---|---|
| `CLAUDE.md` | ≤50 linhas, composto do perfil escolhido |
| `.claude/settings.json` | permissões + hooks do modo |
| `.claude/hooks/*.sh` | gofumpt/goimports/vet + secret-guard pós-edição; build-check no Stop (só autopilot) |
| `.claude/learned.md` | aprendizados do projeto (importado pelo CLAUDE.md, cap 15 linhas) |
| `Makefile`, `.golangci.yml` | só se não existirem |
| `.mcp.json` | só se fizer sentido (raramente) |

Depois, o ciclo de trabalho:

```
/go-plan adicionar rate limiting no gateway   # plano terso em docs/plans/
/go-implement                                  # executa conforme o modo
/go-review                                     # achados em 1 linha cada
/go-test -race                                 # roda e tria no Haiku
/go-audit                                      # govulncheck + gosec + gitleaks + revisão
/go-deps github.com/redis/go-redis/v9          # gate de dependência
/go-learn "sqlc: sempre regenerar após migration"  # persiste lição no escopo certo
```

## Perfis

Dois eixos independentes, escolhidos no `/go-init` — é isso que torna o kit reutilizável entre projetos diferentes:

**Automação**
- `autopilot` — Claude encadeia plan→implement→review→test sozinho, edita com `acceptEdits`, delega a subagents, tem Stop hook que bloqueia encerrar com build quebrado. `git push` sempre proibido.
- `copilot` — assistente cirúrgico: mudanças pequenas, mostra diff antes de aplicar em >1 arquivo, não cria arquivos sem confirmar, respostas curtas.

**Dependências**
- `minimal` — stdlib-first; dependência nova exige sua aprovação com justificativa; `golang.org/x/*` liberado.
- `pragmatic` — lista curada liberada (preenchida conforme o stack: chi+sqlc+pgx, ou gin/echo+gorm, etc.); fora da lista, gate de 3 linhas.

## Agents e roteamento de modelo

A maior alavanca de economia está aqui — cada agent roda no modelo mais barato que dá conta:

| Agent | Modelo | Papel | Acesso |
|---|---|---|---|
| `go-explorer` | **haiku** | achar código, responder "onde/como" | read-only |
| `go-planner` | inherit | plano de implementação terso | read-only + bash |
| `go-implementer` | **sonnet** | escrever código do plano | completo |
| `go-reviewer` | **sonnet** | review formato `arquivo:linha [SEV] → fix` | read-only |
| `go-tester` | **haiku** | rodar suite, triar falhas | bash + read |
| `go-auditor` | **sonnet** | auditoria de segurança (tools + manual) | read-only + bash |

Subagents também protegem o contexto da sessão principal: a saída de um `go test ./...` gigante morre no contexto do tester; só o diagnóstico de 3 linhas volta.

## Skills

Carregadas sob demanda (não pesam quando não usadas): `go-style` (Effective Go + Google Style destilados), `go-testing` (table-driven, paralelismo, mocks), `go-concurrency` (goroutines, channels, ctx, errgroup), `go-security` (input, SQL, crypto, segredos, hardening, supply chain), `go-review-checklist` (severidades BLOCKER/WARN/NIT). Regras transversais embutidas no template e nos agents: código sempre em inglês (independente do idioma do chat), comentários apenas para "porquês" não óbvios, e organização de arquivos por responsabilidade — tipo junto do comportamento, sem `types.go` genérico.

## Segurança

Três camadas, do zero-token ao sob-demanda:

1. **Hooks (custo zero de token)** — `go-secret-guard.sh` roda após toda edição e bloqueia (exit 2) padrões de segredo (chave privada, AWS/GitHub/API keys, `password = "..."`), devolvendo o erro para o Claude corrigir na hora. Fixtures dummy: marque a linha com `// gcksafe`. `testdata/` é ignorado.
2. **Ferramentas via `make`** — `make vuln` (govulncheck: só vulns *alcançáveis* no call graph) e `make audit` (lint com gosec + vuln + gitleaks). O autopilot roda govulncheck automaticamente quando `go.mod` muda.
3. **`/go-audit`** — o agent `go-auditor` combina as ferramentas com revisão manual guiada pela skill `go-security` (math/rand em token, SQL concatenado, server sem timeout, InsecureSkipVerify…). Saída: `arquivo:linha [CRIT|HIGH|MED|LOW] problema → fix`.

Os `settings.json` também ganharam `deny` para `*.pem`, `id_rsa*`, `*.key` — o Claude nem consegue ler material de chave por engano.

## Autoaprimoramento

O comando `/go-learn` captura lições (de um argumento seu ou extraídas da conversa quando você corrigiu algo) e as persiste no escopo certo:

| Escopo | Destino | Custo de contexto | Cap |
|---|---|---|---|
| projeto | `.claude/learned.md` (importado via `@` no CLAUDE.md) | todo turno, neste projeto | 15 linhas |
| global sempre-ativo | `~/.claude/CLAUDE.md` § `## Go — aprendizados` | todo turno, todo projeto | 10 linhas |
| global técnico | skill `~/.claude/skills/go-lessons/` | só quando relevante | 30 linhas |
| plugin | patch no seu clone do go-claude-kit | zero (vira versão nova) | — |

O desenho é anti-inflação por construção: caps invioláveis, dedupe/merge obrigatório antes de inserir, e estourou o cap → funde ou remove (você decide). Preferência pessoal nunca sobe ao plugin; detalhe de um codebase nunca vira global. O gatilho é distribuído: o CLAUDE.md gerado instrui o Claude a *sugerir* `/go-learn` quando você corrigir a mesma coisa duas vezes, e o autopilot faz uma retro de 1 linha ao final de cada `/go-implement`. Nada é gravado sem sua confirmação — a promoção ao plugin gera um diff no seu clone local (nunca edita `~/.claude/plugins/` direto, que seria sobrescrito no update).

## Economia de tokens no plano Pro/Max

No seu caso o custo real é o **limite de uso**, não dólares. O que este kit já faz e o que fica com você:

1. **Haiku/Sonnet nos subagents** — trabalho pesado de volume (explorar, testar) roda barato; o modelo caro fica para planejar e decidir.
2. **CLAUDE.md ≤50 linhas** — ele entra em *todo* prompt da sessão. Cada linha inútil é cobrada centenas de vezes.
3. **Quase zero MCP** — cada MCP ativo injeta as definições de tools em todo turno. Prefira CLIs via Bash: `gh` em vez de GitHub MCP, `psql` em vez de Postgres MCP. O `templates/mcp.json` existe, mas é opt-in.
4. **Tools restritos por agent** — reviewer não carrega Write/Edit; menos definição de tool, menos superfície de erro.
5. **Hooks em shell, não em prompt** — formatar e vetar código via script custa zero tokens; pedir isso ao modelo custa em todo turno.
6. **Saídas tersas por contrato** — todos os agents têm formato de saída fixo e curto.
7. **Hábitos**: `/clear` entre tarefas não relacionadas; `/compact` quando o contexto encher; plan mode (`shift+tab`) antes de tarefas grandes — implementar na direção errada é o maior desperdício de limite que existe.

## Caveman

[Caveman](https://github.com/JuliusBrussee/caveman) comprime o *estilo* das respostas (~65% menos tokens de saída) mantendo código/comandos byte-exatos — e responde no seu idioma (português entra, caveman-português sai).

Números honestos, do próprio projeto: ele só reduz **output**; adiciona ~1–1,5k tokens de *input* por turno; em cargas já concisas pode ficar negativo. Por isso a integração aqui é calibrada:

- **Copilot / sessões conversacionais** → vale muito (é onde o modelo mais "fala").
- **Autopilot** → ganho menor (a saída já é majoritariamente código e os agents já são tersos), mas inofensivo.
- **`/caveman-compress CLAUDE.md`** → o melhor uso: comprime o arquivo de memória ~46% e economiza **input em toda sessão futura**. O `/go-init` sugere isso ao final.

## Estrutura

```
go-claude-kit/
├── .claude-plugin/{plugin,marketplace}.json
├── commands/    go-init, go-plan, go-implement, go-review, go-test,
│                go-audit, go-deps, go-learn, go-ship, go-handoff, go-bench
├── agents/      go-explorer, go-planner, go-implementer, go-reviewer,
│                go-tester, go-auditor
├── skills/      go-style, go-testing, go-concurrency, go-security,
│                go-review-checklist
├── scripts/     install-tools.sh
└── templates/   CLAUDE.base.md, settings.{autopilot,copilot}.json,
                 hooks/, Makefile, .golangci.yml, ci.yml, mcp.json
```

## Extras

- **CI (`templates/ci.yml`)** — GitHub Actions com build, golangci-lint, `test -race`, govulncheck e gitleaks. O `/go-init` oferece copiar. É a rede de segurança *fora* do Claude: garante as mesmas regras quando alguém commita sem ele.
- **`/go-ship`** — agrupa mudanças em commits atômicos convencionais (≤50 chars), roda pré-voo (build + testes dos pacotes tocados) e imprime o comando de push + `gh pr create` pronto para colar. O push continua negado no settings de propósito — o último clique é sempre seu.
- **`/go-handoff`** — o hábito que mais economiza limite no Pro/Max: antes de `/clear`, salva estado em `docs/handoff.md` (≤30 linhas: feito, próximo passo, arquivos quentes, armadilhas). Retomar lendo 30 linhas é ordens de magnitude mais barato que arrastar uma sessão inchada.
- **`/go-bench`** — benchmarks com `-count=6` + comparação estatística via `benchstat` contra baseline; só reporta deltas significativos (nada de comemorar ruído). Sugere pprof em regressão.
- **`scripts/install-tools.sh`** — instala gofumpt, goimports, govulncheck, gosec e benchstat de uma vez (golangci-lint e gitleaks via binário oficial).

Três hábitos que não são arquivos:

1. **Worktrees para paralelismo** — `git worktree add ../proj-feat feat` e uma sessão do Claude por worktree: duas tarefas simultâneas sem brigarem pelo mesmo estado de arquivos.
2. **Overrides locais** — preferências suas que não devem ir ao repo do time: `.claude/settings.local.json` e `CLAUDE.local.md` (ambos já no .gitignore gerado).
3. **Versione o plugin** — quando `/go-learn` promover algo ao kit, bump em `plugin.json` e commit no repo do plugin; os projetos recebem no próximo update, e o histórico do git vira o changelog do seu "processo".

## Personalização

- Novo perfil (ex: "prototipagem"): adicione blocos `[[MODO_X]]` no `CLAUDE.base.md` + um `settings.X.json`, e uma opção na pergunta 1 do `commands/go-init.md`.
- Stack novo: acrescente a opção na pergunta 3 do `go-init` e a lista curada correspondente.
- Regras de time: edite as skills — elas valem para todos os projetos que usam o plugin; regras de *um* projeto vão no CLAUDE.md dele.
