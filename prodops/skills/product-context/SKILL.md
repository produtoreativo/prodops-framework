---
name: product-context
description: Lê e apresenta o estado atual do produto para uma capability ou OBC específico. Use para montar o contexto antes de qualquer execução — lê OBC ativo, backlog, iteration plan, experiment trail e artefatos de confiabilidade sem modificar nada.
---

# Product Context Skill

## Propósito

Use esta skill para obter uma visão consolidada e verificável do estado atual de uma capability antes de qualquer execução. Ela não modifica artefatos — apenas os lê, consolida e apresenta.

O Product Context é o ponto de partida obrigatório para qualquer execução que precise de contexto antes de decidir qual ação tomar:
- Não sei se este item já está em Downstream ou ainda em Upstream
- Preciso entender em que estágio do lifecycle este OBC está
- Quero saber quais experimentos foram conduzidos para esta capability

→ Para começar exploração Upstream, use `/upstream`.
→ Para executar o CommitmentGate, use `/commitment`.
→ Para iniciar entrega, use `/downstream`.

---

## Quando Usar

- Antes de iniciar qualquer skill de execução para verificar o estado atual
- Quando o contexto da capability está incerto ou potencialmente desatualizado
- Para responder "qual o estágio atual deste OBC / desta capability?"
- Para montar a visão consolidada de uma capability para uma retrospectiva, assessment ou handoff
- Quando invocado por um agente que precisa de contexto antes de decidir a próxima ação

---

## Leitura Obrigatória

Antes de iniciar, ler:

- `prodops/framework/lifecycle.md` — estágios e condições de entrada/saída
- `prodops/framework/obc.md` — estados do OBC e transições canônicas
- `prodops/framework/glossary.md` — termos Product Intent, OBC, Commitment, Evidence, Outcome

---

## Fluxo de Leitura de Contexto

### 1. Identificar a capability

Determinar o slug da capability ou OBC-ID a partir da entrada fornecida. Se não fornecido, listar os OBCs ativos em `prodops/artifacts/obcs/` e solicitar identificação.

---

### 2. Ler o OBC ativo

Ler `prodops/artifacts/obcs/<slug>.md` e extrair:
- Estado atual (Draft / Refining / Committed / In Delivery / Released / Archived)
- Origem (Global OBC ou Business Intent + Tracking Item)
- Critérios de aceite (se presentes)
- Observable Events declarados
- Evidências registradas
- KPIs comprometidos

Se o OBC não existir em `prodops/artifacts/obcs/`, buscar em `prodops/artifacts/experiments/*/obcs/` (estado Draft em experimento Upstream).

---

### 3. Determinar o estágio do lifecycle

Com base no estado do OBC e nos artefatos presentes, classificar a capability em um dos 9 estágios do lifecycle canônico:

| Estágio | Indicadores |
|---|---|
| Business Signal | Apenas entrada na Tracking List |
| Business Intent / Product Intent | OBC Draft + referência de origem estabelecida |
| Context Discovery | OBC Draft em diretório de experimento + `experiment.md` ativo |
| Commitment | OBC transitando Draft → Refining; CommitmentGate registrado no `upstream-trail.md` |
| Diligence & Readiness | OBC Refining → Committed; gates de readiness em verificação |
| Iteration | OBC Committed; item no Iteration Plan com status `Entrou` |
| Delivery | OBC In Delivery; Bootstrap.Started registrado; CI Sync em execução |
| Evidence | OBC Released; Release Trail atualizado; Observable Events operando |
| Outcome | OBC Released; KPIs e Product Outcome verificados |

---

### 4. Ler artefatos de suporte

Ler os artefatos existentes na seguinte ordem:

**Backlog:**
- `prodops/artifacts/product/backlogs/tracking-list.md` — presença e status do item
- `prodops/artifacts/plans/iteration-plan.md` — status na iteração ativa

**Experimentos (se em Upstream ou Context Discovery):**
- `prodops/artifacts/experiments/<NNN-slug>/experiment.md` — hipótese, status, Decision Package
- `prodops/artifacts/experiments/<NNN-slug>/upstream-trail.md` — histórico cronológico

**Artefatos de entrega (se em Downstream):**
- `prodops/artifacts/bdd/<slug>.feature` — BDD Feature committed
- `prodops/artifacts/risks/risks.md` — riscos relevantes para a capability
- `prodops/artifacts/plans/reliability/<slug>.md` — Reliability Plan (se existir)

**Evidências e outcome (se Released):**
- `prodops/artifacts/trails/` — Release Trail da capability
- Métricas de Observable Events referenciadas no OBC

---

### 5. Consolidar e apresentar

Produzir um **Context Summary** com:

```markdown
## Context Summary — <capability-slug>

**Estágio do lifecycle:** <estágio>
**Estado do OBC:** <estado>
**Modo de execução atual:** <Upstream | Downstream | —>

### Origem
<Business Intent ou Global OBC de origem>

### Experimentos ativos
<lista de experimentos em andamento ou concluídos>

### Artefatos presentes
- [ ] OBC: <path e estado>
- [ ] BDD Feature: <path ou ausente>
- [ ] Riscos: <presença>
- [ ] Reliability Plan: <presença>
- [ ] Iteration Plan entry: <status>

### Próxima ação recomendada
<ação concreta baseada no estágio atual>
```

---

## Regras de Operação

1. Esta skill nunca modifica artefatos — apenas lê e consolida.
2. Se um artefato esperado não existir, declarar explicitamente como ausente — não inferir estado.
3. Não classificar a capability em um estágio sem evidência concreta (arquivo ou campo lido).
4. Não recomendar ação que não seja compatível com o estágio identificado.
5. Se a capability não for encontrada em nenhum artefato: declarar como "não registrada" e recomendar `/intent` como ponto de entrada.

---

## Saídas Esperadas

- Context Summary consolidado com estágio do lifecycle, estado do OBC e artefatos presentes
- Próxima ação recomendada baseada no estado atual
- Lista de artefatos ausentes que bloqueiam o avanço (quando aplicável)

Esta skill não produz artefatos persistentes — o Context Summary é produzido para consumo imediato pela sessão ou pelo agente solicitante.

---

## Guardrails

- Nunca modificar OBCs, experimentos, backlogs ou qualquer artefato de produto.
- Nunca inferir o estado de uma capability sem leitura concreta dos artefatos.
- Nunca recomendar avançar para Downstream enquanto houver gates de readiness abertos.
- Nunca reportar um OBC como Released sem verificar que o Release Trail existe.

---

## Referências

→ [Lifecycle](../../framework/lifecycle.md)
→ [OBC](../../framework/obc.md)
→ [Glossário](../../framework/glossary.md)
→ [Intent Skill](../intent/SKILL.md)
→ [Commitment Skill](../commitment/SKILL.md)
→ [Evidence Skill](../evidence/SKILL.md)
→ [Outcome Skill](../outcome/SKILL.md)
