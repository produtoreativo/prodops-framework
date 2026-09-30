# GitHub Workspace — Canonical Specification

This file is the Canonical Specification of the product's GitHub Workspace infrastructure. The `inspect` step of the `workspace-reconciliation` capability reads this file and compares it with the Actual Workspace (actual repository state via API) to detect Workspace Drift.

---

## Workspace Reconciliation Flow

The `workspace-reconciliation` capability reads this Canonical Specification and compares it with the Actual Workspace to detect Workspace Drift, reconcile divergences, and produce a Conformance Report.

```mermaid
flowchart TD
    START([Workspace Reconciliation]) --> INSPECT

    subgraph INSPECT["① Inspect — reading and Drift Report"]
        W1[Labels\ngh label list] --> W2
        W2[Milestones\ngh api milestones] --> W3
        W3{"Template\nProdOps — template\nexists in org?"}
        W3 -->|yes| W3B[Verify template\nfields]
        W3 -->|no| W3C[TEMPLATE MISSING]
        W3B --> W4
        W3C --> W4
        W4{"Managed project\nProdOps — repo\nexists in org?"}
        W4 -->|yes| W4B[Verify fields\nand views]
        W4 -->|no| W4C[MANAGED PROJECT\nMISSING]
        W4B --> W5
        W4C --> W5
        W5[Consolidated Drift Report]
    end

    INSPECT --> RECONCILE

    subgraph RECONCILE["② Reconcile — idempotent execution"]
        P1[Labels\ngh label create / edit]
        P1 --> P2

        P2{"Template exists?"}
        P2 -->|no| P2A[gh project create\nProdOps — template]
        P2A --> P2B
        P2 -->|yes, outdated| P2B
        P2B[Provision canonical fields\nin template\ngh project field-create]
        P2B --> P2C[gh project mark-template]
        P2 -->|yes, conformant| P3
        P2C --> P3

        P3{"Managed project\nexists?"}
        P3 -->|no| P3A["gh project copy\nProdOps — template\n→ inherits fields + views"]
        P3 -->|yes| P3B[Missing fields?\ngh project field-create]
        P3A --> P4
        P3B --> P4

        P4[Missing views?\nTry API → Issue if it fails]
        P4 --> P5
        P5[Missing milestones?\nIssue for Product Owner]
    end

    RECONCILE --> VERIFY

    subgraph VERIFY["③ Verify — Conformance Report"]
        V1[Re-verify template +\nmanaged project +\nlabels + milestones]
        V1 --> V2[Update sync manifest]
    end

    VERIFY --> DONE(["CONFORMANT\nPARTIAL\nNON-CONFORMANT"])
```

---

## Labels

### Family: operation

| Label | Color | Description |
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

### Family: artifact-type

| Label | Color | Description |
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

### Family: journey

| Label | Color | Description |
|---|---|---|
| `journey:discovery` | `#d93f0b` | ProdOps journey: Discovery |
| `journey:assessment` | `#d93f0b` | ProdOps journey: Assessment |
| `journey:delivery` | `#d93f0b` | ProdOps journey: Delivery |
| `journey:operation` | `#d93f0b` | ProdOps journey: Operation |
| `journey:diligence` | `#d93f0b` | ProdOps journey: Diligence |

---

## Milestones

Milestones represent product releases. Created by the Product Owner before each iteration.

| Milestone | Description |
|---|---|
| `v{major}.{minor}` | Product release — groups Issues of the corresponding iteration |

Milestones are managed by the Product Owner — they are not automatically provisioned by Diligence.

---

## GitHub Projects — Two managed projects

The framework maintains **two** GitHub Projects in the org, both identified by name (never by number):

| Role | Name | Scope |
|---|---|---|
| Canonical template | `ProdOps — template` | Org — source for `gh project copy` |
| Managed project | `ProdOps — <repo-name>` | Per repository — e.g.: `ProdOps — payments-api` |

**Manual projects are untouchable.** Any project whose name does not match one of these two patterns is ignored by Diligence — including projects created before the framework (e.g.: "Turma Junho 2026").

### ProdOps — template (org-level)

Project marked as template via `gh project mark-template`. Contains all canonical fields and canonical views. Serves as the source for `gh project copy` when creating managed projects for new repositories.

**When to create:** on the first execution of `workspace-reconciliation reconcile` if it does not yet exist.
**Creation:**
```bash
gh project create --owner <org> --title "ProdOps — template"
gh project edit <number> --owner <org> --visibility PUBLIC   # public by default
```
**After creation:** provision canonical fields via API, create views via REST, then `gh project mark-template`.
**Visibility:** PUBLIC by default. Change to PRIVATE only with an explicit directive.

