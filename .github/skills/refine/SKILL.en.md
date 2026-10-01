---
name: refine
description: Coordinates Downstream Discovery during the Icebox period — between the CommitmentGate (/commitment) and the Readiness Gate (/diligence). Receives a Bounded Context as argument and produces all artifacts required by the Readiness Gate: ADR, UX Flows, OBCs at Readiness state, complete BDD Features, updated risks.md, and Reliability Plans when mandatory.
---
<!-- MATERIALIZED FILE — prodops/skills/refine/SKILL.en.md -->

[Português](SKILL.md)

# Refine Skill — Downstream Discovery in the Icebox

Use this skill during the Icebox period — between the CommitmentGate and the Readiness Gate — when capabilities are committed (OBCs in Refining state) but the engineering artifacts required for Bootstrap have not yet been produced.

The skill operates per **Bounded Context**, not per individual OBC. Architecture and UX emerge from the BC; the Readiness Gate verifies OBC by OBC, but shared artifacts are produced once per BC.

**Do not use** before the CommitmentGate — OBCs must be in Refining state.
**Do not use** to replace the Readiness Gate — when done, invoke `/diligence` for the blocking verification.

---

## When to Use

- BC OBCs are in **Refining** state (CommitmentGate executed)
- Status in Iteration Plan: **Icebox**
- None of the BC's engineering artifacts have been produced yet:
  ADR, UX Flows, SLIs/SLOs, complete BDD, Reliability Plan
- Goal: leave the BC ready for the Readiness Gate via `/diligence`

---

## Required Reading

1. BC Business Intent (`prodops/artifacts/business-intents/bi-<bc-slug>.md`)
2. All BC OBCs (`prodops/artifacts/obcs/<slug>.md` where BC = <bc-slug>)
3. Existing BC BDD Features (`prodops/artifacts/bdd/<slug>.feature`)
4. `prodops/artifacts/plans/commitment-trail.md` — committed scope and restrictions
5. `prodops/framework/obc.md` — canonical states and transitions
6. `prodops/framework/principles.md` — Principles 3, 4, 6

---

## Moment 1 — BC Context Capsule

Consolidate the full context of the Bounded Context before any architecture or UX decision. This moment is mandatory — subsequent moments depend on the context produced here.

**What to consolidate:**

| Dimension | Source | What to extract |
|---|---|---|
| User journeys | OBCs + BI | Who the actors are, what the main flows are |
| Aggregate Roots | `features.md` or OBCs | Entities with identity and invariants |
| Domain Events | OBCs (Observable Events) | Events the BC emits after state change |
| Ports & Adapters | OBCs (acceptance criteria) | External dependencies requiring Port/MockAdapter |
| Release restrictions | `commitment-trail.md` | What was restricted and why |

**Output:** structured understanding of the BC in session memory. No file required — the context feeds subsequent moments.

If the BC has more than 5 OBCs or more than 3 distinct actors, record a summary in `prodops/artifacts/architecture/<bc-slug>-context.md` before continuing.

---

## Moment 2 — Architecture Decision Record (ADR)

Produce the BC's architecture decision. The ADR is not an implementation document — it is the pattern declaration the team will follow during Bootstrap and Hack.

**Artifact:** `prodops/artifacts/architecture/<bc-slug>-adr.md`

```markdown
# ADR — <BC Name>

**Date:** YYYY-MM-DD
**Status:** Accepted
**OBCs in scope:** OBC-NNN, OBC-NNN, …

## Context

<Why this BC exists. What problem it solves. What the design constraints are.>

## Aggregate Roots

| Aggregate | Identity | Key invariants |
|---|---|---|
| <Name> | <identity field> | <rules that must never be violated> |

## Domain Events

| Event | Emitter | Trigger |
|---|---|---|
| <EventName> | <Aggregate> | <when it is emitted> |

## Ports & Adapters

| Port | Production Adapter | MockAdapter (local/test) |
|---|---|---|
| <PortName> | <real implementation> | <mock for dev/test> |

## Decisions

1. <Decision 1 — e.g.: single-table DynamoDB for this BC>
   **Reason:** <why>
   **Consequence:** <accepted trade-off>

2. <Decision 2>

## Alternatives considered and discarded

- <Alternative X>: discarded because <reason>

## References

→ [BC Business Intent](../../../prodops/business-intents/bi-<bc-slug>.md)
→ [BC OBCs](../../../prodops/obcs/)
```

