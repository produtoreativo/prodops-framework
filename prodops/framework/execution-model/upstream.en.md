# Upstream Mode

Upstream is the **exploration mode** of the ProdOps Framework.

## Canonical definition

Upstream represents an exploration mode. Its goal is to reduce uncertainty before assuming any delivery commitment. Upstream does not represent a promise — it represents a space for learning. All work done in Upstream is considered experimental.

## Purpose

Reduce uncertainty before assuming any formal commitment. Software produced in Upstream can be production-quality — what does not exist is a delivery commitment, a Committed OBC, or a Release Trail. Rigor is a choice by the engineer, not an imposition of the mode.

## Mode characteristics

In Upstream:

- no mandatory gates
- no obligation to complete artifacts
- no obligation to produce a Committed OBC
- no obligation to follow all Skills
- the engineer decides which Skills to use
- vibecoding is allowed
- experimentation is encouraged
- failing is part of the process

The goal is to learn as fast as possible.

An Upstream experiment can produce production-quality code. The exploratory label describes the commitment model — no mandatory gates, no Committed OBC, no Release Trail — not the deployment limit. By explicit decision of the team and leadership, that code may be deployed to production or controlled productive environments without requiring formal promotion to Downstream. The CommitmentGate formalizes the mode transition; it is not a precondition for deployment.

## OBC in Upstream

When a Business Intent enters the Business Intent Backlog, an OBC is created as a Draft.

During Upstream:

- the OBC remains in Draft
- can be continuously updated
- can remain incomplete
- does not block the progress of experiments

The OBC works as memory of learning — not as a validation mechanism.

## When to use Upstream mode

- Hypothesis to validate, high uncertainty
- Explore a new capability
- Prototype integration with a provider
- Validate a business flow before committing
- Explore a technical approach before deciding

## Conditions for Opening a Formal Experiment

All four conditions must be true to justify opening a formal experiment:

1. **Falsifiable hypothesis** — it is possible to define what would invalidate the hypothesis
2. **Unanswered hypothesis** — the answer does not exist in already available evidence
3. **Answer has decision value** — it affects what will be built or how it will be built
4. **Cost of ignoring > cost of experimenting** — the cost of assuming the hypothesis as true without testing is greater than the cost of the experiment

If any condition fails, an experiment is not the right instrument: it may be internal research, a business decision, or work that already fits directly in Downstream.

## Evidence Threshold

The Evidence Threshold is the criterion that defines when the evidence collected is sufficient to bring the Decision Package to the CommitmentGate.

**It is optional, but recommended.** When declared:
- Must be recorded in `experiment.md` at the start of the experiment
- Revisions to the criterion (loosening or tightening) must be recorded in `upstream-trail.md` with justification
- Reaching the threshold does not automatically convene the CommitmentGate — it convenes the trio

Without a declared Evidence Threshold, the stopping criterion is the judgment of the experiment author. In that case, the author is responsible for documenting in the Decision Package why the accumulated evidence is sufficient.

## Journeys in Upstream

**Upstream is not a synonym for Discovery.** All 5 ProdOps journeys are available in Upstream — with advisory rigor. The engineer decides which to apply and with what depth.

| Journey | Behavior in Upstream |
|---------|----------------------|
| **Discovery** | Exploratory — no mandatory artifacts, no exit gate; experiments, spikes, prototypes, Event Storming |
| **Delivery** | Advisory — CI-Sync phases (Bootstrap → Finish) and CI-Async (Ship → Promote) available; Promote can go to sandbox or, by team decision, to production; no mandatory Release Trail |
| **Operation** | Experimental — behavioral observation in sandbox or controlled environment; no mandatory SLO, no formal runbook |
| **Assessment** | Informs, does not block — risk analysis, premortem, Reliability Plan are optional and used when useful |
| **Diligence** | Light — artifact consistency verification as the engineer deems necessary |

In Upstream, the engineer can use any phase skill with full rigor if desired — for example, `/hack tdd` with Red/Green/Refactor cycle identical to Downstream. The difference is that rigor is a choice, not an imposition.

## Three deployment acts in Upstream

In Upstream, code can reach different environments. There are three distinct acts — with different authorization and rollback. None of the three is capability promotion.

| Act | What it is | Authorization | Rollback |
|-----|-----------|---------------|----------|
| **Sandbox Deploy** | Deploy to an ephemeral, isolated stack (`experiment-*`), without real customer traffic | Engineer decides | Destroy the stack (`action=teardown`) |
| **Controlled Production** | Upstream code deployed to real production, without CommitmentGate | Explicit team and leadership decision | Immediate rollback available; no Release Trail required |
| **Capability Promotion** | CommitmentGate outcome Promote: BDD + OBC moved; item enters Downstream | Trio PM + Tech Lead + Author | Formal Downstream rollback process |

**Controlled Production is not a violation of Upstream mode** — it is an authorized act. What differentiates it from Promotion is that the **capability commitment** (Committed OBC, Release Trail, Downstream gates) has not been assumed. The code reaches production; the capability remains in exploration.

## How to execute in Upstream mode

