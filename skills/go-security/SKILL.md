---
name: go-security
description: Go security - input, SQL, crypto, secrets, HTTP hardening, supply chain. Use when writing code exposed to external input or when auditing.
---

# go-security

## External input
- Validate at the edge (handler), strong types from there on. Bound size: `http.MaxBytesReader`.
- `json.Decoder` + `DisallowUnknownFields()` for strict APIs.
- File path from outside: `filepath.Clean` + prefix check via `filepath.Rel` (traversal).
- `exec.Command`: separate args, NEVER through shell/`sh -c` with external input.

## SQL
- Always placeholders (`$1`/`?`). Concatenating input into a query = BLOCKER, even "sanitized".
- Dynamic identifiers (column for ORDER BY): explicit allowlist.

## Crypto and auth
- Random for token/nonce: `crypto/rand`, never `math/rand`.
- Password hashing: `golang.org/x/crypto/bcrypt` or `argon2`. md5/sha1 for security = BLOCKER.
- Secret comparison: `subtle.ConstantTimeCompare`, not `==`.
- TLS: never `InsecureSkipVerify: true` outside tagged tests.

## Secrets
- Never in code/repo. Config via env (`os.Getenv`) or secret manager.
- Never log: tokens, passwords, Authorization header, auth request bodies. slog: explicit fields, never dump config structs.
- go-secret-guard hook blocks obvious patterns on edit; not an excuse to relax.

## HTTP server/client
- `http.Server` with `ReadHeaderTimeout`, `ReadTimeout`, `WriteTimeout`, `IdleTimeout`. Defaults have no timeout = slowloris.
- Client: `http.Client{Timeout: ...}` or ctx deadline. Bare `http.DefaultClient` = WARN.
- Public API response headers: `X-Content-Type-Options: nosniff`; CORS allowlist, never `*` with credentials.

## Supply chain
- `govulncheck ./...` after any go.mod change and in CI.
- New dep: check maintenance, open security issues, transitive count (`go mod graph | wc -l` before/after).
- `go.sum` always committed. Pinned GOTOOLCHAIN in production.
