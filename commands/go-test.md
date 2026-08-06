---
description: Roda a suite via agent go-tester e tria falhas barato
argument-hint: [pacote ou -race ou -cover]
---

Delegar ao agent **go-tester**: "$ARGUMENTS" (vazio => `./...`).
Repassar o relatorio. Se houver falhas e modo autopilot: perguntar 1x se corrige; sim => go-implementer com o diagnostico.
