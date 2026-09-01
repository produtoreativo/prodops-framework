# Diligence Event Catalog — v2
# ProdOps Framework — Diligence Journey

> **Version:** 2.0.0
> **Status:** Active
> **Namespace:** `Diligence`
> **Journey:** Diligence
> **Schema:** [Event Type Schema v1.0.0](../../../events/event-type-schema.md)
> **Changelog v2.0.0:** Gate.Passed, Gate.Failed, Impediment.Declared → Deprecated (promoted to Active Shared Types). Impediment.Resolved → awaiting shared-types v1.1.0 for formal deprecation.

---

## Overview

| # | Event Type | Category | alters_state | new_state | Producers | v2 Status |
|---|---|---|---|---|---|---|
| 1 | Capture.Started | Phase Lifecycle | true | CAPTURING | Human, Agent | Active |
| 2 | Capture.Completed | Phase Lifecycle | true | CAPTURED | Human, Agent | Active |
| 3 | Attach.Completed | Phase Lifecycle | true | ATTACHED | Human, Agent | Active |
| 4 | Promote.Completed | Phase Lifecycle | true | PROMOTED | Human, Agent | Active |
| 5 | Close.Completed | Phase Lifecycle | true | DONE | Human, Agent | Active |
| 6 | Scan.Started | Phase Lifecycle | true | SCANNING | Agent | Active |
| 7 | Scan.Completed | Phase Lifecycle | true | SCANNED | Agent | Active |
| 8 | Flag.Completed | Phase Lifecycle | true | FLAGGED | Agent | Active |
| 9 | Repair.Started | Phase Lifecycle | true | REPAIRING | Human, Agent | Active |
| 10 | Repair.Completed | Phase Lifecycle | true | REPAIRED | Human, Agent | Active |
| 11 | Promote.Approved | Human Decision | true | PROMOTING | Human | Active |
| 12 | Promote.Rejected | Human Decision | false | — | Human | Active |
| 13 | Waiver.Granted | Human Decision | true | WAIVED | Human | Active |
| 14 | Waiver.Rejected | Human Decision | false | — | Human | Active |
| 15 | Gate.Passed | Gate | false | — | System, Agent | **Deprecated** → Shared.Gate.Passed |
| 16 | Gate.Failed | Gate | false | — | System, Agent | **Deprecated** → Shared.Gate.Failed |
| 17 | Impediment.Declared | Blocking | true | BLOCKED | Human, Agent | **Deprecated** → Shared.Impediment.Declared |
| 18 | Impediment.Resolved | Blocking | false | — | Human | Active — awaiting Shared.Impediment.Resolved (shared-types v1.1.0) |
| 19 | Divergence.Detected | Diligence | false | — | Agent | Active |
| 20 | Finding.Recorded | Diligence | false | — | Agent | Active |

---

## Diligence Sync — Capture

---

### Capture.Started

| Field | Value |
|---|---|
| **name** | `Capture.Started` |
| **category** | Phase Lifecycle |
| **alters_state** | `true` |
| **new_state** | `CAPTURING` |
| **producer_subtypes** | `[Human, Agent]` |
| **lifecycle_status** | Active |
| **introduced_in** | 1.0.0 |

**description:**
The recording of a new Work Item in the Diligence Journey has started. The Work Item is being
captured — its basic information is being verified and recorded in the system before
being formally associated with the managed project.

**preconditions:**
- The Work Item (OBC or Issue) exists and has been identified as a capture candidate
- The Work Item does not yet have a Timeline in the Diligence Journey

**postconditions:**
- The Work Item transitions to the CAPTURING state
- The Diligence Timeline for this Work Item is created with this event

**payload_shape:**
- `source_id` (string, required): identifier of the source Work Item (e.g., GitHub Issue number)
- `capture_reason` (string, required): reason why the Work Item is being captured

**owner_journey:** Diligence

---

### Capture.Completed

| Field | Value |
|---|---|
| **name** | `Capture.Completed` |
| **category** | Phase Lifecycle |
| **alters_state** | `true` |
| **new_state** | `CAPTURED` |
| **producer_subtypes** | `[Human, Agent]` |
| **lifecycle_status** | Active |
| **introduced_in** | 1.0.0 |

