[Português](SKILL.md)

---
name: commitment
description: Execute the CommitmentGate for a Business Intent entering Downstream directly (Downstream Direto), without prior Upstream experiment. Use when context is sufficient to commit — validated demand, clear scope, open questions classified as refinement rather than uncertainty. OBCs and BDD files already exist in canonical locations. For CommitmentGate after a completed Upstream experiment, use upstream/move-to-downstream instead.
---

# Commitment Skill — Downstream Direto

Use this skill when a Business Intent has sufficient context to enter Downstream
**without a prior Upstream experiment** — demand confirmed by independent sources,
clear scope, open questions classified as refinement, not uncertainty.

**Do not use** if artifacts are still in an experiment directory — in that case
use `/upstream move-to-downstream`.

For the Readiness Gate (readiness verification before Bootstrap), use `/diligence`.

---

## When to Use

- Business Intent with defined scope, without hypotheses requiring an experiment
- OBCs in Draft already in `prodops/artifacts/obcs/`
- BDD Features already in `prodops/artifacts/bdd/`
- Evidence comes from sources external to an experiment: market research,
  competitive analysis, prior EXP, historical data, user validation

---

## Required Reading

1. Business Intents for the scope (`prodops/artifacts/business-intents/`)
2. Corresponding Draft OBCs (`prodops/artifacts/obcs/`)
3. Available evidence sources
4. `prodops/framework/obc.md` — canonical states and transitions
5. `prodops/framework/lifecycle.md` — Commitment stage

---

## Moment 1 — Verify Evidence Threshold

Confirm all 5 criteria before registering the gate. All are blocking.

| Criterion | Verification |
|---|---|
| Hypothesis answered | Core business question answered with evidence verifiable by third parties |
| Decision Package present | BI + feature registry, roadmap, competitive analysis, or equivalent |
| OBC Draft exists | File at `prodops/artifacts/obcs/<slug>.md` for each committed capability |
| BDD readable | Feature at `prodops/artifacts/bdd/<slug>.feature` (draft acceptable — completeness required at Readiness Gate) |
| Residual uncertainty declared | Open questions documented and classified as refinement, not hypothesis blockers |

**If any criterion is not satisfied:** do not register the gate. Return to the
Business Intent owner with guidance on what to produce first.

---

## Moment 2 — Register the CommitmentGate

Record in `prodops/artifacts/plans/commitment-trail.md`.

If the file does not exist, create it with the header:

```markdown
# Commitment Trail — <Product>

Append-only record of CommitmentGates executed in Downstream Direto mode.
For post-Upstream CommitmentGates, see the upstream-trail.md of each experiment.
```

Add the entry:

```markdown
## YYYY-MM-DD — CommitmentGate — <scope name>

**Outcome:** <canonical outcome>

**Trio:** PM (<name>) + Tech Lead (<name>) + Author (<name>)

**Evidence base:**
- <source 1>
- <source 2>

**Criterion assessment:**

| Criterion | Status | Evidence |
|---|---|---|
| Hypothesis answered | ✅/❌ | <reference> |
| Decision Package | ✅/❌ | <reference> |
| OBC Draft | ✅/❌ | <N files in prodops/artifacts/obcs/> |
| BDD readable | ✅/❌ | <N files in prodops/artifacts/bdd/> |
| Residual uncertainty | ✅/❌ | <classified as refinement — see BI> |

**Outcome justification:**
<2-3 paragraphs: what was validated, what remains uncertain but is acceptable,
why additional discovery cost exceeds the risk of committing now.>

**Committed scope:**
<list of OBCs or BCs in the Promover outcome>

**Restricted scope (if applicable):**
<what was excluded and why>
```

---

## Moment 3 — Transition OBC Draft → Refining

For each OBC in the committed scope:

**3a. Update the Status field:**

```
Status: Refining. Downstream Declared on YYYY-MM-DD.
Located at prodops/artifacts/obcs/<slug>.md.
```

**3b. Add `## State History` section** (if not present):

```markdown
## State History

| Date | Transition | Actor | Context |
|---|---|---|---|
| YYYY-MM-DD | Draft → Refining | PM + Tech Lead | Downstream Direto CommitmentGate — commitment-trail.md |
```

OBCs marked "Awaits CommitmentGate" remain in Draft — they have their own
pending gate (e.g.: CategoryManagement, Copilot).

---

## Moment 4 — Create or Update Iteration Plan

Create or update `prodops/artifacts/plans/iteration-plan.md`.

Each committed OBC enters with status **`Icebox`** — not `Entrou`. The `Entrou`
status is assigned only after the Readiness Gate (via `/diligence`).

```markdown
## Iteration Backlog

| OBC | Slug | BC | Release | State | Status |
|---|---|---|---|---|---|
| OBC-002 | demand-intent-capture | Demand | v1.0 | Refining | Icebox |
```

---

## Canonical Outcomes (6)

| Outcome | Next step | State transition |
|---|---|---|
| **Promover** | OBC → Refining; Icebox; Readiness Gate via `/diligence` | Draft → Refining |
| **Promover com restrição** | Approved subset → Refining; remainder documented | Partial Draft → Refining |
| **Requer outro experimento** | Open EXP with specific hypothesis; record in commitment-trail | Remains Draft |
| **Aguardar decisão de negócio** | Owner records decision-maker and deadline | Remains Draft |
| **Aguardar dependência externa** | Risk recorded in BI with owner and deadline | Remains Draft |
| **Descartar** | OBC → Archived with justification | Draft → Archived |

---

## Guardrails

- Never skip Moment 1 — a gate without an evidence check is not a CommitmentGate.
- Never transition OBC directly to `Readiness` here — that is the Readiness Gate (`/diligence`).
- The commitment-trail is append-only — never edit existing entries.
- Never transition OBCs marked "Awaits CommitmentGate" — they have their own gate.
- Never use this skill for OBCs coming from a completed Upstream experiment — use `/upstream move-to-downstream`.
- Never create GitHub Work Items without declaring `artifact_type`, `artifact_id`, `operation`, and `journey`.

---

## Expected Outputs

- `prodops/artifacts/plans/commitment-trail.md` with gate entry
- Committed OBCs with Status `Refining` and `## State History` section
- `prodops/artifacts/plans/iteration-plan.md` with entries at status `Icebox`

---

## References

→ [Lifecycle — Commitment stage](../../../../framework/lifecycle.md)
→ [OBC — states and transitions](../../../../framework/obc.md)
→ [upstream/move-to-downstream](../upstream/steps/move-to-downstream/SKILL.md)
→ [diligence — Readiness Gate](../diligence/SKILL.md)
