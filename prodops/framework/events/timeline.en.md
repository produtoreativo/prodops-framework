# Operational Timeline — Operational Event Model
# ProdOps Framework

> **Domain:** Framework — applicable to all Journeys
> **Status:** Canonical
> **Version:** 1.0.0
> **Depends on:** [README.md](README.md) · [ontology.md](ontology.md) · [event-type-schema.md](event-type-schema.md) · [event-instance-schema.md](event-instance-schema.md)

---

## About this document

This document formalizes the behavior of the **Operational Timeline** — the mechanism that
transforms a sequence of Operational Events into a consistent operational representation
of a Work Item.

The Timeline is not a log, a database, or a queue. It is a structure with formal semantics:
ordered, immutable, append-only, with precise processing rules that allow deriving state,
calculating metrics, and reconstructing the complete history of a Work Item at any point
in time.

This document is exclusively conceptual. It does not address storage, implementation,
serialization format, or persistence technology.

→ [Event Type Schema](event-type-schema.md) · [Event Instance Schema](event-instance-schema.md) · [OEM Ontology](ontology.md)

---

## 1. What is an Operational Timeline

An Operational Timeline is the **immutable and ordered sequence of all Operational Events
recorded for a Work Item**.

### 1.1 Formal definition

```
Timeline(W) = [e₁, e₂, ..., eₙ]  where:
  - W is the Work Item to which the Timeline belongs
  - eᵢ is a valid Operational Event (satisfies the Event Instance Schema)
  - for all i < j: eᵢ.timestamp ≤ eⱼ.timestamp  [monotonically increasing]
  - for all i < j: eᵢ.sequence_number < eⱼ.sequence_number  [strictly increasing]
  - n ≥ 0  [Timeline may be empty]
```

### 1.2 Responsibility

The Timeline is the **primary source of truth** about the Work Item. It records:

- all relevant operational occurrences in chronological order
- the current state and all historical states of the Work Item
- the intrinsic evidence of each recorded occurrence
- the context necessary to calculate any operational metric

The Timeline is not responsible for:

- storing calculated states (the Derived State is derived, not stored)
- deciding what should be emitted (responsibility of Producers)
- synchronizing with the COR (responsibility of Diligence)
- validating the semantic correctness of preconditions (responsibility of the Producer)

### 1.3 Timeline boundaries

| Within boundaries | Outside boundaries |
|---|---|
| Record events of a single Work Item | Record events of multiple Work Items |
| Order events chronologically | Reorder events after they are recorded |
| Be read by any Consumer | Be modified by any Consumer |
| Grow with new events | Be truncated or have events removed |
| Exist as long as the Work Item exists | Expire automatically |

### 1.4 Relationship with Work Item

Each Work Item has **exactly one** Timeline — created at the moment the Work Item is
created and kept open as long as the Work Item exists (INV-03 of the Ontology).

```
Work Item 1:1 Timeline
```

The Timeline is the operational identity of the Work Item. Two Work Items never share
a Timeline. If a Work Item is split, two new Work Items are created — each with its own
empty Timeline. The original Work Item's Timeline remains intact.

### 1.5 Relationship with Operational Events

Each Operational Event belongs to exactly one Timeline (INV-03 of the Ontology):

```
Timeline 1:N Operational Events
Operational Event N:1 Timeline
```

An isolated Operational Event has no operational meaning without the Timeline that positions
it. It is the position of the event in the Timeline — relative to other events — that
determines its impact on the Derived State and on the Work Item's metrics.

### 1.6 Relationship with Derived State

The Derived State is the **projection of the Work Item's current state**, calculated
exclusively from Timeline events with `alters_state = true`:

```
DerivedState(Timeline) = new_state of the last event where alters_state = true
```

The Derived State is not stored in the Timeline. It is derived — calculated on demand by
Consumers. The Timeline is the source of truth; the Derived State is a reading of it.

---

## 2. Timeline Structure

### 2.1 How a Timeline is born

A Timeline is born **empty** at the moment the Work Item is created. There is no Timeline
without a Work Item, and no Work Item without a Timeline.

