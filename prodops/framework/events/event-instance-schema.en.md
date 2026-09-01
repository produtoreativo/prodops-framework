# Operational Event Instance Schema — Operational Event Model
# ProdOps Framework

> **Domain:** Framework — applicable to all Journeys
> **Status:** Canonical
> **Version:** 1.0.0
> **Depends on:** [README.md](README.md) · [ontology.md](ontology.md) · [event-type-schema.md](event-type-schema.md)

---

## About this document

This document defines the structure of an **Operational Event** recorded in an Operational
Timeline.

An Operational Event is an occurrence — not a definition. It records what happened,
when it happened, who originated it, and what evidence supports the record. It is the
concrete instance that satisfies the contract defined by the Event Type.

This document does not define the Event Type contract. That contract is in
`event-type-schema.md`.

→ [Event Type Schema](event-type-schema.md) · [OEM Ontology](ontology.md) · [OEM Foundation](README.md)

---

## 1. What an Operational Event instance represents

An Operational Event represents an **operational fact that occurred** — a state change,
a decision made, a gate verified, an impediment declared. It is atomic: it represents
a single occurrence, indivisible, at a specific instant in time.

The Operational Event has three fundamental properties that distinguish it from other
types of records:

**Immutability:** once recorded, it is never altered. The record is the fact. Modifying
the record would alter history — which corrupts the integrity of the Timeline.

**Unique belonging:** it belongs to exactly one Operational Timeline, which belongs to
exactly one Work Item. An Operational Event does not exist outside a Timeline.

**Self-evidence:** the record itself is evidence that the occurrence took place (intrinsic
evidence). Additional evidence may be referenced, but it is not required for the record to be valid.

---

## 2. Field structure

| Group | Definition |
|---|---|
| **Required** | Must be present in every recorded event |
| **Optional** | May be present; not required for the record to be valid |
| **Derived** | Not stored in the event; computable from the required fields or from context |

### 2.1 Required fields

| Field | Type |
|---|---|
| `id` | string (globally unique identifier) |
| `event_type` | string (Event Type name — key to the catalog) |
| `work_item_id` | string (Work Item identifier) |
| `timestamp` | string (ISO 8601 with timezone) |
| `producer_type` | enum: `Human` \| `System` \| `Agent` |
| `producer_identity` | string (specific identity of the Producer) |
| `schema_version` | string (version of the Instance Schema used at recording) |

### 2.2 Optional fields

| Field | Type |
|---|---|
| `payload` | object — occurrence-specific fields per the Event Type's `payload_shape` |
| `evidence_references` | list of references to external artifacts |
| `sequence_number` | integer — ordinal position of the event in the Timeline |
| `notes` | string — additional context about the specific occurrence |

### 2.3 Derived fields

| Derived field | How to derive |
|---|---|
| `timeline_id` | Derived from `work_item_id` — the Timeline is 1:1 with the Work Item |
| `category` | Derived from the Event Type referenced in `event_type` |
| `alters_state` | Derived from the Event Type referenced in `event_type` |
| `new_state` | Derived from the Event Type when `alters_state = true` |
| `evidence_intrinsic` | The record itself (`id` + `timestamp` + `producer_type` + `producer_identity` + `event_type`) |

Derived fields **are not stored in the event**. Consumers that need them compute them by
consulting the referenced Event Type. If they are denormalized for read efficiency (copied
into the event), they must be marked as `[derived]` and never treated as a source of truth —
the source of truth remains the Event Type.

---

## 3. Rules for each field

### `id`

**Meaning:** the unique and immutable identifier of this specific occurrence. It distinguishes
this event from all other events across all Timelines — including events of the same Event
Type emitted for the same Work Item at different moments.

**Who fills it in:** the Producer at the time of emission, or the infrastructure that records
the event (depending on the implementation — `event-instance-schema.md` does not prescribe
who generates the `id`, only requires that it be unique and immutable).

**When it is filled in:** at the time of recording — before any persistence in the Timeline.

**Can it be changed:** no. The `id` is the record's identity. Changing the `id` is equivalent
to creating a different event.

**Rules:**
- Must be globally unique — not just within the Work Item's Timeline. Events from different
  Timelines cannot share the same `id`.
- Once emitted, the `id` is reserved — it cannot be reused even after the event is
  referenced by an `Event.Corrected`.
- The format of the `id` is not prescribed by this Schema (UUID v4, ULID, hash — any
  format that guarantees global uniqueness is valid).

---

### `event_type`

**Meaning:** the name of the Event Type that classifies this occurrence. It is the logical
key that connects the recorded event to its contract — the Event Type defines what the event
represents, what must have been true before, and what is true after.

