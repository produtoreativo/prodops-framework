# Delivery Event Catalog — v2
# ProdOps Framework — Delivery Journey

> **Version:** 2.0.0
> **Status:** Active
> **Namespace:** `Delivery`
> **Journey:** Delivery
> **Schema:** [Event Type Schema v1.0.0](../../../events/event-type-schema.md)
> **Changelog v2.0.0:** Gate.Passed, Gate.Failed, Impediment.Declared → Deprecated (promoted to Active Shared Types). Impediment.Resolved → technical convergence: alters_state=false, Lookback. Cutover: 2026-07-25. Prepared for deprecation after shared-types v1.1.0.

---

## Overview

| # | Event Type | Category | alters_state | new_state | Producers | Status v2 |
|---|---|---|---|---|---|---|
| 1 | Bootstrap.Started | Phase Lifecycle | true | BOOTSTRAPPING | Human, Agent | Active |
| 2 | Bootstrap.Completed | Phase Lifecycle | true | HACKING | Human, Agent | Active |
| 3 | Hack.Completed | Phase Lifecycle | true | SYNCING | Human, Agent | Active |
| 4 | Sync.Completed | Phase Lifecycle | true | FINISHING | System | Active |
| 5 | Finish.Completed | Phase Lifecycle | true | SHIPPING | Human, Agent | Active |
| 6 | Ship.Completed | Phase Lifecycle | true | VALIDATING | System | Active |
| 7 | Promote.Completed | Phase Lifecycle | true | DONE | System | Active |
| 8 | Gate.Passed | Gate | false | — | System, Agent | **Deprecated** → Shared.Gate.Passed |
| 9 | Gate.Failed | Gate | false | — | System, Agent | **Deprecated** → Shared.Gate.Failed |
| 10 | Validate.Started | Phase Lifecycle | false | — | System, Agent | Active |
| 11 | Validate.Completed | Phase Lifecycle | false | — | System, Agent | Active |
| 12 | Promote.Approved | Human Decision | true | PROMOTING | Human | Active |
| 13 | Promote.Rejected | Human Decision | true | VALIDATING | Human | Active |
| 14 | Impediment.Declared | Blocking | true | BLOCKED | Human, Agent | **Deprecated** → Shared.Impediment.Declared |
| 15 | Impediment.Resolved | Blocking | false | — (Lookback) | Human | Active — converged v2 |
| 16 | Rework.Declared | Rework | true | HACKING | Human, Agent | Active |
| 17 | Rework.Completed | Rework | true | SYNCING | Human, Agent | **Deprecated** → Rework.Resolved |
| 18 | Rework.Resolved | Rework | true | SYNCING | Human, Agent | Active |

---

## CI Sync — Bootstrap

---

### Bootstrap.Started

| Field | Value |
|---|---|
| **name** | `Bootstrap.Started` |
| **category** | Phase Lifecycle |
| **alters_state** | `true` |
| **new_state** | `BOOTSTRAPPING` |
| **producer_subtypes** | `[Human, Agent]` |
| **lifecycle_status** | Active |
| **introduced_in** | 1.0.0 |

**description:**
The Work Item has started the Bootstrap Phase. The work environment is being prepared:
the branch will be created, dependencies will be installed, and the initial smoke gate
will be executed.

**preconditions:**
- The Work Item is active in the backlog with a complete definition of done
- The Work Item is not in any previous active state (first state event on the Timeline)
- No other Work Item is in BOOTSTRAPPING for the same developer in the same cycle

**postconditions:**
- The Work Item transitions to the BOOTSTRAPPING state
- The Timeline records Bootstrap.Started as the first state event

**payload_shape:**
- `assignee` (string, required): identity of the developer who started Bootstrap
- `base_branch` (string, required): name of the repository base branch

**owner_journey:** Delivery

---

### Bootstrap.Completed

| Field | Value |
|---|---|
| **name** | `Bootstrap.Completed` |
| **category** | Phase Lifecycle |
| **alters_state** | `true` |
| **new_state** | `HACKING` |
| **producer_subtypes** | `[Human, Agent]` |
| **lifecycle_status** | Active |
| **introduced_in** | 1.0.0 |

