[Português](project-mapping.md)

# From Project to ProdOps — Mapping Guide

This document answers a practical question: **"I have a project — a collection of features with scope, timeline, and teams involved. How do I express that in the ProdOps Framework?"**

The framework has no "project" entity. What projects do — grouping work, coordinating teams, tracking progress, communicating horizon — is covered by specific concepts, each with a well-defined responsibility.

---

## Mapping: project concepts → ProdOps

| Project concept | ProdOps equivalent | Where it lives | Who manages it |
|---|---|---|---|
| Project / Initiative | Business Intent + Global OBC | Business Intent Backlog (BIB) | Portfolio PM |
| Project scope | Global OBC (4 dimensions: Business, Enterprise, Team, Technology) | `prodops-portfolio` | Portfolio PM + Tech Leads |
| Feature / Deliverable | Product Intent + Local OBC | Each product's Product Backlog | Product Owner |
| Scope split across teams | OBC Partitioning | Global OBC → N Local OBCs | Portfolio PM + product Tech Leads |
| Milestone | Platform Release (BIB view) | BIB | Portfolio |
| Roadmap | Roadmap (BIB view) | BIB | Portfolio |
| Sprint / Delivery cycle | Iteration | `prodops/artifacts/plans/iteration-plan.md` | Product Owner |
| Project status | Aggregated state of linked OBCs | Local OBCs per product | Product Owner per product |
| Acceptance criteria | BDD + OBC (Observability and Criteria sections) | Local OBC | Trio (PM + Tech Lead + Author) |
| Approval to deliver | CommitmentGate (Trio) + Readiness Gate | upstream-trail.md | Trio |
| Delivered / Done | OBC Released + Outcome verified | Local OBC + Release Trail | Product Owner + PRE |
| Lessons learned | Postmortem / Continuous Assessment | OBC (Continuous Refinement) | Tech Lead + PM |
| Dependencies between features | `Technical Dependencies` section in Local OBC | Local OBC | Tech Lead |
| Project risk | `prodops/artifacts/risks/risks.md` | Product Repository | Tech Lead |

---

## How to build a "project" in ProdOps

### Step 1 — Register the initiative as a Business Intent

The initiative enters as a **Business Signal** in the Portfolio Tracking List. When the Portfolio PM recognizes it as strategic, it is promoted to a **Business Intent** in the **Business Intent Backlog (BIB)**.

At this point, the **Global OBC** is born as Draft — it represents the complete initiative: expected Business Outcome, success metrics, business acceptance criteria, SLOs, platform dependencies.

```
Portfolio Tracking List
  ↓ recognized as strategic
Business Intent Backlog
  → Global OBC Draft created
```

**Artifact:** `prodops-portfolio/business-intents/<slug>.md` (portfolio repository).

---

### Step 2 — Decompose scope via OBC Partitioning

The Portfolio PM, together with the Tech Leads of the involved products, runs **OBC Partitioning**: identifies which products/repositories are needed and decomposes the Global OBC into **Local OBCs** — one per product.

Each Local OBC:
- references the Global OBC (never duplicates its strategic content)
- specializes acceptance criteria for the product's bounded context
- has an independent lifecycle and gates

The Global OBC maintains a traceability table with the resulting Local OBCs.

```
Global OBC
  ├─ Local OBC — payments-api (product A)
  ├─ Local OBC — notification-service (product B)
  └─ Local OBC — dashboard-bff (product C)
```

**Result:** each product has its own contract, without an intermediary "project manager" controlling tasks.

---

### Step 3 — Each product runs its lifecycle independently

Each Local OBC follows the canonical lifecycle in its Product Repository:

```
Draft → CommitmentGate → Refining → Readiness Gate → In Delivery → Released
```

Gates are run per product — each team decides when it is ready to commit and when it is ready to deliver. There is no forced sprint synchronization across products.

---

### Step 4 — Coordinate joint delivery via Platform Release

