# Operational Event Model
# ProdOps Framework

> **Domain:** Framework — applicable to all Journeys
> **Status:** Canonical
> **Version:** 1.0.0

---

## About this document

This document is the foundational reference for the **Operational Event Model (OEM)** domain
within the ProdOps Framework.

It defines what an Operational Event is, its role in the Framework, how it relates to
the other concepts of the ontology, and which principles govern its use.

This document does not define schema, storage format, technical implementation, nor
how each Journey uses events. Those subjects are addressed in Journey-specific documents.

→ [Ontology](../ontology.md) · [Knowledge vs. Execution](../knowledge-vs-execution.md) · [Glossary](../glossary.md)

---

## 1. Motivation

### 1.1 What the state model represents

ProdOps operates with two distinct spaces: the Knowledge Space, where conceptual artifacts
live (OBCs, Business Intents, BDD Features), and the Execution Space, where operations
on those artifacts live (Work Items, Pull Requests, Releases).

The Canonical Operational Representation (COR) — implemented today through GitHub Projects and
Issues — represents the current state of each Work Item: which phase it is in, who is
responsible, which artifact is associated. This representation is correct and necessary.

However, the current state answers only one question: **where is the Work Item now?**

### 1.2 What the state model does not represent

There is an entire class of questions that the current state cannot answer:

- How did the Work Item get here?
- How long did it remain in each phase?
- How many times did it need to return to a prior phase?
- Which gate failed and what was the recorded cause?
- Who made which decisions and when?
- Was the promotion to production preceded by the correct evidence?
- Is the system improving in terms of speed, quality, and predictability?

These questions require **sequence**, **causality**, and **history** — dimensions that
the current state, by definition, does not preserve. When state changes, the previous
state disappears.

### 1.3 The Operational Event hypothesis

The hypothesis that originated this domain is straightforward:

> **The true source of operational truth is not the current state. It is the sequence of
> events that led to the current state.**

If every significant transition during the execution of a Journey is recorded as an
immutable fact — with producer, moment, context, and evidence — then:

- the current state becomes derivable: it is the projection of the last relevant event;
- metrics become computable: they are functions over event timestamps;
- causality becomes auditable: each state has a recorded cause;
- Diligence becomes predictive: it verifies whether expected events occurred within time
  windows, not just whether the current state is correct;
- agents become more precise: they decide based on facts that occurred, not on snapshots.

### 1.4 Problems the Operational Event Model solves

| Dimension | Limitation with pure states | What OEM solves |
|---|---|---|
| **Observability** | "Where is the Work Item now?" only | "How did it get here? How long did it take?" |
| **Audit** | No trace of past transitions | Each transition recorded with producer and moment |
| **Metrics** | Ad-hoc timestamp fields without semantics | Lead time, rework, gate quality derivable from events |
| **DORA** | Change Fail Rate and MTTR require history | Failure and recovery events make DORA computable |
| **Assessment** | Based on subjective perceptions | Based on observed event patterns across releases |
| **Automation** | Reacts to current state (polling) | Reacts to events (push) — more efficient and precise |
| **Agents** | Infer cause from divergent states | Read the event sequence and have explicit causality |

---

## 2. Definition

### 2.1 Operational Event

> **Operational Event** is a fact that occurred during the execution of a Journey that marks
> a transition, decision, or significant condition within ProdOps' operational flow.

An Operational Event:

- **represents something that happened** — not something that is happening nor something that will happen;
- **is immutable** — once recorded, it cannot be altered or deleted;
- **has an identified producer** — human, system, or agent that originated it;
- **has a precise moment** — a timestamp that anchors it in the Work Item's timeline;
- **is contextual** — belongs to a specific Journey, Phase, and Work Item;
- **is atomic** — represents a single fact, not an aggregation of facts;
- **produces evidence** — the event record itself is evidence that it occurred.

### 2.2 What is not an Operational Event

| Concept | Distinction |
|---|---|
| **Current state** | State is a projection of the last event, not the event itself |
| **Technical log** | Log records system operations without business semantics; see section 6 |
| **Domain Event** | Domain Event belongs to the product's domain model; see section 7 |
| **Business Signal** | Business Signal is a Knowledge Space artifact, not an operational event |
| **Future intent** | Planning, estimation, and commitment are not Operational Events |
| **Artifact** | OBC, BDD Feature, Reliability Plan are artifacts — not events |

