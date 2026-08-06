---
description: Revisa mudancas com o agent go-reviewer (uncommitted por padrao)
argument-hint: [git range, ex: main..HEAD]
---

Escopo: `$ARGUMENTS` (vazio => `git diff HEAD` + untracked .go).
Delegar ao agent **go-reviewer**. Repassar a saida crua ao usuario (formato arquivo:linha ja e terso — nao reformatar, nao resumir).
Se houver BLOCKER e o modo for autopilot: oferecer corrigir via go-implementer.
