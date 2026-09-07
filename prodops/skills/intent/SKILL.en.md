[Português](SKILL.md)

---
name: intent
description: Formalizes business and product intents. Use to identify and register Business Signals, elevate a signal to Business Intent, create or partition an OBC, obtain Owner Approval for a local flow, and ensure the Product Backlog receives the correct Product Intent before any exploration or commitment.
---

# Intent Skill

## Purpose

Use this skill to formalize intents — from signal to Product Backlog — without advancing to exploration or delivery commitment.

The Intent Skill operates exclusively over the first two stages of the canonical lifecycle: **Business Signal** and **Business Intent / Product Intent**. It does not include exploration, CommitmentGate, or Delivery.

→ For Upstream exploration, use `/upstream`.
→ For CommitmentGate and Upstream → Downstream transition, use `/commitment`.
→ For current product context, use `/product-context`.

---

## When to Use

- A market, customer, or operational signal needs to be registered
- A Business Intent needs to be created or structured
- A Global OBC needs to be partitioned into Local OBCs per product
- A local flow requires Owner Approval to directly create a Local OBC
- The Product Backlog received an item whose origins and references need to be established

---

## Required Reading

Before starting, read:

- `prodops/framework/lifecycle.en.md` — Business Signal and Business Intent / Product Intent stages
- `prodops/framework/glossary.en.md` — terms Business Signal, Business Intent, Product Intent, Global OBC, Local OBC
- `prodops/framework/obc.md` — OBC two levels, partitioning, global vs. local flow
- `prodops/framework/backlogs.md` — backlog hierarchy

---

## Formalization Flow

### 1. Business Signal → Business Intent

**Inputs:** any observation — benchmark, customer complaint, market data, internal proposal, regulatory decision.

**Actions:**
1. Register the signal in the Product Tracking List or Portfolio Tracking List with: description, origin, date, strategic relevance.
2. Assess whether the signal is strategically relevant to pursue.
3. If relevant: elevate to **Business Intent** — document with objective, expected value, and initial hypotheses.
4. If irrelevant or premature: register as discarded with justification and date.

**Produced artifact:** Tracking List entry + Business Intent document (when the signal is elevated).

---

### 2. Business Intent → OBC Draft (global flow)

When the Business Intent comes from the Portfolio (BIB):

1. Confirm that a Global OBC has been created in the platform's portfolio repository.
2. Identify all products involved in delivering the Business Intent.
3. Execute **OBC Partitioning**: for each product, create a Local OBC in draft referencing the Global OBC.
4. Update the traceability table in the Global OBC with the created Local OBCs.

**Local OBC created at:** `prodops/artifacts/obcs/<slug>.md` (state: Draft)

---

### 3. Business Intent → OBC Draft (local flow / Owner Approval)

When the Business Intent does not come from the Portfolio:

1. Confirm the Business Intent is registered in the Product Tracking List.
2. Obtain Product Owner approval to start work locally (**Owner Approval**).
3. Create the Local OBC Draft referencing the Business Intent and the Product Tracking Item that justified the Owner Approval.

**Local OBC created at:** `prodops/artifacts/obcs/<slug>.md` (state: Draft)

---

### 4. OBC Draft → Product Backlog (Product Intent)

**Product Intent** is the formalization of a Business Intent at the product level — the moment a Local OBC Draft enters the Product Backlog.

1. Verify the Local OBC Draft exists and correctly references its origin.
2. Add the item to the Product Backlog (Icebox view) with Draft state.
3. Confirm traceability is established: which Business Intent / Global OBC this Product Intent came from.

**Stage exit condition:** Product Intent accepted in the Product Backlog → ready for Context Discovery (Upstream) or for direct CommitmentGate (when context is sufficient).

---

## Operating Rules

1. Never create a Local OBC without a reference to a Business Intent or Global OBC.
2. Never create a Local OBC on behalf of the product without Owner Approval (local flow) or Partitioning (global flow).
3. Do not advance to CommitmentGate in this skill — that belongs to `/commitment`.
4. Do not invent KPIs or acceptance criteria — record only what the stakeholder declared.
5. Do not confuse Business Intent (strategic entity, can span multiple products) with Product Intent (product entity, belongs to exactly one Product Backlog).
6. Use the canonical slug: `<NNN-short-slug>` for Local OBCs.

---

## Expected Outputs

- Product Tracking List or Portfolio Tracking List entry (Business Signal)
- Business Intent document (when the signal is elevated)
- Local OBC Draft at `prodops/artifacts/obcs/<slug>.md` in Draft state
- Documented traceability: Global OBC (global flow) or Business Intent + Tracking Item (local flow)
- Product Backlog updated with Product Intent in the Icebox

---

## Guardrails

- Never create an OBC Draft without declaring its origin (Global OBC or Business Intent + Tracking Item).
- Never elevate a Business Signal directly to an OBC skipping Business Intent — the OBC is the contract of the Intent, not of the signal.
- Never create Work Items in GitHub without declaring `artifact_type`, `artifact_id`, `operation`, and `journey`.
- Never register a delivery commitment in this skill — commitment is the responsibility of the CommitmentGate.

---

## References

→ [Lifecycle](../../framework/lifecycle.en.md)
→ [Glossary](../../framework/glossary.en.md)
→ [OBC](../../framework/obc.md)
→ [Backlogs](../../framework/backlogs.md)
→ [Discovery Journey](../../framework/journeys/discovery/README.en.md)
→ [Commitment Skill](../commitment/SKILL.en.md)
→ [Work Item Schema](../../framework/execution-mapping/work-item-schema.md)
