# Event Type Schema — Operational Event Model
# ProdOps Framework

> **Domain:** Framework — applicable to all Journeys
> **Status:** Canonical
> **Version:** 1.0.0
> **Depends on:** [README.md](README.md) · [ontology.md](ontology.md) · [taxonomy.md](taxonomy.md) · [lifecycle.md](lifecycle.md)

---

## About this document

This document defines the formal contract of an **Event Type** in the Operational Event Model.

An Event Type is a definition — not an occurrence. It specifies what can happen,
who can make it happen, how to classify the occurrence, and what impact it has on
the Work Item's Derived State.

Every Event Type catalog — whether a Journey catalog or a shared types catalog — is
a set of entries that satisfy this Schema.

This document does not define the schema of Operational Events (instances). That contract
is defined in `event-instance-schema.md`.

→ [OEM Taxonomy](taxonomy.md) · [OEM Lifecycle](lifecycle.md) · [OEM Ontology](ontology.md)

---

## 1. What is an Event Type

An Event Type is a **contract** that defines the class of an operational occurrence:

- the **name** that unambiguously identifies the occurrence in any context
- the **category** that classifies it within the Framework Taxonomy
- the **semantics** — what must be true before, what will be true after
- the **impact** on the Work Item's derived state
- who can **produce** the occurrence
- the **status** of the type in its lifecycle

An Event Type does not contain:

- occurrence timestamp (this belongs to the instance — Operational Event)
- reference to a Work Item (this belongs to the instance)
- concrete payload of an occurrence (this belongs to the instance)
- specific producer of an occurrence (this belongs to the instance)

The separation is fundamental: the Event Type is the contract; the Operational Event is the
instance that satisfies the contract.

---

## 2. Field structure

Event Type fields are organized into three groups:

| Group | Definition |
|---|---|
| **Required** | Must be present in every catalog entry for the type to be valid |
| **Conditional** | Required only when a specific condition is satisfied |
| **Optional** | May be present; not required for minimum validity |
| **Derived** | Not written in the catalog entry; computable from other fields or from context |

### 2.1 Required fields

| Field | Type | Immutable after Active? |
|---|---|---|
| `name` | string | Yes |
| `category` | enum (8 values) | Yes |
| `alters_state` | boolean | Yes |
| `preconditions` | list of strings | Yes |
| `postconditions` | list of strings | Yes |
| `producer_subtypes` | list of enum (Human, System, Agent) | Yes |
| `lifecycle_status` | enum (Draft, Proposed, Active, Deprecated, Removed) | No |
| `introduced_in` | string (catalog version) | Yes |
| `description` | string | Yes |

### 2.2 Conditional fields

| Field | Condition for requirement | Immutable after Active? |
|---|---|---|
| `new_state` | Required when `alters_state = true` | Yes |
| `deprecated_in` | Required when `lifecycle_status = Deprecated or Removed` | Yes (once filled) |
| `deprecation_reason` | Required when `lifecycle_status = Deprecated or Removed` | Yes (once filled) |
| `removed_in` | Required when `lifecycle_status = Removed` | Yes (once filled) |
| `replacement_type` | Required when `lifecycle_status = Deprecated` and a direct substitute exists | Yes (once filled) |
| `migration_deadline` | Required when `lifecycle_status = Deprecated` | Yes (once filled) |

### 2.3 Optional fields

| Field | When to use |
|---|---|
| `payload_shape` | When emission requires specific payload fields — documents the expected payload contract |
| `promotion_origin` | Only for Shared Types — reference to the Journey Type that originated the promotion |
| `owner_journey` | Only for Journey Types — identifies the responsible Journey |
| `notes` | Additional context, clarifications, design decisions relevant to catalog readers |

### 2.4 Derived fields

Derived fields are not written in catalog entries. They are computable from primary fields
or from context.

| Derived field | How to derive |
|---|---|
| `namespace` | Prefix of `name` before the first dot, when present (e.g., `Delivery` in `Delivery.Bootstrap.Started`). Within the Journey's own catalog, the namespace may be omitted from `name`. |
| `is_shared` | True if the entry belongs to the `shared-types.md` catalog; false if it belongs to a Journey catalog. |
| `lifecycle_history` | Sequence of `lifecycle_status` transitions with date and responsible party — maintained as a catalog audit log, not as an inline field of the entry. |

---

## 3. Rules for each field

### `name`

**Meaning:** unique and canonical identifier of the Event Type. It is the key that connects
the type to the Operational Event recorded in the Timeline.

**Requirement:** required.