**description:**
The Bootstrap Phase has been completed successfully. The working branch has been created,
the environment is configured, and the initial smoke gate passed. The Work Item is ready
for active development.

**preconditions:**
- The Work Item is in the BOOTSTRAPPING state
- The working branch has been created successfully
- The initial smoke gate passed (Shared.Gate.Passed was recorded on the Timeline before this event)

**postconditions:**
- The Work Item transitions to the HACKING state
- The Timeline contains Bootstrap.Started followed by Bootstrap.Completed

**payload_shape:**
- `branch_name` (string, required): name of the branch created for the Work Item
- `base_commit` (string, required): hash of the branch's base commit

**owner_journey:** Delivery

---

## CI Sync — Hack

---

### Hack.Completed

| Field | Value |
|---|---|
| **name** | `Hack.Completed` |
| **category** | Phase Lifecycle |
| **alters_state** | `true` |
| **new_state** | `SYNCING` |
| **producer_subtypes** | `[Human, Agent]` |
| **lifecycle_status** | Active |
| **introduced_in** | 1.0.0 |

**description:**
The Work Item implementation has been completed by the developer. A Pull Request has been
opened for code review. The Work Item is awaiting review by peers.

**preconditions:**
- The Work Item is in the HACKING state
- At least one commit has been added to the working branch
- A Pull Request has been opened pointing to the base branch

**postconditions:**
- The Work Item transitions to the SYNCING state
- The Timeline records Hack.Completed with a reference to the opened PR

**payload_shape:**
- `pr_number` (integer, required): number of the opened Pull Request
- `pr_title` (string, required): title of the Pull Request
- `commits_count` (integer, required): number of commits in the PR

**owner_journey:** Delivery

---

## CI Sync — Sync

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
An automated quality gate passed successfully. The gate verifies a specific quality criterion
— lint, tests, coverage, security — without altering the Work Item state. Multiple Gate.Passed
may occur in the same Timeline in different Phases.

**preconditions:**
- The Work Item is in any active state (not DONE, not BLOCKED)
- An automated gate has been executed

**postconditions:**
- The gate is recorded as passing on the Timeline
- The Derived State is not altered

**payload_shape:**
- `gate_name` (string, required): identifier of the executed gate (e.g.: `smoke-test`, `lint`, `unit-tests`)
- `duration_ms` (integer, required): gate execution duration in milliseconds

**notes:**
**Promoted to Shared Type in shared-types v1.0.0.** This Journey type has been Deprecated
since v2.0.0 of the catalog. Historical Timelines referencing this type remain valid — the
type remains in the catalog as a read-only historical reference. New emissions must use
`Shared.Gate.Passed`. Complementary pair: Gate.Failed.

**owner_journey:** Delivery

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
An automated quality gate failed. The gate verified a quality criterion that was not
satisfied. The Work Item remains in the current state — the gate failure is a signal for
the Producer to initiate correction (Rework or a new attempt).

**preconditions:**
- The Work Item is in any active state (not DONE, not BLOCKED)
- An automated gate has been executed and produced a failure result

**postconditions:**
- The gate failure is recorded on the Timeline
- The Derived State is not altered
- The Producer is responsible for declaring Rework.Declared if the failure requires returning to development

**payload_shape:**
- `gate_name` (string, required): identifier of the executed gate
- `reason` (string, required): description of the cause of failure
- `duration_ms` (integer, required): gate execution duration in milliseconds

**notes:**
**Promoted to Shared Type in shared-types v1.0.0.** This Journey type has been Deprecated
since v2.0.0 of the catalog. Historical Timelines remain valid. New emissions must use
`Shared.Gate.Failed`. Complementary pair: Gate.Passed.

**owner_journey:** Delivery

---

### Sync.Completed

| Field | Value |
|---|---|
| **name** | `Sync.Completed` |
| **category** | Phase Lifecycle |
| **alters_state** | `true` |
| **new_state** | `FINISHING` |
| **producer_subtypes** | `[System]` |
| **lifecycle_status** | Active |
| **introduced_in** | 1.0.0 |

