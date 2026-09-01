# Operational Event Model Ontology
# ProdOps Framework

> **Domain:** Framework — applicable to all Journeys
> **Status:** Canonical
> **Version:** 1.0.0
> **Depends on:** [README.md](README.md) — OEM foundation

---

## About this document

This document formalizes the ontology of the **Operational Event Model (OEM)**: the canonical
concepts, the relationships between them, the valid cardinalities, the inviolable invariants,
and the responsibility boundaries of each domain.

This document does not define schema, format, storage, technical implementation, or
automation mechanisms. Those subjects belong to subsequent documents.

→ [OEM Foundation](README.md) · [Framework Ontology](../ontology.md) · [Glossary](../glossary.md)

---

## 1. Canonical Diagram

```
┌────────────────────────────────────────────────────────────────────────────┐
│                      OPERATIONAL EVENT MODEL (OEM)                         │
│                                                                            │
│   Event Producer                    Event Category                        │
│   (Human | System | Agent)          (Phase Lifecycle | Gate |              │
│          │                           Human Decision | Blocking |           │
│          │ produces (1→N)            System | Rework | Diligence)          │
│          │                                    │                            │
│          │                                    │ classifies (1→N)           │
│          │                                    ↓                            │
│          └─────────────────────────→ [ Operational Event ]                 │
│                                            │    │                          │
│                                            │    └──── Event Evidence       │
│                                            │           (1:1 with event)    │
│                                            │                               │
│                                   typed by │                               │
│                                            ↓                               │
│                                       Event Type                           │
│                                    (defined by Journey)                    │
│                                            │                               │
│                                            │ instantiates (N→1)            │
│                                            ↓                               │
│                                  [ Operational Timeline ]                  │
│                                    (per Work Item — 1:1)                   │
│                                            │                               │
│                               projects to  │                               │
│                                            ↓                               │
│                                    [ Derived State ]                       │
│                                    (current projection — 1:1 with Timeline)│
│                                                                            │
└────────────────────────────────────────────┬───────────────────────────────┘
                                             │
                materializes Derived State in│
                                             ↓
                      ┌──────────────────────────────────────────┐
                      │    Canonical Operational Representation   │
                      │    (COR — OEM consumer, not part of it)  │
                      └──────────────────────┬───────────────────┘
                                             │
                              verified by    │
                                             ↓
                      ┌──────────────────────────────────────────┐
                      │              Diligence                   │
                      │  (Event Consumer — verifies Timeline×COR)│
                      └──────────────────────────────────────────┘

Event Consumers (orthogonal — consume the Timeline directly):

   ┌──────────────┐   ┌──────────────┐   ┌──────────────┐
   │   Metrics    │   │  Assessment  │   │    Agents    │
   │  (time       │   │  (pattern    │   │  (fact-based │
   │  functions)  │   │  analysis)   │   │  decisions)  │
   └──────────────┘   └──────────────┘   └──────────────┘
```

---

## 2. Canonical Concepts

### 2.1 Operational Event

> The atomic and immutable fact that records a transition, decision, or significant condition
> that occurred during the execution of a Journey.

**Required properties:**

| Property | Type | Description |
|---|---|---|
| `journey` | reference | Journey to which the event belongs |
| `cycle` | reference (optional) | Specific Cycle, when applicable |
| `phase` | reference | Phase during which the event occurred |
| `work_item` | reference | Work Item to which the event belongs |
| `event_type` | Event Type | The canonical type of this event |
| `producer` | Event Producer | Who originated the event |
| `timestamp` | point in time | Precise moment at which the event occurred |
| `evidence` | Event Evidence | The immutable record of the event (self-evidence) |

**Optional properties:**

| Property | Type | Description |
|---|---|---|
| `cause` | reference | Prior event that caused this event (explicit causality) |
| `artifacts` | list of references | Knowledge Space artifacts affected or referenced |
| `alters_state` | boolean | Whether this event alters the Derived State |
| `new_state` | value | The resulting Derived State (when `alters_state = true`) |

**What the Operational Event is not:**

- Not the Work Item — it belongs to the Work Item
- Not the artifact (OBC, BDD) — it records something that happened with the artifact
- Not the Derived State — it may cause a state change, but it is not the state
- Not future intent — records only past facts

---

### 2.2 Operational Timeline

> The ordered, immutable, and cumulative sequence of all Operational Events associated
> with a specific Work Item, from its creation to its closure.