→ [Discovery Journey in Upstream](../journeys/discovery/README.md) — exploration, experiments, Decision Package
→ [Delivery in Upstream](../journeys/delivery/README.md) — available phases with advisory rigor
→ [Sandbox Deploy](../journeys/discovery/README.md#sandbox-deploy-upstream) — deploy in a controlled environment without Downstream rigor

## Perpetual Discovery — Anti-pattern

Perpetual Discovery occurs when an experiment continues accumulating evidence indefinitely without advancing toward a commitment decision. The experiment did not fail — it never ended.

**Four objective diagnostic signals:**

| Signal | Criterion | Action |
|--------|-----------|--------|
| **S1** | No progression in `upstream-trail` for 3 or more consecutive sessions | Identify blocker; escalate to trio |
| **S2** | Questions marked as "unanswerable with available evidence" for 5 or more days | Revisit hypothesis; consider CommitmentGate with Discard or Await outcome |
| **S3** | Declared Evidence Threshold identified as unachievable without a new hypothesis, after 3 or more collection sessions | Reformulate hypothesis or revise threshold; record decision in trail |
| **S4** | Stakeholder with blocked decision for 10 or more business days due to this experiment | Immediate CommitmentGate — the decision to wait longer is also a valid decision (Await outcome) |

The presence of any signal does not require immediate closure — it requires **convening the trio to consciously decide** whether the experiment should continue, be suspended, or closed.

## Upstream closure — CommitmentGate

Upstream does not end automatically. The trio (PM + Tech Lead + Author) is explicitly convened when the Decision Package is ready. This gate is the **CommitmentGate** — it decides the fate of the *capability*, not the code.

There are **6 canonical outcomes**. Each has a distinct action protocol:

| Outcome | Required action |
|---------|-----------------|
| **Promote** | BDD + OBC moved to committed paths; item enters Iteration Plan with `Entrou`; Downstream starts |
| **Promote with restriction** | Subset promoted; restricted parts remain in Upstream for a new experiment |
| **Requires another experiment** | Create new experiment with a more specific hypothesis; record decision in current `upstream-trail.md` |
| **Awaiting business decision** | Block in the Product Tracking List with decision-maker and expected date; do not open a new experiment until decision arrives |
| **Awaiting external dependency** | Record in Reliability Plan and Product Tracking List; monitor in Continuous Assessment |
| **Discard** | Record learning in `prodops/framework/journeys/discovery/learnings.md`; close experiment with justification in `upstream-trail.md` |

Transition to Downstream occurs only on the **Promote** or **Promote with restriction** outcome. In all others, the capability remains at the same stage it was before Upstream.

## Expected outcome

At the end of an Upstream cycle, the following should exist:

- Hypothesis answered with evidence
- Complete Decision Package
- Clear recommendation (promote, requires another experiment, wait, discard)
- Updated ProdOps artifacts

## Sandbox Deploy (Upstream)

An experiment can be deployed to real AWS without going through the rigor of Downstream.

Objective: validate behavior against a real provider (e.g.: Asaas sandbox) when the local environment is not sufficient.

**Characteristics:**

- Activated manually via `workflow_dispatch` — never on push
- Ephemeral stack: `payments-api-experiment` + `payments-api-dynamo-experiment`
- AWS resources prefixed `experiment-*` — isolated from staging and production
- Dedicated IAM role `payments-api-github-experiment` — scope restricted to `experiment-*`
- No approval gate, no Release Trail, no committed OBC
- **Required:** stack destroyed at the end of the experiment via `action=teardown`

→ [Step: deploy-to-sandbox](../../skills/upstream/steps/deploy-to-sandbox/SKILL.md)
→ Deploy workflow: `.github/workflows/experiment-deploy.yml` (implemented by the product)
→ IAM Role: `api/infra/iam-experiment-role.yaml` (implemented by the product)

## Promotion to Downstream (CommitmentGate)

The Upstream → Downstream transition is mediated by the **CommitmentGate** — a formal gate convened by the trio PM + Tech Lead + Author.

Minimum preconditions for convening the CommitmentGate:
- Complete Decision Package
- Evidence Threshold satisfied (if declared)
- OBC Draft exists (at minimum the file with name and reference to the experiment)
- Readable BDD draft

**Decision Package verifiability criterion:** A trio member who did not participate in the experiment must be able to read the Decision Package and reach the same conclusions without additional verbal context. If the Decision Package requires oral explanation to be understood, it is not ready for the CommitmentGate.

After the CommitmentGate with **Promote** outcome:

1. BDD Feature moved from `prodops/artifacts/experiments/<NNN-slug>/features/` to `prodops/artifacts/bdd/`
2. OBC moved from `prodops/artifacts/experiments/<NNN-slug>/obcs/` to `prodops/artifacts/obcs/` (state: Refining)
3. Entry in the Iteration Plan in `prodops/artifacts/plans/iteration-plan.md`
4. Reliability Plan updated in `prodops/framework/journeys/assessment/reliability-plans/`

→ [Full process and Canonical Outcomes](../journeys/discovery/README.md#commitmentgate--transição-upstream--downstream)


---

→ **Next:** [Downstream Mode](downstream.en.md)
