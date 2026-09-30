# GitHub Workspace — Canonical Specification

Este arquivo é a Canonical Specification da infraestrutura do GitHub Workspace do produto. O step `inspect` da capability `workspace-reconciliation` lê este arquivo e compara com o Actual Workspace (estado real do repositório via API) para detectar Workspace Drift.

---

## Fluxo de Workspace Reconciliation

A capability `workspace-reconciliation` lê esta Canonical Specification e a compara com o Actual Workspace para detectar Workspace Drift, reconciliar divergências e produzir um Conformance Report.

```mermaid
flowchart TD
    START([Workspace Reconciliation]) --> INSPECT

    subgraph INSPECT["① Inspect — leitura e Drift Report"]
        W1[Labels\ngh label list] --> W2
        W2[Milestones\ngh api milestones] --> W3
        W3{"Template\nProdOps — template\nexiste na org?"}
        W3 -->|sim| W3B[Verificar campos\ndo template]
        W3 -->|não| W3C[TEMPLATE AUSENTE]
        W3B --> W4
        W3C --> W4
        W4{"Projeto gerenciado\nProdOps — repo\nexiste na org?"}
        W4 -->|sim| W4B[Verificar campos\ne views]
        W4 -->|não| W4C[PROJETO GERENCIADO\nAUSENTE]
        W4B --> W5
        W4C --> W5
        W5[Drift Report consolidado]
    end

    INSPECT --> RECONCILE

    subgraph RECONCILE["② Reconcile — execução idempotente"]
        P1[Labels\ngh label create / edit]
        P1 --> P2

        P2{"Template existe?"}
        P2 -->|não| P2A[gh project create\nProdOps — template]
        P2A --> P2B
        P2 -->|sim, desatualizado| P2B
        P2B[Provisionar campos\ncanônicos no template\ngh project field-create]
        P2B --> P2C[gh project mark-template]
        P2 -->|sim, conforme| P3
        P2C --> P3

        P3{"Projeto gerenciado\nexiste?"}
        P3 -->|não| P3A["gh project copy\nProdOps — template\n→ herda campos + views"]
        P3 -->|sim| P3B[Campos ausentes?\ngh project field-create]
        P3A --> P4
        P3B --> P4

        P4[Views ausentes?\nTentar API → Issue se falhar]
        P4 --> P5
        P5[Milestones ausentes?\nIssue para Product Owner]
    end

    RECONCILE --> VERIFY

    subgraph VERIFY["③ Verify — Conformance Report"]
        V1[Re-verificar template +\nprojeto gerenciado +\nlabels + milestones]
        V1 --> V2[Atualizar sync manifest]
    end

    VERIFY --> DONE(["CONFORME\nPARCIAL\nNÃO CONFORME"])
```

---

## Labels

### Família: operation

| Label | Cor | Descrição |
|---|---|---|
| `operation:capture` | `#0075ca` | ProdOps operation: Capture |
| `operation:create` | `#0075ca` | ProdOps operation: Create |
| `operation:define` | `#0075ca` | ProdOps operation: Define |
| `operation:refine` | `#0075ca` | ProdOps operation: Refine |
| `operation:update` | `#0075ca` | ProdOps operation: Update |
| `operation:prototype` | `#0075ca` | ProdOps operation: Prototype |
| `operation:review` | `#0075ca` | ProdOps operation: Review |
| `operation:approve` | `#0075ca` | ProdOps operation: Approve |
| `operation:validate` | `#0075ca` | ProdOps operation: Validate |
| `operation:split` | `#0075ca` | ProdOps operation: Split |
| `operation:merge` | `#0075ca` | ProdOps operation: Merge |
| `operation:promote` | `#0075ca` | ProdOps operation: Promote |
| `operation:implement` | `#0075ca` | ProdOps operation: Implement |
| `operation:experiment` | `#0075ca` | ProdOps operation: Experiment |
| `operation:release` | `#0075ca` | ProdOps operation: Release |
| `operation:archive` | `#0075ca` | ProdOps operation: Archive |
| `operation:deprecate` | `#0075ca` | ProdOps operation: Deprecate |
| `operation:discard` | `#0075ca` | ProdOps operation: Discard |
| `operation:cancel` | `#0075ca` | ProdOps operation: Cancel |
| `operation:provision` | `#0075ca` | ProdOps operation: Provision |