**Properties:**

| Property | Type | Description |
|---|---|---|
| `work_item` | reference (1:1) | The Work Item to which this Timeline belongs |
| `events` | ordered list | All Operational Events, ordered by timestamp |
| `derived_state` | Derived State | The current projection — computed, not stored |

**Structural characteristics:**

- **Ordered by timestamp:** never by insertion order
- **Append-only:** events are only added, never removed or reordered
- **Cumulative:** the Timeline only grows over the Work Item's lifetime
- **Authoritative:** in conflict with any other state representation, the Timeline prevails

**What the Timeline is not:**

- Not a system log — it has process semantics, not infrastructure semantics
- Not a Kanban — it does not represent the current state; it produces state as a derivation
- Not a Work Item edit history — it records process events, not Work Item metadata changes

---

### 2.3 Derived State

> The current state of a Work Item, computed as the projection of the last Operational Event
> that alters state in its Operational Timeline.

**Properties:**

| Property | Type | Description |
|---|---|---|
| `timeline` | reference (1:1) | The Timeline from which the state is derived |
| `value` | structure | Current state: Journey + Phase + Status + any relevant dimension |
| `derived_from` | reference | The specific event that determined this state |
| `at` | point in time | Timestamp of the event that generated this state |

**Derivation rule:**

```
Derived State = f(last event where alters_state = true in the Timeline)
```

If no event in the Timeline alters state, the Derived State is the Work Item's initial state
(entry into the Journey).

**Characteristics:**

- **Mutable:** changes with each new event where `alters_state = true`
- **Derived:** never updated manually; only via new events
- **Without memory:** the Derived State does not record the past — the Timeline does
- **Always consistent with the Timeline:** if inconsistent, the Timeline prevails

---

### 2.4 Event Producer

> The agent responsible for originating and recording an Operational Event.

Every Operational Event has exactly one Producer. The Producer's identity is immutable
after the event is recorded — it cannot be retroactively changed.

**Three subtypes:**

| Subtype | Description | Identification |
|---|---|---|
| **Human** | Person who made a decision or performed an action | Role + identity |
| **System** | Pipeline, tool, or automated platform | System name + version |
| **Agent** | AI agent executing a Skill | Agent type + instance |

**Notes on identity:**

