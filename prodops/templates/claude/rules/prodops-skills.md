# ProdOps Skills — Regras de Invocação

## Regra 1: Leia o runtime.yaml para resolver skills

Antes de invocar qualquer skill, leia `prodops/runtime/runtime.yaml` (seção `skills:`) para obter o path correto:

```yaml
skills:
  upstream:        prodops/skills/upstream/SKILL.md
  downstream:      prodops/skills/downstream/SKILL.md
  intent:          prodops/skills/intent/SKILL.md
  commitment:      prodops/skills/commitment/SKILL.md
  product-context: prodops/skills/product-context/SKILL.md
  evidence:        prodops/skills/evidence/SKILL.md
  outcome:         prodops/skills/outcome/SKILL.md
  diligence:       prodops/skills/diligence/SKILL.md
  # ...
```

Nunca use `find` ou `ls` para localizar arquivos de skill. O runtime.yaml é a fonte autoritativa.

## Regra 2: Siga o skill como regra de execução

Ao invocar um skill:
1. Leia o arquivo de skill por completo.
2. Siga a seção "Leitura Obrigatória" antes de qualquer ação.
3. Execute o fluxo exatamente como descrito — não pule etapas, não reordene fases.
4. Respeite os Guardrails declarados no skill.

Um skill não é uma sugestão — é a regra de execução autoritativa para aquela ação.

## Regra 3: Mapeamento estágio → skill

| Estágio do lifecycle | Skill principal |
|---|---|
| Business Signal → Business Intent | `intent` |
| Context Discovery (Upstream) | `upstream` |
| CommitmentGate / Readiness Gate | `commitment` |
| Estado atual incerto | `product-context` |
| Delivery (CI Sync / CI Async) | `downstream` |
| Evidence (Upstream ou Downstream) | `evidence` |
| Outcome (KPIs, SLOs, DORA) | `outcome` |
| Sincronização de OBC / Backlogs | `diligence` |

## Regra 4: Agentes invocam skills; skills não invocam agentes

Os agentes (`.claude/agents/`) são orchestrators — eles leem skills e executam seu fluxo.
Skills definem o que fazer; agentes decidem quando e como invocar cada skill.

Nunca escreva um skill que dependa de um agente específico. Skills são agnósticos de agente.

## Referências

→ [Skills README](prodops/skills/README.md)
→ [Runtime YAML](prodops/runtime/runtime.yaml)
