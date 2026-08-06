---
description: Gera o setup Claude deste projeto Go (perfil, CLAUDE.md, settings, hooks, Makefile, lint)
allowed-tools: Read, Write, Edit, Bash, Grep, Glob, AskUserQuestion
---

Voce vai configurar este projeto Go para trabalhar com Claude Code. Seja rapido e nao gaste contexto: leia apenas o necessario.

## 1. Detectar
- `go.mod` existe? Extrair module path e deps principais (router? ORM? sqlc? testify?).
- Layout: existe `cmd/`, `internal/`? `Makefile`? `.golangci.yml`? `CLAUDE.md`? `.claude/settings.json`?
- Se CLAUDE.md ja existe: perguntar se substitui ou faz merge (preservar regras custom do usuario).

## 2. Perguntar (AskUserQuestion, 1 rodada)
Pular perguntas ja respondidas pela deteccao (ex: stack obvio no go.mod).
1. **Modo**: `autopilot` (Claude executa o ciclo completo com autonomia) | `copilot` (assistente cirurgico, propoe antes de aplicar)
2. **Dependencias**: `minimal` (stdlib-first, dep nova exige aprovacao) | `pragmatic` (lista curada liberada)
3. **Stack** (se projeto novo/indefinido): `stdlib puro (net/http, database/sql)` | `chi + sqlc + slog` | `gin ou echo + gorm` | `nao e servico HTTP`
4. **Caveman instalado?**: sim | nao (se sim, integrar; ver passo 4)

## 3. Gerar
Templates em `${CLAUDE_PLUGIN_ROOT}/templates/` (se a var nao existir no seu ambiente: `find ~/.claude/plugins -type d -name go-claude-kit`).

a. **CLAUDE.md**: compor de `CLAUDE.base.md` — manter blocos `[[...]]` do perfil escolhido, deletar os demais e as marcacoes. Preencher `{{...}}` com dados reais do repo (arquitetura em NO MAXIMO 3 linhas com ponteiros de arquivo). Resultado <= 50 linhas. Stack pragmatic: preencher `{{LISTA_LIBS_DO_STACK}}` (ex. chi+sqlc: `go-chi/chi/v5, sqlc, pgx/v5, golang-migrate`; gin+gorm: `gin-gonic/gin, gorm.io/gorm, spf13/viper`).
b. **.claude/settings.json**: copiar `settings.<modo>.json`.
c. **.claude/hooks/**: copiar `hooks/*.sh` + `chmod +x` (go-secret-guard.sh vai nos DOIS modos). Modo copilot: nao copiar `go-stop-check.sh` (so autopilot usa Stop hook).
d. **Makefile** e **.golangci.yml**: copiar apenas se nao existirem.
d2. **.claude/learned.md**: criar com `# Aprendizados (max 15 — /go-learn gerencia)` se nao existir. E o alvo do import `@.claude/learned.md` do CLAUDE.md.
d3. **~/.claude/skills/go-lessons/SKILL.md**: se nao existir, perguntar se cria (escopo global de licoes tecnicas do /go-learn). Skeleton: frontmatter `name: go-lessons`, `description: Licoes de Go deste usuario. Use ao escrever/revisar Go.` + corpo vazio.
e. **.mcp.json**: perguntar so se perfil pragmatic + projeto usa Postgres ou muitas libs; caso contrario, nem oferecer (MCP custa input token todo turno).
e2. **.github/workflows/ci.yml**: se o repo tem remote GitHub e nao ha CI, perguntar se copia `templates/ci.yml` (build + lint + test -race + govulncheck + gitleaks).
e3. Ferramentas: checar `gofumpt`, `golangci-lint`, `govulncheck` no PATH; faltando alguma, oferecer rodar `${CLAUDE_PLUGIN_ROOT}/scripts/install-tools.sh`.
f. `.gitignore`: garantir `cover.out` e `.claude/settings.local.json`.

## 4. Caveman (se sim)
- Adicionar ao final do CLAUDE.md: `## Estilo\n- Respostas em caveman (conciso). Codigo/comandos/erros byte-exatos.`
- Sugerir ao usuario rodar `/caveman-compress CLAUDE.md` DEPOIS de revisar o arquivo — corta ~46% do input desse arquivo em toda sessao futura.

## 5. Finalizar
Imprimir resumo terso: arquivos criados, perfil ativo, e os comandos (`/go-plan`, `/go-implement`, `/go-review`, `/go-test`, `/go-audit`, `/go-learn`). Lembrar: `git add CLAUDE.md .claude/ Makefile .golangci.yml`.