**description:**
The Sync Phase has been completed. The feature branch has incorporated the latest changes
from origin (fetch + rebase) and ProdOps artifacts have been aligned with the current
state of the implementation (BDD Features, Event Storming, architecture, Release Trail).
Sync does not publish or update origin — it only synchronizes the local state with what
already exists there.

**preconditions:**
- The Work Item is in the SYNCING state
- The feature branch fetch + rebase over origin was executed without unresolved conflicts
- ProdOps artifacts have been verified and are aligned with the current state of the implementation

**postconditions:**
- The Work Item transitions to the FINISHING state
- The feature branch is updated with origin
- ProdOps artifacts reflect the current state of the implementation
- No changes have been published to origin

**payload_shape:**
- `rebase_commit` (string, required): hash of the HEAD commit after rebase
- `base_branch` (string, required): base branch used in the rebase (e.g.: `master`)
- `aligned_artifacts` (array, optional): list of verified ProdOps artifacts (e.g.: `["bdd", "event-storming", "release-trail"]`)

**owner_journey:** Delivery

---

## CI Sync — Finish

---

### Finish.Completed

| Field | Value |
|---|---|
| **name** | `Finish.Completed` |
| **category** | Phase Lifecycle |
| **alters_state** | `true` |
| **new_state** | `SHIPPING` |
| **producer_subtypes** | `[Human, Agent]` |
| **lifecycle_status** | Active |
| **introduced_in** | 1.0.0 |

**description:**
The Finish Phase has been completed. The final CI Sync checks have been satisfied — the
Work Item is validated and ready for the asynchronous delivery cycle. From this event
onward, the Work Item enters CI Async.

**preconditions:**
- The Work Item is in the FINISHING state
- The CI Sync definition of done criteria are satisfied (passing tests, minimum coverage reached)

**postconditions:**
- The Work Item transitions to the SHIPPING state
- CI Sync is closed for this Work Item
- The Work Item may be included in the next Ship cycle

**owner_journey:** Delivery

---

## CI Async — Ship

---

### Ship.Completed

| Field | Value |
|---|---|
| **name** | `Ship.Completed` |
| **category** | Phase Lifecycle |
| **alters_state** | `true` |
| **new_state** | `VALIDATING` |
| **producer_subtypes** | `[System]` |
| **lifecycle_status** | Active |
| **introduced_in** | 1.0.0 |

**description:**
The Work Item has been successfully deployed to Staging. The Ship Phase has been completed.
The Work Item is available for validation in Staging.

**preconditions:**
- The Work Item is in the SHIPPING state
- The Staging deployment pipeline was executed successfully

**postconditions:**
- The Work Item transitions to the VALIDATING state
- The Work Item is accessible in Staging for validation

**payload_shape:**
- `environment` (string, required): identifier of the Staging environment where it was deployed
- `deploy_version` (string, required): version or tag deployed

**owner_journey:** Delivery

---

## CI Async — Validate

---

### Validate.Started

| Field | Value |
|---|---|
| **name** | `Validate.Started` |
| **category** | Phase Lifecycle |
| **alters_state** | `false` |
| **producer_subtypes** | `[System, Agent]` |
| **lifecycle_status** | Active |
| **introduced_in** | 2.1.0 |

**description:**
The Validate Phase has started. Automated validation tests in Staging are running. The
Derived State remains VALIDATING — set by the preceding Ship.Completed.

**preconditions:**
- The Work Item is in the VALIDATING state
- Ship.Completed has been recorded on the Timeline

**postconditions:**
- The start of validation is recorded on the Timeline
- The Derived State remains VALIDATING

**payload_shape:**
- `validation_suite` (string, required): identifier of the test suite being executed (e.g.: `e2e`, `smoke`, `contract`)
- `environment` (string, required): environment where validation is being executed (e.g.: `staging`)

**owner_journey:** Delivery

---

### Validate.Completed

| Field | Value |
|---|---|
| **name** | `Validate.Completed` |
| **category** | Phase Lifecycle |
| **alters_state** | `false` |
| **producer_subtypes** | `[System, Agent]` |
| **lifecycle_status** | Active |
| **introduced_in** | 2.1.0 |

**description:**
The Validate Phase has been completed successfully. All automated validation gates passed
in Staging. The Work Item is ready for the human promotion decision (Promote.Approved or
Promote.Rejected). The Derived State remains VALIDATING until the human decision is
recorded.

