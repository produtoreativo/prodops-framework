# Diligence Journey — Operational Event Model
# ProdOps Framework

> **Domain:** Journey — Diligence
> **Status:** Canonical
> **Version:** 1.0.0 (MVP)
> **Depends on:** [OEM README](../../../events/README.md) · [Event Type Schema](../../../events/event-type-schema.md) · [Timeline OEM](../../../events/timeline.md) · [Delivery Catalog](../../delivery/events/catalog.md)

---

## About this document

This document explains how the Diligence Journey uses the Operational Event Model (OEM).
It defines the operational state model, the two Diligence cycles, and the structure of the
Event Type catalog.

The concrete catalog of types is in [catalog.md](catalog.md).

This document also records where Diligence confirms the cross-Journey viability of the
OEM — validating that the same model supports a Journey that is operationally different from Delivery.

---

## 1. The Diligence Journey in ProdOps

The Diligence Journey ensures the integrity and conformance of the ProdOps operational system.
It operates in two independent cycles that can affect the same Work Item at different times:

**Diligence Sync** — synchronous capture and management cycle:
```
Capture → Attach → Promote → Close
```

**Diligence Async** — asynchronous verification and repair cycle:
```
Scan → Flag → Repair
```

A Work Item can go through Sync (to be recorded and managed) and then through
Async (when divergences are detected in later verification iterations).

---

## 2. Operational State Model

The Derived State of a Work Item in the Diligence Journey evolves in two distinct progressions:

### 2.1 Sync cycle progression

```
CAPTURING → CAPTURED → ATTACHED → PROMOTING → PROMOTED → DONE
```

### 2.2 Async cycle progression

```
SCANNING → SCANNED → FLAGGED → REPAIRING → REPAIRED
```

Cross-cutting states (any cycle):
```
BLOCKED  — declared by Impediment.Declared; resolved by Impediment.Resolved (Lookback)
WAIVED   — declared by Waiver.Granted; represents formally approved exception
```

### 2.3 Meaning of each state

| State | Cycle | What it represents |
|---|---|---|
| **CAPTURING** | Sync | The Work Item is being recorded in the system |
| **CAPTURED** | Sync | The Work Item has been recorded; awaiting attachment to the project |
| **ATTACHED** | Sync | The Work Item is associated with the managed project; awaiting review for promotion |
| **PROMOTING** | Sync | The promotion approval has been granted; promotion in execution |
| **PROMOTED** | Sync | The Work Item has been promoted to readiness condition; awaiting formal closure |
| **DONE** | Sync | The Work Item was successfully closed — Sync cycle concluded |
| **SCANNING** | Async | The scanning cycle is running for the Work Item |
| **SCANNED** | Async | The scan was completed; result available for analysis |
| **FLAGGED** | Async | Divergences were found and flagged; awaiting repair or waiver |
| **REPAIRING** | Async | Repair of divergences is in execution |
| **REPAIRED** | Async | Divergences were repaired — Async cycle concluded for this iteration |
| **BLOCKED** | Any | Work Item blocked by external impediment |
| **WAIVED** | Async | Divergence received formal waiver — approved exception |

### 2.4 State derivation

The Derived State is the `new_state` of the last event with `alters_state = true` in the Work Item's Timeline
(algorithm defined in `timeline.md`).

**Lookback usage:** `Impediment.Resolved` in this Journey has `alters_state = false` —
the Consumer uses the Lookback mechanism (`preBlockedState`) to determine the return state
after impediment resolution. This is the refined implementation of the mechanism formalized
in `timeline.md`, and is an improvement over the simplification in the Delivery MVP catalog.

---

## 3. The two Diligence cycles

### 3.1 Diligence Sync

Diligence Sync is the capture and promotion cycle — records new Work Items and
drives them to readiness.

```
Capture.Started (CAPTURING)
    ↓
Capture.Completed (CAPTURED)
    ↓
Attach.Completed (ATTACHED) — Work Item associated with the managed project
    ↓ [human review]
Gate events + Promote.Approved → PROMOTING
    ↓
Promote.Completed (PROMOTED)
    ↓
Close.Completed (DONE)
```

