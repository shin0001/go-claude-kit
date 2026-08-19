# go-claude-kit

A Claude Code plugin that generates, per project, a complete setup for Go backend work: `CLAUDE.md`, model-routed agents, best-practice skills, quality/security hooks, and a `plan → implement → review → test` workflow — all calibrated by profile (autopilot vs copilot, minimal vs pragmatic deps) and optimized to spend the least tokens/usage limit possible.

Everything the model reads is written in English (20–35% cheaper to tokenize, better adherence on Haiku agents). The conversation stays in whatever language you use — the first rule of every generated CLAUDE.md anchors exactly that ("chat replies: user's language; code: always English").

## Installation

```bash
claude plugin marketplace add shin0001/go-claude-kit
claude plugin install go-claude-kit@go-claude-kit
```

No-plugin alternative: copy `commands/`, `agents/` and `skills/` into `~/.claude/` (personal, all projects) or a project's `.claude/`.

Recommended tooling: `gofumpt`, `goimports`, `golangci-lint`, `jq` — or run `scripts/install-tools.sh`.

Caveman (optional, see section below):

```bash
claude plugin marketplace add JuliusBrussee/caveman
claude plugin install caveman@caveman
```

## Usage

In any Go project (new or existing):

```
/go-init
```

Claude detects what already exists (go.mod, layout, Makefile), asks 3–4 questions and generates:

| File | What |
|---|---|
| `CLAUDE.md` | ≤50 lines, composed from the chosen profile |
| `.claude/settings.json` | mode-specific permissions + hooks |
| `.claude/hooks/*.sh` | gofumpt/goimports/vet + secret-guard after every edit; build check on Stop (autopilot only) |
| `.claude/learned.md` | project learnings (imported by CLAUDE.md, 15-line cap) |
| `Makefile`, `.golangci.yml` | only if absent |
| `.mcp.json` | only when it makes sense (rarely) |

Then the working cycle:

```
/go-plan add rate limiting to the gateway     # terse plan in docs/plans/
/go-implement                                  # executes according to the mode
/go-review                                     # one-line findings
/go-test -race                                 # runs and triages on Haiku
/go-audit                                      # govulncheck + gosec + gitleaks + review
/go-deps github.com/redis/go-redis/v9          # dependency gate
/go-learn "sqlc: always regenerate after migrations"  # persists a lesson in the right scope
```

## Profiles

Two independent axes, chosen in `/go-init` — this is what makes the kit reusable across very different projects:

**Automation**
- `autopilot` — Claude chains plan→implement→review→test on its own, edits with `acceptEdits`, delegates to subagents, and a Stop hook blocks ending the turn with a broken build. `git push` is always denied.
- `copilot` — surgical assistant: small changes, shows the diff before applying to >1 file, never creates files without confirming, short answers.

**Dependencies**
- `minimal` — stdlib-first; any new dependency requires your approval with justification; `golang.org/x/*` allowed.
- `pragmatic` — curated list allowed without asking (filled per stack: chi+sqlc+pgx, or gin/echo+gorm, etc.); off-list goes through a 3-line gate.

## Agents and model routing

The biggest savings lever lives here — each agent runs on the cheapest model that can do the job:

| Agent | Model | Role | Access |
|---|---|---|---|
| `go-explorer` | **haiku** | find code, answer "where/how" | read-only |
| `go-planner` | inherit | terse implementation plan | read-only + bash |
| `go-implementer` | **sonnet** | write the plan's code | full |
| `go-reviewer` | **sonnet** | review as `file:line [SEV] → fix` | read-only |
| `go-tester` | **haiku** | run suite, triage failures | bash + read |
| `go-auditor` | **sonnet** | security audit (tools + manual) | read-only + bash |

Subagents also protect the main session's context: the output of a giant `go test ./...` dies inside the tester's context; only a 3-line diagnosis comes back.

## Skills

Loaded on demand (they cost nothing when unused): `go-style` (Effective Go + Google Style distilled), `go-testing` (table-driven, parallelism, mocks), `go-concurrency` (goroutines, channels, ctx, errgroup), `go-security` (input, SQL, crypto, secrets, hardening, supply chain), `go-review-checklist` (BLOCKER/WARN/NIT severities). Cross-cutting rules are baked into the template and agents: code always in English (regardless of chat language), comments only for non-obvious "whys", and file organization by responsibility — types live with their behavior, no generic `types.go`.