**preconditions:**
- The Work Item is in the VALIDATING state
- Validate.Started has been recorded on the Timeline
- All required Shared.Gate.Passed have been recorded

**postconditions:**
- Completion of validation is recorded on the Timeline
- The Derived State remains VALIDATING — awaiting Promote.Approved or Promote.Rejected

**payload_shape:**
- `validation_suite` (string, required): identifier of the executed suite
- `gates_passed` (integer, required): number of gates that passed
- `duration_ms` (integer, required): total duration of the validation suite

**owner_journey:** Delivery

---

## CI Async — Promote

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
A human responsible approved the Work Item's promotion to Sandbox after validation in
Staging. The approval is the formal decision that the Work Item is ready to enter
Sandbox (Release Candidate). Production is outside the Delivery Journey — the Production
deploy is triggered manually via GitHub Actions.

**preconditions:**
- The Work Item is in the VALIDATING state
- Staging validation has been completed satisfactorily

**postconditions:**
- The Work Item transitions to the PROMOTING state
- The Sandbox deployment pipeline can be started

**payload_shape:**
- `approver` (string, required): identity of who approved the promotion
- `environment_validated` (string, required): environment where validation was performed (Staging)

**owner_journey:** Delivery

---

### Promote.Rejected

| Field | Value |
|---|---|
| **name** | `Promote.Rejected` |
| **category** | Human Decision |
| **alters_state** | `true` |
| **new_state** | `VALIDATING` |
| **producer_subtypes** | `[Human]` |
| **lifecycle_status** | Active |
| **introduced_in** | 1.0.0 |

**description:**
A human responsible rejected the Work Item's promotion to Sandbox. The Work Item returns
to the VALIDATING state — new validations in Staging must be performed before a new
promotion decision.

**preconditions:**
- The Work Item is in the VALIDATING state
- An evaluation of the Work Item in Staging was performed

**postconditions:**
- The Work Item returns to the VALIDATING state
- The rejection reason is recorded on the Timeline
- A new approval will be required to promote to Sandbox

**payload_shape:**
- `rejector` (string, required): identity of who rejected the promotion
- `reason` (string, required): reason for rejection

**owner_journey:** Delivery

---

### Promote.Completed

| Field | Value |
|---|---|
| **name** | `Promote.Completed` |
| **category** | Phase Lifecycle |
| **alters_state** | `true` |
| **new_state** | `DONE` |
| **producer_subtypes** | `[System]` |
| **lifecycle_status** | Active |
| **introduced_in** | 1.0.0 |

**description:**
The Work Item has been successfully deployed to Sandbox (Release Candidate). The CI Async
cycle is closed. The Work Item has reached its final state in the Delivery Journey — it
is delivered and available in Sandbox for release validation. The Production deploy is a
separate step, triggered manually via GitHub Actions, outside the Delivery Journey.

**preconditions:**
- The Work Item is in the PROMOTING state
- Promote.Approved has been recorded on the Timeline
- The Sandbox deployment pipeline was executed successfully

**postconditions:**
- The Work Item transitions to the DONE state
- The Work Item is available in Sandbox
- No new state events are expected for this Work Item (except Correction)

**payload_shape:**
- `environment` (string, required): identifier of the target environment (`sandbox`)
- `deploy_version` (string, required): version or tag deployed
- `deploy_commit` (string, required): hash of the deployed commit

**owner_journey:** Delivery

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
An external impediment has been declared for the Work Item. The Work Item is blocked —
work cannot progress until the impediment is resolved. The impediment may be declared
in any Phase.

**preconditions:**
- The Work Item is in any active state (not DONE, not BLOCKED)
- An external impediment has been identified that prevents Work Item progression

**postconditions:**
- The Work Item transitions to the BLOCKED state
- The impediment is recorded on the Timeline with description
- Work is suspended until Impediment.Resolved

**payload_shape:**
- `impediment_description` (string, required): description of the impediment and who or what can resolve it
- `blocking_since` (string, required): timestamp when the impediment was identified (may be earlier than the event timestamp)

