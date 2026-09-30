---
name: refine
description: Coordena o Discovery Downstream no período do Icebox — entre o CommitmentGate (/commitment) e o Readiness Gate (/diligence). Recebe um Bounded Context como argumento e produz todos os artefatos exigidos pelo Readiness Gate: ADR, UX Flows, OBCs em Readiness, BDD Features completas, risks.md atualizado e Reliability Plans quando obrigatório.
---

[English](SKILL.en.md)

# Refine Skill — Discovery Downstream no Icebox

Use este skill no período entre o CommitmentGate e o Readiness Gate — o **Icebox period** — quando as capabilities estão comprometidas (OBCs em Refining) mas ainda não têm os artefatos de engenharia necessários para o Bootstrap.

O skill opera por **Bounded Context**, não por OBC individual. Arquitetura e UX emergem do BC; o Readiness Gate verifica OBC a OBC, mas os artefatos compartilhados são produzidos uma vez por BC.

**Não usar** antes do CommitmentGate — OBCs devem estar em estado Refining.
**Não usar** para substituir o Readiness Gate — ao terminar, invocar `/diligence` para verificação bloqueante.

---

## Quando Usar

- OBCs do BC estão em estado **Refining** (CommitmentGate executado)
- Status no Iteration Plan: **Icebox**
- Nenhum dos artefatos de engenharia do BC foi produzido ainda:
  ADR, UX Flows, SLIs/SLOs, BDD completa, Reliability Plan
- Objetivo: deixar o BC pronto para o Readiness Gate via `/diligence`

---

## Leitura Obrigatória

1. Business Intent do BC (`prodops/artifacts/business-intents/bi-<bc-slug>.md`)
2. Todos os OBCs do BC (`prodops/artifacts/obcs/<slug>.md` onde BC = <bc-slug>)
3. BDD Features existentes do BC (`prodops/artifacts/bdd/<slug>.feature`)
4. `prodops/artifacts/plans/commitment-trail.md` — escopo comprometido e restrições
5. `prodops/framework/obc.md` — estados e transições canônicas
6. `prodops/framework/principles.md` — Princípios 3, 4, 6

---

## Momento 1 — Context Capsule do BC

Consolidar o contexto completo do Bounded Context antes de qualquer decisão de arquitetura ou UX. Este momento é obrigatório — os momentos seguintes dependem do contexto aqui produzido.

**O que consolidar:**

| Dimensão | Fonte | O que extrair |
|---|---|---|
| Jornadas do usuário | OBCs + BI | Quem são os atores, quais são os fluxos principais |
| Aggregate Roots | `features.md` ou OBCs | Entidades com identidade e invariantes |
| Domain Events | OBCs (Observable Events) | Eventos que o BC emite após mudança de estado |
| Ports & Adapters | OBCs (acceptance criteria) | Dependências externas que precisam de Port/MockAdapter |
| Restrições de release | `commitment-trail.md` | O que foi restringido e por quê |

**Saída:** entendimento estruturado do BC em memória de sessão. Não é necessário escrever um arquivo — o contexto alimenta os momentos seguintes.

Se o BC tiver mais de 5 OBCs ou mais de 3 atores distintos, registrar um resumo em `prodops/artifacts/architecture/<bc-slug>-context.md` antes de continuar.

---

## Momento 2 — Architecture Decision Record (ADR)

Produzir a decisão de arquitetura do BC. O ADR não é um documento de implementação — é a declaração de padrão que o time seguirá no Bootstrap e Hack.

**Artefato:** `prodops/artifacts/architecture/<bc-slug>-adr.md`

```markdown
# ADR — <BC Name>

**Data:** YYYY-MM-DD
**Status:** Accepted
**OBCs em escopo:** OBC-NNN, OBC-NNN, …

## Contexto

<Por que este BC existe. Qual problema resolve. Quais as restrições de design.>

## Aggregate Roots

| Aggregate | Identidade | Invariantes principais |
|---|---|---|
| <Nome> | <campo de identidade> | <regras que nunca podem ser violadas> |

## Domain Events

| Evento | Emissor | Gatilho |
|---|---|---|
| <NomeDoEvento> | <Aggregate> | <quando é emitido> |

## Ports & Adapters

| Port | Adapter de produção | MockAdapter (local/test) |
|---|---|---|
| <NomePort> | <implementação real> | <mock para dev/test> |

## Decisões

1. <Decisão 1 — ex: single-table DynamoDB para este BC>
   **Razão:** <por que>
   **Consequência:** <trade-off aceito>

2. <Decisão 2>

## Alternativas consideradas e descartadas

- <Alternativa X>: descartada por <razão>

## Referências

→ [BI do BC](../../business-intents/bi-<bc-slug>.md)
→ [OBCs do BC](../../obcs/)
```

**Guardrails do Momento 2:**
- Nunca definir implementação (código, nomes de função, schemas de banco) — apenas padrão e decisão
- Nunca inventar Aggregate Roots sem base nos OBCs ou BI do BC
- Se houver incerteza de design, registrar como "A decidir antes do Bootstrap" e continuar

