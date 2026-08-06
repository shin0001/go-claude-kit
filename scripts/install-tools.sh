#!/usr/bin/env bash
# Instala o toolchain que o kit usa. Idempotente. Requer Go >= 1.22.
set -e
echo "instalando ferramentas Go do go-claude-kit..."
go install mvdan.cc/gofumpt@latest
go install golang.org/x/tools/cmd/goimports@latest
go install golang.org/x/vuln/cmd/govulncheck@latest
go install github.com/securego/gosec/v2/cmd/gosec@latest
go install golang.org/x/perf/cmd/benchstat@latest
if ! command -v golangci-lint >/dev/null 2>&1; then
  echo "golangci-lint: instale via https://golangci-lint.run/welcome/install/ (binario oficial, nao go install)"
fi
if ! command -v gitleaks >/dev/null 2>&1; then
  echo "gitleaks (opcional): brew install gitleaks | apt/pacman | https://github.com/gitleaks/gitleaks"
fi
if ! command -v jq >/dev/null 2>&1; then
  echo "jq (hooks usam se disponivel): instale via gerenciador do SO"
fi
echo "ok — garanta \$(go env GOPATH)/bin no PATH"