**Who fills it in:** the Producer, at the time of emission.

**When it is filled in:** at the time of recording.

**Can it be changed:** no. The type of an event is immutable: if an event was emitted as
`Bootstrap.Completed`, it is and always was a `Bootstrap.Completed` — even if the type
is subsequently deprecated or removed from the active catalog.

**Rules:**
- Must reference an Event Type with `lifecycle_status = Active` at the time of emission
  (VAL-I-01). Events emitted with a Deprecated type are anomalies detectable by Diligence.
- The name must be the full type name per the catalog — with Namespace when the type is
  from another catalog (e.g., `Delivery.Bootstrap.Completed` for cross-Journey reference).
- Even if the referenced type transitions to Deprecated or Removed after emission, the
  `event_type` of the record remains the original name — the history is immutable.

---

### `work_item_id`

**Meaning:** identifies the Work Item to which this event belongs and, consequently,
the Timeline in which the event will be recorded. Defines the event's scope within the model.

**Who fills it in:** the Producer or the recording infrastructure.

**When it is filled in:** at the time of recording.

**Can it be changed:** no. An event belongs to exactly one Timeline (INV-03 of the
Ontology). Changing the `work_item_id` after recording is equivalent to moving the event
from one Timeline to another — which is structurally prohibited.

**Rules:**
- The referenced Work Item must exist at the time of recording.
- An event cannot be recorded in a Timeline belonging to a Work Item different from the one
  that originated it.

---

### `timestamp`

**Meaning:** the exact instant at which the occurrence took place — not the instant at
which the event was recorded in the Timeline (which may be slightly later). When it is not
possible to distinguish the instant of occurrence from the instant of recording, the instant
of recording is used.

**Who fills it in:** the Producer at the time of emission.

**When it is filled in:** at the time of recording.

**Can it be changed:** no.

**Format:** ISO 8601 with explicit timezone. Valid examples:
```
2026-07-24T09:15:00Z
2026-07-24T09:15:00-03:00
2026-07-24T09:15:00.123Z
```

**Rules:**
- Must include timezone — timestamps without timezone are invalid (timezone ambiguity
  prevents reliable Timeline ordering).
- The `timestamp` of a new event must be greater than or equal to the `timestamp` of the
  last event recorded in the same Timeline (append-only property — VAL-I-07). Events with
  a timestamp earlier than the Timeline's last event are rejected.
