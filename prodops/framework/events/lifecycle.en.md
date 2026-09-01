# Event Type Lifecycle — Operational Event Model
# ProdOps Framework

> **Domain:** Framework — applicable to all Journeys
> **Status:** Canonical
> **Version:** 1.0.0
> **Depends on:** [README.md](README.md) · [ontology.md](ontology.md) · [taxonomy.md](taxonomy.md)

---

## About this document

This document formalizes the lifecycle of **Event Types** in the Operational Event Model:
how they are born, evolve, are promoted to shared, deprecated, and removed over time.

This document does not define schema, implementation, storage format, or concrete Journey
catalogs. It deals exclusively with the governance of type evolution.

→ [OEM Taxonomy](taxonomy.md) · [OEM Ontology](ontology.md) · [OEM Foundation](README.md)

---

## 1. Canonical Lifecycle

### 1.1 Two lifecycle models

Event Types have two distinct lifecycles, corresponding to their two possible registrations
in the Taxonomy:

**Model A — Journey Event Type** (defined and governed by a Journey):

```
[ Draft ] ──────────────────────────────────────→ [ Active ]
    │                                                  │
    │ (Journey approval)                               │ (Journey or Framework)
    │                                                  ↓
    │                                           [ Deprecated ]
    │                                                  │
    └──────────────────────────────────────────→       │ (criteria satisfied)
                                                       ↓
                                                [ Removed ]
                                                       │
                                    (historical Timelines preserve reference)
```

**Model B — Shared Event Type** (defined by the Framework, reusable by any Journey):

```
[ Draft ]
    │
    │ (Journey submits proposal to Framework)
    ↓
[ Proposed ] ──→ (Framework refuses) ──→ returns to Journey as Draft or Active
    │
    │ (Framework approves)
    ↓
[ Active ] ─────────────────────────────────────────────────────────────────
    │                                                                       │
    │ (Framework)                                                           │
    ↓                                                                       │
[ Deprecated ] ─────────────────────────────────────────────────────────── │
    │                                                                       │
    │ (criteria satisfied)                                                  │ (exceptional)
    ↓                                                                       ↓
[ Removed ]                                                            [ Restored ]
    │
    (historical Timelines preserve reference)
```

### 1.2 Canonical statuses

| Status | Applicable to | Authorizes emission? | Who maintains |
|---|---|---|---|
| **Draft** | Journey Type · Shared Type (being drafted) | No | Journey |
| **Proposed** | Shared Type (under Framework review) | No | Framework |
| **Active** | Journey Type · Shared Type | Yes | Journey / Framework |
| **Deprecated** | Journey Type · Shared Type | No (legacy only) | Journey / Framework |
| **Removed** | Journey Type · Shared Type | No | Journey / Framework |
| **Restored** | Any previously Deprecated type | Yes — after restoration | Who deprecated it |

### 1.3 Definition of each status

**Draft**
The type is being drafted — it does not yet have all required properties, or has not yet
passed duplicate and conformance checks. No Skill may emit events of this type while it
is in Draft.

**Proposed**
Status exclusive to the promotion process to Shared Type. The type has been submitted to
the Framework for cross-Journey review. No Skill may emit events of this type while it is
in Proposed (the original Journey type remains Active during review).

**Active**
The type is approved, fully documented, and available for emission. Skills can and should
emit events of this type when preconditions are satisfied.

**Deprecated**
The type should no longer be emitted by new Steps/Skills. Events already recorded with this
type in existing Timelines remain valid and immutable. Event Consumers must continue
recognizing the type for historical processing.

**Removed**
The type has been removed from the active catalog. No new emission is possible. Historical
Timelines containing events of this type remain valid — the type is preserved as a read-only
reference in the historical catalog. Event Consumers processing historical Timelines must
treat the type as valid for reading.

**Restored**
Transitional status: a Deprecated type has returned to Active by a reasoned decision.
Restored is not a final status — the type transitions immediately to Active once the
restoration is approved. The deprecation history is preserved in the type's record.

---

## 2. Transitions

### 2.1 Transition table