---

## 3. Role in the Framework

### 3.1 Positioning in the ontology

The Operational Event is not a new level in the Framework → Journey → Cycle → Phase →
Capability → Skill hierarchy. It belongs to an orthogonal dimension: **the temporal dimension**.

```
┌──────────────────────────────────────────────────────────────────────────────┐
│  Structural Dimension (what)                                                 │
│                                                                              │
│  Framework → Journey → Cycle → Phase → Capability → Skill → Step            │
│                                                                              │
├──────────────────────────────────────────────────────────────────────────────┤
│  Temporal Dimension (when and how)                                           │
│                                                                              │
│  Operational Event → Operational Timeline → Derived State                    │
│                                                                              │
│  Events flow through the structural dimension — each event belongs           │
│  to a Phase, which belongs to a Cycle, which belongs to a Journey.           │
└──────────────────────────────────────────────────────────────────────────────┘
```

### 3.2 Relationship with each ontology concept

**Business Signal**
The Business Signal is a Knowledge Space artifact. Operational Events are not Business
Signals. However, operational events can be analyzed by Diligence to determine whether
a new Business Signal should be generated — for example, if a pattern of failures in
Validate repeated across multiple releases indicates a product gap not captured in the
Knowledge Space.

**Business Intent**
The Business Intent is a Knowledge Space artifact. Operational Events record the work
performed on artifacts that materialize a Business Intent (OBCs, BDD Features). The
sequence of events across Journeys constitutes the operational history of the Intent.

**OBC (Observable Business Contract)**
The OBC is the central artifact of the contract. Operational Events record state transitions
of the OBC (`OBC.StateChanged`), validation milestones (`OBC.ValidateCompleted`), and
promotion conditions (`OBC.PromotedToOperational`). The OBC never becomes an event — it
generates events when it undergoes significant transformations.

**Journey**
Each Operational Event belongs to exactly one Journey. The event carries the identity of
the Journey that generated it. This allows Diligence to aggregate events by Journey and
produce consistency and performance analyses by domain.

**Cycle**
The Cycle is the grouping of Phases. Operational Events can mark the beginning and end
of a Cycle (`Cycle.Started`, `Cycle.Completed`) and any significant transition within it.
Events allow comparing cycles over time — for example, CI Sync of sprint 1 vs. CI Sync
of sprint 10.

**Phase**
The Phase is the primary granularity of Delivery Operational Events. Most events occur
at the transition between Phases: entry, exit, gate pass, gate fail, blocking, unblocking.
A Phase event carries the Phase name, the Cycle it belongs to, and the Journey.

**Capability**
Capabilities are reusable mechanisms. Operational Events recorded during the execution
of a Capability can be reused by any Journey that consumes that Capability. For example,
the Evidence Management Capability produces evidence collection events that are relevant
to both Delivery and Diligence.

**Skill and Step**
Skill and Step are the executable implementation layer. Each Skill is responsible for
emitting the Operational Events corresponding to the transitions it executes. Event emission
is not optional — a Step that does not emit its completion event is considered incomplete.

**Canonical Operational Representation (COR)**
The COR — implemented in GitHub Projects and Issues — materializes the Derived State
produced by the OEM: GitHub Fields and Labels represent the last known state, derived
from the Timeline's events. The COR is a **consumer** of the OEM — it is not part of it.
Diligence verifies the consistency between the event Timeline and the state materialized
in the COR; when there is divergence, the Timeline prevails.

---

## 4. Operational Timeline

### 4.1 Definition

> **Operational Timeline** is the ordered and immutable sequence of all Operational Events
> associated with a Work Item, from its creation to its closure.

The Timeline is the complete history of a Work Item. It answers not only where the Work Item
is, but where it came from, how it got there, how many times it changed direction, and for
what reasons.

### 4.2 Timeline properties

- **Ordered:** events have order defined by timestamp — never by insertion.
- **Immutable:** a recorded event cannot be removed or altered.
- **Cumulative:** the Timeline only grows — never shrinks.
- **Authoritative:** in case of divergence between the Timeline and the current state declared
  in the COR, the Timeline prevails.

