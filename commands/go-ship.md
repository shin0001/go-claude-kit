---
description: Prepara commit(s) convencionais e o comando de push/PR (push e sempre manual)
argument-hint: [mensagem ou vazio p/ inferir do diff]
---

1. `git status` + `git diff`. Nada staged e nada modificado => avisar e parar.
2. Agrupar mudancas em commits atomicos (1 intencao = 1 commit). Mensagem: Conventional Commits, imperativo, subject <= 50 chars, corpo so se o "por que" nao for obvio. "$ARGUMENTS" como base se fornecido.
3. Pre-voo barato: `go build ./...` + testes dos pacotes tocados. Falhou => parar, nao commitar quebrado.
4. `git add` seletivo (NUNCA `git add .` cego — respeitar secret-guard e .gitignore) + `git commit`.
5. Push e PR sao SEUS (o settings nega `git push` de proposito). Imprimir pronto p/ colar:
   `git push -u origin <branch> && gh pr create --title "..." --body "..."`
   Corpo do PR: resumo em 3 bullets + "como testar" em 1 linha.
