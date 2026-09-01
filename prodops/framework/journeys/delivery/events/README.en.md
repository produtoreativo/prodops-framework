# Delivery Journey — Operational Event Model
# ProdOps Framework

> **Domain:** Journey — Delivery
> **Status:** Canonical
> **Version:** 1.0.0 (MVP)
> **Depends on:** [OEM README](../../../events/README.md) · [Event Type Schema](../../../events/event-type-schema.md) · [Taxonomy](../../../events/taxonomy.md) · [Lifecycle](../../../events/lifecycle.md)

---

## About this document

This document explains how the Delivery Journey uses the Operational Event Model (OEM).
It defines the operational state model, the two delivery cycles, and the structure of the
Event Types catalog.

The concrete type catalog is in [catalog.md](catalog.md).

---

## 1. The Delivery Journey in ProdOps

The Delivery Journey represents the operational flow of a Work Item from its activation to
delivery in production. It is composed of two independent cycles in sequence:

**CI Sync** — synchronous development and integration cycle:
```
Bootstrap → Hack → Sync → Finish
```

**CI Async** — asynchronous delivery and validation cycle:
```
Ship → Validate → Promote
```

Work begins in CI Sync (Bootstrap) and ends in CI Async (Promote.Completed → DONE).

---

## 2. Operational State Model

The Derived State of a Work Item in the Delivery Journey follows the progression:

```
BOOTSTRAPPING → HACKING → SYNCING → FINISHING → SHIPPING → VALIDATING → PROMOTING → DONE
```

Cross-cutting state (any Phase):
```
BLOCKED  — declared by Impediment.Declared; resolved by Impediment.Resolved
```

### 2.1 Meaning of each state

| State | Phase | What it represents |
|---|---|---|
| **BOOTSTRAPPING** | CI Sync — Bootstrap | The Work Item is in work environment preparation |
| **HACKING** | CI Sync — Hack | The Work Item is in active development |
| **SYNCING** | CI Sync — Sync | The Work Item is in code review (PR open) |
| **FINISHING** | CI Sync — Finish | The Work Item passed review and is in final checks |
| **SHIPPING** | CI Async — Ship | The Work Item is being deployed to staging environment |
| **VALIDATING** | CI Async — Validate | The Work Item is under validation in staging |
| **PROMOTING** | CI Async — Promote | The Work Item is awaiting or in the process of promotion to production |
| **DONE** | — | The Work Item has been successfully delivered to production |
| **BLOCKED** | Any Phase | The Work Item is blocked by an external impediment |

### 2.2 State derivation

The Derived State is always the `new_state` of the last event with `alters_state = true` in
the Work Item's Timeline. Consumers must not calculate state by any other means.

Events with `alters_state = false` — gates, approvals, notes — are recorded on the
Timeline and affect metrics, but do not alter the Derived State.

---

## 3. The Two Delivery Cycles

### 3.1 CI Sync

The CI Sync is the synchronous cycle — requires active developer presence.

```
Bootstrap.Started (BOOTSTRAPPING)
    ↓
Bootstrap.Completed (HACKING)
    ↓ [active development]
Hack.Completed (SYNCING) — PR opened
    ↓ [code review]
Gate events + Review events
    ↓
Sync.Completed (FINISHING) — PR merged
    ↓ [final checks]
Finish.Completed (SHIPPING)
```

**CI Sync output:** the Work Item is in the SHIPPING state — ready for the asynchronous cycle.

### 3.2 CI Async

The CI Async is the asynchronous cycle — can run without active developer presence.

```
Ship.Completed (VALIDATING) — deployed to staging
    ↓ [automated + manual validation]
Gate events
    ↓
Promote.Approved (PROMOTING) — human decision to promote to production
    ↓
Promote.Completed (DONE) — production updated
```

**CI Async output:** the Work Item is in the DONE state — delivered.

### 3.3 Cross-cutting events

Two groups of events may occur in any Phase, interrupting the normal flow:

**Blocking:** external impediments that suspend work.
- `Impediment.Declared` → BLOCKED
- `Impediment.Resolved` → returns to work (HACKING in MVP)

**Rework:** return to a previous phase due to insufficient quality.
- `Rework.Declared` → HACKING (return to development)
- `Rework.Resolved` → SYNCING (new PR opened after rework)

---

## 4. Event Categories used

The Delivery Journey uses 5 of the 8 Event Categories defined in the OEM Taxonomy:

| Category | Use in Delivery |
|---|---|
| **Phase Lifecycle** | Start and completion of each Phase; Derived State changes |
| **Gate** | Automated quality checks (smoke tests, lint, CI gates) |
| **Human Decision** | Human approvals and reviews (code review, promotion decision) |
| **Blocking** | Declaration and resolution of external impediments |
| **Rework** | Return cycles to development after review |

The **System**, **Diligence**, and **Correction** categories are not represented in this
MVP catalog — they are candidates for future expansion.

---

## 5. Naming convention

All Event Types follow the `Subject.Action` convention (without Namespace within the
own catalog). In cross-Journey references, the `Delivery` Namespace is added:

```
Bootstrap.Started    →  internal reference
Delivery.Bootstrap.Started  →  cross-Journey reference
```

PascalCase in all components. Names free of technology or implementation references.

---

## 6. Catalog version and lifecycle

| Field | Value |
|---|---|
| Catalog version | 1.0.0 (MVP) |
| All types | Active |
| Shared Types used | None in this MVP |
| Shared Types candidates | Gate.Passed, Gate.Failed, Impediment.Declared, Impediment.Resolved, Rework.Declared, Rework.Resolved |

---

## 7. Known MVP limitations

This catalog is an **MVP for validation** — sufficient to cover the complete Delivery
Journey flow, but not exhaustive.

Intentionally documented limitations:

| Limitation | Impact | Future resolution |
|---|---|---|
| `Impediment.Resolved` always returns to HACKING | Simplification — in production should restore the pre-block state | Expand in catalog v2; may require additional field in payload |
| No System events (Pipeline.Failed, Deploy.Failed) | Infrastructure failures are not tracked | Catalog v2 — System category |
| No Hack.Started and Sync.Started events | Explicit Phase start is not recorded | Catalog v2 — low priority |
| No separate Validate.Completed from Promote.Approved | End of validation and start of promotion are implicit | Catalog v2 |
| No Waiting.Declared/Resolved | External dependencies are aggregated in Impediment | Catalog v2 |

---

## References

- [OEM Foundation](../../../events/README.md)
- [OEM Ontology](../../../events/ontology.md)
- [OEM Taxonomy](../../../events/taxonomy.md)
- [OEM Lifecycle](../../../events/lifecycle.md)
- [Event Type Schema](../../../events/event-type-schema.md)
- [Event Instance Schema](../../../events/event-instance-schema.md)
- [Delivery MVP Catalog](catalog.md)