**description:**
The Work Item has been successfully captured. All mandatory information has been verified
and the record is complete. The Work Item awaits association with the managed project (Attach).

**preconditions:**
- The Work Item is in the CAPTURING state
- All mandatory Work Item properties have been verified and are complete
- The Work Item is not duplicated in the system

**postconditions:**
- The Work Item transitions to the CAPTURED state
- The record is complete and ready for the Attach step

**owner_journey:** Diligence

---

## Diligence Sync — Attach

---

### Attach.Completed

| Field | Value |
|---|---|
| **name** | `Attach.Completed` |
| **category** | Phase Lifecycle |
| **alters_state** | `true` |
| **new_state** | `ATTACHED` |
| **producer_subtypes** | `[Human, Agent]` |
| **lifecycle_status** | Active |
| **introduced_in** | 1.0.0 |

**description:**
The Work Item has been successfully associated with the Diligence managed project. From this
event, the Work Item is visible in the project views and can be managed by the promotion cycle.
The Work Item awaits human review for promotion approval.

**preconditions:**
- The Work Item is in the CAPTURED state
- The Diligence managed project exists and is accessible
- The Work Item was not previously associated with the project

**postconditions:**
- The Work Item transitions to the ATTACHED state
- The Work Item is a member of the managed project
- The Work Item appears in the relevant project views

**payload_shape:**
- `project_id` (string, required): identifier of the managed project to which the Work Item was associated
- `project_item_id` (string, required): identifier of the item in the project after association

**owner_journey:** Diligence

---

## Diligence Sync — Promote

---

### Gate.Passed

| Field | Value |
|---|---|
| **name** | `Gate.Passed` |
| **category** | Gate |
| **alters_state** | `false` |
| **producer_subtypes** | `[System, Agent]` |
| **lifecycle_status** | Deprecated |
| **introduced_in** | 1.0.0 |
| **deprecated_in** | 2.0.0 |
| **deprecation_reason** | Promoted to Shared Type. Do not emit new events with this Journey type — use Shared.Gate.Passed. |
| **replacement_type** | `Shared.Gate.Passed` — see [shared-types.md](../../../events/shared-types.md) |

**description:**
An automated verification gate passed successfully. In the Diligence Journey, gates
verify readiness criteria before promotion — completeness of required fields,
presence of canonical labels, conformance with naming standards. The Derived State
is not altered.

**preconditions:**
- The Work Item is in any active state (not DONE, not BLOCKED)
- An automated gate was executed

**postconditions:**
- The gate is recorded as passing in the Timeline
- The Derived State remains unchanged

**payload_shape:**
- `gate_name` (string, required): identifier of the executed gate (e.g., `readiness-check`, `label-conformance`)
- `duration_ms` (integer, required): execution duration in milliseconds

**notes:**
**Promoted to Shared Type in shared-types v1.0.0.** This Journey type has been Deprecated since
v2.0.0 of the catalog. Historical Timelines referencing this type remain valid — the type
remains in the catalog as historical read-only reference only. New emissions should use
`Shared.Gate.Passed`. Complementary pair: Gate.Failed.

**owner_journey:** Diligence

---

### Gate.Failed

| Field | Value |
|---|---|
| **name** | `Gate.Failed` |
| **category** | Gate |
| **alters_state** | `false` |
| **producer_subtypes** | `[System, Agent]` |
| **lifecycle_status** | Deprecated |
| **introduced_in** | 1.0.0 |
| **deprecated_in** | 2.0.0 |
| **deprecation_reason** | Promoted to Shared Type. Do not emit new events with this Journey type — use Shared.Gate.Failed. |
| **replacement_type** | `Shared.Gate.Failed` — see [shared-types.md](../../../events/shared-types.md) |

**description:**
An automated verification gate failed. The verified criterion was not satisfied. The
Work Item remains in the current state — the Producer must take corrective action before a
new promotion attempt.