### Família: artifact-type

| Label | Cor | Descrição |
|---|---|---|
| `artifact-type:business-signal` | `#e4e669` | ProdOps artifact type: Business Signal |
| `artifact-type:business-intent` | `#e4e669` | ProdOps artifact type: Business Intent |
| `artifact-type:global-obc` | `#e4e669` | ProdOps artifact type: Global OBC |
| `artifact-type:local-obc` | `#e4e669` | ProdOps artifact type: Local OBC |
| `artifact-type:bdd-feature` | `#e4e669` | ProdOps artifact type: BDD Feature |
| `artifact-type:architecture` | `#e4e669` | ProdOps artifact type: Architecture |
| `artifact-type:iteration-plan` | `#e4e669` | ProdOps artifact type: Iteration Plan |
| `artifact-type:reliability-plan` | `#e4e669` | ProdOps artifact type: Reliability Plan |
| `artifact-type:release-trail` | `#e4e669` | ProdOps artifact type: Release Trail |
| `artifact-type:experiment` | `#e4e669` | ProdOps artifact type: Experiment |
| `artifact-type:evidence` | `#e4e669` | ProdOps artifact type: Evidence |
| `artifact-type:risk-register` | `#e4e669` | ProdOps artifact type: Risk Register |
| `artifact-type:context-capsule` | `#e4e669` | ProdOps artifact type: Context Capsule |

### Família: journey

| Label | Cor | Descrição |
|---|---|---|
| `journey:discovery` | `#d93f0b` | ProdOps journey: Discovery |
| `journey:assessment` | `#d93f0b` | ProdOps journey: Assessment |
| `journey:delivery` | `#d93f0b` | ProdOps journey: Delivery |
| `journey:operation` | `#d93f0b` | ProdOps journey: Operation |
| `journey:diligence` | `#d93f0b` | ProdOps journey: Diligence |

---

## Milestones

Milestones representam releases do produto. Criados pelo Product Owner antes de cada iteração.

| Milestone | Descrição |
|---|---|
| `v{major}.{minor}` | Release do produto — agrupa Issues da iteração correspondente |

Milestones são gerenciados pelo Product Owner — não são provisionados automaticamente pelo Diligence.

---

## GitHub Projects — Dois projetos gerenciados

O framework mantém **dois** GitHub Projects na org, ambos identificados por nome (nunca por número):

| Papel | Nome | Escopo |
|---|---|---|
| Template canônico | `ProdOps — template` | Org — source para `gh project copy` |
| Projeto gerenciado | `ProdOps — <repo-name>` | Por repositório — ex: `ProdOps — payments-api` |

**Projetos manuais são intocáveis.** Qualquer projeto cujo nome não corresponda a um desses dois padrões é ignorado pelo Diligence — inclusive projetos criados antes do framework (ex: "Turma Junho 2026").

### ProdOps — template (org-level)

Projeto marcado como template via `gh project mark-template`. Contém todos os campos canônicos e as views canônicas. Serve como source de `gh project copy` ao criar projetos gerenciados para novos repositórios.

**Quando criar:** na primeira execução de `workspace-reconciliation reconcile` se ainda não existir.
**Criação:**
```bash
gh project create --owner <org> --title "ProdOps — template"
gh project edit <number> --owner <org> --visibility PUBLIC   # público por default
```
**Após criar:** provisionar campos canônicos via API, criar views via REST, então `gh project mark-template`.
**Visibilidade:** PUBLIC por default. Alterar para PRIVATE somente com diretiva explícita.

### ProdOps — \<repo-name\> (por repositório)

Projeto criado via `gh project copy "ProdOps — template"`, herdando campos e views automaticamente.

**Quando criar:** quando o projeto gerenciado do repositório não existir.
**Criação:**
```bash
gh project copy <template-number> \
  --source-owner <org> --target-owner <org> \
  --title "ProdOps — <repo-name>"
gh project edit <number> --owner <org> --visibility PUBLIC   # público por default
```
**Pré-requisito:** o template deve existir e estar configurado antes da cópia.
**Visibilidade:** PUBLIC por default. `gh project copy` herda a visibilidade do source — verificar e corrigir após cópia se necessário.