---

## Momento 3 — UX Flows

Produzir a descrição estruturada das jornadas críticas do BC. O objetivo é que qualquer desenvolvedor entenda o fluxo do usuário antes de iniciar o Bootstrap, sem precisar de explicação oral.

**Artefato:** `prodops/artifacts/product/ux/<bc-slug>-flows.md`

```markdown
# UX Flows — <BC Name>

**Data:** YYYY-MM-DD
**OBCs em escopo:** OBC-NNN, OBC-NNN, …

## Jornadas

### Jornada 1 — <nome da jornada> (OBC-NNN)

**Ator:** <quem executa>
**Pré-condição:** <estado do sistema antes>
**Pós-condição:** <estado do sistema depois>

**Happy path:**
1. <passo 1>
2. <passo 2>
3. …

**Erros principais:**
- <situação de erro 1> → <comportamento esperado>
- <situação de erro 2> → <comportamento esperado>

**Notas de design:**
- <restrição de UX, acessibilidade, ou comportamento não óbvio>
```

**Guardrails do Momento 3:**
- Cobrir pelo menos o happy path de cada OBC do BC
- Focar em comportamento, não em pixel (wireframes são opcionais — descrição estruturada é suficiente)
- Registrar os erros principais que afetam o fluxo — não todos os erros técnicos

---

## Momento 4 — OBC → Readiness (por OBC do BC)

Para cada OBC do BC, refinar de Refining para Readiness: preencher SLIs/SLOs e completar os critérios de aceite.

**4a. Atualizar o campo `expected_outcome`:**

```
expected_outcome: <métrica mensurável com baseline e target>
  Ex: "Taxa de intent capture > 80% das requisições criadas; lead time mediano < 2 dias"
  Se baseline desconhecido: "Baseline a confirmar via entrevistas com CPOs — target será definido após primeira coleta em produção"
```

**4b. Preencher ou completar `slis_slos`:**

```yaml
slis_slos:
  - sli: <o que é medido>
    slo: <target com unidade e período>
    baseline: <valor atual se conhecido, ou "a coletar">
```

**4c. Completar `acceptance_criteria`:**

```
acceptance_criteria:
  - <critério verificável e objetivo — sem ambiguidade>
  - <critério 2>
```

**4d. Atualizar o campo Status:**

```
Status: Readiness. Refine concluído em YYYY-MM-DD.
Localizado em prodops/artifacts/obcs/<slug>.md.
```

**4e. Adicionar entrada no `## Histórico de Estado`:**

```markdown
| YYYY-MM-DD | Refining → Readiness | PM + Tech Lead | Refine Downstream — <bc-slug>-adr.md |
```

**Guardrails do Momento 4:**
- Nunca inventar SLOs sem dado de baseline — registrar "a confirmar" é correto e honesto
- Nunca transitar para Readiness sem ao menos 1 SLI definido (mesmo que baseline seja "a coletar")
- Nunca remover acceptance criteria existentes — apenas adicionar ou refinar

---

## Momento 5 — BDD Feature completada (por OBC do BC)

Para cada OBC do BC, revisar e completar o arquivo `.feature` correspondente.

**Verificar e completar:**

1. **Happy path** — Scenario: Dado / Quando / Então cobrindo o fluxo principal
2. **Edge cases do OBC** — cenários derivados dos `acceptance_criteria` do Momento 4
3. **Cenários de erro** — comportamento esperado quando a pré-condição não é atendida
4. **Formato Gherkin válido** — Feature, Background (se necessário), Scenario e tags

**Exemplo de completude mínima:**

```gherkin
Feature: <Nome do OBC>

  Background:
    Given <estado inicial do sistema>

  Scenario: Happy path — <descrição>
    Given <pré-condição>
    When <ação do ator>
    Then <resultado observável>

  Scenario: Erro — <descrição do caso de erro>
    Given <pré-condição de erro>
    When <ação>
    Then <comportamento esperado de erro>

  @pending
  Scenario: Edge case — <descrição>
    Given …
```

**Guardrails do Momento 5:**
- Nunca apagar scenarios existentes — apenas adicionar ou refinar
- Scenarios `@pending` são válidos — sinalizam cobertura incompleta para o QA Gate
- O feature file deve estar sincronizado com os `acceptance_criteria` do OBC após o Momento 4

---

## Momento 6 — risks.md atualizado

Registrar ou atualizar os riscos identificados durante os Momentos 2–5.

**Arquivo:** `prodops/artifacts/risks/risks.md`

**Riscos a registrar obrigatoriamente quando identificados:**

| Categoria | Exemplos |
|---|---|
| Integração externa | Dependência de API de terceiro sem SLA documentado |
| Persistência | Migração de schema, acesso concorrente, volume não estimado |
| Segurança | Dados sensíveis (CNPJ, valores financeiros), autenticação, autorização |
| Fiscal/legal | Compliance com NF-e, CBS/IBS, LGPD |
| Dependência de BC externo | Port que depende de capability de outro BC ainda não entregue |