**preconditions:**
- The Work Item is in any active state (not DONE, not BLOCKED)
- An automated gate was executed and produced a failure result

**postconditions:**
- The gate failure is recorded in the Timeline
- The Derived State remains unchanged
- It is up to the Producer to evaluate whether Promote.Rejected should be emitted

**payload_shape:**
- `gate_name` (string, required): identifier of the executed gate
- `reason` (string, required): description of the criterion that failed
- `duration_ms` (integer, required): execution duration in milliseconds

**notes:**
**Promoted to Shared Type in shared-types v1.0.0.** This Journey type has been Deprecated since
v2.0.0 of the catalog. Historical Timelines remain valid. New emissions should use
`Shared.Gate.Failed`. Complementary pair: Gate.Passed.

**owner_journey:** Diligence

---

### Promote.Approved

| Field | Value |
|---|---|
| **name** | `Promote.Approved` |
| **category** | Human Decision |
| **alters_state** | `true` |
| **new_state** | `PROMOTING` |
| **producer_subtypes** | `[Human]` |
| **lifecycle_status** | Active |
| **introduced_in** | 1.0.0 |

**description:**
A human responsible party has approved the promotion of the Work Item to readiness state. The
approval signals that the Work Item satisfies the Diligence quality criteria and
can be formally promoted.

**preconditions:**
- The Work Item is in the ATTACHED state
- Readiness gates were successfully executed (Gate.Passed in the Timeline)
- Human review was completed

**postconditions:**
- The Work Item transitions to the PROMOTING state
- The promotion can be executed (Promote.Completed will be emitted by the system or agent)

**payload_shape:**
- `approver` (string, required): identity of the responsible party who approved
- `readiness_criteria` (string, required): description of the criteria satisfied for approval

**notes:**
**Semantically different from `Promote.Approved` in Delivery.** In Delivery, this
approval implicitly authorizes production deployment. In Diligence, it authorizes promotion in the backlog
(readiness advancement). Preconditions, postconditions and context are distinct — they are
not candidates for Shared Type.

**owner_journey:** Diligence

---

### Promote.Rejected

| Field | Value |
|---|---|
| **name** | `Promote.Rejected` |
| **category** | Human Decision |
| **alters_state** | `false` |
| **producer_subtypes** | `[Human]` |
| **lifecycle_status** | Active |
| **introduced_in** | 1.0.0 |

**description:**
A human responsible party rejected the promotion of the Work Item. The Work Item did not satisfy
the necessary criteria to advance in readiness. The state remains ATTACHED — the Producer
must correct the deficiencies and submit for new review.

**preconditions:**
- The Work Item is in the ATTACHED state
- A human review was conducted and the Work Item does not meet the criteria

**postconditions:**
- The Derived State remains ATTACHED
- The rejection reason is recorded in the Timeline
- A new review can be requested after the necessary corrections

**payload_shape:**
- `rejector` (string, required): identity of the responsible party who rejected
- `reason` (string, required): description of the criterion not satisfied

**owner_journey:** Diligence

---

### Promote.Completed

| Field | Value |
|---|---|
| **name** | `Promote.Completed` |
| **category** | Phase Lifecycle |
| **alters_state** | `true` |
| **new_state** | `PROMOTED` |
| **producer_subtypes** | `[Human, Agent]` |
| **lifecycle_status** | Active |
| **introduced_in** | 1.0.0 |

**description:**
The Work Item has been successfully promoted to the readiness level. The promotion was executed
after human approval (Promote.Approved). The Work Item awaits formal closure by
the responsible party.

**preconditions:**
- The Work Item is in the PROMOTING state
- Promote.Approved was recorded in the Timeline before this event

**postconditions:**
- The Work Item transitions to the PROMOTED state
- The Work Item is formally at the reached readiness level

**notes:**
**Semantically different from `Promote.Completed` in Delivery.** In Delivery, it represents
production deployment with final state DONE. In Diligence, it represents readiness promotion
in the backlog — it is not the final state (Close.Completed is still required).

**owner_journey:** Diligence

---

## Diligence Sync — Close

---

### Close.Completed

