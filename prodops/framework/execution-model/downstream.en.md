# Downstream Mode

Downstream is the **commitment mode** of the ProdOps Framework.

## Canonical definition

Downstream represents a commitment mode. From the moment a Business Intent enters Downstream, there is a commitment to delivery, quality, and reliability. All work must mandatorily follow the ProdOps operational model.

## Purpose

Deliver software with traceability, verifiable acceptance criteria, and evidence recorded at each step.

## Mode characteristics

In Downstream:

- there is an implementation commitment
- there is a reliability commitment
- there is governance
- there is mandatory validation
- there is traceability
- there is evidence generation
- there is conformance with the operational model

Skills are no longer optional. They become part of the execution process — they participate in journey validation, produce evidence, and guarantee consistency.

## OBC in Downstream

When entering Downstream, the OBC is no longer just a record. It becomes the operational contract of the work.

During Discovery (in the Icebox), it will be refined until reaching the Committed state. That OBC controls the evolution of the subsequent journeys: Iteration Backlog → Iteration Plan → Delivery.

## When to use Downstream mode

- Item approved in the Iteration Plan
- Implement existing OBC + BDD Feature
- Deliver feature with formal commitment
- Execute item from the Reliability Plan

## Three Transition Moments

Downstream has three explicit moments, each with verifiable entry conditions:

### Moment 1 — CommitmentGate → Downstream Declared

The commitment has been assumed. The CommitmentGate with outcome **Promote** is the only event that opens Downstream.

**Mandatory entry conditions for CommitmentGate to emit Promote:**
1. Hypothesis answered with Evidence Threshold satisfied (if declared)
2. Decision Package with real substance — readable by a trio member who did not participate in the experiment
3. OBC Draft existing as a file (at minimum the file with name and reference to the experiment)
4. Readable BDD draft — draft of expected behavior scenarios

**Resulting state:** `Downstream Declared` — item enters the Icebox for refinement.

---

### Moment 2 — Artifact promotion + Icebox entry

Occurs immediately after the CommitmentGate. These are distinct actions from Moment 1:
- OBC transitions `Draft → Refining`
- Work Item created in Icebox referencing the experiment and the OBC
- Experiment upstream-trail updated with promotion record

---

### Moment 3 — Readiness Gate → Downstream Ready

**Mandatory conditions before starting any Delivery phase:**
1. OBC in `prodops/artifacts/obcs/` with state **Committed**
2. BDD Feature in `prodops/artifacts/bdd/`
3. Risks documented in `prodops/artifacts/risks/risks.md`
4. Iteration Plan entry with status `In` in `prodops/artifacts/plans/iteration-plan.md`
5. Reliability Plan when there is money movement, an external integration, an SLO change, high/critical risk, or a persistence or security change

**Resulting state:** `Downstream Ready` → `Delivery Started` (after Bootstrap.Started).

When a mandatory requirement is missing, Downstream stops before Delivery, identifies the owner, and guides the next action.

## Mandatory sequence

```
Bootstrap → Hack → Sync → Finish → Ship → Validate → Promote
```

Work is divided into two cycles:

```
CI Sync: Bootstrap → Hack → Sync → Finish     (local work, synchronous)
CI Async: Ship → Validate → Promote            (platform, pipelines, environments)
```

## Phases

| Phase | Description | Link |
|---|---|---|
| Bootstrap | Dependencies + local infrastructure + configuration + smoke gate | [../journeys/delivery/phases/bootstrap/README.en.md](../journeys/delivery/phases/bootstrap/README.en.md) |
| Hack | Implementation via ProdOps TDD | [../journeys/delivery/phases/hack/README.en.md](../journeys/delivery/phases/hack/README.en.md) |
| Sync | Branch sync (rebase) + artifact alignment (align) | [../journeys/delivery/phases/sync/README.en.md](../journeys/delivery/phases/sync/README.en.md) |
| Finish | Quality Gates + PR | [../journeys/delivery/phases/finish/README.en.md](../journeys/delivery/phases/finish/README.en.md) |
| Ship | Preparation + Deployment | [../journeys/delivery/phases/ship/README.en.md](../journeys/delivery/phases/ship/README.en.md) |
| Validate | Runtime + observability + SLO | [../journeys/delivery/phases/validate/README.en.md](../journeys/delivery/phases/validate/README.en.md) |
| Promote | Formal approval + Release Trail | [../journeys/delivery/phases/promote/README.en.md](../journeys/delivery/phases/promote/README.en.md) |

## Evidence

Record significant delivery evidence in the active session trail at `prodops/artifacts/trails/sessions/YYYY-MM-DD-<session-id>.md`.

## Direct Downstream (without prior Upstream)

A Business Signal can enter Downstream directly without going through Upstream exploration when:

- The demand is confirmed by independent channels (no experiment needed)
- The scope is clearly delimited enough to commit
- Open questions are classified as **refinement** — they do not block the start; they are resolved in the Icebox
- The remaining uncertainty is acceptable with the commitment being explicitly assumed

**This is a correct mode calibration** — not an absence of discovery. Discovery happens within the commitment, with the Discovery journey running in Downstream mode with blocking rigor and a Readiness Gate before Delivery.

The PM must explicitly document the justification for direct Downstream entry (e.g.: "sufficient clarity about what to build; timeline does not allow Upstream exploration"). Open questions classified as refinement must be listed and marked as non-blocking.

---

## Downstream Anti-patterns

| ID | Name | Description |
|----|------|-------------|
| **AP-D1** | Gate Theater | Gates executed formally without the artifacts satisfying the criteria. The ritual exists; the substance does not. |
| **AP-D2** | Proxy Commitment | OBC marked as Committed without measurable success criteria. The commitment is named but not verifiable. |
| **AP-D3** | Forced Readiness | Readiness Gate approved with known gaps due to deadline pressure. Unlike a Waiver (which is explicit and recorded), Forced Readiness is silent. |
| **AP-D4** | Phantom BDD | BDD Feature written after the code, describing what was implemented instead of the expected behavior. The test passes because the code already exists — not because the behavior was specified. |
| **AP-D5** | Empty Release Trail | Promote executed without a filled Release Trail. The commitment was honored but is not verifiable by those who did not participate. |

**AP-D3 vs. Waiver distinction:** a Waiver is the *explicit and recorded* acknowledgment that a criterion is not satisfied, with justification and a commitment to resolution within a defined deadline. AP-D3 is *silent* advancement without the gap being acknowledged. The Waiver is governance; AP-D3 is governance evasion.

---

## Downstream → Upstream Regression Protocol

Triggered when a hypothesis is invalidated during Delivery — what was committed cannot be honored as committed.

**This is a formal commitment suspension** — not a return to a previous step. The mandatory sequence:

1. **Record in Release Trail:** entry documenting the reason for suspension, the invalidated hypothesis, and the regression decision
2. **Open new Upstream experiment:** referencing the original OBC and the suspended Downstream; the experiment investigates what invalidated the hypothesis
3. **Transition the OBC:** `Committed → Refining` (the transition is recorded in the OBC with date and justification)
4. **Update the Work Item:** status returns to Icebox; Downstream Declared remains recorded as history

The team and leadership must be notified. Regression is not a process failure — it is the correct protocol when evidence changes during execution.

---

## Downstream must preserve

Traceability from the current state and assessment through implementation, validation, and promotion.


---

→ **Next:** [Discovery Journey](../journeys/discovery/README.en.md)