The initial state of an empty Timeline is `null` — no event has been recorded, therefore
no Derived State exists yet. The first event with `alters_state = true` will be the
Timeline's first Derived State.

```
Timeline born:          []  →  DerivedState = null
After Bootstrap.Started: [Bootstrap.Started]  →  DerivedState = BOOTSTRAPPING
```

### 2.2 How a Timeline grows

A Timeline grows exclusively by **recording new Operational Events** (append). Each new
event is added to the end of the sequence — never in the middle, never at the beginning.

Append is the only valid write mechanism. There are no update or delete operations on
already-recorded events.

```
Before:  [e₁, e₂, e₃]
Append: [e₁, e₂, e₃, e₄]  ← e₄ is always the most recent
```

### 2.3 When a Timeline ends

**A Timeline never ends.** The Timeline of a Work Item remains open even after the Work
Item reaches the DONE state.

The reason is that Correction events may be recorded at any time — including after the
Work Item is DONE. Immutability requires that the history always be accessible and that
corrections be recorded as new events, not as edits.

A Work Item in DONE state has its Timeline "quiescent" — no new operational event is
expected, but the Timeline remains as a permanent historical record and can receive
Correction events.

### 2.4 When a Timeline remains open

A Timeline remains actively in use while the Work Item is in any state other than DONE.
The states BOOTSTRAPPING, HACKING, SYNCING, FINISHING, SHIPPING, VALIDATING, PROMOTING,
and BLOCKED are active states — new events are expected.

---

## 3. Event Ordering

### 3.1 Primary ordering: timestamp

Events are ordered primarily by the `timestamp` field in ascending order. The oldest
timestamp comes first in the sequence.

```
[e₁.timestamp ≤ e₂.timestamp ≤ ... ≤ eₙ.timestamp]
```

The ordering uses `≤` (less than or equal), not `<` — two events may have the same timestamp.

### 3.2 Secondary ordering: sequence_number

When two events have the same `timestamp`, the `sequence_number` is the authoritative
tiebreaker. The event with the lower `sequence_number` precedes the event with the higher
`sequence_number`.

```
if eᵢ.timestamp == eⱼ.timestamp:
  order is determined by eᵢ.sequence_number < eⱼ.sequence_number
```

The `sequence_number` is assigned by the recording infrastructure at the time of insertion —
not by the Producer. This ensures that the order is deterministic even when two Producers
emit events with the same timestamp.

### 3.3 Timestamp ties

Two events in the same Timeline may have the same timestamp when:

- two Producers emit events simultaneously (within the system clock's resolution)
- an Agent emits multiple events in rapid succession

In those cases, `sequence_number` resolves the tie. The order of events with the same
timestamp is determined by their arrival order at the recording infrastructure.

### 3.4 Simultaneous events and their effects

When two events with the same timestamp are processed in sequence, the resulting Derived
State is the `new_state` of the event with the higher `sequence_number` (the last in
the sequence).

```
t=09:15:00: [Bootstrap.Completed (seq=5), Gate.Passed (seq=6)]
DerivedState = new_state of Bootstrap.Completed (seq=5, alters_state=true)
               Gate.Passed (seq=6, alters_state=false) does not affect the state
```

### 3.5 Out-of-order events

Events whose `timestamp` is earlier than the `timestamp` of the last event recorded in the
Timeline are **rejected** (VAL-I-07 of the Instance Schema). The Timeline is strictly
append-only in time.

If an event physically occurred earlier but arrived late at the recording infrastructure,
the timestamp used must be the registration moment — not the original occurrence moment.
The Producer may include the original occurrence timestamp in the `payload` or in `notes`.

---

## 4. Derived State

### 4.1 Definition

The Derived State is the **Work Item's current state**, derived exclusively from the Timeline.
It is the only valid source of state — states stored externally (such as in the COR) are
materializations of the Derived State, not primary sources.

### 4.2 Calculation algorithm

The Derived State is calculated by traversing the Timeline in reverse order (from the most
recent to the oldest event) and returning the `new_state` of the first event found with
`alters_state = true`:

```
function derivedState(timeline):
  for event in reversed(timeline):
    if eventType(event.event_type).alters_state == true:
      return eventType(event.event_type).new_state
  return null
```

The result `null` indicates that no state-altering event has been recorded yet —
the Work Item does not yet have a derived state (empty Timeline or one with only
`alters_state = false` events).

### 4.3 State at a point in time

The Derived State can be calculated for any point in time `t`, by restricting the Timeline
to events with `timestamp ≤ t`:

```
function derivedStateAt(timeline, t):
  filtered = [e for e in timeline if e.timestamp <= t]
  return derivedState(filtered)
```

This allows reconstructing the historical state of the Work Item at any instant — without
storing snapshots.

### 4.4 State sequence

The complete state sequence of the Work Item can be reconstructed by listing all events
with `alters_state = true` in order:

```
function stateSequence(timeline):
  result = []
  for event in timeline:
    if eventType(event.event_type).alters_state == true:
      result.append({
        state: eventType(event.event_type).new_state,
        since: event.timestamp,
        caused_by: event.event_type,
        producer: event.producer_identity
      })
  return result
```

The state sequence is the complete transition history of the Work Item — with no additional
data beyond the Timeline's events.

### 4.5 Immutability of Derived State

The Derived State is immutable in the past: the Work Item's state at any past point in time
never changes, because the Timeline is immutable. New events may alter the current state,
but never the history.

---

## 5. Replay

### 5.1 What is Replay

Replay is the processing of the Timeline from beginning to end to reconstruct any derived
representation — current state, state history, metrics, audit. Every Timeline Consumer
conceptually operates by Replay.

Replay is the direct consequence of immutability: because events are not altered, any
derived representation can always be reconstructed from the beginning.

### 5.2 Full Replay

Full Replay processes all Timeline events in order:

```
function fullReplay(timeline, processor):
  state = null
  for event in timeline:
    type = eventType(event.event_type)
    if type.alters_state:
      state = type.new_state
    processor.process(event, state)
  return processor.result()
```

The `processor` is the specific Consumer — it can be a metrics calculator, a Diligence
verifier, a COR updater, or any other.

### 5.3 Partial Replay (from checkpoint)

For long Timelines, the Consumer may store checkpoints — snapshots of the partial Replay
result at a specific point in the Timeline (by `sequence_number`). When recalculation is
needed, the Consumer restarts from the most recent checkpoint instead of starting from scratch.

The checkpoint includes: the `sequence_number` of the last processed event, the Derived State
at that point, and the Consumer's partial state.

### 5.4 Recovery after failure

When a Consumer fails during processing, it resumes from the last persisted checkpoint and
reprocesses from that point. Because the Timeline is immutable, the result of Replay is
always identical regardless of how many times it is executed — Replay is idempotent.

```
idempotence property:
  fullReplay(timeline) == fullReplay(timeline) for any deterministic Consumer
```

### 5.5 Historical Replay

Historical Replay reconstructs the Work Item's state at any past point:

```
function replayUntil(timeline, target_timestamp, processor):
  for event in timeline:
    if event.timestamp > target_timestamp:
      break
    type = eventType(event.event_type)
    if type.alters_state:
      state = type.new_state
    processor.process(event, state)
  return processor.result()
```

Historical Replay is the mechanism that allows answering questions such as "what was the
Work Item's state on date X?" and "what was the rework rate last quarter?" — without
stored snapshots.

---

## 6. Lookback

### 6.1 What is Lookback

Lookback is the mechanism for **retroactive consultation of the Timeline** — reading prior
events at a specific position to obtain information not explicitly present in the current event.

Lookback is a Consumer operation — it is not stored in the Timeline and does not alter any
event. It is the formal solution for situations where the meaning of an event depends on
the Timeline's historical context.

### 6.2 General Lookback algorithm

```
function lookback(timeline, anchor_position, predicate):
  for event in reversed(timeline[:anchor_position]):
    if predicate(event):
      return event
  return null
```

The `anchor_position` is the index of the event from which the retroactive search begins.
The `predicate` is the condition the sought event must satisfy.

### 6.3 Lookback for pre-BLOCKED state

The most important Lookback use case — and the solution to the MVP catalog limitation
in Delivery — is recovering the state the Work Item was in before entering BLOCKED.

**Problem:** when `Impediment.Declared` is recorded, the Work Item enters BLOCKED.
When `Impediment.Resolved` is recorded, the Work Item must return to the state prior to
blocking — but that state is not explicit in the `Impediment.Resolved` event.

**Solution via Lookback:**

```
function preBlockedState(timeline, impediment_resolved_position):
  # Find the corresponding Impediment.Declared
  declared = lookback(
    timeline,
    impediment_resolved_position,
    e => e.event_type == "Impediment.Declared"
  )

  if declared is null:
    return null  # anomaly — no corresponding Impediment.Declared

  declared_position = timeline.indexOf(declared)

  # Return to the state before blocking
  return lookback(
    timeline,
    declared_position,
    e => eventType(e.event_type).alters_state
         and eventType(e.event_type).new_state != "BLOCKED"
  ).new_state
```

**Concrete example:**

```
Timeline: WI-033
pos 1: Bootstrap.Started    → BOOTSTRAPPING  [alters_state=true]
pos 2: Bootstrap.Completed  → HACKING        [alters_state=true]
pos 3: Hack.Completed       → SYNCING        [alters_state=true]
pos 4: Impediment.Declared  → BLOCKED        [alters_state=true]
pos 5: Impediment.Resolved  → ?

Lookback at pos 5:
  search for Impediment.Declared → found at pos 4
  search before pos 4 where alters_state=true and new_state != BLOCKED
  → pos 3: Hack.Completed with new_state=SYNCING

Return state after Impediment.Resolved: SYNCING
```

This mechanism allows `Impediment.Resolved` to have `alters_state = false` in future catalog
versions — the Consumer uses Lookback to calculate the return state without the type needing
to declare it explicitly.

### 6.4 Lookback for Rework interpretation

Rework may occur from a non-HACKING state (e.g., the Work Item is in SYNCING and
`Rework.Declared` takes it back to HACKING). To calculate the cost of rework (time lost),
the Consumer uses Lookback to find the state that preceded the Rework:

```
function priorStateBeforeRework(timeline, rework_declared_position):
  return lookback(
    timeline,
    rework_declared_position,
    e => eventType(e.event_type).alters_state
  ).new_state
```

With the pre-Rework state and the `Rework.Declared` timestamp, it is possible to calculate
the time the Work Item spent in the state that was discarded.

### 6.5 Lookback for Correction interpretation

When a Consumer encounters `Event.Corrected` in the Timeline, it uses Lookback to locate
the corrected event by `corrected_event_id` in the payload:

```
function findCorrectedEvent(timeline, correction_position):
  corrected_id = timeline[correction_position].payload.corrected_event_id
  return lookback(
    timeline,
    correction_position,
    e => e.id == corrected_id
  )
```

The Consumer then applies the correction from the payload when semantically processing the
original event. The original event remains immutable — the Consumer maintains a "corrected"
view in memory during processing.

### 6.6 Lookback for open complementary pairs

When `Impediment.Declared` does not have a corresponding `Impediment.Resolved`, the Work
Item is genuinely blocked. Lookback for Impediment.Resolved returns `null` — the Consumer
interprets this as "impediment open".

```
function openImpediments(timeline):
  return [
    e for e in timeline
    if e.event_type == "Impediment.Declared"
    and not hasMatchingResolved(timeline, e)
  ]
```

This pattern is the basis for Diligence verification: complementary pairs without resolution
are anomalies.

---

## 7. Corrections, duplicates, and anomalies

### 7.1 Event.Corrected

`Event.Corrected` is the only valid mechanism for recording that a prior event contains
incorrect data. The original event remains immutable — the correction is a new event that
references the original.

**Processing during Replay:**

```
function replayWithCorrections(timeline, processor):
  corrections = {
    c.payload.corrected_event_id: c
    for c in timeline if c.event_type == "Event.Corrected"
  }

  for event in timeline:
    if event.event_type == "Event.Corrected":
      continue  # processed as overlay, not as primary event

    corrected_view = applyCorrectionOverlay(event, corrections.get(event.id))
    processor.process(corrected_view, currentState)
```

The overlay applies the corrected content only to the Consumer's view — the original event
is not modified.

**What `Event.Corrected` can correct:**
- `payload` fields with incorrect values
- The `notes` field
- The `producer_identity` field (if incorrectly recorded)

**What `Event.Corrected` cannot correct:**
- `event_type` — the event type is immutable; if the type was wrong, the entire event is
  conceptually invalid and must be treated as an anomaly
- `timestamp` — the temporal position is immutable
- `work_item_id` — the belonging to a Timeline is immutable
- `alters_state`, `new_state` — these are Event Type attributes, not event attributes

### 7.2 Duplicate events

A duplicate event is one with the same `id` as an event already recorded in the Timeline.

**Behavior:** the duplicate is **rejected** before recording — it does not enter the Timeline.
Idempotent event recording (trying to record the same event twice) must result in the first
being persisted and the second being silently discarded.

**Detection:** `id` uniqueness is verified before insertion (VAL-I-06 of the Instance Schema).

### 7.3 Invalid events

An invalid event is one that fails any of the validations VAL-I-01 to VAL-I-10 of the
Instance Schema.

**Behavior:** invalid events are **rejected** before entering the Timeline. They are never
persisted — the Timeline contains only events that passed all validations.

**Permissive exception:** VAL-I-09 (authorized producer_type) may be permissive — the event
enters with a warning. Diligence detects the anomaly retroactively.

### 7.4 Out-of-chronological-order events

An event whose `timestamp` is earlier than the `timestamp` of the Timeline's last event is
rejected by VAL-I-07. There is no "retroactive insertion" mechanism in the Timeline.

**Timestamp handling:** when an event occurred before the registration moment (e.g., a human
event that was reported late), the timestamp must reflect the registration moment. The Producer
documents the original occurrence timestamp in `payload` or `notes`, if relevant.

### 7.5 Semantically incoherent event sequence

The Timeline does not validate the semantic coherence of events — only structural validity.
A Timeline may contain `Hack.Completed → SYNCING` immediately followed by
`Bootstrap.Started → BOOTSTRAPPING` (semantically inconsistent) as long as the timestamps
are valid.

Semantic coherence verification (Event Type preconditions and postconditions) is the
responsibility of **Diligence** during the verification cycle — not of the Timeline's
recording mechanism.

---

## 8. Metrics

The Timeline is the source of all operational metrics. No additional fields are needed —
all metrics are derived from events already present.

### 8.1 Lead Time

Total time from work start to production delivery:

```
LeadTime(W) = Promote.Completed.timestamp - Bootstrap.Started.timestamp
```

Includes all wait time, blocking, and rework. It is the most comprehensive metric.

### 8.2 Cycle Time

Active development time — from implementation start to delivery:

```
CycleTime(W) = Promote.Completed.timestamp - Bootstrap.Completed.timestamp
```

Excludes setup time (Bootstrap). Measures the efficiency of the development cycle.

### 8.3 Time per Phase

Time spent in each Work Item state, calculated from the state sequence:

```
function timePerState(timeline):
  sequence = stateSequence(timeline)
  result = {}
  for i, entry in enumerate(sequence):
    state = entry.state
    start = entry.since
    end = sequence[i+1].since if i+1 < len(sequence) else now()
    result[state] = result.get(state, 0) + (end - start)
  return result
```

### 8.4 Block Time

Total time the Work Item spent in the BLOCKED state:

```
BlockTime(W) = sum(
  Impediment.Resolved.timestamp - Impediment.Declared.timestamp
  for each pair (Impediment.Declared, Impediment.Resolved) in timeline
)
```

For still-open impediments, `end = now()`.

### 8.5 Rework Rate

Proportion of Work Items that had at least one rework cycle:

```
ReworkRate = count(W : exists Rework.Declared in Timeline(W)) / count(all W)
```

Per Work Item, the number of rework cycles:

```
ReworkCycles(W) = count(Rework.Declared in Timeline(W))
```

### 8.6 Rework Time

Total time spent in rework cycles (from Rework.Declared to Rework.Resolved):

```
ReworkTime(W) = sum(
  Rework.Resolved.timestamp - Rework.Declared.timestamp
  for each pair in timeline
)
```

### 8.7 DORA — Deployment Frequency

```
DeploymentFrequency(period) = count(Promote.Completed in period) / duration(period)
```

### 8.8 DORA — Change Failure Rate

```
ChangeFailureRate(period) =
  count(Promote.Rejected in period) /
  count(Promote.Approved + Promote.Rejected in period)
```

### 8.9 DORA — Time to Restore

Not calculable with the Delivery MVP catalog types — requires Incident events (outside the
scope of the current catalog). When added, the calculation would be:

```
TimeToRestore = Incident.Resolved.timestamp - Incident.Declared.timestamp
```

### 8.10 Gate Failure Rate

```
GateFailureRate(W) =
  count(Gate.Failed in Timeline(W)) /
  count(Gate.Passed + Gate.Failed in Timeline(W))
```

### 8.11 Review Cycle Count

Number of code review iterations per Work Item:

```
ReviewCycles(W) = count(Review.ChangesRequested in Timeline(W))
```

### 8.12 Promote Approval Rate

```
PromoteApprovalRate(period) =
  count(Promote.Approved in period) /
  count(Promote.Approved + Promote.Rejected in period)
```

### 8.13 General metric derivation principle

Every metric can be expressed as one of the following operations over the Timeline:

| Operation | Example |
|---|---|
| **Count** of events by type | Deployment Frequency, Rework Cycles |
| **Timestamp difference** between two events | Lead Time, Cycle Time, Block Time |
| **Sum** of timestamp differences | Rework Time, Total Block Time |
| **Ratio** between counts | Gate Failure Rate, Change Failure Rate |
| **Aggregation** across multiple Timelines | Cross-Work Item DORA |
| **Filter** by period | Metrics by quarter, by sprint |

There is no metric that requires fields beyond those already defined in the Event Instance Schema.

---

## 9. Timeline Consumers

### 9.1 Canonical Operational Representation (COR)

The COR — materialized in GitHub Projects and GitHub Issues — is the most visible Timeline
Consumer. It reads the Derived State and materializes it as the Work Item's state in the
GitHub Project.

**What the COR reads:**
- The current Derived State: `derivedState(Timeline)` — to update the Issue's state field
- The most recent event: to identify the last producer and the timestamp of the last activity

**Reading frequency:** after each new event recorded in the Work Item's Timeline.

**Writing:** the COR does not write to the Timeline — it only reads and materializes.

### 9.2 Diligence

Diligence is the verifying Consumer. It audits the Timeline to ensure consistency between
what was recorded and what should have been recorded.

**What Diligence verifies:**
- Complementary event pairs without resolution (e.g., Impediment.Declared without Impediment.Resolved)
- Events emitted with a Deprecated type after the `migration_deadline`
- Events with `producer_type` not authorized by the Event Type (permissive VAL-I-09)
- Consistency between Derived State in the Timeline and state in the COR
- Absence of expected events for the current state (e.g., Work Item in HACKING for more than X cycles without activity)

**Mechanism:** Diligence executes full Replay of the Timeline and verifies each invariant.

### 9.3 Assessment

Assessment analyzes historical patterns across multiple Timelines. It aggregates metrics,
identifies structural anomalies, and produces evidence-based recommendations.

**What Assessment reads:**
- State sequences from multiple Timelines
- Lead Time, Cycle Time, Rework Rate across comparable Work Items
- Correlation between events and delivery metrics

**Mechanism:** Assessment executes Replay over a set of Timelines and applies statistical
analysis to the results.

### 9.4 Metrics and Dashboards

Metrics and dashboard Consumers read Timelines to calculate operational indicators in real
time or historically. They may process individual Timelines (per Work Item) or aggregations
(by team, by Journey, by period).

**Mechanism:** partial or full Replay with a specific metrics processor.

### 9.5 Agents

AI or automation agents read the Timeline to make decisions or emit new events. An agent
reads the current Derived State, analyzes recent events, and decides whether to emit a new
event (e.g., the Diligence Agent detects an anomaly and emits a Diligence category event).

**Pattern:** the agent is both a Consumer (reads) and a Producer (emits new events in the Timeline).

### 9.6 Humans

Humans read Timelines through interfaces (dashboards, CLIs, OKR tools) to understand the
state and history of Work Items. The Timeline is the basis of all operational narrative
for the Work Item.

---

## 10. Relationship with Journeys

### 10.1 The Timeline model is universal

The Operational Timeline model is defined at the Framework level — independent of any
Journey. Every Journey that uses the OEM uses exactly the same Timeline model.

What varies between Journeys are the **Event Types** recorded — each Journey has its catalog.
The structure, ordering rules, Derived State algorithm, Replay, Lookback, and validations
are identical.

```
Framework:  Timeline model (universal)
Journey A:  Delivery Event Types  →  Timeline of Delivery Work Items
Journey B:  Diligence Event Types →  Timeline of Diligence Work Items
Journey C:  Discovery Event Types →  Timeline of Discovery Work Items
```

### 10.2 Cross-Journey interoperability

Because the model is universal, a Consumer can process Timelines from multiple Journeys
with the same algorithm — only the referenced Event Type Schema varies.

For cross-Journey metrics (e.g., Lead Time compared between Delivery and Discovery), the
Consumer uses the same Replay algorithm applied to Timelines from different Journeys.

### 10.3 Each Journey defines its own states

The Derived State is calculated by the same algorithm in all Journeys — but the set of
possible `new_state` values is defined by each Journey's catalog.

Delivery has: BOOTSTRAPPING, HACKING, SYNCING, FINISHING, SHIPPING, VALIDATING, PROMOTING, DONE, BLOCKED.

A future Discovery Journey would have its own states (e.g., RESEARCHING, VALIDATING, CONCLUDED).

The `derivedState(timeline)` algorithm is identical — only the `new_state` values differ.

---

## 11. Timeline Invariants

### INV-TL-01 — A Work Item's Timeline is never destroyed

As long as the Work Item exists, its Timeline exists. There is no Timeline destruction
operation — only archiving.

### INV-TL-02 — New events are always added at the end

Append is the only write mechanism. There are no mid-Timeline insertion operations.

### INV-TL-03 — Events in the Timeline are never removed or modified

Once recorded, an event remains in the Timeline exactly as recorded forever. Immutability
is absolute (INV-01 of the Ontology).

### INV-TL-04 — Derived State is always derived from the Timeline

It is never stored directly in the Timeline or in Timeline entries. It is calculated on
demand by Consumers.

### INV-TL-05 — Replay is idempotent

Executing the same Replay over the same Timeline, with the same deterministic Consumer,
always produces the same result.

### INV-TL-06 — Lookback is read-only

Lookback is a read operation — it never modifies the Timeline, never creates new events,
and never persists results in the Timeline.

### INV-TL-07 — The Timeline is the only source of truth for historical state

No external representation (COR, database, cache) can be used as a source of truth for a
Work Item's historical state. In case of conflict, the Timeline prevails (INV-09 of the Ontology).

---

## References

- [OEM Foundation](README.md)
- [OEM Ontology](ontology.md)
- [OEM Taxonomy](taxonomy.md)
- [OEM Lifecycle](lifecycle.md)
- [Event Type Schema](event-type-schema.md)
- [Event Instance Schema](event-instance-schema.md)
- [Delivery Event Catalog](../journeys/delivery/events/catalog.md)

---

*This document is the canonical source of Operational Timeline behavior in the OEM.
Every Consumer that processes Timelines and every Journey that records events must adhere
to the model defined here.*
