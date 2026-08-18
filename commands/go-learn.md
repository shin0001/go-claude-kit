---
description: Captures a session lesson and persists it in the right scope (project, global, skill or plugin)
argument-hint: [lesson in 1 sentence | empty to extract from conversation]
---

Lesson: "$ARGUMENTS". If empty: find recent user corrections, rework, or repeated preferences in the conversation; propose the lesson as 1 imperative line and confirm.

## 1. Classify scope (AskUserQuestion if ambiguous)
| Scope | When | Destination | Cap |
|---|---|---|---|
| **project** | specific to this codebase (local convention, local pitfall) | `.claude/learned.md` | 15 lines |
| **global-always** | user preference valid in EVERY project, every turn | `~/.claude/CLAUDE.md`, section `## Go — learnings` | 10 lines |
| **global-technical** | Go technical pattern/pitfall, useful on demand | `~/.claude/skills/go-lessons/SKILL.md` | 30 lines |
| **plugin** | universal best practice that should ship to any kit user | patch in the go-claude-kit repo | — |

Criterion: personal preference NEVER goes to plugin. Single-codebase detail NEVER goes global.

## 2. Persist (with hygiene — this is what prevents context inflation)
- Format: `- ` + 1 imperative, specific, verifiable line. No prose.
- Before adding: grep the destination for a similar lesson. Similar exists => MERGE into it, don't duplicate.
- Cap exceeded => merge the 2 most similar or propose removing the least useful (user decides). The cap is inviolable.
- Global destination missing => create it (go-lessons skill: frontmatter `name: go-lessons`, `description: This user's Go lessons. Use when writing/reviewing Go.`).

## 3. Plugin scope
Ask for the local go-claude-kit clone path. Exists => edit the relevant skill/agent/command + remind to commit. Doesn't exist => print the ready-to-apply diff. Never edit `~/.claude/plugins/` directly (plugin updates overwrite it).

## 4. Confirm
Show the final line + destination + current count/cap. E.g. `project 7/15`.
