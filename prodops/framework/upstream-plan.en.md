# Experiment Plan

The **Experiment Plan** is the coordination artifact for Upstream mode — the equivalent of the Iteration Plan for the non-blocking (advisory) regime.

While the Iteration Plan records *what is being delivered in this iteration* (committed capabilities), the Experiment Plan records *what is being investigated right now* (active hypotheses). The two artifacts are symmetric: one governs Downstream in execution, the other governs Upstream in exploration.

---

## What it is

**Nature:** VIEW over PIB items that have an active Upstream experiment — i.e., items with `experiment.md` and `upstream-trail.md` present and in progress.

**Question:** Which hypotheses are currently being investigated?

**It is not:** A task list. The Experiment Plan does not define sequence or impose deadlines. It is an instrument of visibility and WIP control — not sprint planning.

---

## Structure

| Field | Description |
|---|---|
| **ID** | Experiment identifier (EXP-NNN) |
| **Hypothesis** | One line: what is being tested |
| **Status** | Active / Waiting (external dependency) / Concluded (awaiting CommitmentGate) |
| **Decision Package** | Ready / In progress / Not started |
| **Sessions since last entry** | Session count since the last upstream-trail entry (S1 signal of Perpetual Discovery) |
| **Discovery WIP** | Position of this experiment within total WIP (e.g., 2/3) |

---

## Relationship with the Iteration Plan

| Dimension | Experiment Plan | Iteration Plan |
|---|---|---|
| **Mode** | Upstream (non-blocking / advisory) | Downstream (blocking) |
| **What it lists** | Experiments with active hypothesis | Capabilities with OBC in Readiness state |
| **Entry gate** | Experiment opened by PM/Tech Lead | CommitmentGate outcome Promote + Readiness Gate |
| **Exit gate** | CommitmentGate (any of the 6 outcomes) | Promote completed → OBC Released |
| **WIP limit** | Discovery WIP (controlled by the team) | Iteration capacity |
| **Central artifact** | `experiment.md` + `upstream-trail.md` | OBC (Readiness) + BDD Feature |

---

## Discovery WIP

Discovery WIP is the primary metric of the Experiment Plan: the number of simultaneously active Upstream experiments. High Discovery WIP indicates attention dispersed across multiple hypotheses, which tends to increase the TTE (Time to Evidence) of all of them.

The Discovery WIP limit is a decision for each team — not a fixed framework value. The Experiment Plan makes this limit visible and manageable.

---

## Warning signals in the Experiment Plan

| Signal | Criterion | Diagnosis |
|---|---|---|
| **S1** | Active experiment with no hypothesis progression for 3+ sessions (upstream-trail has entries but `Hypothesis` has not changed in 2+ weeks and Decision Package has no substance) | Stagnation — experiment stuck without a decision |
| **S2** | Experiment active for more than N weeks without a Decision Package | Perpetual Discovery — exploration without a stop criterion |
| **S3** | Discovery WIP above the team-defined limit | Dispersion — too many hypotheses in parallel |
| **S4** | Experiment with ready Decision Package but CommitmentGate not convened | Decision Latency — evidence available, decision deferred |

When multiple signals are simultaneously active, convening the CommitmentGate is the specific operational response — not to force approval, but to decide the experiment's destination.

---

## Canonical artifact

`prodops/artifacts/product/backlogs/experiment-plan.md`

The Experiment Plan is updated at the beginning of each Upstream work session, before any exploration activity. Its maintenance is the responsibility of the Author (experiment conductor) with PM review.

---

## Relationship with the Icebox and the PIB

```
Product Intent Backlog (PIB)
    │
    └─ [VIEW] Icebox         (OBC ≠ Readiness)
            │
            └─ [VIEW] Experiment Plan   (active Upstream experiments)
                       │
                       └─ CommitmentGate → Iteration Backlog (OBC Readiness)
```

A PIB item can be in the Icebox without being in the Experiment Plan — for example, when awaiting an external business decision before opening an experiment. The Experiment Plan is the active subview of the Icebox for ongoing exploration work.
