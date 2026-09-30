---
name: readiness
description: Executa o Readiness Gate para um Bounded Context — verifica bloqueantemente se todos os artefatos do /refine estão presentes e completos antes de autorizar o Bootstrap (OBC: Refining → Readiness verificada). Gate paralelo ao CommitmentGate. Nunca produz artefatos; apenas verifica e registra o gate.
---

# Readiness Gate Skill

O Readiness Gate é o gate de lifecycle que separa o período de Icebox (Discovery
Downstream via `/refine`) da fase de entrega comprometida (Bootstrap via
`/bootstrap`). É um gate bloqueante: se qualquer artefato obrigatório estiver
ausente, o gate não é registrado e o Bootstrap não pode iniciar.

**Analogia:** assim como `/commitment` governa o CommitmentGate (Upstream →
Icebox), `/readiness` governa o Readiness Gate (Icebox → Delivery).

**Não use este skill para produzir artefatos.** Se um artefato estiver faltando,
retorne ao `/refine` do BC correspondente para completá-lo.

---

## Quando Usar

- Após `/refine` completado para um BC (todos os Momentos executados)
- Antes de invocar `/bootstrap` para iniciar a primeira iteração de entrega
- Quando quiser verificar se um BC individual está pronto para entrar em Delivery

**Invocação:** `/readiness <bc-slug>` ou `/readiness` (todos os BCs com OBCs em Refining)

---

## Leitura Obrigatória

Antes de qualquer verificação, ler:

1. `prodops/runtime/runtime.yaml` — confirmar path deste skill
2. `prodops/artifacts/plans/commitment-trail.md` — OBCs comprometidos para o BC
3. OBCs do BC: `prodops/artifacts/obcs/<obc-slug>.md` para cada OBC do BC
4. ADR do BC: `prodops/artifacts/architecture/<bc-slug>-adr.md`
5. UX Flows do BC: `prodops/artifacts/product/ux/<bc-slug>-flows.md`
6. BDD Features: `prodops/artifacts/bdd/<obc-slug>.feature` para cada OBC
7. Risks do BC: `prodops/artifacts/risks/risks-<bc-slug>.md`
8. Reliability Plans: `prodops/artifacts/plans/reliability/<obc-slug>.md` (quando aplicável)

---

## Momento 1 — Identificar Escopo

1. Ler `commitment-trail.md` e identificar os OBCs do BC informado.
2. Para cada OBC, registrar em memória: slug, path do arquivo, BDD feature path.
3. Confirmar que todos os OBCs do BC estão em estado `Refining` (candidatos ao gate)
   ou já em `Readiness` (gate já executado — reportar e encerrar sem re-execução).

Se o BC não estiver no commitment-trail: parar. Reportar que o CommitmentGate não
foi executado para este BC.

---

## Momento 2 — Checklist de Artefatos por OBC

Para cada OBC do BC, verificar os itens abaixo. Cada item ausente é um **bloqueio**.

### 2a. OBC (arquivo `prodops/artifacts/obcs/<obc-slug>.md`)

| Item | Verificação |
|---|---|
| Status field | Contém `Readiness` (após /refine) |
| `## Acceptance Criteria` | Presente antes de `## Related Artifacts`, com pelo menos 3 critérios verificáveis |
| `## Histórico de Estado` | Contém entrada `Refining → Readiness` com data e responsável |

### 2b. BDD Feature (`prodops/artifacts/bdd/<obc-slug>.feature`)

| Item | Verificação |
|---|---|
| `# Estado:` | Valor é `Readiness` (não `Draft`) |
| Scenarios ativos | Pelo menos 1 Scenario ativo (não `@pending`) cobrindo o happy path |
| Sem `# @future` soltos | Nenhum comentário `# @future` sem correspondente `@pending Scenario` |

### 2c. Artefatos de BC (compartilhados entre OBCs do mesmo BC)

| Artefato | Path | Obrigatório |
|---|---|---|
| ADR | `prodops/artifacts/architecture/<bc-slug>-adr.md` | Sempre |
| UX Flows | `prodops/artifacts/product/ux/<bc-slug>-flows.md` | Sempre |
| Risk Register do BC | `prodops/artifacts/risks/risks-<bc-slug>.md` | Sempre |

### 2d. Reliability Plan (verificar por OBC)