| From | To | Initiated by | Conditions |
|---|---|---|---|
| Draft | Active | Journey governance | Complete properties; no semantic duplicate; REG-01 to REG-10 satisfied |
| Draft | Proposed | Journey governance | Type is a Shared candidate; formal proposal to Framework |
| Proposed | Active (Shared) | Framework | Review complete; promotion criteria satisfied |
| Proposed | Draft | Framework | Review refused; Journey receives feedback |
| Active | Deprecated | Journey (Journey Type) · Framework (Shared Type) | Replacement available; reason documented |
| Active | Proposed | Journey governance | Promotion initiated; original Journey type remains Active during review |
| Deprecated | Removed | Journey (Journey Type) · Framework (Shared Type) | Removal criteria satisfied |
| Deprecated | Restored | Who deprecated it | Deprecation was premature; compatibility review performed |
| Restored | Active | Who restored it | Restoration approved — immediate transition |

### 2.2 Detail of each transition

---

#### Draft → Active (Journey Event Type)

**Who can initiate:** the Journey governance (whoever approves structural changes to the Journey).

**Preconditions:**
- All required properties are filled in (`name`, `category`, `alters_state`,
  `producer_subtypes`, `preconditions`, `postconditions`, `status`, `introduced_in`)
- The name follows the Taxonomy's `Subject.Action` convention
- A duplicate check was performed across all Journey catalogs and shared types —
  no semantic duplicate found
- REG-01 to REG-10 of the Taxonomy are satisfied
- If `alters_state = true`, the `new_state` is documented and consistent with the Journey's
  Derived State model
- The declared Category exists in the Taxonomy catalog
- INV-TAX-04 is satisfied: the Category allows `alters_state = true` if the type declares it

**Required evidence:**
- Complete definition in the Journey catalog
- Record of the duplicate check result

**Postconditions:**
- The type can be emitted by Journey Skills
- Event Consumers processing the Journey must recognize the type
- The catalog version is incremented

---

#### Draft → Proposed (start of Shared promotion)

**Who can initiate:** the Journey that owns the active Journey type being proposed for promotion.

**Preconditions:**
- The Journey type is in Active status (it is not possible to propose a Draft directly as Shared)
- There is evidence of proven reuse or demonstrated cross-Journey need (see section 3)
- The proposal is complete: includes cross-Journey semantic analysis, list of Journeys that
  would use the type, and proposed name in the shared catalog

**Required evidence:**
- Formal proposal with semantic analysis
- Evidence of use or request by at least one additional Journey

**Postconditions:**
- The original Journey type remains Active throughout the entire review
- The Framework assumes review responsibility
- No new emission of the Proposed type is allowed (it is not an emissible type in this status)

---

#### Proposed → Active (Framework approval as Shared Type)

**Who can initiate:** exclusively the Framework.

**Preconditions:**
- The cross-Journey review is complete
- No type in the existing shared catalog has equivalent semantics
- The proposed name does not collide with any existing type in any catalog
- The promotion criteria in section 3 are satisfied
- Journeys that will use the type have been consulted and confirmed compatibility

**Required evidence:**
- Framework review record with reasoned decision
- List of Journeys that will adopt the shared type

**Postconditions:**
- The type is added to the shared types catalog with Active status
- The original Journey type (that originated the proposal) is automatically Deprecated with
  a reference to the shared type as a substitute
- Journeys using the original Journey type are notified to migrate emission to the shared type
- Historical Timelines with the original Journey type remain valid

---

#### Proposed → Draft (Framework refusal)

**Who can initiate:** the Framework, after review.

**Preconditions:**
- The review concluded that promotion is not appropriate (duplicate type, insufficiently
  generic semantics, inadequate naming, etc.)

**Required evidence:**
- Refusal record with structured feedback for the Journey

**Postconditions:**
- The original Journey type remains Active (the refusal does not affect it)
- The Journey can adjust the proposal and try again, or keep the type as Journey-exclusive
- The feedback is recorded in the Journey catalog for future reference

---

#### Active → Deprecated