| Field | Value |
|---|---|
| **name** | `Close.Completed` |
| **category** | Phase Lifecycle |
| **alters_state** | `true` |
| **new_state** | `DONE` |
| **producer_subtypes** | `[Human, Agent]` |
| **lifecycle_status** | Active |
| **introduced_in** | 1.0.0 |

**description:**
The Diligence Sync cycle was successfully concluded. The Work Item was promoted and formally
closed by the responsible party. The DONE state indicates that the Sync cycle is complete for this
Work Item — the Async cycle may be initiated in future iterations.

**preconditions:**
- The Work Item is in the PROMOTED state
- Promote.Completed was recorded in the Timeline
- The responsible party confirmed the closure

**postconditions:**
- The Work Item transitions to the DONE state
- The Diligence Sync cycle is concluded
- The Timeline remains open for correction events and for the future Async cycle

**owner_journey:** Diligence

---

## Diligence Async — Scan

---

### Scan.Started

| Field | Value |
|---|---|
| **name** | `Scan.Started` |
| **category** | Phase Lifecycle |
| **alters_state** | `true` |
| **new_state** | `SCANNING` |
| **producer_subtypes** | `[Agent]` |
| **lifecycle_status** | Active |
| **introduced_in** | 1.0.0 |

**description:**
The asynchronous scanning cycle has been initiated for the Work Item. The Diligence agent is
verifying the Work Item's conformance against defined criteria — labels,
required fields, project association, expected states.

**preconditions:**
- The Work Item has an active Timeline in the Diligence Journey
- The scheduled scanning cycle was triggered

**postconditions:**
- The Work Item transitions to the SCANNING state
- The Diligence agent is executing the verifications

**payload_shape:**
- `scan_cycle` (string, required): scanning cycle identifier (e.g., `2026-Q3-W30`)
- `criteria_version` (string, required): version of the conformance criteria applied

**owner_journey:** Diligence

---

### Divergence.Detected

| Field | Value |
|---|---|
| **name** | `Divergence.Detected` |
| **category** | Diligence |
| **alters_state** | `false` |
| **producer_subtypes** | `[Agent]` |
| **lifecycle_status** | Active |
| **introduced_in** | 1.0.0 |

**description:**
A divergence from conformance criteria was detected during the scan.
Each divergence found generates a separate event — multiple events may be emitted
during the same scan cycle. The Derived State remains SCANNING.

**preconditions:**
- The Work Item is in the SCANNING state
- The agent identified a specific divergence during the scan

**postconditions:**
- The divergence is recorded in the Timeline with description
- The Derived State remains SCANNING
- The divergence will be evaluated at the end of the scan (Scan.Completed)

**payload_shape:**
- `divergence_type` (string, required): category of the detected divergence (e.g., `missing-label`, `stale-state`, `missing-required-field`)
- `divergence_description` (string, required): detailed description of the divergence found
- `severity` (string, required): divergence severity (`high`, `medium`, `low`)

**owner_journey:** Diligence

---

### Finding.Recorded

| Field | Value |
|---|---|
| **name** | `Finding.Recorded` |
| **category** | Diligence |
| **alters_state** | `false` |
| **producer_subtypes** | `[Agent]` |
| **lifecycle_status** | Active |
| **introduced_in** | 1.0.0 |

**description:**
A specific audit finding has been recorded for the Work Item during the scan.
Unlike Divergence.Detected (which records an operational non-conformance), the
Finding documents a structural observation that may or may not require immediate action.

**preconditions:**
- The Work Item is in the SCANNING state
- The agent identified a relevant finding for audit

**postconditions:**
- The finding is recorded in the Timeline
- The Derived State remains SCANNING
- The finding will be available for Assessment analysis

**payload_shape:**
- `finding_type` (string, required): finding category (e.g., `stale-timeline`, `missing-evidence`, `producer-anomaly`)
- `finding_description` (string, required): detailed description of the finding
- `action_required` (boolean, required): indicates whether the finding requires corrective action

**owner_journey:** Diligence

---

### Scan.Completed

