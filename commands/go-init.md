---
description: Generates this Go project's Claude setup (profile, CLAUDE.md, settings, hooks, Makefile, lint)
allowed-tools: Read, Write, Edit, Bash, Grep, Glob, AskUserQuestion
---

Configure this Go project for Claude Code. Be fast, don't waste context: read only what's needed. Talk to the user in THEIR language; generated files follow the template language.

## 1. Detect
- `go.mod` present? Extract module path and main deps (router? ORM? sqlc? testify?).
- Layout: `cmd/`, `internal/`? `Makefile`? `.golangci.yml`? `CLAUDE.md`? `.claude/settings.json`?
- If CLAUDE.md exists: ask replace or merge (preserve the user's custom rules).

## 2. Ask (AskUserQuestion, 1 round)
Skip questions already answered by detection (e.g. stack obvious from go.mod).
1. **Mode**: `autopilot` (Claude runs the full cycle autonomously) | `copilot` (surgical assistant, proposes before applying)
2. **Dependencies**: `minimal` (stdlib-first, new dep requires approval) | `pragmatic` (curated list allowed)
3. **Stack** (if new/undefined project): `pure stdlib (net/http, database/sql)` | `chi + sqlc + slog` | `gin or echo + gorm` | `not an HTTP service`
4. **Caveman installed?**: yes | no (if yes, integrate; see step 4)

## 3. Generate
Templates at `${CLAUDE_PLUGIN_ROOT}/templates/` (if the var is missing: `find ~/.claude/plugins -type d -name go-claude-kit`).

a. **CLAUDE.md**: compose from `CLAUDE.base.md` — keep the `[[...]]` blocks of the chosen profile, delete the rest and the markers. Fill `{{...}}` with real repo data (architecture in AT MOST 3 lines with file pointers). Result <= 50 lines. Pragmatic stack: fill `{{STACK_CURATED_LIBS}}` (e.g. chi+sqlc: `go-chi/chi/v5, sqlc, pgx/v5, golang-migrate`; gin+gorm: `gin-gonic/gin, gorm.io/gorm, spf13/viper`).
b. **.claude/settings.json**: copy `settings.<mode>.json`.
c. **.claude/hooks/**: copy `hooks/*.sh` + `chmod +x` (go-secret-guard.sh goes in BOTH modes). Copilot mode: skip `go-stop-check.sh` (only autopilot uses the Stop hook).
d. **Makefile** and **.golangci.yml**: copy only if absent.
d2. **.claude/learned.md**: create with `# Learnings (max 15 — managed by /go-learn)` if absent. Target of the CLAUDE.md `@.claude/learned.md` import.
d3. **~/.claude/skills/go-lessons/SKILL.md**: if absent, ask whether to create (global scope for /go-learn technical lessons). Skeleton: frontmatter `name: go-lessons`, `description: This user's Go lessons. Use when writing/reviewing Go.` + empty body.
e. **.mcp.json**: ask only if pragmatic profile + project uses Postgres or many libs; otherwise don't even offer (MCP costs input tokens every turn).
e2. **.github/workflows/ci.yml**: if repo has a GitHub remote and no CI, ask whether to copy `templates/ci.yml` (build + lint + test -race + govulncheck + gitleaks).
e3. Tools: check `gofumpt`, `golangci-lint`, `govulncheck` on PATH; if missing, offer to run `${CLAUDE_PLUGIN_ROOT}/scripts/install-tools.sh`.
f. `.gitignore`: ensure `cover.out` and `.claude/settings.local.json`.

## 4. Caveman (if yes)
- Append to CLAUDE.md: `## Style\n- Caveman replies (concise). Code/commands/errors byte-exact.`
- Suggest running `/caveman-compress CLAUDE.md` AFTER reviewing the file — cuts ~46% of that file's input in every future session.

## 5. Finish
Print terse summary: files created, active profile, and the commands (`/go-plan`, `/go-implement`, `/go-review`, `/go-test`, `/go-audit`, `/go-learn`). Remind: `git add CLAUDE.md .claude/ Makefile .golangci.yml`.