**Who can initiate:**
- Journey (for Journey Event Types)
- Framework (for Shared Event Types)

**Preconditions:**
- A substitute type in Active status exists (except for obsolescence deprecation without a substitute)
- The reason for deprecation is documented
- All Skills that emitted the type have been identified (not necessarily migrated —
  migration may occur after deprecation)
- The substitute type has been communicated to relevant Event Consumers

**Required evidence:**
- `deprecated_in`: catalog version in which the deprecation occurred
- `deprecation_reason`: textual reason
- `replacement_type`: reference to the substitute type (when applicable)
- `migration_deadline`: date or cycle until which emission of the deprecated type is still tolerated

**Postconditions:**
- The type should no longer be emitted by new Steps
- Existing Skills that emit the type remain valid during the migration period
- Event Consumers continue recognizing the type for historical reading
- The type remains in the catalog as a reference for historical Timelines

---

#### Deprecated → Removed

**Who can initiate:**
- Journey (for Journey Event Types)
- Framework (for Shared Event Types)

**Preconditions:**
- No new emission of the type has occurred after the `migration_deadline`
- All Skills that emitted the type have been updated to the substitute type (or removed)
- Event Consumers have confirmed they treat the type as historical and do not process it
  in an active context
- The minimum deprecation period has been observed (at least one complete Journey cycle
  without new emissions)

**Required evidence:**
- `removed_in`: catalog version in which the removal occurred
- `removal_reason`: confirmation that criteria were satisfied
- Record that historical Timelines with the type are recognized as valid

**Postconditions:**
- The type is marked as Removed in the active catalog
- The type remains as a read-only entry in the historical catalog (so Event Consumers
  can decode old Timelines)
- No new emission is possible — systems that try to emit the type must receive an error

---

#### Deprecated → Restored → Active

**Who can initiate:** whoever deprecated the type (Journey for Journey Types; Framework for
Shared Types).

**Condition for restoration:**
- The deprecation was premature — the substitute type proved inadequate, or the reason for
  deprecation did not materialize
- The restoration does not violate historical compatibility
- No Timeline was corrupted during the deprecation period

**Preconditions:**
- The type is still in Deprecated status (not Removed)
- The compatibility analysis confirms that restoring the type does not create ambiguity with
  events emitted during the deprecation period
- The restoration decision is documented with justification

**Postconditions:**
- The type returns to Active status
- The deprecation history is preserved in the type's record (the type was Deprecated and
  was Restored — this is relevant information for audit)
- If there was a substitute type, it remains Active — both coexist with clarity

---

## 3. Shared Event Types — When to Promote

### 3.1 The promotion decision

> A Journey Event Type must remain exclusive to its Journey as long as there is reasonable
> doubt that the semantics are specific to the Journey's context.
>
> It should be promoted to a Shared Event Type when the semantics are demonstrably
> equivalent and reusable across multiple Journey contexts.

### 3.2 Promotion criteria — all must be satisfied

**CRT-01 — Active or proven reuse**
The type is being requested by at least one additional Journey for an occurrence with
equivalent semantics, OR it has current use in one Journey and clear evidence that other
Journeys will need the same type soon.

**CRT-02 — Verified semantic equivalence**
The preconditions and postconditions of the type make sense in the context of all Journeys
that would use it, without requiring semantic adaptation. If any Journey needs to "adjust the
meaning", the type is not a Shared candidate.

**CRT-03 — Demonstrated stability**
The type has been Active in the originating Journey for at least one complete cycle without
changes to its critical properties (Category, `alters_state`, `new_state`). Unstable types
must not be promoted.

**CRT-04 — Generality without loss of precision**
The type name remains precise and self-descriptive outside the context of the originating
Journey. `Gate.Failed` is generic enough without losing meaning. `BootstrapSmokeGate.Failed`
is too specific to be Shared.

**CRT-05 — No duplicate in the shared catalog**
No type with equivalent semantics already exists in the shared types catalog. If one exists,
the Journey must migrate to the existing type — not create a second competing Shared Type.

### 3.3 Criteria that do not justify promotion