### 3.2 Diligence Async

Diligence Async is the verification cycle — detects and repairs divergences.

```
Scan.Started (SCANNING)
    ↓
Divergence.Detected  (alters_state=false — divergences recorded during scan)
Finding.Recorded     (alters_state=false — specific findings documented)
    ↓
Scan.Completed (SCANNED)
    ↓ [result verification]
Flag.Completed (FLAGGED)  ← only if divergences were detected
    ↓
Repair.Started (REPAIRING)
    ↓ [or]  Waiver.Granted (WAIVED) ← approved exception
    ↓
Repair.Completed (REPAIRED)
```

If no divergence is detected, the Timeline ends at SCANNED — no Flag or Repair.

### 3.3 Interaction between cycles

A Work Item can have events from both cycles in its Timeline:

```
Timeline: OBC-Checkout
  1. Capture.Started         → CAPTURING
  2. Capture.Completed       → CAPTURED
  3. Attach.Completed        → ATTACHED
  4. Promote.Approved        → PROMOTING
  5. Promote.Completed       → PROMOTED
  6. Close.Completed         → DONE
  ...weeks later, Async cycle detects divergence...
  7. Scan.Started            → SCANNING
  8. Divergence.Detected     (alters_state=false)
  9. Scan.Completed          → SCANNED
 10. Flag.Completed          → FLAGGED
 11. Repair.Started          → REPAIRING
 12. Repair.Completed        → REPAIRED
```

---

## 4. Event Categories used

The Diligence Journey uses 5 of the 8 Event Categories:

| Category | Usage in Diligence |
|---|---|
| **Phase Lifecycle** | Start and completion of each step of the Sync and Async cycles |
| **Gate** | Readiness checks before promotion |
| **Human Decision** | Promotion approval; granting or rejection of waiver |
| **Blocking** | External impediments that suspend the operation |
| **Diligence** | Divergences detected and findings recorded during scan |

The **Rework**, **System** and **Correction** categories are not represented in the MVP.

---

## 5. Lookback usage

This Journey implements `Impediment.Resolved` with `alters_state = false` — unlike
the Delivery MVP catalog (where it was `alters_state = true, new_state = HACKING`).

The Consumer uses `preBlockedState(timeline, resolved_position)` as formalized in
`timeline.md` to determine the return state after impediment resolution.

This decision was made because:
1. The Delivery catalog documented the simplification as a known limitation
2. `timeline.md` formalized Lookback as the canonical mechanism
3. Diligence is the second catalog — it implements the refined version

---

## 6. Identified Shared Type candidates

| Journey Type (Diligence) | Journey Type (Delivery) | Equivalent semantics? | Candidate? |
|---|---|---|---|
| Gate.Passed | Gate.Passed | Yes — generic gate | Strong |
| Gate.Failed | Gate.Failed | Yes — generic gate | Strong |
| Impediment.Declared | Impediment.Declared | Yes — generic block | Strong |
| Impediment.Resolved | Impediment.Resolved | Yes — block resolution | Strong |
| Promote.Approved | Promote.Approved | No — distinct semantics | No |
| Promote.Completed | Promote.Completed | No — distinct semantics | No |

The formal promotion of these types to Shared Types should follow the `lifecycle.md` process
when at least two Journeys confirm active usage with equivalent semantics.

---

## 7. Version and lifecycle

| Field | Value |
|---|---|
| Catalog version | 1.0.0 (MVP) |
| All types | Active |
| Shared Types used | None in this MVP |
| Namespace for cross-Journey references | `Diligence` |

---

## References

- [OEM Foundation](../../../events/README.md)
- [OEM Ontology](../../../events/ontology.md)
- [OEM Taxonomy](../../../events/taxonomy.md)
- [OEM Lifecycle](../../../events/lifecycle.md)
- [Event Type Schema](../../../events/event-type-schema.md)
- [Event Instance Schema](../../../events/event-instance-schema.md)
- [Timeline OEM](../../../events/timeline.md)
- [Delivery Event Catalog](../../delivery/events/catalog.md)
- [Diligence MVP Catalog](catalog.md)