- A Human Producer is identified by their role in the process (e.g., "Tech Lead approving
  Promote") and by their identity — not just a username.
- A System Producer is identified by the specific system (e.g., "CI Pipeline — build gate")
  — not generically as "automation".
- An Agent Producer is identified by the agent type and the Skill being executed.

**Event Producer as a formal concept:**

The Event Producer is not an independent entity with its own lifecycle in the OEM — it is
a required structural attribute of every Operational Event. There is no separate "Producer
registry"; the Producer exists as part of the event it originated.

---

### 2.5 Event Consumer

> The role assumed by any Framework component that reads Operational Events or the Operational
> Timeline to produce analysis, verification, or decisions.

Event Consumer is a role, not an entity. The same component can be a Producer in one context
and a Consumer in another.

**Canonical OEM consumers:**

| Consumer | What it consumes | For what purpose |
|---|---|---|
| **Diligence** | Complete Timeline | COR×Timeline consistency verification; temporal checks |
| **Metrics** | Event timestamps | Lead Time, Rework, Gate Quality, DORA calculation |
| **Assessment** | Event patterns across Timelines | Objective analysis of multiple releases |
| **Agents** | Current Work Item's Timeline | Fact-based decision making; execution context |
| **Humans** | Timeline visualization | Review, audit, postmortem, retrospective |

**Note on the COR:**

The COR does not consume the Timeline directly — it materializes the Derived State. The COR
is a projection of a single point in the Timeline (the current state), not an analytical
consumer of the entire event sequence.

**Event Consumer as a formal concept:**

Like Event Producer, Event Consumer is an interaction attribute, not an entity with its
own lifecycle in the OEM. It defines the role of whoever reads events — but the consumers
themselves (Diligence, Assessment, Agents) are concepts defined in their own domains.

---

### 2.6 Event Category

> A high-level classification that groups Event Types by operational nature.

Event Categories are defined at the Framework level — they are fixed and apply to all
Journeys. An Event Type belongs to exactly one Category.

**Canonical categories:**

| Category | Nature | Examples of types |
|---|---|---|
| **Phase Lifecycle** | Entry or exit transition of a Phase | `Phase.Started`, `Phase.Completed` |
| **Gate** | Result of a quality criterion evaluation | `Gate.Passed`, `Gate.Failed` |
| **Human Decision** | Decision made by a human in the flow | `Approve.Granted`, `Approve.Rejected` |
| **Blocking** | Declaration or resolution of an impediment | `Impediment.Declared`, `Impediment.Resolved` |
| **Rework** | Return to a prior Phase | `Rework.Declared`, `Rework.Resolved` |
| **System** | Event originated by infrastructure or pipeline | `Pipeline.Failed`, `Deploy.Completed` |
| **Diligence** | Event emitted by Diligence when detecting an anomaly | `Stale.Detected`, `Drift.Detected` |
| **Correction** | Correction of an incorrectly recorded event | `Event.Corrected` |

**Properties of a Category:**

| Property | Type | Description |
|---|---|---|
| `name` | identifier | Unique category name |
| `nature` | description | The operational nature the category represents |
| `alters_state` | boolean | Whether events of this category typically alter the Derived State |
| `requires_producer` | subtype | Required Producer subtype (e.g., Human Decision requires Human) |

---

### 2.7 Event Type

> The canonical name of a specific class of Operational Event, belonging to an Event
> Category and defined in a Journey's event catalog.

**Event Type vs. Operational Event:**

- `Event Type` is the class: the abstract definition of a type of event (`Bootstrap.Started`)
- `Operational Event` is the instance: the concrete occurrence of a type at a specific moment
  for a specific Work Item

**Properties of an Event Type:**

| Property | Type | Description |
|---|---|---|
| `name` | identifier | Name in `Phase.Action` format (PascalCase) |
| `category` | Event Category | The category to which this type belongs |
| `journey` | Journey | The Journey whose catalog defines this type |
| `phase` | Phase | The Phase during which this event typically occurs |
| `alters_state` | boolean | Whether instances of this type alter the Derived State |
| `new_state` | value (optional) | The resulting Derived State when `alters_state = true` |
| `producer_subtypes` | list | Valid Producer subtypes for this type |
| `preconditions` | list | Conditions that must be true before emitting this event |
| `postconditions` | list | Conditions that become true after emitting this event |

**Naming convention:**

```
[Phase].[Action]        → Bootstrap.Completed
[Phase].[Subject]       → Hack.PROpened
[Gate].[Result]         → Validate.GateFailed
[Entity].[Transition]   → OBC.StateChanged
```

The Event Type catalog of each Journey is defined in Journey-specific documents
(`journeys/<journey>/events/catalog.md`). This document defines the concept of Event
Type — not the concrete types of any Journey.

---

### 2.8 Event Evidence

> The immutable record that proves an Operational Event occurred.

**Fundamental principle:**

> An Operational Event is self-evidencing: the event record itself IS the evidence
> that it occurred.

However, events of high criticality (approvals, promotions, quality gates) may reference
additional evidence external to the OEM — Knowledge Space artifacts, pipeline results,
test reports.

**Two levels of evidence:**

| Level | Description | Origin |
|---|---|---|
| **Intrinsic** | The immutable event record itself (producer, timestamp, context) | The OEM — part of every event |
| **Referenced** | External artifacts that corroborate the event | Knowledge Space, pipeline, external systems |

**Event Evidence as a formal concept:**

Event Evidence is not a separate entity with its own identity — it is a structural property
of every Operational Event. Its formalization as a canonical concept serves to make explicit that:

1. Every event is evidence of its own occurrence (intrinsic evidence)
2. Critical events should reference external verifiable evidence
3. Diligence can verify the quality of evidence — not just the existence of the event

---

## 3. Relationships

### 3.1 Relationship table

| Concept | Depends on | Belongs to | Produces | Consumes | References | Can exist without |
|---|---|---|---|---|---|---|
| **Operational Event** | Event Type, Event Producer, Work Item | Operational Timeline | Event Evidence (intrinsic) | — | Journey, Phase, Cycle, Artifacts | Derived State change (event may not alter state) |
| **Operational Timeline** | Work Item | — (is the root per Work Item) | Derived State | — | Work Item | Cannot exist without Work Item |
| **Derived State** | Operational Timeline | Operational Timeline | — | COR (for materialization) | — | Cannot exist without Timeline |
| **Event Producer** | — | — (is a role) | Operational Events | — | — | Event Producer exists independently of OEM |
| **Event Consumer** | — | — (is a role) | — | Operational Events / Timeline | — | Event Consumer exists independently of OEM |
| **Event Category** | — | OEM (Framework) | — | — | Event Types | Yes — Category exists even without associated Types |
| **Event Type** | Event Category | Journey Event Catalog | Operational Events (instances) | — | Phase, Journey | No — Type requires Category |
| **Event Evidence** | Operational Event | Operational Event | — | Diligence (verification) | External artifacts | Intrinsic evidence: no. Referenced: yes |

### 3.2 Detailed relationships per concept

**Operational Event:**
- belongs to exactly **1** Operational Timeline
- is typed by exactly **1** Event Type
- has exactly **1** Event Producer
- produces exactly **1** Event Evidence (intrinsic)
- may reference **0 to N** Knowledge Space artifacts
- may or may not alter the Derived State (depends on the Event Type)
- may have **0 or 1** cause event (explicit causality)

**Operational Timeline:**
- belongs to exactly **1** Work Item
- contains **0 to N** Operational Events (0 at creation time)
- produces exactly **1** Derived State (the current projection)
- is consumed by **N** Event Consumers (Diligence, metrics, Assessment, agents)
- is partially materialized by the COR (only the Derived State, not the full Timeline)

**Derived State:**
- belongs to exactly **1** Operational Timeline
- is derived from exactly **1** Operational Event (the last state-altering one)
- is materialized by the COR (partially — the COR does not store the entire Timeline)
- is never edited directly — only via new events in the Timeline

**Event Category:**
- groups **1 to N** Event Types
- is defined at the Framework level — not by Journey
- an Event Type belongs to exactly **1** Category

**Event Type:**
- belongs to exactly **1** Event Category
- belongs to the catalog of exactly **1** Journey
- is instantiated by **0 to N** Operational Events (across the system's lifetime)
- each instance is a concrete Operational Event

---

## 4. Cardinalities

### 4.1 Cardinality table

| Relationship | Cardinality | Justification |
|---|---|---|
| Work Item → Operational Timeline | 1:1 | Each Work Item has exactly one operational history |
| Operational Timeline → Operational Events | 1:N | A Timeline contains zero or more events |
| Operational Event → Operational Timeline | N:1 | Every event belongs to exactly one Timeline |
| Operational Event → Event Type | N:1 | Every event is typed by exactly one Type |
| Operational Event → Event Producer | N:1 | Every event has exactly one Producer |
| Operational Event → Event Evidence (intrinsic) | 1:1 | Every event is self-evidencing |
| Operational Event → Referenced Artifacts | N:M | An event may reference multiple artifacts; an artifact may be referenced by multiple events |
| Operational Timeline → Derived State | 1:1 | A Timeline has exactly one Derived State (the current one) |
| Event Category → Event Types | 1:N | A Category groups one or more Types |
| Event Type → Event Category | N:1 | A Type belongs to exactly one Category |
| Event Type → Operational Events | 1:N | A Type may be instantiated zero or more times |
| Event Producer → Operational Events | 1:N | A Producer may originate zero or more events |

### 4.2 Critical cardinalities with expanded justification

**1 Work Item : 1 Operational Timeline**
The Timeline is the operational identity of a Work Item. It does not make sense for a Work
Item to have two parallel Timelines — that would be like having two simultaneous histories.
If a Work Item is split, two distinct Work Items arise, each with its own Timeline.

**N Operational Events : 1 Operational Timeline** (not 1:1)
The Timeline starts empty (the Work Item exists before having events). Over the Work Item's
lifetime, events are added. The minimum cardinality is 0 (a newly created Work Item with
no events recorded yet).

**N Operational Events : 1 Event Type** (not 1:1)
The same type of event may occur multiple times in the same Work Item — for example,
`Hack.PROpened` may occur 3 times if there were 3 PRs across multiple iterations.
The Event Type defines the class; the Timeline contains all instances.

**1 Operational Timeline : 1 Derived State** (current snapshot — not history)
The Derived State is not a list of all states the Work Item has ever been in — that is
the event history in the Timeline. The Derived State is the state *now*. There is always
exactly one current state per Work Item.

---

## 5. Invariants

Invariants are rules that can never be violated, regardless of Journey, Phase, implementation,
or context. Any violation represents a fundamental breach of the OEM.

### INV-01 — Immutability of events

> Every Operational Event is immutable from the moment of its recording.

No field of a recorded event can be altered — not the timestamp, not the producer,
not the state change. If an event was recorded incorrectly, a new event of type
`Event.Corrected` is emitted, referencing the original event. The original event remains
in the Timeline unchanged.

**Violation:** directly altering any field of an already-recorded event.

### INV-02 — Timeline integrity (append-only)

> Operational Events are never removed from an Operational Timeline.

The Timeline is append-only — it grows over the Work Item's lifetime, never shrinks. Removing
an event would be equivalent to erasing a fact from operational history — which would make
the Timeline untrustworthy as a source of truth.

**Violation:** deleting, archiving, or moving events from a Timeline.

### INV-03 — Timeline uniqueness per Work Item

> Every Work Item has exactly one Operational Timeline.

There are no duplicate, alternative, or parallel Timelines for the same Work Item.

**Violation:** creating a second Timeline for a Work Item that already has an active Timeline.

### INV-04 — Producer required in every event

> Every Operational Event has exactly one identified Event Producer.

There are no anonymous events in the OEM. The absence of a Producer invalidates the record
as an Operational Event — making it a log without process semantics.

**Violation:** recording an event without a Producer, or with a generic Producer like
"system" without precise identification.

### INV-05 — Derived State never updated directly

> The Derived State of a Work Item is always and exclusively computed from the events
> of its Operational Timeline.

No agent, human, system, or external mechanism can update the Derived State directly. The
only way to change the Derived State is to add a new event to the Timeline with `alters_state = true`.

**Violation:** updating a Work Item state field without recording the corresponding event.

### INV-06 — COR is never the source of truth

> The Canonical Operational Representation (COR) is a materialization of the Derived State —
> never the primary source of operational truth.

In case of divergence between what the COR displays and what the Timeline indicates, the
Timeline prevails. The COR must be corrected to reflect the Derived State derived from the Timeline.

**Violation:** using the state displayed in the COR as a reference when it diverges from the
Timeline, without investigating and correcting the divergence.

### INV-07 — Event Types are defined in Journey catalogs

> No Operational Event may use an Event Type that is not defined in the corresponding
> Journey's event catalog.

Ad-hoc events with types invented at the time of emission compromise standardization and
make the Timeline impossible to process consistently by Event Consumers.

**Violation:** recording an event with an arbitrary, uncataloged type.

### INV-08 — The absence of an expected event is treated as data

> When an event expected for a Phase does not occur within the expected time window,
> that absence is recorded as operational information — not ignored as a gap.

Diligence is responsible for detecting event absences and emitting the corresponding
diagnostic event (Diligence category, e.g., `Stale.Detected`).

**Violation:** ignoring the absence of an expected event without recording it as an anomaly.

### INV-09 — Work Item Timeline prevails over any other representation

> In case of conflict between the Operational Timeline and any other system that represents
> the Work Item's state (COR, backlogs, reports), the Timeline prevails.

**Violation:** resolving a divergence by correcting the Timeline to match the COR, instead
of correcting the COR to match the Timeline.

### INV-10 — Corrections are events, never retroactive edits

> Errors in recorded events are corrected by emitting a new event of type `Event.Corrected`,
> never by retroactively editing the original event.

**Violation:** editing any field of an already-recorded event, even if the field contains
incorrect information.

---

## 6. Responsibility Boundaries

### 6.1 What belongs to the OEM

The OEM is responsible for the definition and governance of the following concepts:

- **Operational Event:** definition, required and optional properties, invariants
- **Operational Timeline:** structure, ordering, append-only property, relationship with Work Item
- **Derived State:** definition, derivation rule, relationship with Timeline
- **Event Producer:** taxonomy of subtypes (Human, System, Agent)
- **Event Consumer:** role definition; concrete consumers are defined in their domains
- **Event Category:** canonical taxonomy of categories (fixed in the Framework)
- **Event Type:** structure and naming conventions; concrete types are defined by Journey
- **Event Evidence:** definition of the two levels (intrinsic and referenced)
- **Invariants** (INV-01 to INV-10)
- **Principles** (P-01 to P-10, defined in the README)

### 6.2 What belongs to Diligence

Diligence is a specialized Event Consumer — it verifies, it does not produce operational state.
It is responsible for:

- Definition of temporal Checks (did the expected event occur?)
- Definition of consistency Checks (does the COR reflect the Derived State?)
- Generation of Findings when invariants are violated
- Emission of `Diligence` category events when anomalies are detected
- Workspace Reconciliation (keeping the COR synchronized with the Derived State)

Diligence is **not** responsible for:
- Defining what an Operational Event is
- Defining OEM invariants
- Conducting Journeys — only verifying them

### 6.3 What belongs to the COR

The Canonical Operational Representation is responsible for:

- Materialization of the Derived State in a human- and agent-accessible representation
- Work Item structure (Fields, Labels, Views) displaying the current state
- Representation schema (what is shown and how)

The COR is **not** responsible for:
- Storing the event Timeline
- Being the source of truth
- Defining the Derived State — it only materializes it

### 6.4 What belongs to the Journeys

Each Journey is responsible for:

- Definition of the Event Type catalog specific to its Phases and Cycles
- Definition of expected time windows per Phase (used by Diligence for INV-08)
- Definition of which events alter the Derived State and to which value
- Emission obligation: which Skills emit which events in which Steps
- Definition of preconditions and postconditions for each Event Type

Journeys are **not** responsible for:
- Defining OEM invariants
- Defining the Timeline structure
- Defining what an Event Producer or Consumer is

### 6.5 What belongs to none of the above (implementation)

The following topics do not belong to the ontology — they are implementation domains addressed
in future documents:

- **Technical event schema:** format, fields, data types, validation
- **Event Store:** storage and retrieval mechanism
- **Projection Engine:** mechanism that computes the Derived State from the Timeline
- **Tool integration:** how events are recorded in GitHub, Jira, etc.
- **Event-based automation:** automatic reactions to event emission

---

## 7. Future Dependencies

The following documents will depend on this ontology for their definition:

### 7.1 OEM domain documents

| Document | Depends on | Purpose |
|---|---|---|
| `events/schema.md` | Ontology (Operational Event structure, Event Type) | Defines required fields, formats, and validation rules |
| `events/categories.md` | Ontology (Event Category) | Expands the definition of each category with examples |
| `events/timeline.md` | Ontology (Operational Timeline, Derived State) | Defines Timeline behavior, ordering, projection |

### 7.2 Journey documents

| Document | Depends on | Purpose |
|---|---|---|
| `journeys/delivery/events/catalog.md` | Ontology (Event Type, Event Category) | Delivery Journey Event Type catalog |
| `journeys/diligence/events/catalog.md` | Ontology (Event Type, Diligence category) | Diligence Journey Event Type catalog |
| `journeys/assessment/events/catalog.md` | Ontology (Event Type) | Assessment Journey Event Type catalog |
| `journeys/discovery/events/catalog.md` | Ontology (Event Type) | Discovery Journey Event Type catalog |
| `journeys/operation/events/catalog.md` | Ontology (Event Type) | Operation Journey Event Type catalog |

### 7.3 Integration documents

| Document | Depends on | Purpose |
|---|---|---|
| `events/github-implementation.md` | Schema + Timeline | How events are recorded in the COR (GitHub) |
| `events/diligence-integration.md` | Ontology + Diligence | How Diligence consumes the Timeline for Checks |
| `events/metrics.md` | Ontology (Timeline, timestamps) | How metrics are calculated from events |

---

## 8. Evaluated and Discarded Concepts

The following concepts were considered during the elaboration of this ontology and
discarded with justification:

| Candidate concept | Reason for discard |
|---|---|
| **Operational History** | Informal language for Timeline; formalizing it would imply ambiguous cardinality (by OBC? By Sprint?) |
| **Event Stream** | Synonym for Timeline with implementation connotation (streaming) — unnecessary at the conceptual level |
| **Event Aggregate** | Belongs to implementation domain (DDD Aggregate) — not to the conceptual model |
| **Projection Engine** | Execution mechanism — belongs to `events/timeline.md` or implementation |
| **Event Subscriber** | Technical synonym for Event Consumer — Consumer is sufficient at this level |
| **Event Schema** | Schema is implementation — belongs to `events/schema.md` |
| **Timeline Version** | Timeline versioning is implementation — the Timeline is append-only by definition |

---

## References

- [OEM Foundation](README.md)
- [Framework Ontology](../ontology.md)
- [Knowledge Space vs. Execution Space](../knowledge-vs-execution.md)
- [Glossary](../glossary.md)
- Delivery event analysis
- OEM foundation refinement

---

*This ontology is the canonical source of the conceptual structure of the Operational Event
Model. Every Journey event catalog and every implementation document must reference this
document as the origin of definitions and invariants.*
