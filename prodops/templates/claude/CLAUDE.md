# Claude Code — ProdOps Consumer Repo

Este repositório usa o ProdOps Framework. Leia as regras em `.claude/rules/` antes de qualquer ação.

## Entrypoints canônicos

| Ação | Skill | Agente |
|---|---|---|
| Identificar e formalizar uma Business Intent | `prodops/skills/intent/SKILL.md` | — |
| Explorar uma hipótese (Upstream) | `prodops/skills/upstream/SKILL.md` | — |
| Executar CommitmentGate ou Readiness Gate | `prodops/skills/commitment/SKILL.md` | `tpm-agent` |
| Ler o estado atual de uma capability | `prodops/skills/product-context/SKILL.md` | `pce-agent` |
| Iniciar entrega Downstream | `prodops/skills/downstream/SKILL.md` | `downstream-agent` |
| Capturar ou verificar evidências | `prodops/skills/evidence/SKILL.md` | `pre-agent` |
| Verificar Business e Product Outcome | `prodops/skills/outcome/SKILL.md` | `pqe-agent` |
| Sincronizar estado do OBC | `prodops/skills/diligence/SKILL.md` | `diligence-agent` |

## Resolução de skills

O caminho canônico de cada skill está declarado em `prodops/runtime/runtime.yaml` (seção `skills:`).

Leia o `runtime.yaml` para resolver o path correto antes de invocar qualquer skill.

Nunca use `find` ou `ls` para localizar arquivos de skill.

## Regra de lifecycle

Toda intenção de trabalho passa pelo lifecycle canônico:

```
Business Signal → Business Intent / Product Intent
→ Context Discovery (Upstream) → CommitmentGate
→ Diligence & Readiness → Iteration → Delivery
→ Evidence → Outcome
```

Identifique o estágio atual antes de decidir qual skill ou agente invocar.
Use `/product-context` ou o `pce-agent` quando o estágio for incerto.

## Não modifique artefatos canônicos

Scripts em `prodops/scripts/`, skills em `prodops/skills/`, documentação em
`prodops/framework/` e runtime em `prodops/runtime/` são gerenciados pelo
ProdOps Framework upstream. Edições diretas serão sobrescritas na próxima
execução de `sync-from-framework.sh`.

## Referências

→ [Lifecycle](prodops/framework/lifecycle.md)
→ [Glossário](prodops/framework/glossary.md)
→ [OBC](prodops/framework/obc.md)
→ [Jornada Discovery](prodops/framework/journeys/discovery/README.md)
→ [AGENTS.md](AGENTS.md)
