[English](project-mapping.en.md)

# De Projeto para ProdOps — Guia de Mapeamento

Este documento responde a uma pergunta prática: **"Tenho um projeto — uma coleção de funcionalidades com escopo, prazo e times envolvidos. Como expresso isso no ProdOps Framework?"**

O framework não tem a entidade "projeto". O que projetos fazem — agrupar trabalho, coordenar times, acompanhar progresso, comunicar horizonte — é coberto por conceitos específicos, cada um com responsabilidade bem definida.

---

## DE-PARA: conceitos de projeto → ProdOps

| Conceito de projeto | Equivalente ProdOps | Onde vive | Quem gerencia |
|---|---|---|---|
| Projeto / Iniciativa | Business Intent + Global OBC | Business Intent Backlog (BIB) | Portfolio PM |
| Escopo do projeto | Global OBC (4 dimensões: Business, Enterprise, Team, Technology) | `prodops-portfolio` | Portfolio PM + Tech Leads |
| Feature / Entregável | Product Intent + Local OBC | Product Backlog de cada produto | Product Owner |
| Divisão de escopo entre times | OBC Partitioning | Global OBC → N Local OBCs | Portfolio PM + Tech Leads dos produtos |
| Milestone / Marco | Platform Release (view do BIB) | BIB | Portfolio |
| Roadmap | Roadmap (view do BIB) | BIB | Portfolio |
| Sprint / Ciclo de entrega | Iteração | `prodops/artifacts/plans/iteration-plan.md` | Product Owner |
| Status do projeto | Estado agregado dos OBCs vinculados | Local OBCs por produto | Product Owner por produto |
| Critério de aceite | BDD + OBC (seção de Observabilidade e Critérios) | Local OBC | Trio (PM + Tech Lead + Autor) |
| Aprovação para entregar | CommitmentGate (Trio) + Readiness Gate | upstream-trail.md | Trio |
| Entregue / Concluído | OBC Released + Outcome verificado | Local OBC + Release Trail | Product Owner + PRE |
| Lições aprendidas | Postmortem / Continuous Assessment | OBC (Refinamento Contínuo) | Tech Lead + PM |
| Dependências entre features | Seção `Dependências Técnicas` no Local OBC | Local OBC | Tech Lead |
| Risco do projeto | `prodops/artifacts/risks/risks.md` | Product Repository | Tech Lead |

---

## Como construir um "projeto" no ProdOps

### Passo 1 — Registrar a iniciativa como Business Intent

A iniciativa entra como **Business Signal** na Portfolio Tracking List. Quando o Portfolio PM a reconhece como estratégica, ela é promovida a **Business Intent** no **Business Intent Backlog (BIB)**.

Nesse momento, o **Global OBC** nasce como Draft — ele representa a iniciativa completa: Business Outcome esperado, métricas de sucesso, critérios de aceite de negócio, SLOs, dependências de plataforma.

```
Portfolio Tracking List
  ↓ reconhecido como estratégico
Business Intent Backlog
  → Global OBC Draft criado
```

**Artefato:** `prodops-portfolio/business-intents/<slug>.md` (repositório de portfólio).

---

### Passo 2 — Decompor o escopo via OBC Partitioning

O Portfolio PM, junto com os Tech Leads dos produtos envolvidos, executa o **OBC Partitioning**: identifica quais produtos/repositórios são necessários e decompõe o Global OBC em **Local OBCs** — um por produto.

Cada Local OBC:
- referencia o Global OBC (nunca duplica seu conteúdo estratégico)
- especializa os critérios de aceite para o bounded context do produto
- tem lifecycle e gates independentes

O Global OBC mantém uma tabela de rastreabilidade com os Local OBCs resultantes.

```
Global OBC
  ├─ Local OBC — payments-api (produto A)
  ├─ Local OBC — notification-service (produto B)
  └─ Local OBC — dashboard-bff (produto C)
```

**Resultado:** cada produto tem seu próprio contrato, sem um "gerente de projeto" intermediário controlando tasks.

---

### Passo 3 — Cada produto executa seu lifecycle independentemente

Cada Local OBC segue o lifecycle canônico no seu Product Repository:

```
Draft → CommitmentGate → Refining → Readiness Gate → In Delivery → Released
```

Os gates são executados por produto — cada time decide quando está pronto para commitar e quando está pronto para entregar. Não existe sincronização forçada de sprints entre produtos.

---

### Passo 4 — Coordenar a entrega conjunta via Platform Release