**Vínculo com o repositório (obrigatório, não automático):** `gh project copy` copia campos e views mas **não** vincula o projeto ao repositório. Executar imediatamente após a cópia:
```bash
gh api graphql -f query='
  mutation {
    linkProjectV2ToRepository(input: {
      projectId: "<project-id>"
      repositoryId: "<repo-id>"
    }) { repository { nameWithOwner } }
  }'
```
O Inspect verifica o vínculo; o Reconcile o cria automaticamente.

### Custom Fields canônicos (obrigatórios em ambos os projetos)

14 campos customizados — derivados do estado canônico verificado em `ProdOps — payments-api` em 2026-09-30.

#### Campos de identificação de artefato

| Campo | Tipo | Opções / Formato |
|---|---|---|
| `Artifact ID` | text | slug ou path relativo do artefato |
| `Artifact Type` | single_select | OBC, Business Signal, Business Intent, BDD Feature, Architecture, Reliability Plan, Release Trail, Experiment, Risk Register |

#### Campos de classificação de trabalho

| Campo | Tipo | Opções |
|---|---|---|
| `Journey` | single_select | Discovery, Assessment, Delivery, Operation, Diligence |
| `Operation` | single_select | Review, Implement, Validate, Approve, Capture, Attach, Reconcile, Promote, Close, Create, Update |
| `Cycle` | single_select | CI Sync, CI Async |
| `Phase` | single_select | Capture, Attach, Promote, Close *(Diligence Sync)* · Scan, Flag, Repair *(Diligence Async)* · Inspect, Reconcile, Verify *(Workspace Reconciliation)* |
| `Mode` | single_select | Sync, Async, Manual |

#### Campos de estado OEM

| Campo | Tipo | Opções |
|---|---|---|
| `oem-state` | single_select | PENDING, BOOTSTRAPPING, HACKING, SYNCING, FINISHING, SHIPPING, VALIDATING, PROMOTING, DONE, BLOCKED, REWORKING |
| `oem-last-event` | text | último evento registrado pelo OEM |

#### Campos de estado Diligence

| Campo | Tipo | Opções |
|---|---|---|
| `diligence-status` | single_select | Pending, Sync In Progress, Captured, Attached, Blocked, Promoting, Promoted, Closing, Closed, Scanning, Flagged, Repairing, Repaired |
| `diligence-evidence` | single_select | Missing, Partial, Complete, Invalid |
| `runtime-sync` | single_select | Pending, In Sync, Drift, Repairing, Blocked |
| `diligence-block-reason` | text | razão do bloqueio do ciclo Diligence |
| `diligence-finding-id` | text | ID do Finding associado |

> **Campos removidos em relação à spec anterior:** `Execution Mode`, `Owner`, `Release`, `Evidence Required` — ausentes no canônico derivado de `payments-api`. Não provisionar nesses projetos.

### View canônica (obrigatória em ambos os projetos)

1 view, derivada do estado canônico verificado em `ProdOps — payments-api` em 2026-09-30.

| View | Layout | Criação |
|---|---|---|
| `01 — Delivery Timeline` | BOARD_LAYOUT | herdada via `gh project copy` |

A view é herdada automaticamente pela cópia do template — não requer criação separada.

> **Known Platform Limitation — `group_by`:** GitHub API não suporta configuração de `group_by` em views (REST retorna 404, GraphQL sem mutation existente). Configurar via UI quando necessário. Ver Princípio 8 — [Automation First](automation-first.md).
> **Known Platform Limitation — DELETE de views:** `DELETE /orgs/{org}/projectsV2/{N}/views/{V}` retorna 404 via REST. Usar GraphQL: `deleteProjectV2View(input: { viewId: "..." }) { __typename }`.

> **Nota histórica:** versões anteriores desta especificação declaravam 5 views canônicas (All Work Items, By Operation, Business Signals, Delivery, Diligence) e 8 campos custom. Esse modelo foi supersedido pela adoção do comportamento canônico de `payments-api` em 2026-09-30 — 14 campos e 1 view BOARD como ponto de entrada único.

---

## Referências

→ [Work Item Schema](execution-mapping/work-item-schema.md) — campos, enums e título canônico
→ [Workspace Reconciliation capability](journeys/diligence/workspace-reconciliation.md)
→ GitHub Sync Manifest: `prodops/artifacts/trails/github-sync-manifest.md` (criado pelo produto)