**Mutability:** immutable after Active status (INV-TAX-01 of the Taxonomy).

**Who defines it:** the Journey (for Journey Types) or the Framework (for Shared Types).

**Rules:**
- Must follow the `[Namespace.]Subject.Action` convention of the Taxonomy
- All components in PascalCase
- Namespace is optional within the Journey's own catalog; required in cross-Journey references
- Must be unique within the catalog in which it is registered — and must be verified against
  all other catalogs (REG-01)
- Names of Deprecated and Removed types are reserved — they cannot be reused by new types
- Must be free of references to technology, implementation, or tools

---

### `category`

**Meaning:** classifies the Event Type within the 8 fixed Event Categories of the Taxonomy.
Determines the expected behavior by Event Consumers that process by category.

**Requirement:** required.

**Mutability:** immutable after Active status.

**Who defines it:** the Journey (for Journey Types) or the Framework (for Shared Types),
based on the 8 fixed categories. Journeys cannot create new categories (INV-TAX-02).

**Valid values:**

| Value | Description |
|---|---|
| `Phase Lifecycle` | Start and completion of Phases; alters state in most cases |
| `Gate` | Quality verifications or criteria; may or may not alter state |
| `Human Decision` | Human approvals, rejections, reviews; may or may not alter state |
| `Blocking` | Declaration and resolution of impediments; may or may not alter state |
| `Rework` | Return and correction cycles; alters state |
| `System` | Events generated by systems or pipelines; rarely alters state |
| `Diligence` | Anomalies detected by Diligence; rarely alters state |
| `Correction` | Corrections of recording errors; never alters state |

**Consistency rule with `alters_state`:** a type with `alters_state = true` cannot
belong to the `Correction` category (INV-TAX-04 of the Taxonomy).

---

### `alters_state`

**Meaning:** declares whether emitting this type alters the Work Item's Derived State.
This is the field Consumers use to determine which events need to be processed to
reconstruct the current state.

**Requirement:** required.

**Mutability:** immutable after Active status.

**Who defines it:** the Journey or the Framework, based on the type's semantics.

**Valid values:** `true` | `false`

**Consequence of `alters_state = true`:** the `new_state` field becomes required.

**Consistency rule:** cannot be `true` for types in the `Correction` category.

---

### `new_state`

**Meaning:** the value to which the Work Item's Derived State transitions when this type
is emitted. This is the field that allows reconstruction of the current state without
processing the entire Timeline.

**Requirement:** conditional — required when `alters_state = true`; absent when
`alters_state = false`.

**Mutability:** immutable after Active status.

**Who defines it:** the Journey or the Framework, based on the Journey's state model.

**Rules:**
- Must be a valid value in the Journey's state model (e.g., `HACKING`, `BLOCKED`,
  `DONE` for the Delivery Journey)
- The set of possible `new_state` values must be consistent within a Journey —
  the Journey's catalog is the source of truth for possible states

---

### `preconditions`

**Meaning:** list of conditions that must be true at the time of emission for the event
to be valid. Defines the semantics of when the type should be emitted.

**Requirement:** required (may be an empty list only if no preconditions exist —
which must be explicitly declared, not omitted).

**Mutability:** immutable after Active status.

**Who defines it:** the Journey or the Framework.

**Format:** list of strings in natural language, each item representing a verifiable
condition. Example:
```
- The Work Item is in the HACKING state
- At least one Pull Request is open for the Work Item
- The PR author is the same as the one with the Work Item in progress
```

---

### `postconditions`

**Meaning:** list of guarantees that must be true after the event is emitted.
Defines what Consumers that process this type can assume.

**Requirement:** required (same empty list rule as `preconditions`).

**Mutability:** immutable after Active status.

**Who defines it:** the Journey or the Framework.

**Format:** list of strings in natural language. Example:
```
- The Work Item transitions to the SYNCING state
- The Timeline contains at least one Bootstrap.Completed event before this one
- The Derived State in the COR reflects the new state after synchronization
```

---

### `producer_subtypes`

**Meaning:** declares which Producer subtypes may emit events of this type.
Delimits the contract of who is responsible for emission.

**Requirement:** required.

**Mutability:** immutable after Active status.

**Who defines it:** the Journey or the Framework, based on who naturally originates
the represented occurrence.

**Valid values (list — at least one must be present):**

| Value | Description |
|---|---|
| `Human` | A human who interacts with the process (e.g., developer, reviewer, manager) |
| `System` | An automated system, pipeline, or external tool (e.g., CI/CD, GitHub Actions) |
| `Agent` | An AI or automation agent in the ProdOps context (e.g., Diligence engine, Assessment agent) |

