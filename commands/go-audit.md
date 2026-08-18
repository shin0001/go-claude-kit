---
description: Security audit (govulncheck + gosec + gitleaks + review) via the go-auditor agent
argument-hint: [package or empty for ./...]
---

Delegate to the **go-auditor** agent: scope "$ARGUMENTS" (empty => whole repo).
Relay the raw report. If CRIT/HIGH and autopilot mode: offer to fix via go-implementer (ask once, don't push).
Missing tools: show install commands (govulncheck: `go install golang.org/x/vuln/cmd/govulncheck@latest`; gosec: `go install github.com/securego/gosec/v2/cmd/gosec@latest`; gitleaks: OS package manager).