If the initiative requires multiple products to be ready before a public launch, the Portfolio creates a **Platform Release** — a BIB view that groups the Local OBCs of the initiative.

The Platform Release marks the point where the local releases of each product compose a coherent platform delivery. It is not a separate backlog — it is a coordination lens.

```
Platform Release v3.0
  ├─ payments-api: Local OBC Released ✅
  ├─ notification-service: Local OBC In Delivery 🔄
  └─ dashboard-bff: Local OBC Readiness 🔄
```

---

## How to track progress

Progress on an initiative is not measured by % of completed tasks — it is measured by the **aggregated state of linked OBCs**.

### Progress view by OBC

| Local OBC | Product | State | Current gate | Next step |
|---|---|---|---|---|
| `split-payment-payments-api` | payments-api | In Delivery | — | Ship + Validate |
| `split-payment-notif` | notification-service | Readiness | Readiness Gate ✅ | Enter iteration |
| `split-payment-bff` | dashboard-bff | Refining | — | Readiness Gate |

### Advancement signals (not task progress)

- **Draft → Refining:** CommitmentGate executed — the team assumed the commitment.
- **Refining → Readiness:** Readiness Gate approved — the team is ready to deliver.
- **Readiness → In Delivery:** Bootstrap.Started — delivery underway.
- **In Delivery → Released:** Ship + Promote complete, Evidence Package recorded.
- **Released + Outcome verified:** Outcome confirmed or follow-up Business Signal generated.

### Flow indicators

See [`dora-metrics.en.md`](dora-metrics.en.md) for per-product flow metrics:
- **TTE (Time to Evidence):** time from Business Signal to Evidence Package ready.
- **Decision Latency:** time between Evidence ready and CommitmentGate held.
- **Discovery WIP:** number of Upstream experiments running in parallel per product.

---

## How to link the concepts

### Global OBC → Local OBCs traceability

The Global OBC maintains a traceability section:

```markdown
## Partitioning

| Product | Repository | Local OBC | State |
|---|---|---|---|
| Payments API | payments-api | `split-payment-payments-api.md` | In Delivery |
| Notification | notification-service | `split-payment-notif.md` | Readiness |
| Dashboard BFF | dashboard-bff | `split-payment-bff.md` | Refining |
```

### Local OBC → Global OBC

Each Local OBC references the Global OBC in the origin section:

```markdown
## Origin

- **Global OBC:** `prodops-portfolio/business-intents/split-payment.md`
- **OBC Partitioning:** 2026-09-15 — Portfolio PM + Tech Leads from 3 products
```

### Work Items → OBC

Each delivery GitHub Issue references the Local OBC in the `Linked OBC` field of the Work Item Schema. See [`execution-mapping/work-item-schema.md`](execution-mapping/work-item-schema.md).

### Platform Release → Business Intents

The Platform Release is a BIB view — its items are the Local OBCs themselves. No additional structure is needed: the BIB state already expresses the release state.

---

## What ProdOps eliminates from the project model

| Common project practice | Why ProdOps doesn't use it |
|---|---|
| Project manager centralizing status | Each product governs its OBC; Portfolio observes the BIB |
| % task completion | OBC state is the truth — not task counts |
| Forced sprint synchronization across teams | Each product has its own cycle; coordination is by OBC |
| Silent scope creep | Any scope change requires OBC update + re-gate |
| Done = code in production | Done = OBC Released + Outcome verified |
| Separate requirements document from contract | OBC is both the contract and the requirement — one artifact |

---

## References

→ [Glossary — Global OBC, Local OBC, OBC Partitioning, Platform Release](glossary.en.md)
→ [Lifecycle](lifecycle.en.md)
→ [Backlogs](backlogs.en.md)
→ [OBC](obc.en.md)
→ [Artifact Governance](artifact-governance.en.md)
→ [DORA Metrics](dora-metrics.en.md)
→ [Work Item Schema](execution-mapping/work-item-schema.md)