---

### `lifecycle_status`

**Meaning:** current status of the type in its lifecycle — reflects whether the type is
being drafted, available for emission, deprecated, or removed.

**Requirement:** required.

**Mutability:** changes as the lifecycle progresses (this is the only required field
that is mutable after Active — but transitions follow the rules in `lifecycle.md`).

**Who defines it:** whoever governs the type (Journey for Journey Types; Framework
for Shared Types and for the `Proposed → Active` transition).

**Valid values:** `Draft` | `Proposed` | `Active` | `Deprecated` | `Removed`

**Transition rules:** defined in `lifecycle.md`.

---

### `introduced_in`

**Meaning:** version of the catalog in which the type was added. Allows tracing when
the type became part of the catalog and auditing backward compatibility.

**Requirement:** required.

**Mutability:** immutable after being filled in.

**Who defines it:** whoever approves the Draft → Active transition (Journey or Framework).

**Format:** string identifying the catalog version (e.g., `"1.0.0"`, `"2026-Q3"` — the
format is defined by the Journey catalog or by the Framework for Shared Types).

---

### `description`

**Meaning:** textual description of the occurrence that the type represents. Must be
sufficient for a catalog reader to understand the purpose of the type without needing
to consult additional documentation.

**Requirement:** required.

**Mutability:** immutable after Active status.

**Who defines it:** the Journey or the Framework.

