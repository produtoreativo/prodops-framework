---
name: commitment
description: Executa o CommitmentGate e o Readiness Gate. Use para convocar o trio (PM + Tech Lead + Autor), verificar o Decision Package, registrar o outcome canônico, transitar do modo Upstream para Downstream Declared, e verificar pré-requisitos de readiness antes de uma capability entrar no Iteration Plan.
---

# Commitment Skill

## Propósito

Use esta skill para formalizar a transição de modo de execução: de Upstream (exploratório, sem compromisso) para Downstream (comprometido, com rigor bloqueante).

Esta skill cobre dois gates sequenciais do lifecycle canônico:

1. **CommitmentGate** — transição Upstream → Downstream Declared
2. **Readiness Gate** — transição Downstream Declared → Downstream Ready

→ Para exploração Upstream que antecede o CommitmentGate, use `/upstream`.
→ Para execução da jornada Delivery após o Readiness Gate, use `/downstream`.
→ Para manutenção de estado dos artefatos, use `/diligence`.

---

## Quando Usar

**CommitmentGate:**
- O Decision Package de um experimento está completo e o trio precisa ser convocado
- Uma hipótese foi respondida e a recomendação é `Promover` ou `Promover com restrição`
- É necessário registrar formalmente um outcome canônico (incluindo os não-promoção)
- Um item precisa transitar para Downstream Declared

**Readiness Gate:**
- Um item em Downstream Declared precisa ser verificado antes de entrar no Iteration Plan
- O OBC precisa estar em estado Committed e todos os artefatos obrigatórios verificados
- O Diligence bloqueou uma capability e é necessário avaliar prontidão atual

---

## Leitura Obrigatória

Antes de iniciar, ler:

- `prodops/framework/lifecycle.md` — estágios Commitment e Diligence & Readiness
- `prodops/framework/glossary.md` — termos CommitmentGate, Commitment, Readiness Gate
- `prodops/framework/journeys/discovery/README.md` — pré-condições, trio, outcomes canônicos, processo de promoção

---

## Fluxo do CommitmentGate

### Pré-condições (verificar todas antes de convocar o trio)

1. **Decision Package completo:** o `experiment.md` tem Executive Summary, Decisão Recomendada, Riscos, Oportunidades, Itens de Tracking, OBCs e Escopo Downstream.
2. **Hipótese respondida:** os Exit Criteria do experimento estão satisfeitos.
3. **Evidence Threshold satisfeito** (se declarado no `experiment.md`).
4. **OBC Draft existe:** ao menos o arquivo em `prodops/artifacts/experiments/<NNN-slug>/obcs/<slug>.md`.
5. **BDD draft legível:** rascunho dos cenários em `prodops/artifacts/experiments/<NNN-slug>/features/`.
6. **Critério de verificabilidade:** qualquer membro do trio que não participou do experimento consegue ler o Decision Package e chegar às mesmas conclusões sem contexto oral adicional.

Se qualquer pré-condição não for satisfeita: não convocar o trio. Retornar ao experimento e completar o Decision Package.

---

### O Trio

| Papel | Responsabilidade |
|---|---|
| Product Manager | Valida o valor de negócio; decide se a capability entra no Iteration Plan |
| Tech Lead | Valida viabilidade técnica, riscos arquiteturais e OBC |
| Autor do experimento | Apresenta descobertas; defende a recomendação |

A aprovação é coletiva. Qualquer membro pode bloquear com justificativa registrada.

---

### Outcomes Canônicos

| Outcome | Ação |
|---|---|
| **Promover** | Executar processo de promoção (ver abaixo). OBC Draft → Refining. Downstream Declared. |
| **Promover com restrição** | Subconjunto é promovido. Partes restritas retornam a Upstream para novo experimento. |
| **Requer outro experimento** | Criar novo experimento com hipótese mais específica. Registrar no `upstream-trail.md`. |
| **Aguardar decisão de negócio** | Bloquear na Product Tracking List com decisor e data esperada. |
| **Aguardar dependência externa** | Registrar no Reliability Plan e na Product Tracking List. |
| **Descartar** | Registrar aprendizado em `prodops/framework/journeys/discovery/learnings.md`. Fechar experimento. |

---

### Registro Obrigatório

Independente do outcome, registrar no `upstream-trail.md` do experimento:
- Data do CommitmentGate
- Participantes (trio)
- Outcome canônico selecionado
- Próximos passos