### 4.3 Derived State

> **Derived State** is the current state of a Work Item computed from its Operational
> Timeline — specifically, the projection of the last state-altering event.

The Derived State is **mutable**: each new event can change it. The events that originate it
are immutable. This asymmetry is intentional — the state changes, but the cause of each
change is preserved forever in the Timeline.

The Derived State is the only legitimate form of operational state in the OEM. States not
derived from events are opaque snapshots without traceable causality.

```
Timeline                          Resulting Derived State
────────────────────────────────  ──────────────────────────────
Bootstrap.Started   (t₁)         → BOOTSTRAPPING
Bootstrap.Completed (t₂)         → HACKING
Hack.Completed      (t₃)         → SYNCING
Rework.Declared     (t₄)         → HACKING        (rework_count: 1)
Rework.Resolved     (t₅)         → SYNCING
Sync.Completed      (t₆)         → FINISHING
Finish.Completed    (t₇)         → SHIPPING
```

The derivation rule is straightforward: the Derived State is determined by the last
state-altering event. The COR stores this Derived State as a human- and agent-readable
projection — never as a source of truth.

### 4.4 What the Timeline enables

- **Lead Time:** `T(last closure event) - T(first start event)`
- **Time per Phase:** `T(exit event) - T(entry event)` for each Phase
- **Rework:** count of events representing return to a previous Phase
- **Gate quality:** proportion of `Gate.Passed` vs. `Gate.Failed` per gate type
- **Predictability:** variance between expected and actual time per Phase

---

## 5. Operational Event and State

Events and states do not compete. They have distinct and complementary responsibilities.

| Dimension | Operational Event | State |
|---|---|---|
| **Nature** | Immutable — represents a past fact | Mutable — represents the current situation |
| **Temporal axis** | Historical — sequence over time | Snapshot — cross-section at the present moment |
| **Structure** | Sequential — order matters | Positional — only the current value matters |
| **Primary role** | Produces metrics, audit, and causality | Facilitates visualization and day-to-day operations |
| **Question answered** | What happened, when, and by whom? | Where is the Work Item now? |
| **Derivation** | Not derived — it is the primary source | Derived from the event sequence |
| **Lifecycle** | Accumulates — never deleted | Replaced at each transition |
| **Diligence usage** | Temporal and causality verification | Point-in-time state verification |
| **Visibility for humans** | Timeline / history | Kanban / board / list |

The correct architecture combines both: **events as primary source of truth; state as
derived projection for operational consumption**.

---

## 6. Operational Event and Log

### 6.1 The confusion problem

Operational Events may appear similar to logs. The difference is fundamental.

### 6.2 Comparison

| Dimension | Technical log | Operational Event |
|---|---|---|
| **Semantics** | System operation (debug, trace, info, error) | Significant business fact in the operational flow |
| **Producer** | System automatically | Identified human, system, or agent |
| **Audience** | Infrastructure engineering | Engineering, product, operations, diligence, agents |
| **Volume** | Dozens to thousands per minute | Dozens per complete lifecycle |
| **Retention** | Transient — can be discarded | Permanent — never discarded |
| **Immutability** | Can be rotated and purged | Immutable by definition |
| **Business context** | Absent — is technical data | Required — carries Journey, Phase, Work Item |
| **Interpretability** | Requires technical correlation | Self-descriptive for product stakeholders |

### 6.3 Audit Trail

An Audit Trail is a subset of the Timeline: records focused on compliance and accountability
— especially events involving human approvals, quality gates, and promotion decisions.
The Audit Trail is derived from the Timeline — it is not a separate structure.

---

## 7. Operational Event and Domain Event

### 7.1 Domain Event

In the context of Domain-Driven Design (DDD), a **Domain Event** represents something
significant that occurred in the problem domain — the business of the application. For
example: `PaymentConfirmed`, `CreditAccountOpened`, `WebhookDelivered`.

Domain Events belong to the **product domain** — the system that ProdOps helps build.

### 7.2 Business Event

A **Business Event** is a business-world event — something that occurred in the real world
and that the system must record or react to. For example: `CustomerPurchased`, `ContractCancelled`.

