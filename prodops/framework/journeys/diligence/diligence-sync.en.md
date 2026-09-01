# Diligence Sync

## Nature

Diligence Sync is the **synchronous and reactive** cycle of ProdOps Diligence.

- **Synchronous:** executes together with an operation in progress or state transition in another journey.
- **Contextual:** tied to a specific operation or transition — it is not periodic and does not occur independently.
- **Reactive:** triggered by external events (Assessment decision, completed Discovery experiment, Operation signal, strategic change in the Roadmap).
- **Blocking:** can block a transition when canonical criteria are not satisfied. The flow does not advance until the precondition is resolved or escalated.

```
diligence-sync: Capture → Attach → Promote → Close
```

---

## Purpose

Diligence Sync produces:
- OBC updated with the canonical state of the decision that triggered the cycle
- Work Item created or updated referencing the OBC, the operation and the journey — when there is an active operation
- Item promoted in the backlog hierarchy up to the correct readiness level
- Work Item closed when the OBC reaches Operational state and the Release Trail records the delivery

---

## Trigger model

Diligence Sync is triggered by an event that represents an operation in progress or a necessary transition:

| Triggering event | Typically initiated phase |
|---|---|
| Assessment decision recorded | Capture |
| Discovery experiment concluded with decision | Capture |
| OBC ready to advance in the backlog | Promote |
| Active work identified without Work Item | Attach |
| OBC reached Operational state + Release Trail confirmed | Close |
| Attach or Promote failure due to missing infrastructure | Workspace Reconciliation (Capability invoked) |

**Diligence Sync is not scheduled periodically.** Periodic scanning belongs to the Diligence Async cycle.

---

## Phases

### Capture

**Objective:** Record the canonical state of the decision that triggered the cycle in the corresponding artifact.

**What it does:**
- Creates or updates the OBC from the decision that triggered the cycle
- Records the canonical state in the Markdown file in `prodops/artifacts/obcs/`
- Fills or updates: identifier, source Business Intent, state, recorded decision, date

**What it does NOT do:**
- Does not create Work Items — only stabilizes the artifact state
- Does not invent business content — only records decisions already made by the competent journey
- Does not evaluate whether the decision was correct

**Entry precondition:** Decision, experiment or signal with documented canonical trigger.

**Output:** OBC with updated canonical state, date and decision recorded.

→ [steps/capture/SKILL.md](../../../skills/diligence/diligence-sync/steps/capture/SKILL.md)

---

### Attach

**Objective:** Verify whether a traceable Work Item exists for the operation in progress; create one if necessary.

**What it does:**
- Verifies whether an active Work Item referencing the OBC exists in the corresponding external backlog
- Verifies whether the Work Item is in the correct state and has canonical fields filled
- If it does not exist and there is an active operation: creates a Work Item following the canonical schema with `artifact_type`, `artifact_id`, `operation` and `journey` filled

**Canonical title format:**

```
[Artifact ID]: concise description
```

Example: `observability-datadog: advance to Iteration Plan`

The operation (`Promote`) and artifact type (`Local OBC`) go in the Issue's fields and labels — **not in the title**.

→ [work-item-schema.md](../../execution-mapping/work-item-schema.md)

**What it does NOT do:**
- Does not create Issue for artifact without active operation (does not violate the N:M model)
- Does not create Issues in bulk for all tracking list artifacts
- Does not alter OBC content

**When absence of Work Item is legitimate:** passive artifact (Business Signal recorded, no active investigation; OBC in Draft without authorized operation in progress).

**When absence of Work Item is a divergence:** there is an active operation identified (Capture completed, Promote in progress, Delivery work in progress) without a traceable Work Item.

**Output:** Existing Work Item confirmed or new Work Item created with complete schema.

→ [steps/attach/SKILL.md](../../../skills/diligence/diligence-sync/steps/attach/SKILL.md)

---

### Promote

**Objective:** Move the item through the backlog hierarchy verifying the prerequisites of each transition.

**What it does:**
- Verifies canonical prerequisites of each transition
- Records the `Entered` status at the target level when the transition is completed
- Records the block and the missing artifact when the transition cannot occur
- Blocks the flow when a precondition is not satisfied — the flow does not advance until resolved or escalated

**Prerequisites by transition:**

| Destination | Mandatory prerequisites |
|---|---|
| → Icebox | OBC transitioning from Draft to Refining; active Discovery started |
| → Iteration Backlog | OBC Committed; sufficient Discovery; risks identified |
| → Iteration Plan | OBC Committed + BDD Feature Committed + documented risks |
| → Iteration Plan (with qualified risk) | + Reliability Plan (when: financial movement, external integration, SLO change, high/critical risk, persistence or security change) |

**What it does NOT do:**
- Does not promote item without satisfied criteria
- Does not decide the backlog in place of the Product Owner
- Does not evaluate the business merit of the item

**Output:** Transition recorded with date and verified prerequisites, or block recorded with missing artifact identified.

→ [steps/promote/SKILL.md](../../../skills/diligence/diligence-sync/steps/promote/SKILL.md)

---

### Close

**Objective:** Close the tracking cycle when the OBC reaches Operational state.

**What it does:**
- Closes the Work Item when the OBC reaches `Operational` state and the Release Trail records the delivery
- Updates management artifacts (Roadmap, Product Backlog) to reflect the final state
- Preserves history: Work Item closed with reference to the Release and the OBC

**What it does NOT do:**
- Does not close Work Item prematurely (without Release Trail confirmation)
- Does not erase history of previous operations
- Does not alter OBC state (the OBC transitions to Operational by Assessment or Promote — not by Close)

**Output:** Work Item closed with reference to the delivery; management artifacts updated.

→ [steps/close/SKILL.md](../../../skills/diligence/diligence-sync/steps/close/SKILL.md)

---

## Relationship with Workspace Reconciliation

Diligence Sync can invoke the **Workspace Reconciliation** Capability when the Attach or Promote step fails due to missing canonical label, required field missing in the Project or infrastructure drift.

**Workspace Reconciliation is a Capability invoked as a subroutine — it is not a phase of Diligence Sync.** After Workspace Reconciliation completes, the step that invoked it resumes its execution.

```
Diligence Sync — Attach (failure: missing label)
       │
       └──→ Workspace Reconciliation (Capability)
                  Inspect → Reconcile → Verify
                  └──→ returns to Attach
```

→ [workspace-reconciliation.md](workspace-reconciliation.md)

---

## Capabilities used

| Capability | Phase |
|---|---|
| [Backlog Synchronization](capabilities/README.md) | Capture, Promote |
| [Work Item Management](capabilities/README.md) | Attach, Close |
| [Readiness Verification](capabilities/README.md) | Promote |
| [Artifact Evolution](capabilities/README.md) | Capture, Close |
| [Workspace Reconciliation](workspace-reconciliation.md) | Invoked by Attach or Promote when necessary |
