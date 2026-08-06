---
description: Auditoria de seguranca (govulncheck + gosec + gitleaks + revisao) via agent go-auditor
argument-hint: [pacote ou vazio p/ ./...]
---

Delegar ao agent **go-auditor**: escopo "$ARGUMENTS" (vazio => repo todo).
Repassar o relatorio cru. Se houver CRIT/HIGH e modo autopilot: oferecer corrigir via go-implementer (1 pergunta, nao insistir).
Ferramentas ausentes: mostrar comando de instalacao (govulncheck: `go install golang.org/x/vuln/cmd/govulncheck@latest`; gosec: `go install github.com/securego/gosec/v2/cmd/gosec@latest`; gitleaks: gerenciador de pacotes do SO).
