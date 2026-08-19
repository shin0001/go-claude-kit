---
description: Syncs this project's generated files with the current kit templates, preserving local customizations
allowed-tools: Read, Write, Edit, Bash, Grep, Glob, AskUserQuestion
---

Bring this project's kit-generated files up to date with `${CLAUDE_PLUGIN_ROOT}/templates/` (fallback: `find ~/.claude/plugins -type d -name go-claude-kit`).

## 1. Detect mode
Read CLAUDE.md "Mode:" section (autopilot|copilot). Missing => ask.

## 2. Per-file strategy
For each pair (project file, template):
- `.claude/settings.json` vs `settings.<mode>.json`
- `.claude/hooks/*.sh` vs `hooks/*.sh`
- `Makefile`, `.golangci.yml`, `.github/workflows/ci.yml`, `.github/dependabot.yml` vs same-named templates

Classify by diff:
- **identical** => skip silently.
- **template-only changes** (project file matches what an older template plausibly was; no user markers) => show diff, replace on OK.
- **locally customized** (project has lines the template never had) => 3-way: apply template additions AROUND the custom lines; never delete a line you can't attribute to an old template. Ambiguous => show both and ask.

## 3. CLAUDE.md — never overwrite
Diff only the fixed sections (Rules, Commands) against `CLAUDE.base.md`. Propose NEW rule lines one by one (accept/reject each). Architecture, learnings, custom sections: untouched.

## 4. Report
Terse table: file — action (skipped | updated | merged | kept). Remind: `git diff` before committing, and re-run `/caveman-compress CLAUDE.md` if it was compressed before.