| Inadequate criterion | Why it is insufficient |
|---|---|
| "May be useful in the future" | Would violate ANT-LC-01 (premature promotion) |
| "The name is similar to another Journey's" | Name similarity ≠ semantic equivalence |
| "It would be more organized as Shared" | Organization is not an architectural criterion |
| "The Journey wants to use another Journey's type" | Direct import is ANT-TAX-09; promotion is the correct solution |

### 3.4 When not to promote (keep as Journey Type)

A type should remain Journey-exclusive when:

- The semantics are genuinely specific to the Journey's context (e.g., `Bootstrap.SmokeGate.Failed`
  only makes sense in Delivery, where Bootstrap is a Phase with a smoke test gate)
- The type is in Draft or was recently modified (instability)
- No other Journey has demonstrated a need for the same type
- Promotion would require renaming the type — which violates INV-LC-06

---

## 4. Promotion Process

### 4.1 Canonical promotion flow

```
Phase 1 — Identification (Journey)
│
│  • Journey identifies that its active Journey type is being
│    requested by another Journey with equivalent semantics
│  • Journey verifies CRT-01 to CRT-05
│  • Journey confirms no equivalent Shared Type exists
│
↓

Phase 2 — Proposal Drafting (Journey)
│
│  • Journey drafts the promotion proposal including:
│    - cross-Journey semantic analysis
│    - list of Journeys that would use the type
│    - proposed name in the shared catalog
│    - historical compatibility analysis
│    - proposed migration plan for the original Journey type
│
↓

Phase 3 — Submission (Journey → Framework)
│
│  • Journey type transitions to Proposed status
│  • Original Journey type remains Active
│  • No new emission of the "Proposed" type is allowed
│
↓

Phase 4 — Review (Framework)
│
│  • Framework verifies CRT-01 to CRT-05
│  • Framework consults Journeys that would use the type
│  • Framework verifies absence of duplicate in the shared catalog
│  • Framework decides: Approved | Refused | Approved with adjustments
│
↓

Phase 5A — Approval (Framework)          │  Phase 5B — Refusal (Framework)
│                                         │
│  • Type added to the shared catalog     │  • Type returns to Draft status
│    as Active                            │    in the Journey
│  • Original Journey type → Deprecated  │  • Framework provides feedback
│    (reference to Shared as substitute)  │  • Journey can adjust and
│  • Journeys migrate emission to Shared  │    resubmit, or keep as
│                                         │    Journey Type
↓

Phase 6 — Migration (affected Journeys)
│
│  • Skills updated to emit the Shared Type
│  • Historical Timelines with the original Journey type: valid and preserved
│  • Original Journey type remains in catalog as Deprecated (read-only historical)
│
↓

[ Shared Type Active — available to all Journeys ]
```

### 4.2 Promotion process guarantees

- The original Journey type is **never deleted** — only deprecated with a reference to the Shared Type
- Historical Timelines with the original Journey type **remain valid** — promotion
  does not break backward compatibility
- The Shared Type **inherits the semantics** of the original Journey type — it is not a new
  entity with different semantics

---

## 5. Deprecation

### 5.1 When to deprecate

An Event Type must be deprecated when:

| Situation | Criterion |
|---|---|
| **Replacement** | A more precise or more adequate type is available as a substitute |
| **Redundancy** | The type was promoted to Shared Type (the original Journey type is automatically deprecated) |
| **Obsolescence** | The occurrence the type represented no longer occurs in the Journey's flow |
| **Phase refactoring** | A Phase was renamed or restructured, making the type outdated |

### 5.2 When not to deprecate

| Situation | What to do instead of deprecating |
|---|---|
| "The name could be better" | Do not deprecate; names of active types are immutable |
| "It has low usage" | Low usage is not a deprecation criterion; zero usage for a full cycle may be |
| "We want to consolidate two similar types" | Create the consolidated type; deprecate the originals with a reference to the new one |

### 5.3 Compatibility with historical Timelines

Deprecation of a type never affects historical Timelines. The reason is ontological: events
are immutable (INV-02 of the Ontology). An event recorded with a deprecated type is valid —
it records a fact that occurred when the type was Active.