## Security

Three layers, from zero-token to on-demand:

1. **Hooks (zero token cost)** — `go-secret-guard.sh` runs after every edit and blocks (exit 2) secret patterns (private keys, AWS/GitHub/API keys, `password = "..."`), returning the error for Claude to fix on the spot. Dummy fixtures: mark the line with `// gcksafe`. `testdata/` is ignored.
2. **Tools via `make`** — `make vuln` (govulncheck: only vulns *reachable* in the call graph) and `make audit` (lint with gosec + vuln + gitleaks). Autopilot runs govulncheck automatically whenever `go.mod` changes.
3. **`/go-audit`** — the `go-auditor` agent combines the tools with a manual review guided by the `go-security` skill (math/rand near tokens, concatenated SQL, servers without timeouts, InsecureSkipVerify…). Output: `file:line [CRIT|HIGH|MED|LOW] problem → fix`.

The `settings.json` files also `deny` reads of `*.pem`, `id_rsa*` and `*.key` — Claude can't even read key material by accident.

## Self-improvement

The `/go-learn` command captures lessons (from an argument you give, or extracted from the conversation when you corrected something) and persists them in the right scope:

| Scope | Destination | Context cost | Cap |
|---|---|---|---|
| project | `.claude/learned.md` (imported via `@` in CLAUDE.md) | every turn, this project | 15 lines |
| global always-on | `~/.claude/CLAUDE.md` § `## Go — learnings` | every turn, every project | 10 lines |
| global technical | `~/.claude/skills/go-lessons/` skill | only when relevant | 30 lines |
| plugin | patch in your clone of shin0001/go-claude-kit | zero (ships as a new version) | — |

The design is anti-inflation by construction: inviolable caps, mandatory dedupe/merge before inserting, and cap overflow → merge or remove (you decide). Personal preferences never get promoted to the plugin; single-codebase details never go global. Triggers are distributed: the generated CLAUDE.md tells Claude to *suggest* `/go-learn` when you correct the same thing twice, and autopilot ends every `/go-implement` with a 1-line retro. Nothing is written without your confirmation — plugin promotion produces a diff in your local clone (it never edits `~/.claude/plugins/` directly, which updates would overwrite).

## Token economy on Pro/Max plans

On subscription, the real cost is the **usage limit**, not dollars. What the kit already does, and what stays with you:

1. **Haiku/Sonnet on subagents** — high-volume grunt work (exploring, testing) runs cheap; the expensive model plans and decides.
2. **CLAUDE.md ≤50 lines** — it enters *every* prompt of the session. Every useless line is billed hundreds of times.
3. **Near-zero MCP** — every active MCP injects its tool definitions into every turn. Prefer CLIs via Bash: `gh` instead of the GitHub MCP, `psql` instead of the Postgres MCP. `templates/mcp.json` exists, but it's opt-in.
4. **Restricted tools per agent** — the reviewer doesn't carry Write/Edit; fewer tool definitions, smaller error surface.
5. **Hooks in shell, not in prompt** — formatting and vetting via script costs zero tokens; asking the model to do it costs on every turn.
6. **Terse outputs by contract** — every agent has a fixed, short output format.
7. **Habits**: `/clear` between unrelated tasks; `/compact` when context fills up; plan mode (`shift+tab`) before big tasks — implementing in the wrong direction is the biggest limit-burner there is.

## Caveman