**notes:**
**Promoted to Shared Type in shared-types v1.0.0.** This Journey type has been Deprecated
since v2.0.0 of the catalog. Historical Timelines referencing this type remain valid. New
emissions must use `Shared.Impediment.Declared`. Complementary pair: Impediment.Resolved.

**owner_journey:** Delivery

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
| **convergence_version** | 2.0.0 |
| **migration_cutover** | 2026-07-25 |
| **migration_note** | Converged to canonical pattern (alters_state=false, Lookback). Consumers that depended on new_state=HACKING must use preBlockedState(). Events emitted before the cutover (2026-07-25) are interpreted under v1 rules. |

**description:**
The external impediment has been resolved and work can resume. The Work Item returns to
the state it was in before the impediment was declared.

The return state is **not hardcoded** in this type — the Consumer uses the Lookback
mechanism (`preBlockedState`) defined in `timeline.md` to calculate the state prior to
BLOCKED. This is the canonical implementation, aligned with Diligence and Assessment.

**preconditions:**
- The Work Item is in the BLOCKED state
- The impediment declared in Impediment.Declared (or Shared.Impediment.Declared) has been resolved

**postconditions:**
- The Derived State is **not directly altered** by this event (`alters_state = false`)
- The Consumer uses Lookback to determine the return state (pre-BLOCKED state)
- The impediment resolution is recorded on the Timeline

**payload_shape:**
- `resolution_description` (string, required): description of how the impediment was resolved

**notes:**
**Converged to canonical pattern in v2.0.0.** In v1.0.0, this type used `alters_state=true,
new_state=HACKING` — an MVP simplification that always returned to the HACKING state,
regardless of the pre-BLOCKED state. v2.0.0 corrects this simplification: the Consumer
must use Lookback (`preBlockedState`) to determine the correct return state.

**Backward compatibility:** events emitted before 2026-07-25 (v1→v2 cutover) were recorded
under v1 rules and are interpreted as `alters_state=true, new_state=HACKING` for historical
replay purposes. Use the event `timestamp` as a discriminator.

**Next step:** after shared-types v1.1.0 promotes `Shared.Impediment.Resolved` to Active,
this type will be marked as Deprecated with `replacement_type: Shared.Impediment.Resolved`.
Complementary pair: Impediment.Declared.

**owner_journey:** Delivery

---

## Cross-cutting Events — Rework

---

### Rework.Declared

| Field | Value |
|---|---|
| **name** | `Rework.Declared` |
| **category** | Rework |
| **alters_state** | `true` |
| **new_state** | `HACKING` |
| **producer_subtypes** | `[Human, Agent]` |
| **lifecycle_status** | Active |
| **introduced_in** | 1.0.0 |

**description:**
A rework cycle has been declared for the Work Item. The Work Item returns to active
development — the implementation needs to be revised or corrected before a new attempt
at review and delivery.

**preconditions:**
- The Work Item is in the SYNCING or FINISHING state
- A rework reason has been identified (Gate.Failed, Review.ChangesRequested, or human decision)

**postconditions:**
- The Work Item transitions to the HACKING state
- The rework is recorded on the Timeline with the reason
- The developer resumes development on the existing branch or a new branch

**payload_shape:**
- `rework_reason` (string, required): description of what motivated the rework
- `origin_event_id` (string, optional): id of the event that motivated the rework (e.g.: Gate.Failed or Review.ChangesRequested)

**notes:**
Shared Type candidate — the semantics of returning to development due to insufficient
quality are generic. Complementary pair: Rework.Resolved.

**owner_journey:** Delivery

---

### Rework.Completed

| Field | Value |
|---|---|
| **name** | `Rework.Completed` |
| **category** | Rework |
| **alters_state** | `true` |
| **new_state** | `SYNCING` |
| **producer_subtypes** | `[Human, Agent]` |
| **lifecycle_status** | Deprecated |
| **introduced_in** | 1.0.0 |
| **deprecated_in** | 2.1.0 |
| **deprecation_reason** | Name does not follow REG-09 of the Taxonomy (complementary pair must use `.Resolved`, not `.Completed`). Use Rework.Resolved. |
| **replacement_type** | `Rework.Resolved` |