Se a iniciativa exige que múltiplos produtos estejam prontos antes de um lançamento público, o Portfolio cria uma **Platform Release** — uma view sobre o BIB que agrupa os Local OBCs da iniciativa.

A Platform Release marca o ponto onde os releases locais de cada produto compõem uma entrega de plataforma coerente. Não é um backlog separado — é uma lente de coordenação.

```
Platform Release v3.0
  ├─ payments-api: Local OBC Released ✅
  ├─ notification-service: Local OBC In Delivery 🔄
  └─ dashboard-bff: Local OBC Readiness 🔄
```

---

## Como acompanhar o progresso

O progresso de uma iniciativa não é medido por % de tasks concluídas — é medido pelo **estado agregado dos OBCs vinculados**.

### Visão de progresso por OBC

| Local OBC | Produto | Estado | Gate atual | Próximo passo |
|---|---|---|---|---|
| `split-payment-payments-api` | payments-api | In Delivery | — | Ship + Validate |
| `split-payment-notif` | notification-service | Readiness | Readiness Gate ✅ | Entrar na iteração |
| `split-payment-bff` | dashboard-bff | Refining | — | Readiness Gate |

### Sinais de avanço (não de progresso de tarefa)

- **Draft → Refining:** CommitmentGate executado — o time assumiu o compromisso.
- **Refining → Readiness:** Readiness Gate aprovado — o time está pronto para entregar.
- **Readiness → In Delivery:** Bootstrap.Started — entrega iniciada.
- **In Delivery → Released:** Ship + Promote concluídos, Evidence Package registrado.
- **Released + Outcome verificado:** Outcome confirmado ou Business Signal de follow-up gerado.

### Indicadores de fluxo

Consultar [`dora-metrics.md`](dora-metrics.md) para as métricas de fluxo por produto:
- **TTE (Time to Evidence):** tempo do Business Signal até Evidence Package pronto.
- **Decision Latency:** tempo entre Evidence pronto e CommitmentGate realizado.
- **Discovery WIP:** quantidade de experimentos Upstream em paralelo por produto.

---

## Como vincular os conceitos

### Rastreabilidade Global OBC → Local OBCs

O Global OBC mantém uma seção de rastreabilidade:

```markdown
## Particionamento

| Produto | Repositório | Local OBC | Estado |
|---|---|---|---|
| Payments API | payments-api | `split-payment-payments-api.md` | In Delivery |
| Notification | notification-service | `split-payment-notif.md` | Readiness |
| Dashboard BFF | dashboard-bff | `split-payment-bff.md` | Refining |
```

### Local OBC → Global OBC

Cada Local OBC referencia o Global OBC na seção de origem:

```markdown
## Origem

- **Global OBC:** `prodops-portfolio/business-intents/split-payment.md`
- **OBC Partitioning:** 2026-09-15 — Portfolio PM + Tech Leads de 3 produtos
```

### Work Items → OBC

Cada GitHub Issue de entrega referencia o Local OBC no campo `Linked OBC` do Work Item Schema. Ver [`execution-mapping/work-item-schema.md`](execution-mapping/work-item-schema.md).

### Platform Release → Business Intents

A Platform Release é uma view sobre o BIB — seus itens são os próprios Local OBCs. Nenhuma estrutura adicional é necessária: o estado do BIB já expressa o estado da release.

---

## O que o ProdOps elimina do modelo de projeto

| Prática comum em projetos | Por que o ProdOps não usa |
|---|---|
| Gerente de projeto centralizando status | Cada produto governa seu OBC; o Portfolio observa o BIB |
| % de conclusão de tasks | Estado do OBC é a verdade — não contagem de tasks |
| Sincronização forçada de sprints entre times | Cada produto tem seu ciclo; coordenação é por OBC |
| Scope creep silencioso | Qualquer mudança de escopo exige atualização do OBC + re-gate |
| Entregue = código em produção | Entregue = OBC Released + Outcome verificado |
| Documento de requisitos separado do contrato | OBC é o contrato e o requisito — um só artefato |

---

## Referências

→ [Glossário — Global OBC, Local OBC, OBC Partitioning, Platform Release](glossary.md)
→ [Lifecycle](lifecycle.md)
→ [Backlogs](backlogs.md)
→ [OBC](obc.md)
→ [Artifact Governance](artifact-governance.md)
→ [DORA Metrics](dora-metrics.md)
→ [Work Item Schema](execution-mapping/work-item-schema.md)
