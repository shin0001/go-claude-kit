---
description: Implementa um plano aprovado (ou tarefa direta) conforme o modo do projeto
argument-hint: [caminho do plano | descricao da tarefa]
---

Alvo: "$ARGUMENTS" (se vazio: plano mais recente em `docs/plans/`).

Modo **autopilot** (ver CLAUDE.md):
1. Delegar ao agent **go-implementer** com o plano completo.
2. Ao terminar, delegar ao **go-tester** (com `-race` se houve codigo concorrente).
3. Falhas: devolver diagnostico ao implementer. Max 3 ciclos; depois, parar e reportar.
4. `go.mod`/`go.sum` mudou => `govulncheck ./...` (ou delegar ao **go-auditor** se a mudanca de deps foi grande).
5. Delegar diff final ao **go-reviewer**. BLOCKERs: corrigir e re-revisar 1x.
6. Reporte final: arquivos, testes (pass/fail), achados restantes. Terso.
7. Retro (1 linha, so se aplicavel): houve correcao do usuario ou retrabalho evitavel => sugerir `/go-learn "<licao>"`.

Modo **copilot**:
1. Implementar VOCE MESMO na sessao principal, passo a passo do plano.
2. Mostrar diff antes de aplicar quando tocar >1 arquivo. Rodar so os testes do pacote tocado.
3. Parar entre passos maiores para o usuario validar.
