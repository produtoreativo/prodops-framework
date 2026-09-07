[Português](SKILL.md)

---
name: commitment
description: Executes the CommitmentGate and Readiness Gate. Use to convene the trio (PM + Tech Lead + Author), verify the Decision Package, record the canonical outcome, transition from Upstream to Downstream Declared, and verify readiness prerequisites before a capability enters the Iteration Plan.
---

# Commitment Skill

## Purpose

Use this skill to formalize the execution mode transition: from Upstream (exploratory, no commitment) to Downstream (committed, with blocking rigor).

This skill covers two sequential gates of the canonical lifecycle:

1. **CommitmentGate** — Upstream → Downstream Declared transition
2. **Readiness Gate** — Downstream Declared → Downstream Ready transition

→ For work in Upstream mode (without delivery commitment), use `/upstream`.
→ For executing the committed delivery cycle in Downstream mode (CI Sync + CI Async), use `/downstream`.
→ For maintaining artifact state, use `/diligence`.

---

## When to Use

**CommitmentGate:**
- An experiment's Decision Package is complete and the trio needs to be convened
- A hypothesis has been answered and the recommendation is `Promote` or `Promote with restriction`
- A canonical outcome needs to be formally recorded (including non-promotion outcomes)
- An item needs to transition to Downstream Declared

**Readiness Gate:**
- An item in Downstream Declared needs to be verified before entering the Iteration Plan
- The OBC needs to be in Committed state and all required artifacts verified
- Diligence blocked a capability and current readiness needs to be assessed

---

## Required Reading

Before starting, read:

- `prodops/framework/lifecycle.en.md` — Commitment and Diligence & Readiness stages
- `prodops/framework/glossary.en.md` — terms CommitmentGate, Commitment, Readiness Gate
- `prodops/framework/journeys/discovery/README.en.md` — preconditions, trio, canonical outcomes, promotion process

---

## CommitmentGate Flow

### Preconditions (verify all before convening the trio)

1. **Decision Package complete:** `experiment.md` has Executive Summary, Recommended Decision, Risks, Opportunities, Tracking Items, OBCs, and Downstream Scope.
2. **Hypothesis answered:** the experiment's Exit Criteria are satisfied.
3. **Evidence Threshold satisfied** (if declared in `experiment.md`).
4. **OBC Draft exists:** at least the file at `prodops/artifacts/experiments/<NNN-slug>/obcs/<slug>.md`.
5. **BDD draft readable:** draft of behavior scenarios in `prodops/artifacts/experiments/<NNN-slug>/features/`.
6. **Verifiability criterion:** any trio member who did not participate in the experiment can read the Decision Package and reach the same conclusions without additional oral context.

If any precondition is not satisfied: do not convene the trio. Return to the experiment and complete the Decision Package.

---

### The Trio

| Role | Responsibility |
|---|---|
| Product Manager | Validates business value; decides whether the capability enters the Iteration Plan |
| Tech Lead | Validates technical feasibility, architectural risks, and OBC |
| Experiment Author | Presents findings; defends the recommendation |

Approval is collective. Any member can block with a recorded justification.

---

### Canonical Outcomes

| Outcome | Action |
|---|---|
| **Promote** | Execute promotion process (see below). OBC Draft → Refining. Downstream Declared. |
| **Promote with restriction** | Subset is promoted. Restricted parts return to Upstream for a new experiment. |
| **Requires another experiment** | Create new experiment with a more specific hypothesis. Record in `upstream-trail.md`. |
| **Awaiting business decision** | Block in Product Tracking List with decision-maker and expected date. |
| **Awaiting external dependency** | Record in Reliability Plan and Product Tracking List. |
| **Discard** | Record learning in `prodops/framework/journeys/discovery/learnings.md`. Close experiment. |

---

### Mandatory Record

Regardless of outcome, record in the experiment's `upstream-trail.md`:
- CommitmentGate date
- Participants (trio)
- Canonical outcome selected
- Next steps

---

