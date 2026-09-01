# Shared Types — Operational Event Model
# ProdOps Framework

> **Domain:** Framework — applicable to all Journeys
> **Status:** Canonical
> **Version:** 1.0.0
> **Depends on:** [Event Type Schema](event-type-schema.md) · [Lifecycle](lifecycle.md) · [Taxonomy](taxonomy.md)
> **Promotion evidence:** Cross-Journey Analysis

---

## About this document

This is the canonical catalog of **Shared Event Types** for the Operational Event Model —
event types promoted to the Framework level and reusable by any Journey, present or future.

A type only enters this catalog after satisfying all five promotion criteria (CRT-01 to
CRT-05) defined in `lifecycle.md` section 3, with documented evidence.

This document does not define Journey catalogs. It does not modify any existing catalog.

---

## 1. Types in this catalog

| # | Event Type | Status | Confirmed Journeys | Promotion date |
|---|---|---|---|---|
| 1 | **Gate.Passed** | Active | Delivery · Diligence · Assessment | 2026-07-25 |
| 2 | **Gate.Failed** | Active | Delivery · Diligence · Assessment | 2026-07-25 |
| 3 | **Impediment.Declared** | Active | Delivery · Diligence · Assessment | 2026-07-25 |
| 4 | **Impediment.Resolved** | Proposed | Delivery (simplif.) · Diligence · Assessment | Pending Delivery v2 |

---

## 2. Promotion criteria

The criteria below, defined in `lifecycle.md` section 3.2, **must all be satisfied**
for a type to be promoted:

| Criterion | Description |
|---|---|
| **CRT-01** | Active or proven reuse in two or more Journeys |
| **CRT-02** | Verified semantic equivalence — preconditions and postconditions make sense in all Journeys that would use it |
| **CRT-03** | Demonstrated stability — no changes in Category, alters_state, or new_state since introduction |
| **CRT-04** | Generality without loss of precision — the type name remains precise and self-descriptive outside the originating Journey |
| **CRT-05** | No duplicate in the shared catalog |

---

## 3. Governance

### 3.1 Who can propose a new Shared Type

Any **Journey owner** or **Framework contributor** may propose a type for promotion, provided:

1. The origin Journey type is in **Active** status (a Draft cannot be proposed directly)
2. There is documented evidence of use in **at least two Journeys** with equivalent semantics
3. The proposal includes a formal analysis of CRT-01 to CRT-05 with cited evidence
4. The analysis confirms that no equivalent type already exists in the Shared catalog

**Proposal format:** document `prodops/documentation-review-[type]-shared-promotion.md`
containing the complete analysis of the five criteria, list of involved Journeys, and proposed
canonical definition.

### 3.2 Who approves

**Exclusively the Framework** — represented by the OEM maintainer.

Approval is granted when:
- All CRTs satisfied with documented evidence
- No consulted Journey identified a semantic or technical conflict
- The canonical definition is complete (all required fields of the Event Type Schema)
- The type name does not collide with any existing type in any catalog

The Framework may approve, refuse, or approve with adjustments. In case of refusal, structured
feedback is recorded so the Journey can resubmit or keep the type as a Journey Type.

### 3.3 When a Shared Type may be deprecated

A Shared Type may be deprecated by the Framework when:

| Situation | Criterion |
|---|---|
| **Replacement** | A more precise type is available and Journeys confirmed migration |
| **Obsolescence** | No Journey has emitted events of the type for at least two complete cycles |
| **Model refactoring** | An OEM revision makes the type conceptually inadequate |

A Shared Type **must not be deprecated** because:
- "The name could be better" — names of Active types are immutable (INV-LC-05)
- "Few Journeys use it" — low usage is not a criterion; zero usage for multiple cycles may be

### 3.4 How a Journey must migrate to a promoted Shared Type

When a type is promoted to Shared, Journeys that used it must:

**Step 1 — Deprecate the Journey type:** in the Journey catalog, mark the original Journey
type as `Deprecated` with:
- `deprecated_in`: Journey catalog version in which the deprecation occurs
- `deprecation_reason`: "Promoted to Shared Type. See `framework/events/shared-types.md`."
- `replacement_type`: reference to the Shared Type (e.g., `Shared.Gate.Passed`)

**Step 2 — Update Skills:** Skills that emitted the Journey type now emit the Shared Type.
The `event_type` in Event Instances now references the Shared name.

**Step 3 — Preserve history:** historical Timelines containing the original deprecated
Journey type remain valid and immutable. Event Consumers must continue recognizing the
deprecated Journey type for historical processing.

**Note on current catalogs:** the MVP catalogs of Delivery, Diligence, and Assessment were
not modified by this document. Deprecation of the originating Journey types is work for the
v2 catalogs of each Journey. Historical Timelines with Journey types remain entirely valid.

---