**What changes with deprecation:**
- Skills should not emit the type
- New Journey catalogs should not reference the type as active
- Catalog documentation marks the type as Deprecated with reason and substitute

**What does not change:**
- Historical events with the deprecated type — they remain unchanged
- The meaning of those events — the deprecated type is still recognized by Consumers
- The Work Item Timeline — it is not altered by the type's deprecation

### 5.4 Deprecation period

The deprecation period must be sufficient for:

1. All active Skills that emitted the type to be identified
2. All those Skills to be updated to the substitute type
3. Event Consumers to be notified of the deprecation
4. At least one complete Journey cycle to elapse without new emissions of the deprecated type

There is no minimum period in days or weeks — deprecation is Journey-cycle oriented, not
calendar-oriented.

---

## 6. Compatibility

### 6.1 OEM compatibility contract

> Any change in an Event Type's lifecycle must preserve the ability of Event Consumers
> to process historical Timelines containing events of the affected type.

This contract is unconditional. Historical compatibility can never be sacrificed for
implementation or reorganization convenience.

### 6.2 How Event Consumers treat deprecated and removed types

| Type status | How the Consumer must treat it |
|---|---|
| **Active** | Process normally — the type is in active use |
| **Deprecated** | Process normally for historical data — the type is recognized; new emission is a signal of anomaly |
| **Removed** | Process normally for historical data — the type exists in the read-only historical catalog; new emission is an error |

### 6.3 Historical catalog (read-only)

The OEM type catalog has two sections:

**Active catalog:** types in Draft, Proposed, Active, Deprecated status — those that are still
actively managed.

**Historical catalog (read-only):** types in Removed status — preserved exclusively so that
Event Consumers can decode old Timelines. No modification is allowed to the historical catalog.

### 6.4 Audit of Timelines with deprecated or removed types

The presence of events with Deprecated types in an active Timeline may be:

- **Normal:** the event occurred when the type was still Active — a valid event
- **Anomaly:** the event was emitted after the `migration_deadline` — a signal that a Skill
  was not updated

Diligence is responsible for distinguishing the two cases: verify whether the event's
timestamp is before or after the type's `deprecated_in`.

---

## 7. Governance

### 7.1 Responsibility map

| Action | Journey | Framework | Note |
|---|---|---|---|
| **Create** type in Draft | Yes | No | Only the Journey that owns the catalog |
| **Approve** Draft → Active (Journey Type) | Yes | No | Journey's internal governance |
| **Propose** promotion to Shared | Yes (initiates) | Approves | Journey initiates; Framework decides |
| **Approve** Proposed → Active (Shared) | No | Yes | Framework exclusivity |
| **Refuse** promotion | No | Yes | With mandatory feedback |
| **Deprecate** Journey Type | Yes | No | With documented criteria |
| **Deprecate** Shared Type | No | Yes | With documented migration |
| **Remove** Journey Type | Yes | No | After criteria satisfied |
| **Remove** Shared Type | No | Yes | After criteria satisfied |
| **Restore** deprecated type | Who deprecated it | Who deprecated it | Mandatory compatibility review |
| **Audit** cross-Journey conformance | No | Yes | Verify REG-01 to REG-10 |
| **Maintain** historical catalog | Journey (Journey Types) | Framework (Shared Types) | Read-only after Removed |

### 7.2 Framework responsibilities

The Framework is responsible for:

- Approving and publishing all Shared Event Types
- Maintaining the shared types catalog (active and historical)
- Arbitrating naming and semantic conflicts between Journeys
- Periodically auditing Journey catalogs for conformance with REG-01 to REG-10
- Communicating Shared Type deprecations to all affected Journeys
- Maintaining this document (`lifecycle.md`) updated as the governance reference

### 7.3 Journey responsibilities

Each Journey is responsible for:

- Maintaining its Journey Event Type catalog with versioning
- Verifying duplicates before proposing any new type
- Correctly executing the promotion process when criteria are satisfied
- Updating Skills when types are deprecated
- Notifying the Framework when a new Shared Type need is identified
- Recording `deprecated_in`, `deprecation_reason`, and `replacement_type` when deprecating