**Moment 2 guardrails:**
- Never define implementation (code, function names, database schemas) — only pattern and decision
- Never invent Aggregate Roots without basis in the BC's OBCs or BI
- If design uncertainty exists, record as "To decide before Bootstrap" and continue

---

## Moment 3 — UX Flows

Produce a structured description of the BC's critical user journeys. The goal is that any developer understands the user flow before starting Bootstrap, without needing oral explanation.

**Artifact:** `prodops/artifacts/product/ux/<bc-slug>-flows.md`

```markdown
# UX Flows — <BC Name>

**Date:** YYYY-MM-DD
**OBCs in scope:** OBC-NNN, OBC-NNN, …

## Journeys

### Journey 1 — <journey name> (OBC-NNN)

**Actor:** <who executes>
**Precondition:** <system state before>
**Postcondition:** <system state after>

**Happy path:**
1. <step 1>
2. <step 2>
3. …

**Key errors:**
- <error situation 1> → <expected behavior>
- <error situation 2> → <expected behavior>

**Design notes:**
- <UX constraint, accessibility, or non-obvious behavior>
```

**Moment 3 guardrails:**
- Cover at least the happy path for each BC OBC
- Focus on behavior, not pixels (wireframes are optional — structured description is sufficient)
- Record the main errors that affect the flow — not all technical errors

---

## Moment 4 — OBC → Readiness (per BC OBC)

For each BC OBC, refine from Refining to Readiness: fill in SLIs/SLOs and complete acceptance criteria.

**4a. Update the `expected_outcome` field:**

```
expected_outcome: <measurable metric with baseline and target>
  E.g.: "Intent capture rate > 80% of created requisitions; median lead time < 2 days"
  If baseline unknown: "Baseline to confirm via CPO interviews — target to be defined after first production collection"
```

**4b. Fill or complete `slis_slos`:**

```yaml
slis_slos:
  - sli: <what is measured>
    slo: <target with unit and period>
    baseline: <current value if known, or "to collect">
```

**4c. Complete `acceptance_criteria`:**

```
acceptance_criteria:
  - <verifiable, objective criterion — unambiguous>
  - <criterion 2>
```

**4d. Update the Status field:**

```
Status: Readiness. Refine completed on YYYY-MM-DD.
Located at prodops/artifacts/obcs/<slug>.md.
```

**4e. Add entry to `## State History`:**

```markdown
| YYYY-MM-DD | Refining → Readiness | PM + Tech Lead | Downstream Refine — <bc-slug>-adr.md |
```

**Moment 4 guardrails:**
- Never invent SLOs without baseline data — recording "to confirm" is correct and honest
- Never transition to Readiness without at least 1 SLI defined (even if baseline is "to collect")
- Never remove existing acceptance criteria — only add or refine

---

## Moment 5 — BDD Feature completed (per BC OBC)

For each BC OBC, review and complete the corresponding `.feature` file.

**Review and complete:**

1. **Happy path** — Scenario: Given / When / Then covering the main flow
2. **OBC edge cases** — scenarios derived from Moment 4 `acceptance_criteria`
3. **Error scenarios** — expected behavior when precondition is not met
4. **Valid Gherkin format** — Feature, Background (if needed), Scenario and tags

**Minimum completeness example:**

```gherkin
Feature: <OBC Name>

  Background:
    Given <initial system state>

  Scenario: Happy path — <description>
    Given <precondition>
    When <actor action>
    Then <observable result>

  Scenario: Error — <error case description>
    Given <error precondition>
    When <action>
    Then <expected error behavior>

  @pending
  Scenario: Edge case — <description>
    Given …
```

**Moment 5 guardrails:**
- Never delete existing scenarios — only add or refine
- `@pending` scenarios are valid — they signal incomplete coverage for the QA Gate
- The feature file must be in sync with the OBC's `acceptance_criteria` after Moment 4

---

## Moment 6 — risks.md updated

Record or update risks identified during Moments 2–5.

**File:** `prodops/artifacts/risks/risks.md`

**Risks to record when identified:**

| Category | Examples |
|---|---|
| External integration | Third-party API dependency without documented SLA |
| Persistence | Schema migration, concurrent access, unestimated volume |
| Security | Sensitive data (CNPJ, financial values), authentication, authorization |
| Fiscal/legal | NF-e compliance, CBS/IBS, LGPD |
| External BC dependency | Port depending on capability from another BC not yet delivered |

**Entry format:**

