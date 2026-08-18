---
description: Prepares conventional commit(s) and the push/PR command (push is always manual)
argument-hint: [message or empty to infer from diff]
---

1. `git status` + `git diff`. Nothing staged and nothing modified => warn and stop.
2. Group changes into atomic commits (1 intent = 1 commit). Message: Conventional Commits, imperative, subject <= 50 chars, body only if the "why" isn't obvious. Use "$ARGUMENTS" as base if given.
3. Cheap preflight: `go build ./...` + tests of touched packages. Failed => stop, never commit broken.
4. Selective `git add` (NEVER blind `git add .` — respect secret-guard and .gitignore) + `git commit`.
5. Push and PR are the USER's (settings denies `git push` on purpose). Print ready to paste:
   `git push -u origin <branch> && gh pr create --title "..." --body "..."`
   PR body: 3-bullet summary + "how to test" in 1 line.
