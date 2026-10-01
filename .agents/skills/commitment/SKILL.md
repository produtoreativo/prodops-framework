---
name: commitment
description: Execute the CommitmentGate for a Business Intent entering Downstream directly (Downstream Direto), without prior Upstream experiment. Use when context is sufficient to commit — validated demand, clear scope, open questions classified as refinement rather than uncertainty. OBCs and BDD files already exist in canonical locations. For CommitmentGate after a completed Upstream experiment, use upstream/move-to-downstream instead.
---
<!-- MATERIALIZED FILE — DO NOT EDIT MANUALLY
     Source:    prodops/skills/commitment/SKILL.md
     Player:    codex
     Generator: prodops/scripts/agents/materialize-skills.sh
     Generated: 2026-10-01T19:59:54Z
     To update: bash prodops/scripts/agents/materialize-skills.sh --skill commitment
-->

# Commitment Skill — Downstream Direto

Use este skill quando a Business Intent tem contexto suficiente para entrar em
Downstream **sem experimento Upstream prévio** — demanda confirmada por fontes
independentes, escopo claro, questões abertas são de refinamento, não incerteza.

**Não usar** se os artefatos ainda estão no diretório de um experimento —
nesse caso usar `/upstream move-to-downstream`.

Para o Readiness Gate (verificação de prontidão antes do Bootstrap), usar
`/diligence`.

---

## Quando Usar

- Business Intent com escopo definido, sem hipóteses que exijam experimento
- OBCs em Draft já em `prodops/artifacts/obcs/`
- BDD Features já em `prodops/artifacts/bdd/`
- Evidência vem de fontes externas ao experimento: pesquisa de mercado,
  competitive analysis, EXP anterior, dados históricos, validação com usuários

---

## Leitura Obrigatória

1. Business Intents do escopo (`prodops/artifacts/business-intents/`)
2. OBCs Draft correspondentes (`prodops/artifacts/obcs/`)
3. Fontes de evidência disponíveis
4. `prodops/framework/obc.md` — estados e transições canônicas
5. `prodops/framework/lifecycle.md` — estágio Commitment

---

## Momento 1 — Verificar Evidence Threshold

Confirmar os 5 critérios antes de registrar o gate. Todos são bloqueantes.

| Critério | Verificação |
|---|---|
| Hipótese respondida | Pergunta de negócio central respondida com evidência verificável por terceiros |
| Decision Package presente | BI + feature registry, roadmap, competitive analysis ou equivalente |
| OBC Draft existe | Arquivo em `prodops/artifacts/obcs/<slug>.md` para cada capability comprometida |
| BDD legível | Feature em `prodops/artifacts/bdd/<slug>.feature` (draft aceitável — completude é exigida no Readiness Gate) |
| Incerteza residual declarada | Questões abertas documentadas e classificadas como refinamento, não bloqueio de hipótese |

Se qualquer critério não estiver satisfeito: não registrar o gate. Retornar
ao owner com orientação sobre o que produzir antes.

---

## Momento 2 — Registrar o CommitmentGate

Registrar em `prodops/artifacts/plans/commitment-trail.md`.

Se o arquivo não existir, criá-lo com o header:

```markdown
# Commitment Trail — <Produto>

Registro append-only de CommitmentGates executados no modo Downstream Direto.
Para CommitmentGates pós-Upstream, ver os upstream-trail.md dos experimentos.
```

Adicionar a entrada:

```markdown
## YYYY-MM-DD — CommitmentGate — <nome do escopo>

**Outcome:** <outcome canônico>

**Trio:** PM (<nome>) + Tech Lead (<nome>) + Autor (<nome>)

**Evidência base:**
- <fonte 1>
- <fonte 2>

**Avaliação por critério:**

| Critério | Status | Evidência |
|---|---|---|
| Hipótese respondida | ✅/❌ | <referência> |
| Decision Package | ✅/❌ | <referência> |
| OBC Draft | ✅/❌ | <N arquivos em prodops/artifacts/obcs/> |
| BDD legível | ✅/❌ | <N arquivos em prodops/artifacts/bdd/> |
| Incerteza residual | ✅/❌ | <classificada como refinamento — ver BI> |

**Justificativa do outcome:**
<2-3 parágrafos: o que foi validado, o que permanece incerto mas é aceitável,
por que o custo de descoberta adicional supera o risco de comprometer agora.>

**Escopo comprometido:**
<lista de OBCs ou BCs no outcome Promover>

**Escopo restringido (se aplicável):**
<o que ficou fora e por quê>
```

---

## Momento 3 — Transitar OBC Draft → Refining

Para cada OBC no escopo comprometido:

**3a. Atualizar o campo Status:**

```
Status: Refining. Downstream Declared em YYYY-MM-DD.
Localizado em prodops/artifacts/obcs/<slug>.md.
```

**3b. Adicionar seção `## Histórico de Estado`** (se não existir):

```markdown
## Histórico de Estado

| Data | Transição | Ator | Contexto |
|---|---|---|---|
| YYYY-MM-DD | Draft → Refining | PM + Tech Lead | CommitmentGate Downstream Direto — commitment-trail.md |
```

OBCs marcados como "Aguarda CommitmentGate" permanecem em Draft — eles têm
seu próprio gate pendente (ex: CategoryManagement, Copilot).

---

## Momento 4 — Criar ou atualizar Iteration Plan

Criar ou atualizar `prodops/artifacts/plans/iteration-plan.md`.

Cada OBC comprometido entra com status **`Icebox`** — não `Entrou`. O status
`Entrou` é atribuído apenas após o Readiness Gate (via `/diligence`).

```markdown
## Iteration Backlog

| OBC | Slug | BC | Release | Estado | Status |
|---|---|---|---|---|---|
| OBC-002 | demand-intent-capture | Demand | v1.0 | Refining | Icebox |
```

---

## Outcomes Canônicos (6)

| Outcome | Próximo passo | Transição de estado |
|---|---|---|
| **Promover** | OBC → Refining; Icebox; Readiness Gate via `/diligence` | Draft → Refining |
| **Promover com restrição** | Subconjunto → Refining; restante documentado | Parcial Draft → Refining |
| **Requer outro experimento** | Abrir EXP com hipótese específica; registrar no commitment-trail | Permanece Draft |
| **Aguardar decisão de negócio** | Owner registra decisor e prazo | Permanece Draft |
| **Aguardar dependência externa** | Risco registrado na BI com owner e prazo | Permanece Draft |
| **Descartar** | OBC → Archived com justificativa | Draft → Archived |

---

## Guardrails

- Nunca pule o Momento 1 — gate sem evidence check não é CommitmentGate.
- Nunca transite OBC direto para `Readiness` aqui — isso é o Readiness Gate (`/diligence`).
- O commitment-trail é append-only — nunca edite entradas existentes.
- Nunca transite OBCs marcados "Aguarda CommitmentGate" — eles têm gate próprio.
- Nunca use este skill para OBCs que vêm de experimento Upstream concluído — use `/upstream move-to-downstream`.
- Nunca crie Work Items no GitHub sem declarar `artifact_type`, `artifact_id`, `operation` e `journey`.

---

## Saídas Esperadas

- `prodops/artifacts/plans/commitment-trail.md` com entrada do gate
- OBCs comprometidos com Status `Refining` e seção `## Histórico de Estado`
- `prodops/artifacts/plans/iteration-plan.md` com entradas em status `Icebox`

---

## Referências

→ [Lifecycle — estágio Commitment](../../../prodops/framework/lifecycle.md)
→ [OBC — estados e transições](../../../prodops/framework/obc.md)
→ [upstream/move-to-downstream](../upstream/steps/move-to-downstream/SKILL.md)
→ [diligence — Readiness Gate](../diligence/SKILL.md)