Obrigatório quando o OBC atende a qualquer uma das condições abaixo:
- Movimento financeiro (aprovação, pagamento, PO, nota fiscal)
- Integração externa crítica (SEFAZ, ERP, e-Signature, SSO, LLM, fornecedor externo)
- Mudança de SLO em relação ao estado anterior
- Risco classificado como Alta severidade no Risk Register
- Persistência de dados sensíveis (evidence_hash, LGPD, dados fiscais, auditoria)

| Item | Path |
|---|---|
| Reliability Plan | `prodops/artifacts/plans/reliability/<obc-slug>.md` |

Se a condição de obrigatoriedade for atendida e o arquivo não existir: **bloqueio**.
Se nenhuma condição for atendida: registrar "Reliability Plan não obrigatório — critérios
ausentes" e avançar.

---

## Momento 3 — Gate Decision

### APROVADO

Todos os itens do Momento 2 estão presentes e completos para todos os OBCs do BC.

Registrar na saída:
```
Readiness Gate — <BC Name> — APROVADO
Data: <data>
OBCs aprovados: <lista>
Autoriza: Bootstrap do BC <BC Name>
```

### BLOQUEADO

Um ou mais itens estão ausentes ou incompletos.

Registrar na saída:
```
Readiness Gate — <BC Name> — BLOQUEADO
Data: <data>
Bloqueios:
  - [OBC-NNN] <obc-slug>: <artefato ausente> em <path esperado>
  - ...
Ação: executar /refine <bc-slug> para completar os artefatos ausentes.
Bootstrap não autorizado.
```

**Nunca** registrar o gate em `commitment-trail.md` se o resultado for BLOQUEADO.
**Nunca** invocar `diligence-sync` para um OBC bloqueado.

---

## Momento 4 — Registrar Gate e atualizar Iteration Plan

Apenas se o resultado for APROVADO.

### 4a. Registrar em commitment-trail.md

Adicionar entrada na seção `## Readiness Gate` do `commitment-trail.md`:

```markdown
## Readiness Gate

| BC | OBCs | Data | Resultado | Responsável |
|---|---|---|---|---|
| <BC Name> | OBC-NNN, OBC-MMM | <data> | APROVADO | PM + Tech Lead |
```

Se a seção não existir, criá-la após a seção de OBCs comprometidos.

### 4b. Atualizar Iteration Plan

Para cada OBC aprovado, atualizar a coluna **Status** em
`prodops/artifacts/plans/iteration-plan.md` de `Icebox` para `Pronto para Bootstrap`.

O Iteration Plan **não** possui coluna Estado — o estado canônico vive exclusivamente
no arquivo OBC. O Iteration Plan rastreia apenas a posição do OBC no ciclo de
entrega (Status). Nunca adicionar coluna Estado ao Iteration Plan.

---

## Momento 5 — Invocar diligence-sync

Para cada OBC aprovado, invocar `diligence-sync promote` para avançar o Work Item
correspondente no backlog externo (GitHub Projects).

```
/diligence diligence-sync promote <obc-id>
```

Se `diligence-sync promote` retornar bloqueio por Work Item ausente, registrar como
pendência operacional — **não bloqueia o gate já aprovado**. Criar issue de
rastreamento com `operation: Reconcile` e `journey: Diligence`.

---

## Guardrails

- **Nunca produzir artefatos** — este skill apenas verifica. Para criar artefatos
  ausentes, retornar ao `/refine`.
- **Nunca aprovar parcialmente** — o gate é por BC inteiro. Se um OBC do BC falhar,
  o BC inteiro é BLOQUEADO.
- **Nunca pular a verificação de Reliability Plan** quando a condição de
  obrigatoriedade for atendida.
- **Nunca registrar o gate** em `commitment-trail.md` com resultado BLOQUEADO.
- **Nunca re-executar** o gate para um BC que já está APROVADO na trail — reportar
  o estado existente e encerrar.
- **Nunca inventar** critérios de aprovação que não estejam neste skill.

---

## Referências

→ [Lifecycle canônico](../../framework/lifecycle.md)
→ [Commitment Trail](../../artifacts/plans/commitment-trail.md)
→ [/refine Skill](../refine/SKILL.md) — produz os artefatos verificados por este gate
→ [/commitment Skill](../commitment/SKILL.md) — gate anterior no lifecycle
→ [/bootstrap Skill](../bootstrap/SKILL.md) — skill que este gate autoriza
→ [diligence-sync](../diligence/diligence-sync/SKILL.md) — invocado no Momento 5