| Field | Value |
|---|---|
| **name** | `Scan.Completed` |
| **category** | Phase Lifecycle |
| **alters_state** | `true` |
| **new_state** | `SCANNED` |
| **producer_subtypes** | `[Agent]` |
| **lifecycle_status** | Active |
| **introduced_in** | 1.0.0 |

**description:**
The asynchronous scanning cycle was completed for the Work Item. All verifications
were executed. The result (divergences and findings) is recorded in the Timeline.
The next event will be Flag.Completed (if divergences were found) or none
(if the scan resulted in full conformance).

**preconditions:**
- The Work Item is in the SCANNING state
- All verifications of the scanning cycle were executed

**postconditions:**
- The Work Item transitions to the SCANNED state
- All Divergence.Detected and Finding.Recorded of the cycle are recorded
- The agent will evaluate whether Flag.Completed should be emitted

**payload_shape:**
- `scan_cycle` (string, required): identifier of the completed scanning cycle
- `divergences_found` (integer, required): number of divergences detected
- `findings_found` (integer, required): number of findings recorded
- `compliant` (boolean, required): `true` if no divergence was detected

**owner_journey:** Diligence

---

## Diligence Async — Flag

---

### Flag.Completed

| Field | Value |
|---|---|
| **name** | `Flag.Completed` |
| **category** | Phase Lifecycle |
| **alters_state** | `true` |
| **new_state** | `FLAGGED` |
| **producer_subtypes** | `[Agent]` |
| **lifecycle_status** | Active |
| **introduced_in** | 1.0.0 |

**description:**
The divergences found during the scan have been formally flagged. The Work Item
requires corrective action — repair of the divergences or granting of waiver. The FLAGGED state
indicates that the Work Item is not in conformance and needs attention.

**preconditions:**
- The Work Item is in the SCANNED state
- At least one Divergence.Detected was recorded in the scanning cycle
- `compliant = false` in the corresponding Scan.Completed

**postconditions:**
- The Work Item transitions to the FLAGGED state
- The divergences are formally flagged and awaiting action
- Repair.Started or Waiver.Granted are the next expected events

**payload_shape:**
- `flagged_divergences_count` (integer, required): number of divergences flagged
- `highest_severity` (string, required): highest severity among the flagged divergences

**owner_journey:** Diligence

---

## Diligence Async — Repair

---

### Repair.Started

| Field | Value |
|---|---|
| **name** | `Repair.Started` |
| **category** | Phase Lifecycle |
| **alters_state** | `true` |
| **new_state** | `REPAIRING` |
| **producer_subtypes** | `[Human, Agent]` |
| **lifecycle_status** | Active |
| **introduced_in** | 1.0.0 |

**description:**
The repair process for the flagged divergences has started. The responsible party (human
or agent) is applying the necessary corrections to restore the Work Item's conformance.

**preconditions:**
- The Work Item is in the FLAGGED state
- The responsible party for the repair has been identified

**postconditions:**
- The Work Item transitions to the REPAIRING state
- The repair is in progress

**payload_shape:**
- `repairer` (string, required): identity of the responsible party for the repair
- `repair_plan` (string, required): description of the planned repair actions

**owner_journey:** Diligence

---

### Repair.Completed

| Field | Value |
|---|---|
| **name** | `Repair.Completed` |
| **category** | Phase Lifecycle |
| **alters_state** | `true` |
| **new_state** | `REPAIRED` |
| **producer_subtypes** | `[Human, Agent]` |
| **lifecycle_status** | Active |
| **introduced_in** | 1.0.0 |

**description:**
The repair of the divergences was successfully completed. The Work Item is in conformance.
The Diligence Async cycle is concluded for this iteration — the Work Item may be
scanned again in future cycles.

**preconditions:**
- The Work Item is in the REPAIRING state
- All flagged divergences were corrected
- The agent or human confirmed the completion of the repair

**postconditions:**
- The Work Item transitions to the REPAIRED state
- The Work Item is in conformance with Diligence criteria
- The Timeline remains open for future scanning cycles

**payload_shape:**
- `repairs_applied` (integer, required): number of corrections applied
- `verification_result` (string, required): description of the post-repair verification

