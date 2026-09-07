[Português](SKILL.md)

---
name: product-context
description: Reads and presents the current state of the product for a specific capability or OBC. Use to build context before any execution — reads active OBC, backlog, iteration plan, experiment trail, and reliability artifacts without modifying anything.
---

# Product Context Skill

## Purpose

Use this skill to obtain a consolidated, verifiable view of the current state of a capability before any execution. It does not modify artifacts — it only reads, consolidates, and presents them.

Product Context is the mandatory starting point for any execution that needs context before deciding which action to take:
- I don't know if this item is already in Downstream or still in Upstream
- I need to understand what lifecycle stage this OBC is at
- I want to know which experiments were conducted for this capability

→ For work in Upstream mode (without delivery commitment), use `/upstream`.
→ To execute the CommitmentGate, use `/commitment`.
→ To execute committed delivery in Downstream mode, use `/downstream`.

---

## When to Use

- Before starting any execution skill to verify current state
- When the capability's context is uncertain or potentially outdated
- To answer "what is the current stage of this OBC / capability?"
- To build a consolidated view of a capability for a retrospective, assessment, or handoff
- When invoked by an agent that needs context before deciding the next action

---

## Required Reading

Before starting, read:

- `prodops/framework/lifecycle.en.md` — stages and entry/exit conditions
- `prodops/framework/obc.md` — OBC states and canonical transitions
- `prodops/framework/glossary.en.md` — terms Product Intent, OBC, Commitment, Evidence, Outcome

---

## Context Reading Flow

### 1. Identify the capability

Determine the capability slug or OBC-ID from the provided input. If not provided, list active OBCs at `prodops/artifacts/obcs/` and request identification.

---

### 2. Read the active OBC

Read `prodops/artifacts/obcs/<slug>.md` and extract:
- Current state (Draft / Refining / Committed / In Delivery / Released / Archived)
- Origin (Global OBC or Business Intent + Tracking Item)
- Acceptance criteria (if present)
- Declared Observable Events
- Recorded evidence
- Committed KPIs

If the OBC does not exist at `prodops/artifacts/obcs/`, search in `prodops/artifacts/experiments/*/obcs/` (Draft state in Upstream experiment).

---

### 3. Determine the lifecycle stage

Based on the OBC state and artifacts present, classify the capability in one of the 9 canonical lifecycle stages:

| Stage | Indicators |
|---|---|
| Business Signal | Only Tracking List entry |
| Business Intent / Product Intent | OBC Draft + origin reference established |
| Context Discovery | OBC Draft in experiment directory + active `experiment.md` |
| Commitment | OBC transitioning Draft → Refining; CommitmentGate recorded in `upstream-trail.md` |
| Diligence & Readiness | OBC Refining → Committed; readiness gates under verification |
| Iteration | OBC Committed; item in Iteration Plan with `Entered` status |
| Delivery | OBC In Delivery; Bootstrap.Started recorded; CI Sync in execution |
| Evidence | OBC Released; Release Trail updated; Observable Events operating |
| Outcome | OBC Released; KPIs and Product Outcome verified |

---

### 4. Read supporting artifacts

Read existing artifacts in the following order:

**Backlog:**
- `prodops/artifacts/product/backlogs/tracking-list.md` — item presence and status
- `prodops/artifacts/plans/iteration-plan.md` — status in active iteration

**Experiments (if in Upstream or Context Discovery):**
- `prodops/artifacts/experiments/<NNN-slug>/experiment.md` — hypothesis, status, Decision Package
- `prodops/artifacts/experiments/<NNN-slug>/upstream-trail.md` — chronological history

**Delivery artifacts (if in Downstream):**
- `prodops/artifacts/bdd/<slug>.feature` — committed BDD Feature
- `prodops/artifacts/risks/risks.md` — risks relevant to the capability
- `prodops/artifacts/plans/reliability/<slug>.md` — Reliability Plan (if exists)

**Evidence and outcome (if Released):**
- `prodops/artifacts/trails/` — Release Trail for the capability
- Observable Event metrics referenced in the OBC

---

### 5. Consolidate and present

Produce a **Context Summary** with:

```markdown
## Context Summary — <capability-slug>

**Lifecycle stage:** <stage>
**OBC state:** <state>
**Current execution mode:** <Upstream | Downstream | —>

### Origin
<Business Intent or Global OBC of origin>

### Active experiments
<list of ongoing or completed experiments>

### Artifacts present
- [ ] OBC: <path and state>
- [ ] BDD Feature: <path or absent>
- [ ] Risks: <presence>
- [ ] Reliability Plan: <presence>
- [ ] Iteration Plan entry: <status>

### Recommended next action
<concrete action based on current stage>
```

---

## Operating Rules

1. This skill never modifies artifacts — it only reads and consolidates.
2. If an expected artifact does not exist, declare it explicitly as absent — do not infer state.
3. Do not classify the capability in a stage without concrete evidence (file or field read).
4. Do not recommend an action incompatible with the identified stage.
5. If the capability is not found in any artifact: declare as "unregistered" and recommend `/intent` as entry point.

---

## Expected Outputs

- Consolidated Context Summary with lifecycle stage, OBC state, and present artifacts
- Recommended next action based on current state
- List of absent artifacts blocking advancement (when applicable)

This skill does not produce persistent artifacts — the Context Summary is produced for immediate consumption by the session or requesting agent.

---

## Guardrails

- Never modify OBCs, experiments, backlogs, or any product artifact.
- Never infer the state of a capability without concrete artifact reading.
- Never recommend advancing to Downstream while there are open readiness gates.
- Never report an OBC as Released without verifying the Release Trail exists.

---

## References

→ [Lifecycle](../../framework/lifecycle.en.md)
→ [OBC](../../framework/obc.md)
→ [Glossary](../../framework/glossary.en.md)
→ [Intent Skill](../intent/SKILL.en.md)
→ [Commitment Skill](../commitment/SKILL.en.md)
→ [Evidence Skill](../evidence/SKILL.en.md)
→ [Outcome Skill](../outcome/SKILL.en.md)