---

## 8. Invariants

### INV-LC-01 — Historical Event Types never disappear from Timelines

Timelines are immutable (INV-02 of the Ontology). An event recorded with any type —
Active, Deprecated, or Removed — remains in the Timeline with the original type. No migration,
deprecation, or type removal process can alter already-recorded events.

### INV-LC-02 — Shared Event Types never return to being Journey-exclusive

Once a type has been promoted to Shared and is Active in the shared catalog, it belongs to
the Framework — it cannot be "returned" to a Journey. If the type proves inadequate as
Shared, it must be deprecated and replaced by a more appropriate type.

### INV-LC-03 — Promotion to Shared preserves historical compatibility

The original Journey type that gave rise to a Shared Type is deprecated — never deleted.
Historical Timelines containing events of the original Journey type remain valid. Promotion
cannot be used as a mechanism to invalidate history.

### INV-LC-04 — Deprecation never alters existing events

Deprecating a type is an operation exclusively on the catalog — not on Timelines. No
already-recorded event changes its `event_type` as a result of a deprecation.

### INV-LC-05 — Removal only occurs after criteria are satisfied

A type cannot transition from Deprecated to Removed unless: (a) no new emission has occurred
after the `migration_deadline`, (b) all relevant Skills have been updated, and (c) Event
Consumers have confirmed adequate historical treatment.

### INV-LC-06 — Promotion does not rename the type

A Shared Type must have the same name as the original Journey type that originated it
(except for Namespace adjustment). If the name needs to change, the correct process is:
deprecate the original Journey type, create a new Journey type with the correct name, and
propose that new type for promotion.

### INV-LC-07 — Draft and Proposed do not authorize emission

No Skill may emit events of types in Draft or Proposed status. Only types in Active status
may be emitted. An emission of a Draft type is a process error — not a valid event.

### INV-LC-08 — The lifecycle history record is preserved

When a type is Restored after deprecation, the history of it having been Deprecated and
Restored must be preserved in the catalog. It is not possible to "erase" the lifecycle
history. The trail `Draft → Active → Deprecated → Restored → Active` is auditable.

---

## 9. Anti-patterns

### ANT-LC-01 — Premature promotion

**The problem:** a Journey promotes a type to Shared Type after a single usage request from
another Journey, without evidence of stability or verified semantic equivalence.

**Consequence:** the Shared Type is unstable and will need to be deprecated soon — generating
noise in the shared catalog. The lifecycle of shared types should be long; emitting an
unstable Shared Type compromises catalog reliability for all Journeys.

**Mitigation:** require that the Journey type has been Active for at least one complete cycle
(CRT-03) before any promotion proposal.

---

### ANT-LC-02 — Creating Shared Types without proven use

**The problem:** the Framework creates shared types "preventively" — before any Journey
needs them — to "prevent future duplications".

**Consequence:** the shared catalog accumulates unused types. When a Journey finally needs a
similar type, it may find that the existing Shared Type does not have adequate semantics —
but is Active and cannot be renamed.

**Mitigation:** Shared Types are born from the promotion of Journey Types with proven use —
never from prediction of future use.

---

### ANT-LC-03 — Reusing a name with different semantics

**The problem:** after deprecating `Phase.Started`, a Journey creates a new type with the
same name (`Phase.Started`) with slightly different semantics.

**Consequence:** Event Consumers processing historical Timelines cannot distinguish which
version of the type is being referenced. Metrics and audits become corrupted.

**Mitigation:** names of Deprecated and Removed types are reserved — they cannot be reused.
Every new type must have a name that never existed in the catalog (active or historical).

---

### ANT-LC-04 — Altering the meaning of an Active type

**The problem:** a Journey updates the preconditions of an Active type in a way that changes
its semantics — without deprecating the original type and creating a new one.

**Consequence:** historical events with the type are now interpreted under different semantics
from what existed when they were emitted. The Timeline loses historical integrity.