### Promotion Process (outcome: Promote)

Execute in order:

```
1. Move BDD Feature:
   prodops/artifacts/experiments/<NNN-slug>/features/<slug>.feature
   → prodops/artifacts/bdd/<slug>.feature

2. Move OBC:
   prodops/artifacts/experiments/<NNN-slug>/obcs/<slug>.md
   → prodops/artifacts/obcs/<slug>.md
   Remove draft marking. Update state to Refining.

3. Create Iteration Plan entry:
   prodops/artifacts/plans/iteration-plan.md
   Add with "Entered" decision in the table. Status: Downstream Declared.

4. Update Product Tracking List if item was there:
   prodops/artifacts/product/backlogs/tracking-list.md
   Change status to "Promoted to Downstream".

5. Record promotion in the experiment's upstream-trail:
   prodops/artifacts/experiments/<NNN-slug>/upstream-trail.md

6. Record in global upstream trail:
   prodops/framework/journeys/discovery/upstream-trail.md
   (high-level entry: what was promoted and when)
```

---

## Readiness Gate Flow

The Readiness Gate verifies that an item in Downstream Declared has all prerequisites to begin Delivery.

### Readiness Gates

1. Local OBC in Committed state at `prodops/artifacts/obcs/<slug>.md`
2. BDD Feature committed at `prodops/artifacts/bdd/<slug>.feature`
3. Risks documented at `prodops/artifacts/risks/risks.md`
4. Item in the Iteration Plan with status `Entered`
5. GitHub Issue existing and mapped in the active iteration's `plan.md`
6. Reliability Plan updated (required when there is financial movement, external integration, SLO change, high/critical risk, or persistence or security changes)

**All gates 1–5 are blocking.** Gate 6 is blocking only under the declared conditions.

### Readiness Gate Result

- **Downstream Ready:** all gates passed → item can proceed to Bootstrap.
- **Downstream Declared blocked:** list missing gates, absent artifacts, and concrete action required. Do not advance until resolved.

---

## Operating Rules

1. Never skip the CommitmentGate for items coming from Upstream — the mode transition must be formal and recorded.
2. Never record an outcome other than the 6 canonical ones — there are no intermediate outcomes.
3. Never mark an item as Downstream Ready while there are blocking gates.
4. Do not invent acceptance criteria, OBCs, or BDD during the CommitmentGate — artifacts must exist before convening.
5. The CommitmentGate is not a prerequisite for code deployment — code can go to production before the gate; the gate formalizes the *capability*, not the deploy.

---

## Expected Outputs

**CommitmentGate (Promote):**
- Experiment's `upstream-trail.md` updated with outcome, date, and trio
- OBC moved to `prodops/artifacts/obcs/<slug>.md` in Refining state
- BDD Feature moved to `prodops/artifacts/bdd/`
- Iteration Plan updated with Downstream Declared status
- `prodops/framework/journeys/discovery/upstream-trail.md` with promotion entry

**Readiness Gate (approved):**
- Formal Downstream Ready confirmation
- Context capsule ready for the CI Sync Bootstrap (Downstream mode)

---

## Guardrails

- Never record an outcome without date, participants, and next steps in `upstream-trail.md`.
- Never start Bootstrap without an approved Readiness Gate.
- Never create Issues or PRs without declaring `artifact_type`, `artifact_id`, `operation`, and `journey`.
- Do not confuse "code in production" with "capability promoted" — they are distinct objects.

---

## References

→ [Lifecycle](../../framework/lifecycle.en.md)
→ [Glossary](../../framework/glossary.en.md)
→ [Discovery Journey — CommitmentGate](../../framework/journeys/discovery/README.en.md)
→ [OBC — states and transitions](../../framework/obc.md)
→ [Intent Skill](../intent/SKILL.en.md)
→ [Upstream Skill](../upstream/SKILL.md)
→ [Downstream Skill](../downstream/SKILL.md)
→ [Work Item Schema](../../framework/execution-mapping/work-item-schema.md)
