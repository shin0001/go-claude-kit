---
description: Avalia adicao de dependencia conforme a politica do projeto
argument-hint: <import path da lib>
---

Lib: "$ARGUMENTS". Ler a politica de dependencias no CLAUDE.md.

1. **minimal**: mostrar como resolver com stdlib/x. So se inviavel, apresentar a lib com custo: transitivas (`go mod graph` estimado), manutencao, licenca. Decisao e do usuario.
2. **pragmatic**: na lista curada => `go get` + `go mod tidy` direto. Fora => 3 linhas: o que resolve, alternativa stdlib descartada e por que, saude do repo (busque na web se necessario). Aguardar ok.

Nunca adicionar dep sem o gate acima. Apos adicionar: registrar na lista curada do CLAUDE.md.