## 4. Active Shared Types

---

### 4.1 Gate.Passed

| Field | Value |
|---|---|
| **name** | `Gate.Passed` |
| **namespace** | `Shared` (derived from `is_shared = true`) |
| **category** | Gate |
| **alters_state** | `false` |
| **new_state** | — |
| **producer_subtypes** | `[System, Agent]` |
| **lifecycle_status** | **Active** |
| **introduced_in** | shared-types 1.0.0 |
| **is_shared** | `true` |
| **promotion_origin** | `Delivery.Gate.Passed` · `Diligence.Gate.Passed` · `Assessment.Gate.Passed` |

**Canonical definition:**
An automated quality gate passed successfully. The gate verifies a specific quality criterion
without altering the Work Item's state. The Producer records the positive result in the
Timeline. Multiple Gate.Passed events may occur in the same Timeline at different phases.

**Canonical preconditions:**
- The Work Item is in any active state (not DONE, not BLOCKED)
- An automated gate was executed and produced a positive result

**Canonical postconditions:**
- The gate's positive result is recorded in the Timeline
- The Work Item's Derived State is not altered

**Guaranteed minimum payload:**

| Field | Type | Requirement | Description |
|---|---|---|---|
| `gate_name` | string | Required | Identifier of the executed gate (e.g., `smoke-test`, `lint`, `readiness-check`, `data-completeness`) |
| `duration_ms` | integer | Required | Duration of gate execution in milliseconds |

Journeys may add additional fields to the payload — but `gate_name` and `duration_ms`
are required in any implementation.

**Journeys that use it:**

| Journey | Journey Type (origin) | Introduced in | Notes |
|---|---|---|---|
| Delivery | `Delivery.Gate.Passed` | 1.0.0 | Verifies lint, tests, coverage, security |
| Diligence | `Diligence.Gate.Passed` | 1.0.0 | Verifies readiness, canonical labels, conformance |
| Assessment | `Assessment.Gate.Passed` | 1.0.0 | Verifies data completeness, metrics coverage |

**Promotion criteria verification:**

| Criterion | Satisfied? | Evidence |
|---|---|---|
| CRT-01 | **Yes** | Active use in 3 Journeys (Delivery, Diligence, Assessment) |
| CRT-02 | **Yes** | Identical semantics: "automated gate passed"; preconditions and postconditions equivalent across the 3 Journeys; legitimate variation only in `gate_name` |
| CRT-03 | **Yes** | Active since 1.0.0 in all Journeys — no change in Category, alters_state, producers, or payload |
| CRT-04 | **Yes** | `Gate.Passed` is precise and self-descriptive outside any Journey |
| CRT-05 | **Yes** | No equivalent type existed in the Shared catalog before this promotion |

**Promotion history:**

| Date | Event | Reference |
|---|---|---|
| 2026-07-24 | Identified as candidate in cross-journey analysis | Cross-Journey Analysis |
| 2026-07-25 | Confirmed by the third Journey (Assessment) | Assessment Event Catalog |
| 2026-07-25 | Promoted to Shared Type — all CRTs satisfied | This document v1.0.0 |

---

### 4.2 Gate.Failed

| Field | Value |
|---|---|
| **name** | `Gate.Failed` |
| **namespace** | `Shared` |
| **category** | Gate |
| **alters_state** | `false` |
| **new_state** | — |
| **producer_subtypes** | `[System, Agent]` |
| **lifecycle_status** | **Active** |
| **introduced_in** | shared-types 1.0.0 |
| **is_shared** | `true` |
| **promotion_origin** | `Delivery.Gate.Failed` · `Diligence.Gate.Failed` · `Assessment.Gate.Failed` |

**Canonical definition:**
An automated quality gate failed. The verified criterion was not satisfied. The Work Item
remains in its current state — the gate failure is a signal for the Producer to take
corrective action. The Producer is responsible for declaring Rework (Delivery) or emitting
the appropriate rejection (Diligence, Assessment) if the failure requires returning to a
previous step.

**Canonical preconditions:**
- The Work Item is in any active state (not DONE, not BLOCKED)
- An automated gate was executed and produced a failure result

**Canonical postconditions:**
- The gate failure is recorded in the Timeline
- The Work Item's Derived State is not altered
- The Producer determines the appropriate corrective action for the Journey

**Guaranteed minimum payload:**

| Field | Type | Requirement | Description |
|---|---|---|---|
| `gate_name` | string | Required | Identifier of the executed gate |
| `reason` | string | Required | Description of the failure cause or unsatisfied criterion |
| `duration_ms` | integer | Required | Duration of gate execution in milliseconds |

**Journeys that use it:**