**Formato de entrada:**

```markdown
## RISCO-NNN — <título curto>

**Data:** YYYY-MM-DD
**BC:** <bc-slug>
**OBCs afetados:** OBC-NNN
**Severidade:** Alta / Média / Baixa
**Probabilidade:** Alta / Média / Baixa

**Descrição:** <o que pode dar errado>
**Impacto:** <consequência se ocorrer>
**Mitigação:** <ação planejada ou aceite de risco documentado>
**Owner:** <quem monitora>
**Status:** Aberto / Mitigado / Aceito
```

---

## Momento 7 — Reliability Plan (condicional)

Obrigatório — bloqueia o Readiness Gate — quando o OBC satisfaz ao menos uma das condições:

| Condição | Exemplos no Procurare |
|---|---|
| Movimentação financeira | AP automation, PO lifecycle, NF-e |
| Integração externa crítica | ERP sync, e-Signature, SEFAZ |
| Mudança de SLO | OBC com SLO mais restritivo que o BC atual |
| Risco Alto ou Crítico declarado no Momento 6 | — |
| Alteração de persistência ou segurança | Novo índice DynamoDB, novo Cognito group |

**Artefato:** `prodops/artifacts/plans/reliability/<obc-slug>.md`

```markdown
# Reliability Plan — <OBC slug>

**OBC:** OBC-NNN
**BC:** <bc-slug>
**Data:** YYYY-MM-DD

## SLO Targets

| SLI | Target | Período de medição | Baseline |
|---|---|---|---|
| <o que medir> | <target %> | <janela> | <atual ou "a coletar"> |

## Error Budget

Budget mensal: `(1 - SLO) × período`
Política de queima: <ação quando > 50% do budget for consumido em < 50% do período>

## Alertas

| Alerta | Threshold | Canal | Severidade |
|---|---|---|---|
| <nome> | <condição> | <Slack / PagerDuty> | <P1/P2/P3> |

## Runbook de Incidente

1. <passo de diagnóstico>
2. <passo de mitigação imediata>
3. <escalation se não resolvido em X min>

## Referências

→ [OBC](../../obcs/<obc-slug>.md)
→ [ADR do BC](../architecture/<bc-slug>-adr.md)
```

**Guardrails do Momento 7:**
- A ausência do Reliability Plan não bloqueia o `/refine` — bloqueia o Readiness Gate (`/diligence`) quando as condições se aplicam
- Nunca inventar SLO targets sem baseline — registrar "a coletar na primeira semana em produção" é correto
- Para OBCs sem as condições acima: registrar explicitamente "Reliability Plan não obrigatório" no OBC

---

## Saídas Esperadas

Após `/refine <bc-slug>`, o Bounded Context deve ter:

| Artefato | Path | Obrigatório |
|---|---|---|
| ADR | `prodops/artifacts/architecture/<bc-slug>-adr.md` | Sempre |
| UX Flows | `prodops/artifacts/product/ux/<bc-slug>-flows.md` | Sempre |
| OBCs em Readiness | `prodops/artifacts/obcs/<slug>.md` (Status: Readiness) | Por OBC |
| BDD Features completas | `prodops/artifacts/bdd/<slug>.feature` | Por OBC |
| `risks.md` atualizado | `prodops/artifacts/risks/risks.md` | Quando riscos identificados |
| Reliability Plans | `prodops/artifacts/plans/reliability/<slug>.md` | Quando condições se aplicam |

O BC está **pronto para o Readiness Gate** quando todos os artefatos acima existem. Invocar `/diligence diligence-sync <obc-id>` para verificar cada OBC individualmente.

---

## Guardrails

- Nunca criar OBCs novos — apenas refinar os existentes (Refining → Readiness).
- Nunca inventar SLOs sem baseline declarado — registrar "a confirmar" quando não há dado.
- Nunca pular o Momento 1 — os momentos seguintes dependem do contexto consolidado.
- A ordem dos momentos é obrigatória: Arch (M2) antes de UX (M3), UX antes de OBC Readiness (M4).
- Reliability Plan ausente não bloqueia este skill — bloqueia o Readiness Gate se as condições se aplicam.
- Nunca transitar OBC direto para `In Delivery` aqui — isso é responsabilidade do Bootstrap após o Readiness Gate.
- Nunca remover acceptance criteria, scenarios BDD ou riscos existentes — apenas adicionar ou refinar.
- Se um OBC do BC tiver sido restringido no `commitment-trail.md`, não processá-lo neste skill.

---

## Referências

→ [Lifecycle — estágios 3, 4, 5](../../framework/lifecycle.md)
→ [Princípios 3, 4, 6](../../framework/principles.md)
→ [commitment/SKILL.md — gate de entrada do Icebox](../commitment/SKILL.md)
→ [diligence/SKILL.md — gate de saída do Icebox](../diligence/SKILL.md)
→ [OBC — estados e transições](../../framework/obc.md)
→ [Work Item Schema](../../framework/execution-mapping/work-item-schema.md)