---

### Processo de Promoção (outcome: Promover)

Executar em ordem:

```
1. Mover BDD Feature:
   prodops/artifacts/experiments/<NNN-slug>/features/<slug>.feature
   → prodops/artifacts/bdd/<slug>.feature

2. Mover OBC:
   prodops/artifacts/experiments/<NNN-slug>/obcs/<slug>.md
   → prodops/artifacts/obcs/<slug>.md
   Remover marcação de draft. Atualizar estado para Refining.

3. Criar entrada no Iteration Plan:
   prodops/artifacts/plans/iteration-plan.md
   Adicionar com decisão "Entrou" na tabela. Status: Downstream Declared.

4. Atualizar Product Tracking List se o item estava lá:
   prodops/artifacts/product/backlogs/tracking-list.md
   Mudar status para "Promovido para Downstream".

5. Registrar promoção no upstream-trail do experimento:
   prodops/artifacts/experiments/<NNN-slug>/upstream-trail.md

6. Registrar no upstream trail global:
   prodops/framework/journeys/discovery/upstream-trail.md
   (entrada de alto nível: o que foi promovido e quando)
```

---

## Fluxo do Readiness Gate

O Readiness Gate verifica que um item em Downstream Declared tem todos os pré-requisitos para iniciar a Delivery.

### Gates de Prontidão

1. Local OBC no estado Committed em `prodops/artifacts/obcs/<slug>.md`
2. BDD Feature committed em `prodops/artifacts/bdd/<slug>.feature`
3. Riscos documentados em `prodops/artifacts/risks/risks.md`
4. Item no Iteration Plan com status `Entrou`
5. GitHub Issue existente e mapeada no `plan.md` da iteração ativa
6. Reliability Plan atualizado (obrigatório quando houver movimentação financeira, integração externa, mudança de SLO, risco alto/crítico ou alteração de persistência ou segurança)

**Todos os gates 1–5 são bloqueantes.** O gate 6 é bloqueante apenas nas condições declaradas.

### Resultado do Readiness Gate

- **Downstream Ready:** todos os gates passaram → item pode entrar no Bootstrap.
- **Downstream Declared bloqueado:** listar gates faltando, artefatos ausentes e ação concreta necessária. Não avançar até resolução.

---

## Regras de Operação

1. Nunca pular o CommitmentGate para itens que vêm de Upstream — a transição de modo deve ser formal e registrada.
2. Nunca registrar outcome diferente dos 6 canônicos — não existem outcomes intermediários.
3. Nunca marcar um item como Downstream Ready enquanto houver gates bloqueantes.
4. Não inventar critérios de aceite, OBCs ou BDD durante o CommitmentGate — os artefatos devem existir antes da convocação.
5. O CommitmentGate não é pré-condição de implantação de código — código pode ir a produção antes do gate; o gate formaliza a *capability*, não o deploy.

---

## Saídas Esperadas

**CommitmentGate (Promover):**
- `upstream-trail.md` do experimento atualizado com outcome, data e trio
- OBC movido para `prodops/artifacts/obcs/<slug>.md` em estado Refining
- BDD Feature movida para `prodops/artifacts/bdd/`
- Iteration Plan atualizado com status Downstream Declared
- `prodops/framework/journeys/discovery/upstream-trail.md` com entrada de promoção

**Readiness Gate (aprovado):**
- Confirmação formal de Downstream Ready
- Context capsule pronto para o Bootstrap da jornada Delivery

---

## Guardrails

- Nunca registrar outcome sem data, participantes e próximos passos no `upstream-trail.md`.
- Nunca iniciar Bootstrap sem Readiness Gate aprovado.
- Nunca criar Issues ou PRs sem declarar `artifact_type`, `artifact_id`, `operation` e `journey`.
- Não confundir "código em produção" com "capability promovida" — são objetos distintos.

---

## Referências

→ [Lifecycle](../../framework/lifecycle.md)
→ [Glossário](../../framework/glossary.md)
→ [Jornada Discovery — CommitmentGate](../../framework/journeys/discovery/README.md#commitmentgate--transição-upstream--downstream)
→ [OBC — estados e transições](../../framework/obc.md)
→ [Intent Skill](../intent/SKILL.md)
→ [Upstream Skill](../upstream/SKILL.md)
→ [Downstream Skill](../downstream/SKILL.md)
→ [Work Item Schema](../../framework/execution-mapping/work-item-schema.md)