**owner_journey:** Diligence

---

## Cross-cutting Events — Human Decision (Waiver)

---

### Waiver.Granted

| Field | Value |
|---|---|
| **name** | `Waiver.Granted` |
| **category** | Human Decision |
| **alters_state** | `true` |
| **new_state** | `WAIVED` |
| **producer_subtypes** | `[Human]` |
| **lifecycle_status** | Active |
| **introduced_in** | 1.0.0 |

**description:**
A formal exception has been granted for one or more flagged divergences. The waiver
represents an explicit decision that the divergence is acceptable under the current
circumstances — without need for repair. The Work Item transitions to WAIVED — approved
exception state.

**preconditions:**
- The Work Item is in the FLAGGED state
- A waiver request was presented and evaluated by an authorized responsible party

**postconditions:**
- The Work Item transitions to the WAIVED state
- The exception is formally recorded with justification
- The Work Item does not need repair for the divergences covered by the waiver

**payload_shape:**
- `waiver_authority` (string, required): identity of who granted the waiver
- `justification` (string, required): formal justification for granting the waiver
- `waiver_scope` (string, required): which specific divergences are covered by the waiver
- `expiration` (string, optional): cycle or date when the waiver expires and must be re-evaluated

**notes:**
Concept exclusive to the Diligence Journey — no equivalent exists in the Delivery catalog.
The Waiver formalizes the management of operational exceptions.

**owner_journey:** Diligence

---

### Waiver.Rejected

| Field | Value |
|---|---|
| **name** | `Waiver.Rejected` |
| **category** | Human Decision |
| **alters_state** | `false` |
| **producer_subtypes** | `[Human]` |
| **lifecycle_status** | Active |
| **introduced_in** | 1.0.0 |

**description:**
The waiver request was rejected. The flagged divergences were not accepted as exceptionable
— the Work Item must be repaired. The state remains FLAGGED and Repair.Started
is the next expected event.

**preconditions:**
- The Work Item is in the FLAGGED state
- A waiver request was evaluated and rejected

**postconditions:**
- The Derived State remains FLAGGED
- The rejection reason is recorded in the Timeline
- Repair.Started is the next expected event

**payload_shape:**
- `rejector` (string, required): identity of who rejected the waiver
- `reason` (string, required): rejection reason

**owner_journey:** Diligence

---

## Cross-cutting Events — Blocking

---

### Impediment.Declared

| Field | Value |
|---|---|
| **name** | `Impediment.Declared` |
| **category** | Blocking |
| **alters_state** | `true` |
| **new_state** | `BLOCKED` |
| **producer_subtypes** | `[Human, Agent]` |
| **lifecycle_status** | Deprecated |
| **introduced_in** | 1.0.0 |
| **deprecated_in** | 2.0.0 |
| **deprecation_reason** | Promoted to Shared Type. Do not emit new events with this Journey type — use Shared.Impediment.Declared. |
| **replacement_type** | `Shared.Impediment.Declared` — see [shared-types.md](../../../events/shared-types.md) |

**description:**
An external impediment has been declared for the Work Item. Diligence work cannot
progress until the impediment is resolved. Can occur in any phase of the Sync or Async cycles.

**preconditions:**
- The Work Item is in any active state (not DONE, not BLOCKED, not REPAIRED, not WAIVED)
- An external impediment was identified that prevents progression

**postconditions:**
- The Work Item transitions to the BLOCKED state
- Work is suspended until Impediment.Resolved

**payload_shape:**
- `impediment_description` (string, required): description of the impediment and who can resolve it
- `blocking_since` (string, required): timestamp of when the impediment was identified

**notes:**
**Promoted to Shared Type in shared-types v1.0.0.** This Journey type has been Deprecated since
v2.0.0 of the catalog. Historical Timelines referencing this type remain valid. New
emissions should use `Shared.Impediment.Declared`. Complementary pair: Impediment.Resolved.

**owner_journey:** Diligence

---

### Impediment.Resolved