**Mitigation:** types are immutable after approval (INV-TAX-01 of the Taxonomy). Any
semantic change requires deprecating the type and creating a new one.

---

### ANT-LC-05 — Removing a type still present in active Timelines

**The problem:** a Journey removes a type from the catalog without verifying whether there
are still active Timelines with events of that type.

**Consequence:** Event Consumers that encounter the type in Timelines will not recognize it
and may fail to process. Metrics and audits become corrupted.

**Mitigation:** INV-LC-05 requires objective removal criteria, including confirmation that
Event Consumers treat the type as historical. Premature removal is prohibited.

---

### ANT-LC-06 — Deprecating without an available substitute type

**The problem:** a Journey deprecates a type because "it doesn't like the name", without
having an Active substitute. Skills that emitted the type are left without an option —
they either stop emitting or continue emitting the deprecated one.

**Consequence:** gaps in the Timeline — moments of real occurrences without event recording.
P-07 (mandatory emission) is violated.

**Mitigation:** before deprecating, ensure the substitute type is Active. If no substitute
exists, create and approve the new type before deprecating the old one.

---

### ANT-LC-07 — Eternal Draft (zombie Draft)

**The problem:** a type remains in Draft indefinitely — it exists in the catalog but is
never approved or discarded. The Journey has "been working on it" for multiple cycles.

**Consequence:** the catalog accumulates noise; others consulting the catalog don't know if
the type will be approved; duplicates may be created by other Journeys that didn't see the Draft.

**Mitigation:** Drafts must have a `target_cycle` — the cycle in which approval is expected.
Drafts without progress after two cycles must be discarded.

---

### ANT-LC-08 — Restoration without compatibility review

**The problem:** a Deprecated type is Restored without checking what happened during the
deprecation period — whether there were emissions of the substitute type with overlapping
semantics, or whether Timelines already recorded both types.

**Consequence:** two versions of the same occurrence in the Timeline — represented by
different types. Metrics and Diligence cannot aggregate them consistently.

**Mitigation:** the Deprecated → Restored transition is always preceded by a compatibility
analysis (what was emitted during the deprecation period? is there overlap with the
substitute type?).

---

### ANT-LC-09 — Bypassing promotion with informal import

**The problem:** Delivery decides to simply "use" `Diligence.Scan.Completed` in its Timelines
because "it's the same occurrence".

**Consequence:** another Journey's type referenced in the wrong context; if Diligence
deprecates the type, Delivery breaks silently; cross-Journey analyses collide.

**Mitigation:** REG-09 of the Taxonomy prohibits informal import. The promotion process is
the only valid way to share types between Journeys.

---

## 10. Relationship with Future Documents

### `events/shared-types.md`

The shared types catalog depends directly on this Lifecycle for:

- The status of each type in the catalog (`Active`, `Deprecated`, `Removed`)
- The `deprecated_in`, `deprecation_reason`, `replacement_type` properties of deprecated types
- The `removed_in`, `removal_reason` properties of removed types
- The lifecycle history record of each shared type

### `events/schema.md`

The technical schema of an Event Type depends on this Lifecycle for:

- The required fields of a type record: `status`, `introduced_in`, `deprecated_in`,
  `removed_in` — all conceptually defined here
- Validation rules: an event cannot reference a type in Draft or Proposed status
- Treatment of Removed types in historical records

### `journeys/*/events/catalog.md`

Each Journey catalog depends on this Lifecycle for:

- Understanding when to submit a type for promotion to Shared (section 3)
- Following the correct deprecation process (section 5)
- Maintaining the catalog with lifecycle status fields
- Ensuring that type removal satisfies the criteria of INV-LC-05

---

## References

- [OEM Foundation](README.md)
- [OEM Ontology](ontology.md)
- [OEM Taxonomy](taxonomy.md)
- [Framework Ontology](../ontology.md)
- OEM taxonomy report

---

*This document is the canonical source of Event Type evolution governance in the OEM.
Every Journey event catalog and every shared types document must reference this document
for the rules of creation, promotion, deprecation, and removal.*
