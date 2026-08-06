---
description: Captura uma licao da sessao e persiste no escopo certo (projeto, global, skill ou plugin)
argument-hint: [licao em 1 frase | vazio p/ extrair da conversa]
---

Licao: "$ARGUMENTS". Se vazio: identificar na conversa recente correcoes do usuario, retrabalho ou preferencia repetida; propor a licao em 1 linha imperativa e confirmar.

## 1. Classificar escopo (perguntar via AskUserQuestion se ambiguo)
| Escopo | Quando | Destino | Cap |
|---|---|---|---|
| **projeto** | especifico deste codebase (convencao, armadilha local) | `.claude/learned.md` | 15 linhas |
| **global-sempre** | preferencia minha que vale em TODO projeto, todo turno | `~/.claude/CLAUDE.md`, secao `## Go — aprendizados` | 10 linhas |
| **global-tecnica** | padrao/armadilha tecnica de Go, util sob demanda | `~/.claude/skills/go-lessons/SKILL.md` | 30 linhas |
| **plugin** | boa pratica universal que deveria valer p/ qualquer usuario do kit | patch no repo do go-claude-kit | — |

Criterio: preferencia pessoal NUNCA vai p/ plugin. Detalhe de 1 codebase NUNCA vai p/ global.

## 2. Persistir (com higiene — isto e o que impede inflacao de contexto)
- Formato: `- ` + 1 linha imperativa, especifica, verificavel. Sem prosa.
- Antes de adicionar: grep no destino por licao similar. Similar existe => MESCLAR na existente, nao duplicar.
- Estourou o cap => fundir as 2 mais parecidas ou propor remover a menos util (usuario decide). Cap e inviolavel.
- Destino global nao existe => criar (skill go-lessons: frontmatter `name: go-lessons`, `description: Licoes de Go deste usuario. Use ao escrever/revisar Go.`).

## 3. Escopo plugin
Perguntar caminho do clone local do go-claude-kit. Existe => editar o skill/agent/comando pertinente + lembrar de commitar. Nao existe => imprimir o diff pronto p/ aplicar. Nunca editar `~/.claude/plugins/` direto (update do plugin sobrescreve).

## 4. Confirmar
Mostrar a linha final + destino + contagem atual/cap. Ex: `projeto 7/15`.