| Field | Value |
|---|---|
| **name** | `Impediment.Resolved` |
| **category** | Blocking |
| **alters_state** | `false` |
| **producer_subtypes** | `[Human]` |
| **lifecycle_status** | Active |
| **introduced_in** | 1.0.0 |

**description:**
The external impediment was resolved and work can be resumed. The Work Item returns
to the state it was in before the impediment was declared.

The return state **is not hardcoded** in this type — the Consumer uses the Lookback
mechanism (`preBlockedState`) defined in `timeline.md` to calculate the state prior
to BLOCKED. This is the refined implementation of the mechanism, different from the simplification
adopted in the Delivery MVP catalog.

**preconditions:**
- The Work Item is in the BLOCKED state
- The impediment declared in Impediment.Declared was resolved

**postconditions:**
- The Derived State **is not directly altered** by this event (`alters_state = false`)
- The Consumer uses Lookback to determine the return state (pre-BLOCKED state)
- The impediment resolution is recorded in the Timeline

**payload_shape:**
- `resolution_description` (string, required): description of how the impediment was resolved

**notes:**
**Candidate for promotion as Shared Type.** Awaiting shared-types v1.1.0 — blocked
by the need for technical convergence of Delivery v2 (completed). The promotion of
`Shared.Impediment.Resolved` to Active will be the unblocking to deprecate this Journey type.
When shared-types v1.1.0 is published, this type will be marked as
Deprecated with `replacement_type: Shared.Impediment.Resolved`.

**owner_journey:** Diligence

---

## Reference flows

### Happy path — complete Diligence Sync

```
Timeline: OBC-Checkout
────────────────────────────────────────────────────
Diligence Sync
  1. Capture.Started    → CAPTURING
  2. Capture.Completed  → CAPTURED
  3. Attach.Completed   → ATTACHED
  4. Gate.Passed        (readiness-check)
  5. Promote.Approved   → PROMOTING
  6. Promote.Completed  → PROMOTED
  7. Close.Completed    → DONE
────────────────────────────────────────────────────
Derived State: DONE
Events alters_state=true: 6 | false: 1
```

### Flow with divergence and repair — Diligence Async

```
Timeline: OBC-Checkout (continuation of Sync above)
────────────────────────────────────────────────────
Diligence Async (Q3 iteration)
  8. Scan.Started        → SCANNING
  9. Divergence.Detected  (missing-label, high)
 10. Finding.Recorded    (stale-timeline, action_required=false)
 11. Scan.Completed      → SCANNED (compliant=false, divergences=1)
 12. Flag.Completed      → FLAGGED
 13. Repair.Started      → REPAIRING
 14. Repair.Completed    → REPAIRED
────────────────────────────────────────────────────
Derived State: REPAIRED
```

### Flow with waiver

```
  8. Scan.Started        → SCANNING
  9. Divergence.Detected  (legacy-field, low)
 10. Scan.Completed      → SCANNED (compliant=false, divergences=1)
 11. Flag.Completed      → FLAGGED
 12. Waiver.Granted      → WAIVED (justification: "legacy field, migration Q4")
────────────────────────────────────────────────────
Derived State: WAIVED
```

### Flow with impediment — Lookback in action

```
  8. Scan.Started        → SCANNING
  9. Impediment.Declared → BLOCKED
 10. Impediment.Resolved → alters_state=false [Lookback → returns SCANNING]
 11. Divergence.Detected  (missing-label, medium)
 12. Scan.Completed      → SCANNED (compliant=false)
 13. Flag.Completed      → FLAGGED
 14. Repair.Started      → REPAIRING
 15. Repair.Completed    → REPAIRED

Lookback at pos 10:
  Impediment.Declared found at pos 9
  Search before pos 9: pos 8 = Scan.Started, new_state=SCANNING (≠ BLOCKED)
  Return state: SCANNING  ✓
```

---

*All 20 Event Types in this catalog satisfy Event Type Schema v1.0.0.*
*Catalog version: 2.0.0. Active: 17. Deprecated: 3 (Gate.Passed, Gate.Failed, Impediment.Declared). Impediment.Resolved: Active — awaiting shared-types v1.1.0 for formal deprecation.*