Business Events are inputs for the Knowledge Space — especially for Business Signals and
Business Intents.

### 7.3 Operational Event

An **Operational Event** is an event of the **work process** — something that occurred during
the execution of a ProdOps Journey. For example: `Bootstrap.Completed`, `Validate.GateFailed`,
`Promote.Approved`.

Operational Events belong to the **ProdOps Framework** — to the process of building the
product, not the product itself.

### 7.4 Comparison

| Type | Belongs to | Example | Consumed by |
|---|---|---|---|
| **Domain Event** | Product domain (DDD) | `PaymentConfirmed` | Product systems |
| **Business Event** | Real world / business | `CustomerSigned` | Business Signals, Analytics |
| **Operational Event** | ProdOps Process | `Bootstrap.Started` | Diligence, Metrics, Agents |

All three types can coexist without conflict — they are orthogonal. A `Promote.Completed`
can trigger the observation of `PaymentConfirmed` in production, which in turn can generate
a `Business Signal`. This chain is perfectly valid — each event belongs to its own domain.

---

## 8. Benefits

### 8.1 For Engineering

- **Calculable lead time:** total time from Bootstrap to Promote derived from the Timeline,
  without ad-hoc fields or manual recording processes.
- **Identified rework:** each return to a prior Phase is a named event, with a recorded
  cause — not a metric inferred from states.
- **Measurable gate quality:** proportion of pass/fail per gate type over time indicates
  which gates need attention.
- **DORA without extra instrumentation:** Lead Time for Changes, Deployment Frequency,
  Change Failure Rate, and MTTR are directly derivable from the Timeline.

### 8.2 For Product

- **Predictability:** time patterns per Phase across sprints build predictive models —
  the team knows how long Bootstrap typically takes.
- **Informed prioritization:** which OBCs stayed longest in Validate? Which gates failed
  repeatedly? The Timeline answers without manual reports.
- **Evidence-driven Assessment:** instead of subjective retrospectives, event pattern
  analysis supports Assessment recommendations with data.

### 8.3 For Operations

- **Complete audit:** each Promote.Approved has a producer, timestamp, and recorded gate
  criteria — traceability for compliance and postmortem.
- **Anomaly detection:** events absent within expected time windows are signals of blocking
  before the item appears as delayed on the Kanban.
- **Traceable rollback:** `Ship.RollbackTriggered` with recorded cause produces data for
  delivery system stability analysis.

### 8.4 For Diligence

- **Temporal checks:** "did the expected event occur within the window?" is a class of
  verification that pure state does not allow. Events enable predictive Diligence.
- **Causality of Findings:** a Finding opened by Diligence can reference the specific event
  that originated it — increasing precision and reducing false positives.
- **Fact-based synchronization:** Diligence verifies whether the state declared in the COR
  is consistent with the last recorded event — more precise drift detection.

### 8.5 For Assessment

- **Objective basis for analysis:** Assessment receives the complete Timeline of one or
  more releases as input — not a subjective perception of what occurred.
- **Measurable triggers:** event patterns (e.g., `Validate.GateFailed` > 30% over 3
  consecutive releases) justify a new Assessment cycle with data.
- **Verifiable evolution:** comparing the Timeline of release 1 with release 10 produces
  objective evidence of process improvement or degradation.

### 8.6 For AI Agents

- **Fact-based decisions:** an agent that reads the Timeline decides based on what occurred,
  not on what it infers from a divergent state.
- **Rich context for instrumentation:** instead of reconstructing the current Phase context
  from scattered fields, the agent reads the event sequence and has the complete history.
- **Event emission as contract:** the obligation to emit events at the end of each Step
  makes agent behavior verifiable — Diligence detects agents that did not fulfill their contract.

---

## 9. Principles

### P-01 — Operational Events represent facts, not intentions

An Operational Event records something that occurred. Planning, estimation, commitment, and
future decision are not operational events. The canonical phrase is: "this happened" — never
"this will happen" or "this should happen".

### P-02 — Operational Events are immutable

Once recorded, an Operational Event cannot be altered, corrected, or deleted. If an event
was recorded incorrectly, a new correction event (`Event.Corrected`) is emitted — the
original event remains in the Timeline.

### P-03 — Every Operational Event has an identified producer