| Journey | Journey Type (origin) | Introduced in | Post-failure behavior |
|---|---|---|---|
| Delivery | `Delivery.Gate.Failed` | 1.0.0 | Producer declares `Rework.Declared` if failure requires return |
| Diligence | `Diligence.Gate.Failed` | 1.0.0 | Producer evaluates whether `Promote.Rejected` should be emitted |
| Assessment | `Assessment.Gate.Failed` | 1.0.0 | Producer evaluates whether `Report.Rejected` should be emitted |

**Promotion criteria verification:**

| Criterion | Satisfied? | Evidence |
|---|---|---|
| CRT-01 | **Yes** | Active use in 3 Journeys |
| CRT-02 | **Yes** | Identical semantics: "automated gate failed"; the corrective action post-failure varies by Journey but is the Producer's responsibility — does not alter the type's semantics |
| CRT-03 | **Yes** | Active since 1.0.0 in all Journeys — no change in critical properties |
| CRT-04 | **Yes** | `Gate.Failed` is precise and self-descriptive outside any Journey |
| CRT-05 | **Yes** | No equivalent type existed in the Shared catalog |

**Promotion history:**

| Date | Event | Reference |
|---|---|---|
| 2026-07-24 | Identified as candidate | Cross-Journey Analysis |
| 2026-07-25 | Confirmed by the third Journey | Assessment Event Catalog |
| 2026-07-25 | Promoted to Shared Type | This document v1.0.0 |

---

### 4.3 Impediment.Declared

| Field | Value |
|---|---|
| **name** | `Impediment.Declared` |
| **namespace** | `Shared` |
| **category** | Blocking |
| **alters_state** | `true` |
| **new_state** | `BLOCKED` |
| **producer_subtypes** | `[Human, Agent]` |
| **lifecycle_status** | **Active** |
| **introduced_in** | shared-types 1.0.0 |
| **is_shared** | `true` |
| **promotion_origin** | `Delivery.Impediment.Declared` · `Diligence.Impediment.Declared` · `Assessment.Impediment.Declared` |

**Canonical definition:**
An external impediment has been declared for the Work Item. Work cannot progress until the
impediment is resolved. An impediment is an external cause that blocks the Work Item's
progression — it is not a rejection decision, not a quality failure, and not a voluntary
pause. The Work Item transitions to the BLOCKED state and remains there until
Impediment.Resolved is emitted.

**Canonical preconditions:**
- The Work Item is in any active state (not DONE, not BLOCKED)
- An external impediment has been identified that prevents the Work Item's progression

**Canonical postconditions:**
- The Work Item transitions to the `BLOCKED` state
- The impediment is described and recorded in the Timeline
- Work is suspended until `Impediment.Resolved`

**Guaranteed minimum payload:**

| Field | Type | Requirement | Description |
|---|---|---|---|
| `impediment_description` | string | Required | Description of the impediment and who or what can resolve it |
| `blocking_since` | string | Required | Timestamp (ISO 8601) when the impediment was identified — may be earlier than the event's timestamp |

**Journeys that use it:**

| Journey | Journey Type (origin) | Introduced in | Usage context |
|---|---|---|---|
| Delivery | `Delivery.Impediment.Declared` | 1.0.0 | External infrastructure dependencies, denied access |
| Diligence | `Diligence.Impediment.Declared` | 1.0.0 | Access to external systems, third-party dependencies |
| Assessment | `Assessment.Impediment.Declared` | 1.0.0 | Access to Timelines, analysis system unavailability |

**Promotion criteria verification:**

| Criterion | Satisfied? | Evidence |
|---|---|---|
| CRT-01 | **Yes** | Active use in 3 Journeys |
| CRT-02 | **Yes** | Identical semantics: "external impediment declared, Work Item BLOCKED"; context varies by Journey but the operational phenomenon is the same |
| CRT-03 | **Yes** | Active since 1.0.0 in all Journeys — no change in alters_state, new_state, or payload |
| CRT-04 | **Yes** | `Impediment.Declared` is precise and generic — "blocking declaration" makes sense in any Journey |
| CRT-05 | **Yes** | No equivalent type existed in the Shared catalog |

**Promotion history:**

| Date | Event | Reference |
|---|---|---|
| 2026-07-24 | Identified as candidate | Cross-Journey Analysis |
| 2026-07-25 | Confirmed by the third Journey | Assessment Event Catalog |
| 2026-07-25 | Promoted to Shared Type | This document v1.0.0 |

---

## 5. Pending Promotion

---

### 5.1 Impediment.Resolved

| Field | Value |
|---|---|
| **name** | `Impediment.Resolved` |
| **namespace** | `Shared` (pending) |
| **category** | Blocking |
| **alters_state** | `false` |
| **new_state** | — (Consumer uses Lookback: `preBlockedState`) |
| **producer_subtypes** | `[Human]` |
| **lifecycle_status** | **Proposed** |
| **introduced_in** | — (pending approval) |
| **is_shared** | pending |
| **promotion_origin** | `Delivery.Impediment.Resolved` (simplif.) · `Diligence.Impediment.Resolved` · `Assessment.Impediment.Resolved` |