[Caveman](https://github.com/JuliusBrussee/caveman) compresses the *style* of replies (~65% fewer output tokens) while keeping code/commands byte-exact — and it answers in your language (Portuguese in, caveman-Portuguese out).

Honest numbers, from the project itself: it only reduces **output**; it adds ~1–1.5k *input* tokens per turn; on already-terse workloads it can go net-negative. That's why the integration here is calibrated:

- **Copilot / conversational sessions** → big win (where the model "talks" the most).
- **Autopilot** → smaller gain (output is mostly code and the agents are already terse), but harmless.
- **`/caveman-compress CLAUDE.md`** → the best use: compresses the memory file ~46% and saves **input in every future session**. `/go-init` suggests it at the end. It compounds with the English tokenization discount on the same always-loaded file.

## Structure

```
go-claude-kit/
├── .claude-plugin/{plugin,marketplace}.json
├── .github/workflows/validate.yml   (CI of the kit itself)
├── commands/    go-init, go-plan, go-implement, go-review, go-test,
│                go-audit, go-deps, go-learn, go-ship, go-handoff, go-bench,
│                go-debug, go-upgrade
├── agents/      go-explorer, go-planner, go-implementer, go-reviewer,
│                go-tester, go-auditor
├── skills/      go-style, go-testing, go-concurrency, go-security,
│                go-review-checklist
├── scripts/     install-tools.sh, validate-kit.sh
└── templates/   CLAUDE.base.md, settings.{autopilot,copilot}.json,
                 hooks/, Makefile, .golangci.yml, ci.yml, dependabot.yml, mcp.json
```

## Extras

- **CI (`templates/ci.yml`)** — GitHub Actions with build, golangci-lint, `test -race`, govulncheck and gitleaks. `/go-init` offers to copy it. It's the safety net *outside* Claude: the same rules hold when someone commits without it.
- **`/go-ship`** — groups changes into atomic conventional commits (≤50 chars), runs a preflight (build + tests of touched packages), and prints the push + `gh pr create` command ready to paste. Push stays denied in settings on purpose — the last click is always yours.
- **`/go-handoff`** — the single best limit-saving habit on Pro/Max: before `/clear`, it saves state to `docs/handoff.md` (≤30 lines: done, next step, hot files, pitfalls). Resuming from 30 lines is orders of magnitude cheaper than dragging a bloated session.
- **`/go-bench`** — benchmarks with `-count=6` + statistical comparison via `benchstat` against a baseline; reports only significant deltas (no celebrating noise). Suggests pprof on regressions.
- **`scripts/install-tools.sh`** — installs gofumpt, goimports, govulncheck, gosec and benchstat in one go (golangci-lint and gitleaks via official binaries).
- **`/go-upgrade`** — syncs a project's generated files (settings, hooks, Makefile, lint, CI) with the current kit templates. Diff-classifies each file: identical → skip, template-only drift → replace, locally customized → 3-way merge that never deletes a line it can't attribute to an old template. CLAUDE.md is never overwritten — new rule lines are proposed one by one.
- **`/go-debug`** — systematic bug fixing with one hard discipline: no fix before a red test. Reproduce → isolate (go-explorer, `git log -S`, optional bisect) → minimal fix → `-race` verify; the repro test stays as a regression test.
- **Kit self-validation (`scripts/validate-kit.sh` + `.github/workflows/validate.yml`)** — the kit repo now checks itself: JSON validity, shell syntax + shellcheck, required frontmatter in every agent/skill/command, hook references, and token-budget guards (CLAUDE.base ≤90 lines, skills ≤70). Since `/go-learn` promotes lessons by editing this repo, the CI is what keeps self-improvement from silently breaking the kit.
- **`templates/dependabot.yml`** — weekly grouped gomod + actions updates. Closes the supply-chain loop: govulncheck detects, Dependabot remediates. `/go-init` offers it alongside CI.

Three habits that aren't files:

1. **Worktrees for parallelism** — `git worktree add ../proj-feat feat` and one Claude session per worktree: two simultaneous tasks without fighting over file state.
2. **Local overrides** — personal preferences that shouldn't reach the team repo: `.claude/settings.local.json` and `CLAUDE.local.md` (both already in the generated .gitignore).
3. **Version the plugin** — when `/go-learn` promotes something to the kit, bump `plugin.json` and commit to shin0001/go-claude-kit; projects pick it up on the next update, and the git history becomes the changelog of your *process*.

## Customization

- New profile (e.g. "prototyping"): add `[[MODE_X]]` blocks to `CLAUDE.base.md` + a `settings.X.json`, and an option to question 1 of `commands/go-init.md`.
- New stack: add the option to question 3 of `go-init` and the matching curated list.
- Team rules: edit the skills — they apply to every project using the plugin; rules for *one* project go in that project's CLAUDE.md.
