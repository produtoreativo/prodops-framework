[Português](SKILL.md)

---
name: outcome
description: Verifies the Business Outcome and Product Outcome of a capability against the committed OBC. Use after the OBC reaches Released state to confirm that the committed value was produced — business KPIs, SLOs, DORA Metrics, and Observable Events.
---

# Outcome Skill

## Purpose

Use this skill to verify, with real operational evidence, whether the delivery produced the value committed in the OBC.

The Outcome is not the delivery itself — it is the confirmation that the delivery produced a result. A Released OBC without Outcome verification is an unconfirmed delivery: the system does not know if value was produced.

This skill verifies two distinct planes:

- **Business Outcome:** business KPIs and metrics verified after continued operation
- **Product Outcome:** verifiable technical behavior — SLOs, DORA Metrics, Observable Events

---

## When to Use

- After the OBC reaches Released state and a sufficient operational period has passed
- In Assessment Reviews to verify whether delivered capabilities produced value
- When KPIs or SLOs committed in the OBC need to be contrasted with real data
- When a Released OBC needs to be moved to Archived with a result record
- To feed learnings from the previous cycle before starting a new Business Intent

---

## Required Reading

Before starting, read:

- `prodops/framework/lifecycle.en.md` — Outcome stage
- `prodops/framework/glossary.en.md` — terms Outcome, Business Outcome, Product Outcome, Observable Events, DORA Metrics
- `prodops/artifacts/obcs/<slug>.md` — Released OBC with committed KPIs and criteria

---

## Outcome Verification Flow

### Preconditions

1. OBC in Released state (`prodops/artifacts/obcs/<slug>.md`)
2. Release Trail with Promote completed (`prodops/artifacts/trails/`)
3. Observable Events operating in production (verified by Evidence Skill)
4. Sufficient operational period for metric collection (as declared in the OBC or business criterion)

---

### 1. Read the OBC commitment

Extract from the Released OBC:
- Committed KPIs: target values, measurement period, data source
- Declared SLOs: availability, latency, target error rate
- Expected Observable Events: which events, frequency, conditions
- Operational acceptance criteria ("Expected Results" section of the OBC)

---

### 2. Verify Business Outcome

**Business Outcome** is verified by the Assessment with support from the Portfolio PM.

For each KPI committed in the OBC:

1. Identify the data source (dashboard, report, analytics system).
2. Collect the current value for the declared measurement period.
3. Compare with the committed target value.
4. Classify:
   - **Confirmed:** value met or exceeded the target
   - **Partial:** value is below target but within documented acceptable margin
   - **Not achieved:** value is below target beyond the acceptable margin

5. For unachieved KPIs: record the root cause hypothesis and open a follow-up Business Signal.

**Recording format:**

```markdown
### Business Outcome — <capability-slug>

| KPI | Target | Measured | Period | Status |
|---|---|---|---|---|
| <kpi-name> | <target> | <actual> | <period> | ✅ Confirmed / ⚠️ Partial / ❌ Not achieved |

**Data source:** <dashboard/system>
**Verification date:** <YYYY-MM-DD>
**Observations:** <relevant context>
```

---

### 3. Verify Product Outcome

**Product Outcome** is verified by the Operation journey and the Async Assessment.

#### SLOs

For each SLO declared in the OBC or Reliability Plan:

1. Read the current metric from the observability system (Datadog or equivalent).
2. Compare with the committed SLO (availability, P95 latency, error rate).
3. Verify whether the burn rate period is within the Error Budget.

| SLO | Target | Current | Error Budget | Status |
|---|---|---|---|---|
| Availability | ≥ 99.9% | <value> | <remaining budget> | <status> |
| P95 Latency | ≤ 300ms | <value> | — | <status> |

#### DORA Metrics

Verify the four DORA metrics for the capability's period:

| Metric | Value | Reference | Classification |
|---|---|---|---|
| Deployment Frequency | | | Elite / High / Medium / Low |
| Lead Time for Changes | | | |
| Change Failure Rate | | | |
| Time to Restore Service | | | |

#### Observable Events

For each Observable Event declared in the OBC:
1. Confirm the event is being emitted (check logs / Datadog).
2. Verify emission frequency and conditions.
3. Confirm there are no active alerts related to the event.

---

### 4. Record the Outcome

Record results in the Released OBC:

```markdown
## Outcome Verified

**Verification date:** <YYYY-MM-DD>
**Verified by:** <PM + Tech Lead or Assessment team>
**Operation period:** <start-date> to <verification-date>

### Business Outcome
<KPI table with status>

### Product Outcome
<SLOs, DORA, Observable Events>

### Conclusion
<Outcome confirmed / Partial — see follow-ups / Not achieved — cause recorded>

### Follow-ups
<list of Business Signals opened for unachieved KPIs>
```

---

### 5. Decide on OBC lifecycle

Based on results:

| Situation | Action |
|---|---|
| Outcome confirmed | Transition OBC to Archived. Record learning in `learnings.md`. |
| Outcome partial | Keep OBC Released. Open new Business Signal for value gap. |
| Outcome not achieved | Keep OBC Released. Open investigation. Escalate to Portfolio PM. |

The transition to Archived requires an explicit record: date, who decided, and synthesis of the produced Outcome.

---

## Operating Rules

1. Never verify Outcome before the sufficient operational period — premature data distorts the analysis.
2. Never mark Business Outcome as confirmed without data from the source declared in the OBC.
3. Never move OBC to Archived without a recorded Outcome verification.
4. For unachieved KPIs: always record the hypothesis and open a follow-up — do not leave silently untracked.
5. Never confuse "Released" with "Outcome confirmed" — Released means delivered, not that value was produced.

---

## Expected Outputs

- Outcome record in the Released OBC (Business Outcome + Product Outcome)
- KPI table with measured vs. committed values
- SLOs and DORA Metrics verified for the period
- Observable Events confirmed operating in production
- Follow-up Business Signals opened for value gaps (when applicable)
- Decision on OBC transition to Archived (with justification)

---

## Guardrails

- Never fabricate metrics — record only what was measured from the declared source.
- Never archive an OBC without documented Outcome verification.
- Do not confuse Product Outcome (technical, verifiable by the system) with Business Outcome (business, verified by the PM with Portfolio support).
- Do not treat a violated SLO as a minor follow-up — escalate to the Operation journey.

---

## References

→ [Lifecycle — Outcome stage](../../framework/lifecycle.en.md)
→ [Glossary — Outcome](../../framework/glossary.en.md)
→ [OBC](../../framework/obc.md)
→ [Evidence Skill](../evidence/SKILL.en.md)
→ [Product Context Skill](../product-context/SKILL.en.md)
→ [Operation Journey](../../framework/journeys/operation/README.md)
→ [DORA Metrics](../../framework/dora-metrics.md)
