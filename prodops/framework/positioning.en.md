# ProdOps — Positioning and Communication Guide

This document defines how to describe the ProdOps Framework precisely and consistently.
It is the canonical reference for agents when explaining the framework to stakeholders, new members,
or any audience that needs to understand what ProdOps is and why it exists.

---

## The central differentiator — and the most common mistake

The most frequent mistake when explaining ProdOps is associating:

- **Upstream → Discovery**
- **Downstream → Delivery**

**This is wrong.** Upstream and Downstream are **execution modes**, not product phases.
The three classic journeys — **Discovery, Delivery, and Operation** — exist in both modes.

| | Upstream | Downstream |
|---|---|---|
| **Discovery** | ✓ Free exploration, no gate | ✓ Discovery with gates and traceability |
| **Delivery** | ✓ Disposable code, no commitment | ✓ Governed Delivery, with evidence |
| **Operation** | ✓ Observations without formal SLO | ✓ SLOs, OBCs, postmortems |
| **Commitment** | None | Full |
| **Who controls the transition** | The team, whenever they choose | — |

The mode defines the **level of commitment**, not the product phase.
An item can be in Discovery in Downstream (refining OBC in the Icebox with formal gates),
or in Delivery in Upstream (implementing a prototype without a release commitment).

---

## Summary explanation — approved model

Use this structure when you need to explain ProdOps concisely:

### Problem it solves

Without a framework, each sprint decides differently: what goes in, when it goes in,
who approves it, what evidence exists. Nothing is traceable end to end.

### How it works

The framework operates in two **execution modes**:

**Upstream** — exploration mode. No delivery commitment. The team experiments freely,
validates hypotheses, discovers what it doesn't know. It can stop, pivot, or discard at no cost.
This includes writing code, prototyping integrations and, when the local environment is not sufficient,
deploying to a real sandbox environment in the cloud — all without gates, without Release Trail,
without a committed OBC. The goal is to learn without committing — the team can deploy code and even go to
production, but without the formal capability gate that defines Downstream mode.

**Downstream** — commitment mode. Mandatory gates, sequential phases, evidence at each
step. The team only enters here when it has sufficient clarity to assume delivery.

Both modes traverse the same three product journeys — Discovery, Delivery, and Operation.
The mode does not determine the phase; it determines the level of rigor and commitment.

### The central artifact

The **OBC** — *Observable Business Contract* — is the living document that connects business intent,
acceptance criteria, observability, and reliability. It evolves from the Upstream experiment
to operation in production. Nothing enters Downstream without a committed OBC.

### Closing statement

> ProdOps gives the team the freedom to explore without constraints — even in a real cloud environment —
> and the discipline to deliver with evidence when commitment is assumed.
> The team decides when to switch from one mode to the other.

---

## Upstream reaches a deployed environment

This point is frequently omitted and generates the mistaken perception that Upstream is just
"disposable local code". It is not.

An Upstream experiment can be deployed to real AWS — ephemeral stack, isolated resources,
manually activated — to validate behavior against an external provider that cannot
be exercised locally. The sandbox deploy is part of the exploration repertoire.

**What distinguishes it from Downstream:**
- No approval gate or Release Trail
- Stack destroyed at the end (mandatory `teardown`)
- Resources prefixed `experiment-*`, isolated from staging and production
- No artifact produced here is considered a deliverable

**When to mention:** whenever the conversation suggests that Upstream is limited to the local environment
or that "it would need to go to Downstream" to validate against a real provider.

→ Technical reference: [`execution-model/upstream.md — Sandbox Deploy`](execution-model/upstream.md#sandbox-deploy-upstream)

---

## What never to say

| Incorrect formulation | Why it is wrong | Correct formulation |
|---|---|---|
| "Upstream is the Discovery phase" | Upstream is a mode, not a phase | "Upstream is the exploration mode" |
| "Downstream is where Delivery happens" | Downstream is a mode; Delivery exists in both | "Downstream is the commitment mode" |
| "First goes to Upstream, then to Downstream" | Items can start directly in Downstream | "The team decides the mode based on the clarity of the idea" |
| "ProdOps is a development process" | Limits the view to the technical cycle | "ProdOps is a framework that connects business intent to delivery evidence" |
| "In Upstream there is no deploy" | Upstream has sandbox deploy on real AWS | "Upstream can reach a real environment — without gates, with an ephemeral stack" |
| "To validate against the provider, it needs to go to Downstream" | The `deploy-to-sandbox` step exists exactly for this in Upstream | "Upstream has sandbox deploy to validate real providers without commitment" |

---

## Adjustment by audience

**For an engineer:**
> Upstream is an experiment branch without mandatory PR. Downstream is CI/CD with gates:
> committed OBC, passing BDD, documented Risks, evidence at each phase.
> Both have Discovery and Delivery — the mode defines whether you have a release commitment or not.

**For a PM/PO:**
> Upstream is the safe space to test an idea before putting it on the roadmap.
> Downstream is the commitment: what we promise, we deliver — with evidence.
> The three journeys (Discovery, Delivery, Operation) exist in both modes.

**For an executive:**
> ProdOps ensures that each delivery has traceable evidence — from intent to code in
> production. And it gives the team real freedom to explore before making commitments.

---

## Canonical references in the framework

→ [Execution Model — Upstream](execution-model/upstream.md)
→ [Execution Model — Downstream](execution-model/downstream.md)
→ [Principles](principles.en.md) — Principle 5 (Upstream before commitment)
→ [OBC](obc.en.md) — section "OBC in Upstream" and "OBC in Downstream"
→ [Flow](flow.en.md) — overview of the complete cycle