- Two events in the same Timeline may have the same `timestamp` (when they occur
  simultaneously or in rapid succession within the clock's resolution). In that case,
  `sequence_number` defines the order.

---

### `producer_type`

**Meaning:** classifies the category of the Producer that originated the event — for
traceability, audit, and compliance verification with the `producer_subtypes` declared
by the Event Type.

**Who fills it in:** the Producer (or the recording infrastructure, when the type is
inferable from context).

**When it is filled in:** at the time of recording.

**Can it be changed:** no.

**Valid values:** `Human` | `System` | `Agent`

**Rules:**
- The recorded `producer_type` must be in the `producer_subtypes` list of the referenced
  Event Type (VAL-I-09).
- An event emitted by a Producer not authorized by the Event Type is an anomaly —
  it may technically be recorded, but it is detected by Diligence.

---

### `producer_identity`

**Meaning:** specifically identifies who originated the event within the subtype declared
in `producer_type`. Allows tracing the authorship of each occurrence in the Timeline.

**Who fills it in:** the Producer.

**When it is filled in:** at the time of recording.

**Can it be changed:** no.

**Format and examples by subtype:**

| `producer_type` | Examples of `producer_identity` |
|---|---|
| `Human` | `"christiano.milfont"`, `"@user"`, full name |
| `System` | `"github-actions"`, `"jenkins-pipeline"`, system name |
| `Agent` | `"diligence-agent"`, `"assessment-agent"`, agent name |

**Rules:**
- Must be non-empty (VAL-I-05). An event without a Producer identity does not satisfy
  principle P-03 (Producer required) and invalidates INV-04 of the Ontology.
- The format does not need to be standardized across Journeys — each Journey may use
  the format that best identifies its Producers.

---

### `schema_version`

**Meaning:** version of the Instance Schema that was in effect at the time of recording. Allows
Consumers to correctly read historical Timelines, even when the Schema has evolved after
the events were recorded.

**Who fills it in:** the recording infrastructure (automatically, based on the current
Schema version).

**When it is filled in:** at the time of recording.

**Can it be changed:** no.

**Rules:**
- The value must correspond to an existing version of this document (`event-instance-schema.md`).
- Consumers that encounter an unknown `schema_version` must treat the event with
  caution — do not discard, but flag for review.
- Version `1.0.0` corresponds to this document.

---

### `payload`

**Meaning:** data specific to this occurrence — information that complements the record
with context that does not exist in the required fields. The payload structure is defined
by the `payload_shape` of the referenced Event Type.

**Who fills it in:** the Producer.

**When it is filled in:** at the time of recording, when the Event Type declares `payload_shape`.

**Can it be changed:** no. The payload is part of the immutable record. If a payload field
was recorded incorrectly, the correction occurs by emitting an `Event.Corrected` event
(see section 5).

**Rules:**
- When the Event Type declares `payload_shape`, the payload must include all fields
  marked as required in the `payload_shape` (VAL-I-08).
- Optional fields of the `payload_shape` may be absent.
- Additional fields not declared in the `payload_shape` are tolerated but not guaranteed
  for processing by Consumers.
- The payload must not contain fields that contradict the event's required fields
  (e.g., a `timestamp` field in the payload with a value different from the event's `timestamp`).

---

### `evidence_references`

**Meaning:** list of references to external artifacts that support the record as additional
evidence. Complements the intrinsic evidence (the record itself) with pointers to
documentation, links, artifacts, or external decisions that validate the occurrence.

**Who fills it in:** the Producer.

**When it is filled in:** at the time of recording, when relevant external artifacts exist.

**Can it be changed:** no.

**Structure of each reference:**
- `uri`: address or identifier of the external artifact
- `description`: description of what the artifact represents and why it is evidence of the occurrence

**Examples:**
```
- uri: https://github.com/org/repo/pull/42
  description: "PR approved by reviewer — evidence of the Code Review Gate"

- uri: prodops/artifacts/obcs/feature-checkout.md
  description: "Work Item OBC — evidence that the item had a definition of done"
```

**Rules:**
- The list may be empty or absent when intrinsic evidence is sufficient.
- External references are not validated by this Schema — responsibility for accessibility
  and integrity of external artifacts lies with the Producer.

---

### `sequence_number`

**Meaning:** ordinal position of the event in the Work Item's Timeline. Resolves ordering
ambiguities when two events have the same `timestamp`.

**Who fills it in:** the recording infrastructure (assigned automatically based on the
insertion position in the Timeline).

**When it is filled in:** at the time of recording.

**Can it be changed:** no.

**Rules:**
- Must be strictly increasing within a Timeline — the next event always has a
  `sequence_number` greater than the previous one.
- It is derivable from the event's position in the Timeline — but it is recommended to store
  it explicitly to facilitate Consumer processing without needing to reorder.
- In case of conflict between `timestamp` and `sequence_number`, `sequence_number` is
  authoritative for ordering within a Timeline.

---

### `notes`

**Meaning:** additional context about this specific occurrence — not about the Event Type
in general. Observations the Producer deemed relevant at the time of emission that do not
fit in structured fields.

**Who fills it in:** the Producer.

**When it is filled in:** at the time of recording, when relevant.

**Can it be changed:** no. Notes are part of the immutable record.

**Rules:**
- Must record context about the occurrence, not about the Event Type.
- Must not contradict the `event_type` or the `payload` fields.
- Not processed by automated Consumers — it is human context.

---

## 4. Validations

The validations below define what makes an Operational Event **recordable** in a Timeline.
An invalid event must be rejected before being persisted.

### VAL-I-01 — `event_type` references an Active type

The Event Type referenced in `event_type` must exist in the catalog (Journey or Shared) and
have `lifecycle_status = Active` at the time of emission. Emitting an event of type Draft,
Proposed, Deprecated, or Removed is invalid.

**Read exception:** when processing historical Timelines, Consumers must recognize events
with Deprecated or Removed types as valid — the validation applies only at the time of
emission, not during historical reading.

### VAL-I-02 — `work_item_id` references an existing Work Item

The Work Item identified by `work_item_id` must exist. An event cannot be recorded for
a non-existent Work Item.

### VAL-I-03 — `timestamp` with valid format and timezone

The `timestamp` must be in ISO 8601 format with an explicit timezone. Timestamps without
a timezone are invalid.

### VAL-I-04 — `producer_type` is a valid value

The `producer_type` must be one of the three canonical values: `Human`, `System`, `Agent`.

### VAL-I-05 — `producer_identity` is not empty

The `producer_identity` field must be present and must not be an empty string. Every event
must have a traceable Producer identity (P-03 of the OEM Foundation; INV-04 of the Ontology).

### VAL-I-06 — `id` is globally unique

The event `id` must be unique across all events in all Timelines — not just within the
current Work Item's Timeline.

### VAL-I-07 — `timestamp` respects the append-only property

The `timestamp` of the new event must be greater than or equal to the `timestamp` of the
last event recorded in the same Timeline. Events with a timestamp earlier than the Timeline's
last event are rejected — the Timeline is append-only and chronologically ordered.

### VAL-I-08 — `payload` satisfies the Event Type's `payload_shape`

When the Event Type declares `payload_shape`, the event payload must include all required
fields of the `payload_shape`. Missing required fields invalidate the record.

### VAL-I-09 — `producer_type` is in the Event Type's `producer_subtypes`

The recorded `producer_type` must be one of the values declared in `producer_subtypes`
by the referenced Event Type. An event emitted by an unauthorized Producer violates the
Event Type contract.

**Note:** this validation may be applied permissively (record with a warning instead of
rejecting) when the system does not have access to the catalog at the time of emission —
in that case, Diligence detects the anomaly retroactively.

### VAL-I-10 — `schema_version` corresponds to a known version

The `schema_version` must correspond to a published version of the Instance Schema. Unknown
versions are not necessarily invalid — but must be treated with caution by Consumers.

---

## 5. Immutability

### 5.1 Why an Operational Event can never be altered

The immutability of events is the most fundamental property of the Operational Event Model —
more fundamental than any other rule in this Schema.

The reason is ontological: an Operational Event records a **fact that occurred**. Facts
cannot be undone. `Bootstrap.Completed` occurred at 09:15:00 on July 24, 2026 for Work
Item WI-042. That fact is a permanent part of the Work Item's operational history. Modifying
the record would create a false history — a Timeline that claims the occurrence happened
differently from what actually happened.

Beyond the ontological aspect, immutability has three fundamental practical consequences:

**1. Derived State integrity:** the Derived State is a projection of the Timeline. If an
event could be altered, the Derived State calculated before the alteration may differ from
the one calculated after — making the past state unreliably reconstructible.

**2. Audit reliability:** Diligence verifies consistency between the Timeline and the COR.
If events could be altered, Diligence cannot guarantee that the Timeline it verifies is the
same one that produced the state in the COR.

**3. Equivalence between record and evidence:** the intrinsic evidence of an event is the
record itself. If the record can be altered, the evidence can be altered — which invalidates
the audit trail.

### 5.2 How to handle recording errors

When an event was recorded with incorrect data, the correct approach is to **emit a new
event** — never edit the original. There are two patterns:

---

**Pattern A — Correction Event**

For errors in `payload` fields or in `notes`, the Producer emits an event of type
`Event.Corrected` (Category: Correction, `alters_state = false`).

The `Event.Corrected` references the `id` of the event with the error in its payload and
documents what was incorrect and what the correct value is:

```
id:                ev-corrected-789
event_type:        Event.Corrected
work_item_id:      WI-042
timestamp:         2026-07-24T09:30:00Z
producer_type:     Human
producer_identity: christiano.milfont
schema_version:    1.0.0
payload:
  corrected_event_id: ev-original-456
  correction_note:    "branch_name recorded as 'main' — correct value is 'feat/checkout-redesign'"
```

The original event (`ev-original-456`) remains immutable in the Timeline. Consumers
processing the Timeline must check for `Event.Corrected` events and apply the correction
semantically during processing.

---

**Pattern B — State revision event**

For errors that affected the Derived State (e.g., the event declared `new_state = DONE` but
the Work Item should not have closed), the Producer emits a new event that reverts the state:

```
id:                ev-reopen-890
event_type:        Rework.Declared
work_item_id:      WI-042
timestamp:         2026-07-24T09:35:00Z
producer_type:     Human
producer_identity: christiano.milfont
schema_version:    1.0.0
payload:
  reason: "Premature closure — done criteria not satisfied"
notes:             "Reverts the incorrect DONE recorded in ev-original-456"
```

The erroneous state (`DONE`) was the Derived State for a period — that is part of the history.
The new event (`Rework.Declared`) records that the state changed again — the Timeline
preserves the reality: the Work Item went through DONE, but was reopened.

---

**What is never valid:**
- Editing any field of an already-recorded event
- Deleting an event from the Timeline
- Reordering events in the Timeline
- Replacing an event's `id` with another

---

## 6. Relationship with the Event Type

### 6.1 Contract vs. Occurrence

The Event Type and the Operational Event exist at different levels and have complementary
responsibilities:

| Dimension | Event Type (contract) | Operational Event (occurrence) |
|---|---|---|
| **What it defines** | What *can* happen | What *happened* |
| **Exists in** | Catalog (atemporal) | Timeline (positioned in time) |
| **Created by** | Journey architect / Framework | Producer (Human, System, Agent) |
| **Approved by** | Journey or Framework governance | Does not require approval |
| **Quantity** | One per class of occurrence | Zero or N per Event Type |
| **Mutability** | Fields immutable after Active; `lifecycle_status` changes | Absolutely immutable |

### 6.2 How the instance satisfies the contract

An Operational Event satisfies the Event Type contract when:

1. **`event_type`** correctly references the type name
2. **`producer_type`** is in the type's `producer_subtypes` list (VAL-I-09)
3. **`payload`** satisfies the type's `payload_shape` (VAL-I-08)
4. The type's **preconditions** were true at the time of emission — verification is the
   Producer's responsibility; Diligence may verify retroactively
5. The type's **postconditions** become true after recording — verification is the
   responsibility of Diligence and Consumers

### 6.3 Unidirectional dependency

The dependency between the Schemas is strictly unidirectional:

```
Event Type Schema ──(defines contract for)──→ Operational Event Instance
```

The Event Type Schema does not know about instances. The Operational Event references the
type by name — and the type remains valid as a reference even if it becomes Deprecated or
Removed (the Timeline is immutable; history is preserved).

### 6.4 The Event Type is consulted, never copied

When a Consumer processes a Timeline and needs `category`, `alters_state`, or `new_state`
of an event, it consults the catalog using the event's `event_type` as the key — it does
not expect to find those fields in the recorded event.

If a Consumer denormalizes derived fields for efficiency (copies `category` and `alters_state`
into the event), those fields are read-only copies — the source of truth remains the Event
Type catalog. In case of conflict, the catalog prevails.

---

## 7. Examples

The examples illustrate valid Operational Events. The concrete serialization format is
defined by the implementation — not by this Schema.

### 7.1 Minimal valid event

```
id:                ev-bs-001-started
event_type:        Bootstrap.Started
work_item_id:      WI-042
timestamp:         2026-07-24T09:00:00Z
producer_type:     Human
producer_identity: christiano.milfont
schema_version:    1.0.0
```

### 7.2 Complete event with payload and evidence

```
id:                ev-bs-001-completed
event_type:        Bootstrap.Completed
work_item_id:      WI-042
timestamp:         2026-07-24T09:15:00Z
producer_type:     Agent
producer_identity: hack-start-agent
schema_version:    1.0.0
sequence_number:   2
payload:
  branch_name:   feat/checkout-redesign
  base_commit:   a3f9c12
  smoke_passed:  true
evidence_references:
  - uri:         https://github.com/org/repo/tree/feat/checkout-redesign
    description: "Branch successfully created for Work Item WI-042"
notes:             "Smoke gate passed in 3s — within the acceptable threshold"
```

### 7.3 Gate event that does not alter state

```
id:                ev-gate-smoke-001
event_type:        Gate.Passed
work_item_id:      WI-042
timestamp:         2026-07-24T09:14:57Z
producer_type:     System
producer_identity: github-actions
schema_version:    1.0.0
sequence_number:   1
payload:
  gate_name: smoke-test
  duration_ms: 3241
evidence_references:
  - uri:         https://github.com/org/repo/actions/runs/12345
    description: "Smoke test workflow execution"
```

### 7.4 Correction event

```
id:                ev-correction-001
event_type:        Event.Corrected
work_item_id:      WI-042
timestamp:         2026-07-24T10:00:00Z
producer_type:     Human
producer_identity: christiano.milfont
schema_version:    1.0.0
payload:
  corrected_event_id: ev-bs-001-completed
  correction_note:    "branch_name recorded as 'main' — correct value is 'feat/checkout-redesign'"
```

### 7.5 Minimal Timeline sequence (three events)

```
Timeline: WI-042
──────────────────────────────────────────────────────────────
seq 1 | 09:00:00Z | Bootstrap.Started   | Human: christiano
seq 2 | 09:14:57Z | Gate.Passed         | System: github-actions
seq 3 | 09:15:00Z | Bootstrap.Completed | Agent:  hack-start-agent
──────────────────────────────────────────────────────────────
Current Derived State: HACKING (last alters_state = true → Bootstrap.Completed)
```

---

## References

- [OEM Foundation](README.md)
- [OEM Ontology](ontology.md)
- [OEM Taxonomy](taxonomy.md)
- [OEM Lifecycle](lifecycle.md)
- [Event Type Schema](event-type-schema.md)
- Schema separation decision

---

*This document is the canonical source of the structure of an Operational Event recorded
in an Operational Timeline. Every Producer that emits events and every Consumer that
processes Timelines must satisfy this Schema.*
