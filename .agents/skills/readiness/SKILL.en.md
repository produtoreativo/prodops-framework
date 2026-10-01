---
name: readiness
description: Executes the Readiness Gate for a Bounded Context — blockingly verifies that all /refine artifacts are present and complete before authorizing Bootstrap (OBC: Refining → verified Readiness). Gate parallel to CommitmentGate. Never produces artifacts; only verifies and records the gate.
---
<!-- MATERIALIZED FILE — prodops/skills/readiness/SKILL.en.md -->

# Readiness Gate Skill

The Readiness Gate is the lifecycle gate that separates the Icebox period
(Downstream Discovery via `/refine`) from the committed delivery phase
(Bootstrap via `/bootstrap`). It is a blocking gate: if any mandatory artifact
is absent, the gate is not recorded and Bootstrap cannot start.

**Analogy:** just as `/commitment` governs the CommitmentGate (Upstream →
Icebox), `/readiness` governs the Readiness Gate (Icebox → Delivery).

**Do not use this skill to produce artifacts.** If an artifact is missing,
return to `/refine` for the corresponding BC to complete it.

---

## When to Use

- After `/refine` is completed for a BC (all Moments executed)
- Before invoking `/bootstrap` to start the first delivery iteration
- When you want to verify if an individual BC is ready to enter Delivery

**Invocation:** `/readiness <bc-slug>` or `/readiness` (all BCs with OBCs in Refining)

---

## Mandatory Reading

Before any verification, read:

1. `prodops/runtime/runtime.yaml` — confirm this skill's path
2. `prodops/artifacts/plans/commitment-trail.md` — OBCs committed for the BC
3. BC OBCs: `prodops/artifacts/obcs/<obc-slug>.md` for each OBC in the BC
4. BC ADR: `prodops/artifacts/architecture/<bc-slug>-adr.md`
5. UX Flows: `prodops/artifacts/product/ux/<bc-slug>-flows.md`
6. BDD Features: `prodops/artifacts/bdd/<obc-slug>.feature` for each OBC
7. BC Risks: `prodops/artifacts/risks/risks-<bc-slug>.md`
8. Reliability Plans: `prodops/artifacts/plans/reliability/<obc-slug>.md` (when applicable)

---

## Moment 1 — Identify Scope

1. Read `commitment-trail.md` and identify the OBCs for the informed BC.
2. For each OBC, record in memory: slug, file path, BDD feature path.
3. Confirm all BC OBCs are in `Refining` state (gate candidates) or already in
   `Readiness` (gate already executed — report and stop without re-execution).

If the BC is not in commitment-trail: stop. Report that CommitmentGate was not
executed for this BC.

---

## Moment 2 — Artifact Checklist per OBC

For each OBC in the BC, verify the items below. Each absent item is a **blocker**.

### 2a. OBC (file `prodops/artifacts/obcs/<obc-slug>.md`)

| Item | Verification |
|---|---|
| Status field | Contains `Readiness` (after /refine) |
| `## Acceptance Criteria` | Present before `## Related Artifacts`, with at least 3 verifiable criteria |
| `## Histórico de Estado` | Contains entry `Refining → Readiness` with date and responsible party |

### 2b. BDD Feature (`prodops/artifacts/bdd/<obc-slug>.feature`)

| Item | Verification |
|---|---|
| `# Estado:` | Value is `Readiness` (not `Draft`) |
| Active Scenarios | At least 1 active Scenario (not `@pending`) covering the happy path |
| No loose `# @future` | No `# @future` comment without a corresponding `@pending Scenario` |

### 2c. BC Artifacts (shared across OBCs of the same BC)

| Artifact | Path | Required |
|---|---|---|
| ADR | `prodops/artifacts/architecture/<bc-slug>-adr.md` | Always |
| UX Flows | `prodops/artifacts/product/ux/<bc-slug>-flows.md` | Always |
| BC Risk Register | `prodops/artifacts/risks/risks-<bc-slug>.md` | Always |