**Rules:**
- Must describe the occurrence, not the implementation
- Must be self-contained — a reader without implementation context must understand it
- Must describe the occurrence in the voice that represents the fact (e.g., "The Work Item
  started the Bootstrap Phase", not "When Bootstrap begins")

---

### `deprecated_in`

**Meaning:** version of the catalog in which the type was deprecated.

**Requirement:** conditional — required when `lifecycle_status = Deprecated or Removed`.

**Mutability:** immutable after being filled in.

**Who defines it:** whoever deprecated the type.

---

### `deprecation_reason`

**Meaning:** textual justification of the deprecation. Explains why the type was deprecated
and guides those migrating Skills that emitted it.

**Requirement:** conditional — required when `lifecycle_status = Deprecated or Removed`.

**Mutability:** immutable after being filled in.

---

### `removed_in`

**Meaning:** version of the catalog in which the type was removed from the active catalog.

**Requirement:** conditional — required when `lifecycle_status = Removed`.

**Mutability:** immutable after being filled in.

---

### `replacement_type`

**Meaning:** reference to the replacement type. Must be present when there is a direct
type that replaces the deprecated one — guides the migration of Skills and Consumers.

**Requirement:** conditional — required when `lifecycle_status = Deprecated` and a direct
substitute exists. May be omitted in obsolescence deprecations without a substitute.

**Mutability:** immutable after being filled in.

**Format:** string with the full name of the replacement type (with Namespace when cross-Journey).
Example: `"Shared.Gate.Failed"` or `"Bootstrap.SmokeGate.Failed"`.

---

### `migration_deadline`

**Meaning:** Journey cycle until which emission of the deprecated type is still tolerated.
After this cycle, emissions of the deprecated type are anomalies to be detected by Diligence.

**Requirement:** conditional — required when `lifecycle_status = Deprecated`.

**Mutability:** immutable after being filled in.

---

### `payload_shape`

**Meaning:** description of the expected fields in the payload of an instance of this type.
Defines the data contract that the Producer must include when emitting the event.

**Requirement:** optional — but highly recommended for types with specific semantics
that require structured data.

**Mutability:** immutable after Active status (any addition of a required field to the
payload shape is a semantic change — requires deprecation and creation of a new type).
Optional fields in the payload shape may be added without deprecation.

**Who defines it:** the Journey or the Framework.

**Format:** list of fields with name, type, and requirement. Example:
```
- branch_name (string, required): name of the branch created for the Work Item
- base_commit (string, required): hash of the branch's base commit
- smoke_gate_passed (boolean, optional): result of the initial smoke gate
```

**Payload compatibility rule:**
- Adding an **optional** field to the payload shape: backward-compatible
- Adding a **required** field to the payload shape: breaking change — deprecate type and create new
- Removing a field: breaking change — deprecate type and create new

---

### `promotion_origin`

**Meaning:** reference to the Journey Type that originated this Shared Type. Present only
in shared catalog types that were promoted from a Journey catalog.

**Requirement:** optional — present only in Shared Types created by promotion.

**Mutability:** immutable after being filled in.

**Who defines it:** the Framework, at the time of promotion approval.

---

### `owner_journey`

**Meaning:** identifies the Journey responsible for the type. Present only in Journey Types.

**Requirement:** optional — recommended in Journey Types for clarity of responsibility.

**Mutability:** immutable after being filled in (if the Journey changes, it is an indicator
that the type should be promoted to Shared — not that `owner_journey` should be changed).

---

### `notes`

**Meaning:** additional context relevant to catalog readers. Non-obvious design decisions,
clarifications of ambiguities, justifications for naming choices.

**Requirement:** optional.

**Mutability:** may be updated — notes are not part of the formal type contract; they are
explanatory context. However, notes must not contradict the type's immutable fields.

---

## 4. Validations

The validations below define what makes a catalog entry **valid**. An invalid entry cannot
transition from Draft to Active.

### VAL-01 — Name uniqueness

The `name` of a type must be unique within the catalog in which it is registered.
Additionally, it must be verified against all other catalogs (Journeys and Shared Types)
to ensure no type with the same name and different semantics exists.

Names of types with Deprecated or Removed status are **reserved** — they cannot be reused
by new types.

### VAL-02 — Name convention conformance

The `name` must follow the `[Namespace.]Subject.Action` convention with PascalCase in all
components. Names that do not conform must be rejected at the Draft → Active transition.

**Valid examples:** `Bootstrap.Started`, `Gate.Failed`, `Delivery.Promote.Completed`

**Invalid examples:** `bootstrap_started`, `GATE-FAILED`, `started` (without Subject), `Bootstrap`
(without Action)

### VAL-03 — Valid Category

The `category` must be one of the 8 fixed values of the Taxonomy. Values outside this list
are invalid — Journeys cannot create new categories.

### VAL-04 — `alters_state` declared

The `alters_state` field must be present and have an explicit value (`true` or `false`).
The absence of the field invalidates the entry.

### VAL-05 — `new_state` present when `alters_state = true`

When `alters_state = true`, the `new_state` field is required. Its absence invalidates
the entry regardless of the `lifecycle_status`.

### VAL-06 — `alters_state` × `category` consistency (INV-TAX-04)

A type with `alters_state = true` cannot belong to the `Correction` category. This is the
only Category where `alters_state = true` is structurally invalid — `Correction` represents
the recording of an error correction, which does not alter the Work Item's flow.

### VAL-07 — Valid `lifecycle_status`

The `lifecycle_status` must be one of the 6 canonical values: `Draft`, `Proposed`, `Active`,
`Deprecated`, `Removed`. Transitions between states must follow the rules in `lifecycle.md`.

### VAL-08 — Deprecation fields present when `lifecycle_status = Deprecated`

When `lifecycle_status = Deprecated`, the fields `deprecated_in`, `deprecation_reason`, and
`migration_deadline` are required. The absence of any one invalidates the entry.

### VAL-09 — Removal fields present when `lifecycle_status = Removed`

When `lifecycle_status = Removed`, the fields `deprecated_in`, `deprecation_reason`, and
`removed_in` are required (the type went through Deprecated before Removed).

### VAL-10 — `producer_subtypes` not empty

The `producer_subtypes` list must contain at least one valid value. An empty list invalidates
the entry — every Event Type must have at least one authorized Producer type.

### VAL-11 — Emission prohibited for non-Active types

Only types with `lifecycle_status = Active` may be emitted by Skills and Steps.
Types in Draft, Proposed, Deprecated, or Removed status cannot be referenced by new
emissions. This validation is executed at the time of emission (Instance Schema), but derives
from the Event Type Schema's `lifecycle_status`.

### VAL-12 — `payload_shape` immutable after Active

If `payload_shape` is present in an Active type, its required fields cannot be altered or
removed. Addition of optional fields is compatible; any breaking change requires deprecation
of the type and creation of a new one.

---

## 5. Schema Compatibility

### 5.1 Compatible evolution principle

The Event Type Schema must be able to evolve without forcing the rewriting of existing
catalogs. Catalogs that were valid before a Schema evolution must remain valid after the
evolution — or receive a migration period with clear communication.

### 5.2 Backward-compatible changes

The following Schema changes do not break existing catalogs:

| Change | Why it is compatible |
|---|---|
| Adding an optional field | Existing catalogs do not have the field — this is valid by the definition of optional |
| Adding a new possible `category` value | Existing catalogs use the old values — they remain valid |
| Adding an explanatory note to an existing field | Does not alter the formal structure |
| Adding a new enum for `producer_subtypes` | Existing catalogs use the old values — they remain valid |
| Changing the description of a field (without altering its semantics) | Clarification, not a breaking change |

### 5.3 Breaking changes (require migration)

The following Schema changes break existing catalogs and require a migration period:

| Change | Why it is breaking | Process |
|---|---|---|
| Making an optional field required | Existing entries without the field become invalid | Version the Schema; communicate migration deadline to all catalogs |
| Removing an existing field | Existing entries with the field have data without a contract | Deprecate the field first; remove in the next version |
| Altering the semantics of a field | Existing entries formally but not semantically satisfy the new Schema | Deprecate the field, create a new field with a different name |
| Changing a possible enum value | Existing entries with the old value become invalid | Version the Schema; communicate deadline |

### 5.4 Schema versioning

The Schema is versioned in `event-type-schema.md` with the `Version:` field in the header.

Each Journey catalog and the Shared Types catalog must declare the Schema version they
satisfy. When the Schema evolves with a breaking change, existing catalogs declare the
previous version — and have a period to migrate to the new version.

The Framework is responsible for communicating breaking Schema evolutions to all Journeys
and establishing the migration deadline.

### 5.5 Historical backward-compatibility guarantee

Regardless of any Schema evolution, Removed types remain readable in the historical catalog
with the structure they had at the time of removal. The historical catalog is not migrated —
it preserves the original definition so Consumers can decode historical Timelines.

---

## 6. Examples

The examples below illustrate valid catalog entries. The concrete serialization format
(YAML, JSON, Markdown table) is defined by the catalog that implements this Schema — not
by this document.

### 6.1 Minimal valid type in Draft

```
name:              Phase.Started
category:          Phase Lifecycle
alters_state:      true
new_state:         [to be defined by the Journey]
preconditions:     []
postconditions:    []
producer_subtypes: [Human, Agent]
lifecycle_status:  Draft
introduced_in:     (to be filled when transitioning to Active)
description:       A Phase has started for the Work Item.
```

### 6.2 Complete Active type

```
name:              Bootstrap.Completed
category:          Phase Lifecycle
alters_state:      true
new_state:         HACKING
preconditions:
  - The Work Item is in the BOOTSTRAPPING state
  - The working branch was successfully created
  - The smoke gate passed
postconditions:
  - The Work Item transitions to the HACKING state
  - The Timeline records Bootstrap.Completed before any Hack Phase event
producer_subtypes: [Human, Agent]
lifecycle_status:  Active
introduced_in:     1.0.0
description:       The Bootstrap Phase completed successfully. The Work Item is
                   ready to begin development in the Hack Phase.
payload_shape:
  - branch_name (string, required): name of the created branch
  - base_commit  (string, required): hash of the base commit
  - smoke_passed (boolean, required): result of the smoke gate
owner_journey:     Delivery
```

### 6.3 Deprecated type with substitute

```
name:              Phase.Finished
category:          Phase Lifecycle
alters_state:      true
new_state:         (obsolete — see replacement_type)
preconditions:     [obsolete — see replacement_type]
postconditions:    [obsolete — see replacement_type]
producer_subtypes: [Human, Agent]
lifecycle_status:  Deprecated
introduced_in:     1.0.0
deprecated_in:     1.2.0
deprecation_reason: Type renamed to Bootstrap.Completed for greater semantic precision.
                    The generic name Phase.Finished created ambiguity between Phases.
replacement_type:  Bootstrap.Completed
migration_deadline: Cycle 2026-Q4
description:       [DEPRECATED] A Phase was completed. Use Bootstrap.Completed.
owner_journey:     Delivery
```

### 6.4 Correction type (alters_state = false)

```
name:              Event.Corrected
category:          Correction
alters_state:      false
preconditions:
  - A previous event in the Timeline has incorrect data
  - The correction has been authorized and documented
  - The original event remains immutable in the Timeline
postconditions:
  - The Timeline contains the correction event after the original event
  - The correction event references the corrected event's id in the payload
producer_subtypes: [Human]
lifecycle_status:  Active
introduced_in:     1.0.0
description:       A recording error in a previous event has been corrected. The correction
                   does not alter the Derived State — it is an audit record.
payload_shape:
  - corrected_event_id (string, required): id of the event with incorrect data
  - correction_note    (string, required): description of what was corrected and why
```

---

## References

- [OEM Foundation](README.md)
- [OEM Ontology](ontology.md)
- [OEM Taxonomy](taxonomy.md)
- [OEM Lifecycle](lifecycle.md)
- Schema separation decision

---

*This document is the canonical source of the Event Type contract in the OEM. Every event
catalog — per Journey or shared — must satisfy this Schema in all its entries with Active status.*