**description:**
Deprecated. See Rework.Resolved.

**notes:**
Historical Timelines referencing this type remain valid — interpreted as
`alters_state=true, new_state=SYNCING`. New emissions must use `Rework.Resolved`.

**owner_journey:** Delivery

---

### Rework.Resolved

| Field | Value |
|---|---|
| **name** | `Rework.Resolved` |
| **category** | Rework |
| **alters_state** | `true` |
| **new_state** | `SYNCING` |
| **producer_subtypes** | `[Human, Agent]` |
| **lifecycle_status** | Active |
| **introduced_in** | 2.1.0 |

**description:**
The rework cycle has been resolved. The necessary corrections have been implemented and the
Work Item resumes the normal flow from Sync — rebase + align before proceeding to Finish.

**preconditions:**
- The Work Item is in the HACKING state after a Rework.Declared
- The necessary corrections have been implemented and committed

**postconditions:**
- The Work Item transitions to the SYNCING state
- The Timeline contains Rework.Declared before Rework.Resolved

**payload_shape:**
- `changes_description` (string, required): description of the changes made during rework
- `origin_event_id` (string, optional): id of the Rework.Declared that started this cycle

**notes:**
Replaces Rework.Completed (Deprecated in v2.1.0). Canonical complementary pair: Rework.Declared / Rework.Resolved.

**owner_journey:** Delivery

---

## Reference flows

### Happy path (no impediments or rework)

```
Timeline: WI-042
────────────────────────────────────────────────────────────────
CI Sync
  1. Bootstrap.Started    → BOOTSTRAPPING
  2. Gate.Passed          (smoke-test)
  3. Bootstrap.Completed  → HACKING
  4. Hack.Completed       → SYNCING
  5. Gate.Passed          (lint)
  6. Gate.Passed          (unit-tests)
  7. Sync.Completed       → FINISHING
  8. Gate.Passed          (integration-tests)
  9. Finish.Completed     → SHIPPING
CI Async
 10. Ship.Completed       → VALIDATING
 11. Validate.Started
 12. Shared.Gate.Passed   (e2e-tests)
 13. Validate.Completed
 14. Promote.Approved     → PROMOTING
 15. Promote.Completed    → DONE
────────────────────────────────────────────────────────────────
Final Derived State: DONE
Events with alters_state = true: 7
Events with alters_state = false: 8
```

### Flow with rework

```
Timeline: WI-099
────────────────────────────────────────────────────────────────
  1. Bootstrap.Started    → BOOTSTRAPPING
  2. Gate.Passed          (smoke-test)
  3. Bootstrap.Completed  → HACKING
  4. Hack.Completed       → SYNCING
  5. Gate.Failed          (lint)
  6. Rework.Declared      → HACKING   [return due to lint failure]
  7. Rework.Resolved      → SYNCING   [corrections applied]
  8. Gate.Passed          (lint)
  9. Gate.Passed          (unit-tests)
 10. Sync.Completed       → FINISHING
 ...continued...
────────────────────────────────────────────────────────────────
Rework cycles: 2
```

### Flow with impediment — Lookback in action (v2 pattern)

```
Timeline: WI-033
────────────────────────────────────────────────────────────────
  1. Bootstrap.Started    → BOOTSTRAPPING
  2. Gate.Passed          (smoke-test)
  3. Bootstrap.Completed  → HACKING
  4. Impediment.Declared  → BLOCKED   [external dependency]
  ...days later...
  5. Impediment.Resolved  → alters_state=false [Lookback → returns HACKING]
  6. Hack.Completed       → SYNCING
  ...continued...

Lookback at pos 5:
  Impediment.Declared found at pos 4
  Search before pos 4: pos 3 = Bootstrap.Completed, new_state=HACKING (≠ BLOCKED)
  Return state: HACKING  ✓
────────────────────────────────────────────────────────────────
```

---

*All 17 Event Types in this catalog satisfy Event Type Schema v1.0.0.*
*Catalog version: 2.0.0. Active: 14. Deprecated: 3 (Gate.Passed, Gate.Failed, Impediment.Declared). Impediment.Resolved: Active — converged, awaiting shared-types v1.1.0 for formal deprecation.*