```markdown
## RISK-NNN — <short title>

**Date:** YYYY-MM-DD
**BC:** <bc-slug>
**Affected OBCs:** OBC-NNN
**Severity:** High / Medium / Low
**Probability:** High / Medium / Low

**Description:** <what could go wrong>
**Impact:** <consequence if it occurs>
**Mitigation:** <planned action or documented risk acceptance>
**Owner:** <who monitors>
**Status:** Open / Mitigated / Accepted
```

---

## Moment 7 — Reliability Plan (conditional)

Mandatory — blocks the Readiness Gate — when the OBC satisfies at least one condition:

| Condition | Examples in Procurare |
|---|---|
| Financial movement | AP automation, PO lifecycle, NF-e |
| Critical external integration | ERP sync, e-Signature, SEFAZ |
| SLO change | OBC with more restrictive SLO than current BC |
| High or Critical risk declared in Moment 6 | — |
| Persistence or security change | New DynamoDB index, new Cognito group |

**Artifact:** `prodops/artifacts/plans/reliability/<obc-slug>.md`

```markdown
# Reliability Plan — <OBC slug>

**OBC:** OBC-NNN
**BC:** <bc-slug>
**Date:** YYYY-MM-DD

## SLO Targets

| SLI | Target | Measurement period | Baseline |
|---|---|---|---|
| <what to measure> | <target %> | <window> | <current or "to collect"> |

## Error Budget

Monthly budget: `(1 - SLO) × period`
Burn policy: <action when > 50% of budget consumed in < 50% of period>

## Alerts

| Alert | Threshold | Channel | Severity |
|---|---|---|---|
| <name> | <condition> | <Slack / PagerDuty> | <P1/P2/P3> |

## Incident Runbook

1. <diagnostic step>
2. <immediate mitigation step>
3. <escalation if not resolved in X min>

## References

→ [OBC](../../../prodops/obcs/<obc-slug>.md)
→ [BC ADR](../architecture/<bc-slug>-adr.md)
```

**Moment 7 guardrails:**
- Absence of Reliability Plan does not block `/refine` — it blocks the Readiness Gate (`/diligence`) when conditions apply
- Never invent SLO targets without baseline — "to collect in first production week" is correct
- For OBCs without the above conditions: explicitly record "Reliability Plan not required" in the OBC

---

## Expected Outputs

After `/refine <bc-slug>`, the Bounded Context should have:

| Artifact | Path | Required |
|---|---|---|
| ADR | `prodops/artifacts/architecture/<bc-slug>-adr.md` | Always |
| UX Flows | `prodops/artifacts/product/ux/<bc-slug>-flows.md` | Always |
| OBCs at Readiness | `prodops/artifacts/obcs/<slug>.md` (Status: Readiness) | Per OBC |
| Complete BDD Features | `prodops/artifacts/bdd/<slug>.feature` | Per OBC |
| Updated `risks.md` | `prodops/artifacts/risks/risks.md` | When risks identified |
| Reliability Plans | `prodops/artifacts/plans/reliability/<slug>.md` | When conditions apply |

The BC is **ready for the Readiness Gate** when all artifacts above exist. Invoke `/diligence diligence-sync <obc-id>` to verify each OBC individually.

---

## Guardrails

- Never create new OBCs — only refine existing ones (Refining → Readiness).
- Never invent SLOs without declared baseline — recording "to confirm" when no data is correct.
- Never skip Moment 1 — subsequent moments depend on the consolidated context.
- The moment order is mandatory: Arch (M2) before UX (M3), UX before OBC Readiness (M4).
- Missing Reliability Plan does not block this skill — it blocks the Readiness Gate when conditions apply.
- Never transition OBC directly to `In Delivery` here — that is Bootstrap's responsibility after the Readiness Gate.
- Never remove existing acceptance criteria, BDD scenarios, or risks — only add or refine.
- If a BC OBC was restricted in `commitment-trail.md`, do not process it in this skill.

---

## References

→ [Lifecycle — stages 3, 4, 5](../../../prodops/framework/lifecycle.md)
→ [Principles 3, 4, 6](../../../prodops/framework/principles.md)
→ [commitment/SKILL.md — Icebox entry gate](../commitment/SKILL.md)
→ [diligence/SKILL.md — Icebox exit gate](../diligence/SKILL.md)
→ [OBC — states and transitions](../../../prodops/framework/obc.md)
→ [Work Item Schema](../../../prodops/framework/execution-mapping/work-item-schema.md)