**Proposed canonical definition:**
The external impediment has been resolved and the Work Item can resume work. The return state
is not hardcoded in the type — the Consumer uses the Lookback mechanism (`preBlockedState`)
defined in `timeline.md` to determine the state prior to BLOCKED. This definition reflects
the OEM canonical pattern: `Impediment.Resolved` must never assume a fixed return state,
since the impediment may have been declared at any phase of the cycle.

**Canonical preconditions:**
- The Work Item is in the BLOCKED state
- The impediment declared in `Impediment.Declared` has been resolved

**Canonical postconditions:**
- `alters_state = false` — the Derived State is not directly altered by this event
- The Consumer uses `preBlockedState(timeline, resolved_position)` to determine the return state
- The impediment resolution is recorded in the Timeline

**Proposed minimum payload:**

| Field | Type | Requirement | Description |
|---|---|---|---|
| `resolution_description` | string | Required | Description of how the impediment was resolved |

**Promotion criteria verification:**

| Criterion | Satisfied? | Status |
|---|---|---|
| CRT-01 | **Yes** | Active use in 3 Journeys (Delivery, Diligence, Assessment) |
| CRT-02 | **Partially** | **BLOCKING:** Identical semantics in all 3 Journeys. However, technical implementation diverges: Delivery v1 uses `alters_state=true, new_state=HACKING` (MVP simplification, documented); Diligence and Assessment use `alters_state=false` with Lookback (canonical pattern). The conflicting `alters_state` prevents promotion — the Shared Type defines `alters_state=false` as canonical, but the Delivery v1 catalog declares `true`. A Consumer reading the Delivery Timeline would find inconsistency. |
| CRT-03 | **Yes** | Active since 1.0.0 in all Journeys without semantic change |
| CRT-04 | **Yes** | `Impediment.Resolved` is precise and generic |
| CRT-05 | **Yes** | No equivalent type in the Shared catalog |

**Unblocking condition:**
Promotion can be completed when:

1. The **Delivery v2** catalog updates `Impediment.Resolved` to `alters_state=false` (Lookback)
2. Verification confirms that no existing Delivery Timeline contains hardcoded dependencies
   on the `new_state=HACKING` of `Impediment.Resolved`
3. CRT-02 is re-evaluated and confirmed as satisfied

**History:**

| Date | Event | Reference |
|---|---|---|
| 2026-07-24 | Identified as candidate with Medium confidence | Cross-Journey Analysis |
| 2026-07-25 | Confirmed by Assessment (alters_state=false) — confidence elevated to High | Assessment Event Catalog |
| 2026-07-25 | Proposed status recorded — blocked by Delivery v2 | This document v1.0.0 |

---

## 6. Record of rejected candidates

No candidate has been formally rejected up to this version.

Candidates analyzed and discarded (not Shared Type candidates):

| Analyzed type | Reason for discard |
|---|---|
| `Promote.Approved` | Naming collision — Delivery and Diligence use the name for different semantics (production deploy vs. readiness promotion). CRT-02 not satisfied. |
| `Promote.Rejected` | Naming collision + conflicting alters_state. CRT-02 not satisfied. |
| `Promote.Completed` | Naming collision + incompatible new_state (DONE vs. PROMOTED). CRT-02 not satisfied. |

Reference for the analysis: Cross-Journey Event Analysis section 4.

---

## 7. How to use a Shared Type in a new Journey

For a new Journey that needs `Gate.Passed`, `Gate.Failed`, or `Impediment.Declared`:

**In the Journey catalog:**
```
### Gate.Passed

| Field | Value |
|---|---|
| name        | Gate.Passed                                      |
| namespace   | Shared                                           |
| category    | Gate                                             |
| alters_state| false                                            |
| lifecycle_status | Active                                      |
| is_shared   | true                                             |

Definition: see prodops/framework/events/shared-types.md

payload_shape (Journey-specific extension):
- gate_name   (inherited from Shared — required)
- duration_ms (inherited from Shared — required)
- [additional Journey-specific fields, if needed]
```

The Journey references the Shared Type without redefining it. Additional payload fields
are allowed as long as they do not conflict with the Shared Type's minimum fields.

---

## References

- [Event Type Schema](event-type-schema.md)
- [OEM Lifecycle](lifecycle.md)
- [OEM Taxonomy](taxonomy.md)
- [OEM Timeline](timeline.md)
- Cross-Journey Event Analysis
- [Delivery Event Catalog](../journeys/delivery/events/catalog.md)
- [Diligence Event Catalog](../journeys/diligence/events/catalog.md)
- [Assessment Event Catalog](../journeys/assessment/events/catalog.md)