### 2d. Reliability Plan (verify per OBC)

Mandatory when the OBC meets any of the conditions below:
- Financial movement (approval, payment, PO, invoice)
- Critical external integration (SEFAZ, ERP, e-Signature, SSO, LLM, external supplier)
- SLO change relative to previous state
- Risk classified as High severity in the Risk Register
- Sensitive data persistence (evidence_hash, LGPD, fiscal data, audit)

| Item | Path |
|---|---|
| Reliability Plan | `prodops/artifacts/plans/reliability/<obc-slug>.md` |

If the mandatory condition is met and the file does not exist: **blocker**.
If no condition is met: record "Reliability Plan not required — conditions absent"
and proceed.

---

## Moment 3 — Gate Decision

### APPROVED

All Moment 2 items are present and complete for all BC OBCs.

Record in output:
```
Readiness Gate — <BC Name> — APPROVED
Date: <date>
Approved OBCs: <list>
Authorizes: Bootstrap of BC <BC Name>
```

### BLOCKED

One or more items are absent or incomplete.

Record in output:
```
Readiness Gate — <BC Name> — BLOCKED
Date: <date>
Blockers:
  - [OBC-NNN] <obc-slug>: <missing artifact> at <expected path>
  - ...
Action: run /refine <bc-slug> to complete the missing artifacts.
Bootstrap not authorized.
```

**Never** record the gate in `commitment-trail.md` if the result is BLOCKED.
**Never** invoke `diligence-sync` for a blocked OBC.

---

## Moment 4 — Record Gate and update Iteration Plan

Only if the result is APPROVED.

### 4a. Record in commitment-trail.md

Add entry to the `## Readiness Gate` section of `commitment-trail.md`:

```markdown
## Readiness Gate

| BC | OBCs | Date | Result | Responsible |
|---|---|---|---|---|
| <BC Name> | OBC-NNN, OBC-MMM | <date> | APPROVED | PM + Tech Lead |
```

If the section does not exist, create it after the committed OBCs section.

### 4b. Update Iteration Plan

For each approved OBC, update the **Status** column in
`prodops/artifacts/plans/iteration-plan.md` from `Icebox` to `Pronto para Bootstrap`.

The Iteration Plan does **not** have an Estado column — the canonical state lives
exclusively in the OBC file. The Iteration Plan tracks only the OBC's position in
the delivery cycle (Status). Never add an Estado column to the Iteration Plan.

---

## Moment 5 — Invoke diligence-sync

For each approved OBC, invoke `diligence-sync promote` to advance the corresponding
Work Item in the external backlog (GitHub Projects).

```
/diligence diligence-sync promote <obc-id>
```

If `diligence-sync promote` returns a blocker due to missing Work Item, record as
an operational pending item — **does not block the already-approved gate**. Create
a tracking issue with `operation: Reconcile` and `journey: Diligence`.

---

## Guardrails

- **Never produce artifacts** — this skill only verifies. To create missing artifacts,
  return to `/refine`.
- **Never partially approve** — the gate is for the entire BC. If one OBC in the BC
  fails, the entire BC is BLOCKED.
- **Never skip Reliability Plan verification** when the mandatory condition is met.
- **Never record the gate** in `commitment-trail.md` with a BLOCKED result.
- **Never re-execute** the gate for a BC already APPROVED in the trail — report the
  existing state and stop.
- **Never invent** approval criteria not present in this skill.

---

## References

→ [Canonical Lifecycle](../../../prodops/framework/lifecycle.md)
→ [Commitment Trail](../../../prodops/artifacts/plans/commitment-trail.md)
→ [/refine Skill](../refine/SKILL.md) — produces the artifacts verified by this gate
→ [/commitment Skill](../commitment/SKILL.md) — previous gate in the lifecycle
→ [/bootstrap Skill](../bootstrap/SKILL.md) — skill this gate authorizes
→ [diligence-sync](../diligence/diligence-sync/SKILL.md) — invoked in Moment 5
