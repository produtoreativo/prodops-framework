# Diligence Async

## Nature

Diligence Async is the **asynchronous and proactive** cycle of ProdOps Diligence.

- **Asynchronous:** does not depend on a specific transaction in progress in another journey.
- **Proactive:** initiated by scheduled periodic scanning or by suspicion of drift — does not wait for an external event.
- **Drift-oriented:** its objective is to detect accumulated divergences that escaped synchronous verification.
- **Non-blocking by default:** produces a consistency report and executes authorized repairs; escalates when repair requires a product decision.

```
diligence-async: Scan → Flag → Repair
```

---

## Purpose

Diligence Async produces:
- Consistency report between Markdown artifacts and external backlogs
- Divergences classified with severity and corrective action identified
- Artifacts and tools restored to consistency for repairable items
- Escalations recorded for items that require human decision

---

## Trigger model

Diligence Async is triggered by:

| Trigger | Typical frequency |
|---|---|
| Scheduled periodic scan | Weekly or as configured |
| Drift suspicion reported by agent or user | On demand |
| Change in normative documentation | Automatic |
| Explicit consistency audit request | On demand |

**Diligence Async is not triggered by specific operation events** — that is the role of Diligence Sync.

---

## Phases

### Scan

**Objective:** Full reading of the work system and identification of divergences, distinguishing legitimate absence from incomplete relationship.

**What it does:**
- Reads all active OBCs in `prodops/artifacts/obcs/` and compares the declared state with external backlogs and tools
- Compares the GitHub Workspace (Labels, Fields, Views, Projects) with the Canonical Specification in `prodops/framework/github-workspace.md`
- Reads open Work Items and verifies if they reference valid artifacts
- Identifies gaps by category

**Critical distinction — legitimate absence vs. incomplete relationship:**

| Situation | Classification |
|---|---|
| OBC in Draft, no authorized active operation, no Work Item | **Legitimate absence** — not a divergence |
| Business Signal recorded, no active investigation, no Work Item | **Legitimate absence** — not a divergence |
| Committed OBC with active Delivery operation, no Work Item | **Incomplete relationship** — divergence |
| Committed OBC in Iteration Plan, Work Item still open after Release Operational | **Incomplete relationship** — divergence (Close was not executed) |
| Open Work Item referencing non-existent OBC | **Invalid relationship** — divergence |

**What it does NOT do:**
- Does not repair during Scan — only identifies
- Does not create artifacts, Work Items or Issues during Scan
- Does not classify historical trails as normative divergences

**Output:** List of gaps with affected OBC, gap type, severity and nature (legitimate absence or incomplete/invalid relationship).

→ [steps/scan/SKILL.md](../../../skills/diligence/diligence-async/steps/scan/SKILL.md)

---

### Flag

**Objective:** Classify each divergence found in the Scan and record for action.

**What it does:**
- Classifies each divergence with: affected OBC, type, severity, suggested corrective action, responsible party
- Records items automatically repairable by Diligence
- Marks as `BLOCKED` items that require a product or human decision, identifying the responsible journey (Assessment, Product Owner, Tech Lead)
- Produces an intermediate consistency report

**What it does NOT do:**
- Does not execute repairs — only signals
- Does not decide which action to take — only suggests based on canonical rules
- Does not classify as divergence what was legitimately identified as valid absence in Scan

> **Note:** The formal Finding taxonomy (severity, type, impact) is planned for a future version. In this version, Flag produces functional classification sufficient to guide Repair without implementing the complete Finding schema.

**Output:** Items classified by action type: automatically repairable / requires decision / requires escalation.

→ [steps/flag/SKILL.md](../../../skills/diligence/diligence-async/steps/flag/SKILL.md)

---

### Repair

**Objective:** Execute the authorized corrections identified by Flag.

**What it does:**
- For each gap repairable by Diligence, applies the corresponding step of the diligence-sync cycle (`attach`, `close`, `promote`, `capture`) as a subroutine
- Invokes Workspace Reconciliation when the Scan detected Workspace Drift
- Escalates `BLOCKED` items to the responsible journey with the block record
- Produces final report with: repaired / blocked / escalated

**What it does NOT do:**
- Does not modify product code
- Does not create implementation Pull Requests
- Does not silently alter canonical artifacts — any modification of canonical content requires authorization
- Does not correct historical trails to align them with current vocabulary
- Does not make product decisions in place of the Product Owner or Assessment

**Canonical modification guardrail:** If Repair identifies that the correction requires altering the content of an OBC, BDD Feature, Reliability Plan or other Knowledge Space artifact, it must stop and record the need for human decision — not correct it alone.

**Output:** Final report: list of applied repairs, recorded blocks, generated escalations.

→ [steps/repair/SKILL.md](../../../skills/diligence/diligence-async/steps/repair/SKILL.md)

---

## Relationship with Workspace Reconciliation

The Diligence Async cycle invokes the **Workspace Reconciliation** Capability when Scan detects signs of Workspace Drift: missing labels, missing fields, projects out of spec.

**Workspace Reconciliation is a Capability invoked as a subroutine — it is not a phase of Diligence Async.** Async does not call Workspace Reconciliation on every scan — only when Scan detects explicit drift in the infrastructure.

```
Diligence Async — Repair (gap: missing label)
       │
       └──→ Workspace Reconciliation (Capability)
                  Inspect → Reconcile → Verify
                  └──→ returns to Repair
```

→ [workspace-reconciliation.md](workspace-reconciliation.md)

---

## Capabilities used

| Capability | Phase |
|---|---|
| [Divergence Detection](capabilities/README.md) | Scan, Flag |
| [Artifact Evolution](capabilities/README.md) | Repair |
| [Backlog Synchronization](capabilities/README.md) | Repair |
| [Work Item Management](capabilities/README.md) | Repair |
| [Readiness Verification](capabilities/README.md) | Scan (precondition verification) |
| [Workspace Reconciliation](workspace-reconciliation.md) | Invoked by Repair when Workspace Drift detected |