### ProdOps — \<repo-name\> (per repository)

Project created via `gh project copy "ProdOps — template"`, inheriting fields and views automatically.

**When to create:** when the repository's managed project does not exist.
**Creation:**
```bash
gh project copy <template-number> \
  --source-owner <org> --target-owner <org> \
  --title "ProdOps — <repo-name>"
gh project edit <number> --owner <org> --visibility PUBLIC   # public by default
```
**Prerequisite:** the template must exist and be configured before copying.
**Visibility:** PUBLIC by default. `gh project copy` inherits the source visibility — verify and correct after copy if necessary.

**Link to repository (mandatory, not automatic):** `gh project copy` copies fields and views but **does not** link the project to the repository. Execute immediately after copy:
```bash
gh api graphql -f query='
  mutation {
    linkProjectV2ToRepository(input: {
      projectId: "<project-id>"
      repositoryId: "<repo-id>"
    }) { repository { nameWithOwner } }
  }'
```
Inspect verifies the link; Reconcile creates it automatically.

### Canonical Custom Fields (required in both projects)

14 custom fields — derived from the canonical state verified in `ProdOps — payments-api` on 2026-09-30.

#### Artifact identification fields

| Field | Type | Options / Format |
|---|---|---|
| `Artifact ID` | text | slug or relative path of the artifact |
| `Artifact Type` | single_select | OBC, Business Signal, Business Intent, BDD Feature, Architecture, Reliability Plan, Release Trail, Experiment, Risk Register |

#### Work classification fields

| Field | Type | Options |
|---|---|---|
| `Journey` | single_select | Discovery, Assessment, Delivery, Operation, Diligence |
| `Operation` | single_select | Review, Implement, Validate, Approve, Capture, Attach, Reconcile, Promote, Close, Create, Update |
| `Cycle` | single_select | CI Sync, CI Async |
| `Phase` | single_select | Capture, Attach, Promote, Close *(Diligence Sync)* · Scan, Flag, Repair *(Diligence Async)* · Inspect, Reconcile, Verify *(Workspace Reconciliation)* |
| `Mode` | single_select | Sync, Async, Manual |

#### OEM state fields

| Field | Type | Options |
|---|---|---|
| `oem-state` | single_select | PENDING, BOOTSTRAPPING, HACKING, SYNCING, FINISHING, SHIPPING, VALIDATING, PROMOTING, DONE, BLOCKED, REWORKING |
| `oem-last-event` | text | last event recorded by the OEM |

#### Diligence state fields

| Field | Type | Options |
|---|---|---|
| `diligence-status` | single_select | Pending, Sync In Progress, Captured, Attached, Blocked, Promoting, Promoted, Closing, Closed, Scanning, Flagged, Repairing, Repaired |
| `diligence-evidence` | single_select | Missing, Partial, Complete, Invalid |
| `runtime-sync` | single_select | Pending, In Sync, Drift, Repairing, Blocked |
| `diligence-block-reason` | text | reason for Diligence cycle blockage |
| `diligence-finding-id` | text | associated Finding ID |

> **Fields removed from previous spec:** `Execution Mode`, `Owner`, `Release`, `Evidence Required` — absent from the canonical derived from `payments-api`. Do not provision these fields.

### Canonical View (required in both projects)

1 view, derived from the canonical state verified in `ProdOps — payments-api` on 2026-09-30.

| View | Layout | Creation |
|---|---|---|
| `01 — Delivery Timeline` | BOARD_LAYOUT | inherited via `gh project copy` |

The view is inherited automatically by copying the template — no separate creation required.

> **Known Platform Limitation — `group_by`:** GitHub API does not support configuring `group_by` in views (REST returns 404, GraphQL without existing mutation). Configure via UI when needed. See Principle 11 — [Automation First](automation-first.en.md).
> **Known Platform Limitation — DELETE views:** `DELETE /orgs/{org}/projectsV2/{N}/views/{V}` returns 404 via REST. Use GraphQL: `deleteProjectV2View(input: { viewId: "..." }) { __typename }`.

> **Historical note:** earlier versions of this specification declared 5 canonical views (All Work Items, By Operation, Business Signals, Delivery, Diligence) and 8 custom fields. That model was superseded by adoption of the `payments-api` canonical behavior on 2026-09-30 — 14 fields and 1 BOARD view as the single entry point.

---

## References

→ [Work Item Schema](execution-mapping/work-item-schema.en.md) — fields, enums, and canonical title
→ [Workspace Reconciliation capability](journeys/diligence/workspace-reconciliation.md)
→ GitHub Sync Manifest: `prodops/artifacts/trails/github-sync-manifest.md` (created by the product)
