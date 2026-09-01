# Execution Model

Upstream and Downstream are **execution modes** of the ProdOps Framework — they are not journeys, not phases, and they do not replace journeys.

## Critical distinction — the most common mistake

> **Upstream is not a synonym for Discovery.**
> **Downstream is not a synonym for Delivery.**

This confusion comes from the market, where "upstream" and "downstream" typically name *phases* of a linear process: first you discover (upstream), then you deliver (downstream). In ProdOps, the terms have a different meaning: they describe the **level of commitment and rigor** applied to the work — not which journey is being executed.

**The 3 product journeys (Discovery, Delivery, Operation) and the 2 cross-cutting journeys (Assessment, Diligence) are available in both modes.** The mode determines how each journey is executed — with advisory rigor (Upstream) or blocking rigor (Downstream).

## Canonical terminology

| Concept | Definition |
|---|---|
| **Upstream** | Exploration mode — advisory rigor, no delivery commitment |
| **Downstream** | Commitment mode — blocking rigor, formal delivery |
| **Discovery** | Product journey — present in both modes with different behaviors |
| **Delivery** | Product journey — present in both modes; Downstream requires Release Trail and mandatory production |
| **Operation** | Product journey — present in both modes; Upstream is limited to sandbox/controlled experiment |
| **Assessment** | Cross-cutting journey — present in both modes; Downstream can block |
| **Diligence** | Cross-cutting journey — present in both modes; Downstream can block |

Modes do not replace journeys. They define the rigor with which journeys will be executed.

## What differentiates the modes

```
                     UPSTREAM              DOWNSTREAM
                  (exploration)           (commitment)
                        │                      │
 Discovery          exploratory           preparatory + gate
 Delivery       advisory, sandbox        blocking, production
 Operation      sandbox/experiment       real production
 Assessment     informs, does not block  can block
 Diligence      light                    blocking
                        │                      │
 Gates          none mandatory           all mandatory
 OBC            Draft / Refining         Refining at entry; Committed mandatory for Delivery Started
 Release Trail  not mandatory            mandatory
 Rigor          engineer decides         mandatory sequence
```

## Business Intent decision flow

Every Business Intent follows one of the two modes. In the BIB, the global exploration decision belongs to Portfolio; in the Product Backlog, the local decision belongs to the Product Owner. No transition happens automatically.

```
Business Intent
  ↓
Mode choice (Product Owner)
       ↓                                    ↓
  UPSTREAM                             DOWNSTREAM
  advisory rigor                       blocking rigor
  no delivery commitment               with delivery commitment
       │                                    │
  Discovery (exploratory)            Discovery (preparatory — Icebox)
  Delivery  (sandbox / prod opt.)    Delivery  (production mandatory)
  Operation (experimental)           Operation (real production)
  Assessment (informs)               Assessment (can block)
  Diligence (light)                  Diligence (blocking)
       │                                    │
  CommitmentGate ─────────────────────► Downstream
  (when Decision Package is ready)
```

There is no automatic transition between modes. The change must be an explicit decision — the CommitmentGate.

## Upstream

Permissive, experimental mode with no delivery commitment.

**Characteristics:**
- No delivery commitment
- Freedom to select capabilities and practices as needed
- The engineer decides which Skills to use and with what rigor
- All 5 journeys available with advisory rigor
- Focus on learning — code is a consequence, not the goal

Upstream transforms hypotheses into validated knowledge.

→ [Upstream mode details](upstream.en.md)

## Downstream

Delivery-commitment mode with complete application of current quality gates.

**Characteristics:**
- Formal commitment to acceptance criteria (OBC + BDD Feature)
- Complete governance and traceability
- Mandatory artifacts before start
- Evidence recorded at each step
- Full mandatory sequence

Downstream delivers software with knowledge validated by Discovery, performed directly in Downstream or promoted from Upstream.

→ [Downstream mode details](downstream.en.md)

## How to choose the mode

| Situation | Mode |
|---|---|
| Hypothesis to validate, high uncertainty | Upstream |
| Committed item being guided toward complete readiness | Downstream |
| Explore a new capability | Upstream |
| Execute an item with every readiness gate satisfied | Downstream |
| Prototype integration with a provider | Upstream |
| Deliver feature with commitment | Downstream |

## Canonical phrase

> **The mode defines the rigor — not the journeys.**
> **The same 5 journeys exist in both modes; what changes is the commitment.**

Any compression that maps Upstream to a specific journey ("Upstream learns", "Upstream is discovery") or Downstream to another ("Downstream delivers", "Downstream is delivery") is wrong. Those phrases reproduce the market interpretation — not the ProdOps model.
