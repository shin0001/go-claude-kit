---
name: go-security
description: Seguranca em Go - input, SQL, crypto, segredos, HTTP hardening, supply chain. Use ao escrever codigo exposto a input externo ou ao auditar.
---

# go-security

## Input externo
- Validar na borda (handler), tipos fortes dali em diante. Limitar tamanho: `http.MaxBytesReader`.
- `json.Decoder` + `DisallowUnknownFields()` para APIs estritas.
- Path de arquivo vindo de fora: `filepath.Clean` + verificar prefixo com `filepath.Rel` (traversal).
- `exec.Command`: args separados, NUNCA via shell/`sh -c` com input externo.

## SQL
- Sempre placeholders (`$1`/`?`). Concatenar input em query = BLOCKER, mesmo "sanitizado".
- Identificadores dinamicos (nome de coluna p/ ORDER BY): allowlist explicita.

## Crypto e auth
- Random p/ token/nonce: `crypto/rand`, jamais `math/rand`.
- Hash de senha: `golang.org/x/crypto/bcrypt` ou `argon2`. md5/sha1 p/ seguranca = BLOCKER.
- Comparar segredos: `subtle.ConstantTimeCompare`, nao `==`.
- TLS: nunca `InsecureSkipVerify: true` fora de teste marcado.

## Segredos
- Nunca no codigo/repo. Config via env (`os.Getenv`) ou secret manager.
- Nao logar: token, senha, header Authorization, corpo de request de auth. slog: campos explicitos, nunca despejar struct de config.
- Hook go-secret-guard bloqueia padroes obvios em edicao; nao e desculpa p/ relaxar.

## HTTP server/client
- `http.Server` com `ReadHeaderTimeout`, `ReadTimeout`, `WriteTimeout`, `IdleTimeout`. Default sem timeout = slowloris.
- Client: `http.Client{Timeout: ...}` ou ctx com deadline. `http.DefaultClient` cru = WARN.
- Headers em API publica: `X-Content-Type-Options: nosniff`; CORS allowlist, nunca `*` com credenciais.

## Supply chain
- `govulncheck ./...` apos qualquer mudanca no go.mod e no CI.
- Dep nova: checar manutencao, issues de seguranca abertas, transitivas (`go mod graph | wc -l` antes/depois).
- `go.sum` sempre commitado. GOTOOLCHAIN fixo em producao.