There are no anonymous events. The producer can be a human (identified by role and
identity), a system (identified by name and version), or an agent (identified by type
and instance). The absence of an identified producer invalidates the event as Operational.

### P-04 — Operational Events belong to a Journey, Phase, and Work Item

An event exists in the context of a specific Work Item, in a specific Phase, in a specific
Journey. Events without Journey context are not Operational Events — they are logs.

### P-05 — Current state is a projection, never the source of truth

The state declared in the COR must be derived from the last relevant event. If there is
divergence between the current state and what the Timeline indicates, the Timeline prevails.
Diligence is responsible for detecting and repairing this divergence.

### P-06 — The absence of an expected event is information

If a Phase should have produced an event and did not produce one within an expected time
window, that absence is an operational signal. Diligence treats event absences as data —
not as irrelevant gaps.

### P-07 — Event emission is mandatory, not optional

A Skill that executes a Phase transition is responsible for emitting the corresponding
Operational Event. Emission is not optional — a Step without a completion event is an
incomplete Step. This is verifiable by Diligence.

### P-08 — Events enable metrics; fields are not metrics

Work Item fields (such as timestamps of entry into each Phase) are projections of events —
not metrics themselves. Metrics are functions computed over the Timeline. If events exist,
timestamp fields become redundant and can be eliminated.

### P-09 — Events do not replace artifacts

An Operational Event records that something occurred with an artifact — it does not replace
the artifact. The OBC, the BDD Feature, the Reliability Plan continue to be Knowledge Space
artifacts. The event `OBC.StateChanged` is evidence that the OBC changed — the OBC itself
lives in the repository.

### P-10 — The Timeline is the most valuable asset of the operational system

The delivered code can be discarded. The OBC can be archived. The event Timeline of how
the work was executed is a permanent asset — it contains the accumulated operational
intelligence about how the team delivers, learns, and improves.

---

## 10. Scope of this document

### What this document defines

- The concept of **Operational Event** and its fundamental properties.
- The concept of **Operational Timeline** — the immutable sequence of events per Work Item.
- The concept of **Derived State** — the current state as a Timeline projection.
- The position of the OEM in the Framework ontology.
- The principles governing the use of events in any Journey.
- The distinctions between Operational Event, log, Domain Event, and Business Event.
- The benefits of the model for each audience.

### What this document does not define

This document deliberately does not address the following topics — they are covered in
specific documents as each Journey and domain formalizes them:

| Topic not addressed | Responsible document |
|---|---|
| Event schema (required fields, format) | `events/schema.md` (future) |
| Delivery Journey event catalog | `journeys/delivery/events/catalog.md` (future) |
| Other Journey event catalogs | Per Journey, when formalized |
| Event storage and retrieval | `events/storage.md` (future) |
| GitHub implementation (comments, timeline) | `events/github-implementation.md` (future) |
| Integration with external tools | `events/integrations.md` (future) |
| Event-based automation | Per Journey and Capability |
| How Diligence consumes events | `journeys/diligence/events.md` (future) |
| Assessment event model | `journeys/assessment/events.md` (future) |
| Retention, purge, and archiving | `events/lifecycle.md` (future) |

### Relationship with existing documents

| Document | Relationship |
|---|---|
| [`ontology.md`](../ontology.md) | OEM complements the ontology — does not alter the Journey → Cycle → Phase hierarchy |
| [`knowledge-vs-execution.md`](../knowledge-vs-execution.md) | OEM operates in the Execution Space — events are not Knowledge Space artifacts |
| [`glossary.md`](../glossary.md) | Terms from this document will be added to the glossary in the next revision |
| [`journeys/diligence/README.md`](../journeys/diligence/README.md) | Diligence consumes events for temporal and causality verification |

---

## References

- [Framework Ontology](../ontology.md)
- [Knowledge Space vs. Execution Space](../knowledge-vs-execution.md)
- [Canonical Operational Representation](../knowledge-vs-execution.md#canonical-operational-representation)
- [Glossary](../glossary.md)
- Delivery state model — analysis that preceded this domain
- Delivery event model — analysis that generated the OEM hypothesis

---

*This document is the canonical source of the Operational Event Model. All Journey
documentation that uses events must reference this document as the origin of its principles.*
