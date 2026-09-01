# Assessment Journey — Operational Event Model
# ProdOps Framework

> **Domain:** Journey — Assessment
> **Status:** Canonical
> **Version:** 1.0.0 (MVP)
> **Depends on:** [OEM README](../../../events/README.md) · [Event Type Schema](../../../events/event-type-schema.md) · [Timeline OEM](../../../events/timeline.md) · [Delivery Catalog](../../delivery/events/catalog.md) · [Diligence Catalog](../../diligence/events/catalog.md)

---

## About this document

This document explains how the Assessment Journey uses the Operational Event Model (OEM).
It defines the operational state model, the two cycles of the Assessment, and the structure
of the Event Types catalog.

The concrete type catalog is in [catalog.md](catalog.md).

This is the **third reference implementation** of the OEM. Its goal is to confirm that the
model supports an analytical and retrospective Journey — fundamentally different from the
execution (Delivery) and verification (Diligence) Journeys — without any extensions.

---

## 1. The Assessment Journey in the OEM context

The Assessment operates in a singular way compared to other Journeys:

| Aspect | Delivery | Diligence | Assessment |
|---|---|---|---|
| OEM Role | **Producer** | **Producer** | **Read-only Consumer** |
| Emits events? | Yes | Yes | **Yes — but only in its own Work Items** |
| Reads external Timelines? | No | No | **Yes — Delivery and Diligence** |
| Alters external Timelines? | — | — | **No — never** |

The Assessment **emits its own events** (in the Work Items of each Assessment cycle).
It **reads** Delivery and Diligence Timelines as analysis inputs.
It **never writes** to Timelines other than its own.

---

## 2. Operational State Model

The Derived State of an Assessment Work Item evolves through two independent progressions:

### 2.1 Sync cycle progression (structured Assessment)

```
COLLECTING → COLLECTED → ANALYZING → ANALYZED → SYNTHESIZING → SYNTHESIZED → REPORTING → DONE
```

### 2.2 Async cycle progression (continuous monitoring)

```
MONITORING → ALERTED
```

After `Alert.Raised → ALERTED`, a new Assessment Sync cycle is triggered. A new
`Monitor.Activated` restarts the Async cycle.

### 2.3 Cross-cutting state

```
BLOCKED — declared by Impediment.Declared; resolved by Impediment.Resolved (Lookback)
```

### 2.4 Meaning of each state

| State | Cycle | What it represents |
|---|---|---|
| **COLLECTING** | Sync | The evidence collection cycle is running |
| **COLLECTED** | Sync | The evidence corpus is complete and indexed |
| **ANALYZING** | Sync | Metric calculation and pattern identification is running |
| **ANALYZED** | Sync | Metrics and patterns are calculated — ready for synthesis |
| **SYNTHESIZED** | Sync | Insights have been consolidated — ready for Report approval |
| **REPORTING** | Sync | Approval has been granted — publication is running |
| **DONE** | Sync | The Assessment Report has been published — cycle closed |
| **MONITORING** | Async | The continuous monitoring cycle is active |
| **ALERTED** | Async | A formal alert has been raised — Assessment Sync must be triggered |
| **BLOCKED** | Any | Work Item blocked by an external impediment |

### 2.5 State derivation

The Derived State is the `new_state` of the last event with `alters_state = true` in the
Work Item's Timeline. Algorithm defined in `timeline.md`.

**Lookback usage:** `Impediment.Resolved` in this Journey has `alters_state = false` —
the Consumer uses the Lookback mechanism (`preBlockedState`) to determine the return state
after impediment resolution. Refined implementation — consistent with Diligence.

---

## 3. The two Assessment cycles

### 3.1 Assessment Sync — Structured Review

```
Collect.Started (COLLECTING)
    ↓
Collect.Completed (COLLECTED)
    ↓
Analyze.Started (ANALYZING)
    ↓
Analyze.Completed (ANALYZED)
    ↓
Synthesize.Completed (SYNTHESIZED)
    ↓ [human review + quality gates]
Gate.Passed → Gate.Passed → Report.Approved → REPORTING
    ↓
Report.Published (DONE)
```

Alternative path with rejection:

```
Synthesize.Completed (SYNTHESIZED)
    ↓
Gate.Failed (alters_state=false)
    ↓
Report.Rejected → SYNTHESIZED [re-synthesis required]
    ↓
[new synthesis cycle...]
```

### 3.2 Assessment Async — Continuous Monitoring

```
Monitor.Activated (MONITORING)
    ↓
Threshold.Crossed (alters_state=false — metrics recorded)
Recommendation.Issued (alters_state=false — incremental proposals)
Evolve.Proposed (alters_state=false — evolutions identified)
    ↓ [critical threshold reached]
Alert.Raised (ALERTED)
    ↓ [triggers Assessment Sync]
    [new Monitor.Activated in the next cycle]
```

### 3.3 Observation events (alters_state=false)

During the cycles, multiple observation events are recorded without altering the Derived State:

| Event | When it occurs |
|---|---|
| `Gate.Passed` | Quality gate passed during Collect, Analyze, or before Report.Approved |
| `Gate.Failed` | Quality gate failed — Producer evaluates whether Report.Rejected should be emitted |
| `Threshold.Crossed` | A metric crossed a defined threshold during monitoring |
| `Recommendation.Issued` | A formal recommendation was produced during Analyze or Synthesize |
| `Risk.Identified` | A risk was formally identified during analysis |
| `Opportunity.Identified` | An opportunity was formally identified during analysis |
| `Evolve.Proposed` | An incremental evolution proposal was generated during monitoring |

---

## 4. Event Categories used

The Assessment Journey uses 5 of the 8 Event Categories:

| Category | Use in Assessment |
|---|---|
| **Phase Lifecycle** | Start and completion of each Step in the Sync and Async cycles |
| **Human Decision** | Report approval/rejection; formalized recommendations, risks, and opportunities |
| **Gate** | Quality checks before Report publication |
| **Blocking** | External impediments that suspend the Assessment cycle |
| **System** | Automatic threshold detection; evolution proposals generated by agent |

The **Rework**, **Diligence**, and **Correction** categories are not represented in the MVP.

---

## 5. Lookback usage

This Journey implements `Impediment.Resolved` with `alters_state = false` — consistent
with Diligence and with the canonical OEM pattern (`timeline.md`).

This is the **third Journey** confirming the Lookback pattern for `Impediment.Resolved`.
The Delivery pattern (alters_state=true, new_state=HACKING) is confirmed as the exception
— not the rule. Delivery v2 should adopt the refined pattern.

---

## 6. Shared Types candidates identified

| Journey Type (Assessment) | Confirmed Journeys | Equivalent semantics | Confidence |
|---|---|---|---|
| `Gate.Passed` | Delivery, Diligence, **Assessment** | Yes — automated gate passed | **High** |
| `Gate.Failed` | Delivery, Diligence, **Assessment** | Yes — automated gate failed | **High** |
| `Impediment.Declared` | Delivery, Diligence, **Assessment** | Yes — blocked by external impediment | **High** |
| `Impediment.Resolved` | Delivery (simplif.), Diligence, **Assessment** | Yes — impediment resolution | **High** (3 Journeys) |

Confirmation across three Journeys raises `Impediment.Resolved` from Medium to High confidence.
The only remaining blocker is the technical inconsistency in the Delivery v1 catalog — which
must be resolved in Delivery v2.

No Assessment-exclusive type is a Shared Type candidate in this MVP — they are types
specific to this Journey that would need confirmation in at least one other Journey.

---

## 7. Version and lifecycle

| Field | Value |
|---|---|
| Catalog version | 1.0.0 (MVP) |
| All types | Active |
| Shared Types used | None in this MVP |
| Namespace for cross-Journey references | `Assessment` |

---

## References

- [OEM Foundation](../../../events/README.md)
- [OEM Ontology](../../../events/ontology.md)
- [OEM Taxonomy](../../../events/taxonomy.md)
- [OEM Lifecycle](../../../events/lifecycle.md)
- [Event Type Schema](../../../events/event-type-schema.md)
- [Event Instance Schema](../../../events/event-instance-schema.md)
- [OEM Timeline](../../../events/timeline.md)
- [Delivery Event Catalog](../../delivery/events/catalog.md)
- [Diligence Event Catalog](../../diligence/events/catalog.md)
- [Assessment MVP Catalog](catalog.md)
