# Assessment Event Catalog — v2
# ProdOps Framework — Assessment Journey

> **Version:** 2.0.0
> **Status:** Active
> **Namespace:** `Assessment`
> **Journey:** Assessment
> **Schema:** [Event Type Schema v1.0.0](../../../events/event-type-schema.md)
> **Changelog v2.0.0:** Gate.Passed, Gate.Failed, Impediment.Declared → Deprecated (promoted to Active Shared Types). Impediment.Resolved → awaiting shared-types v1.1.0 for formal deprecation.

---

## Overview

| # | Event Type | Category | alters_state | new_state | Producers | Status v2 |
|---|---|---|---|---|---|---|
| 1 | Collect.Started | Phase Lifecycle | true | COLLECTING | Human, Agent | Active |
| 2 | Collect.Completed | Phase Lifecycle | true | COLLECTED | Human, Agent | Active |
| 3 | Analyze.Started | Phase Lifecycle | true | ANALYZING | Human, Agent | Active |
| 4 | Analyze.Completed | Phase Lifecycle | true | ANALYZED | Human, Agent | Active |
| 5 | Synthesize.Started | Phase Lifecycle | true | SYNTHESIZING | Human, Agent | Active |
| 6 | Synthesize.Completed | Phase Lifecycle | true | SYNTHESIZED | Human, Agent | Active |
| 7 | Report.Published | Phase Lifecycle | true | DONE | Human, Agent, System | Active |
| 8 | Monitor.Activated | Phase Lifecycle | true | MONITORING | System, Agent | Active |
| 9 | Alert.Raised | Phase Lifecycle | true | ALERTED | System, Agent | Active |
| 10 | Report.Approved | Human Decision | true | REPORTING | Human | Active |
| 11 | Report.Rejected | Human Decision | true | SYNTHESIZED | Human | Active |
| 12 | Recommendation.Issued | Human Decision | false | — | Human, Agent | Active |
| 13 | Risk.Identified | Human Decision | false | — | Human, Agent | Active |
| 14 | Opportunity.Identified | Human Decision | false | — | Human, Agent | Active |
| 15 | Gate.Passed | Gate | false | — | System, Agent | **Deprecated** → Shared.Gate.Passed |
| 16 | Gate.Failed | Gate | false | — | System, Agent | **Deprecated** → Shared.Gate.Failed |
| 17 | Impediment.Declared | Blocking | true | BLOCKED | Human, Agent | **Deprecated** → Shared.Impediment.Declared |
| 18 | Impediment.Resolved | Blocking | false | — | Human | Active — awaiting Shared.Impediment.Resolved (shared-types v1.1.0) |
| 19 | Threshold.Crossed | System | false | — | System, Agent | Active |
| 20 | Evolve.Proposed | System | false | — | System, Agent | Active |

---

## Assessment Sync — Collect

---

### Collect.Started

| Field | Value |
|---|---|
| **name** | `Collect.Started` |
| **category** | Phase Lifecycle |
| **alters_state** | `true` |
| **new_state** | `COLLECTING` |
| **producer_subtypes** | `[Human, Agent]` |
| **lifecycle_status** | Active |
| **introduced_in** | 1.0.0 |

**description:**
The Assessment evidence collection cycle has started. The analysis scope, the time window,
and the Work Item selection criteria have been defined. The evidence corpus is being built
from Delivery and Diligence Timelines and Framework artifacts.

**preconditions:**
- The Assessment cycle trigger has been activated (cadence, threshold, signal, or request)
- The analysis scope has been defined (included journeys, period, Work Items)
- An Assessment Work Item has been created for this cycle

**postconditions:**
- The Work Item transitions to the COLLECTING state
- The Assessment Timeline records the cycle start with the defined scope

**payload_shape:**
- `assessment_id` (string, required): unique identifier for this Assessment cycle
- `scope_description` (string, required): scope description (journeys, period, criteria)
- `evidence_window_start` (string, required): ISO 8601 — start of the evidence window
- `evidence_window_end` (string, required): ISO 8601 — end of the evidence window
- `trigger` (string, required): the trigger that activated this cycle (`cadence`, `threshold`, `external_signal`, `explicit_request`)

**owner_journey:** Assessment

---

### Collect.Completed

| Field | Value |
|---|---|
| **name** | `Collect.Completed` |
| **category** | Phase Lifecycle |
| **alters_state** | `true` |
| **new_state** | `COLLECTED` |
| **producer_subtypes** | `[Human, Agent]` |
| **lifecycle_status** | Active |
| **introduced_in** | 1.0.0 |

**description:**
The Assessment evidence corpus is complete and indexed. The Timelines of Work Items in
scope have been collected, raw metrics have been extracted, and relevant artifacts
(OBCs, Reliability Plans, Release Trails, Diligence Findings) have been referenced.
The Work Item is ready for analysis.

**preconditions:**
- The Work Item is in the COLLECTING state
- All Timelines in scope have been collected or documented as unavailable
- Relevant artifacts have been indexed

**postconditions:**
- The Work Item transitions to the COLLECTED state
- The evidence corpus is complete and referenced
- Data completeness is documented in the payload

**payload_shape:**
- `timelines_collected` (integer, required): number of Timelines collected in scope
- `work_items_in_scope` (integer, required): number of Work Items in the analysis scope
- `evidence_items_indexed` (integer, required): total evidence items indexed
- `data_completeness` (string, required): `complete` or `partial` — if partial, a note about what is missing

**owner_journey:** Assessment

---

## Assessment Sync — Analyze

---

### Analyze.Started

| Field | Value |
|---|---|
| **name** | `Analyze.Started` |
| **category** | Phase Lifecycle |
| **alters_state** | `true` |
| **new_state** | `ANALYZING` |
| **producer_subtypes** | `[Human, Agent]` |
| **lifecycle_status** | Active |
| **introduced_in** | 1.0.0 |

**description:**
The Assessment analysis phase has started. The analyst (human or agent) is calculating
operational metrics, identifying patterns, and correlating Diligence Findings with
Timeline data. Multiple observation events (Recommendation.Issued, Risk.Identified,
Opportunity.Identified, Gate.Passed/Failed) may be emitted during this phase.

**preconditions:**
- The Work Item is in the COLLECTED state
- The evidence corpus has been validated (completeness Gate.Passed recorded or exception documented)

**postconditions:**
- The Work Item transitions to the ANALYZING state
- Analysis is running — metrics being calculated

**payload_shape:**
- `analysis_approach` (string, required): description of the analysis approach
- `metrics_planned` (array of strings, required): metrics planned for calculation (e.g.: `["lead_time", "cycle_time", "gate_failure_rate"]`)

**owner_journey:** Assessment

---

### Analyze.Completed

| Field | Value |
|---|---|
| **name** | `Analyze.Completed` |
| **category** | Phase Lifecycle |
| **alters_state** | `true` |
| **new_state** | `ANALYZED` |
| **producer_subtypes** | `[Human, Agent]` |
| **lifecycle_status** | Active |
| **introduced_in** | 1.0.0 |

**description:**
The analysis phase has been completed. Metrics have been calculated, patterns have been
identified, and Diligence Findings have been correlated. Analysis results are documented
and ready for synthesis. Any Recommendation.Issued, Risk.Identified, and
Opportunity.Identified were emitted during this phase.

**preconditions:**
- The Work Item is in the ANALYZING state
- All metrics planned in Analyze.Started have been calculated (or unavailability documented)
- Patterns have been identified and classified (improving / stable / degrading)

**postconditions:**
- The Work Item transitions to the ANALYZED state
- Analysis results are available for synthesis

**payload_shape:**
- `metrics_calculated` (array of strings, required): metrics actually calculated
- `patterns_identified` (integer, required): number of patterns identified
- `findings_correlated` (integer, required): number of Diligence Findings correlated
- `recommendations_issued_count` (integer, required): number of Recommendation.Issued emitted during analysis

**owner_journey:** Assessment

---

## Assessment Sync — Synthesize

---

### Synthesize.Started

| Field | Value |
|---|---|
| **name** | `Synthesize.Started` |
| **category** | Phase Lifecycle |
| **alters_state** | `true` |
| **new_state** | `SYNTHESIZING` |
| **producer_subtypes** | `[Human, Agent]` |
| **lifecycle_status** | Active |
| **introduced_in** | 2.1.0 |

**description:**
The Synthesize Phase has started. Analysis results are being consolidated into high-level
insights and prioritized recommendations to compose the Assessment Report draft.

**preconditions:**
- The Work Item is in the ANALYZED state
- Analyze.Completed has been recorded on the Timeline

**postconditions:**
- The Work Item transitions to the SYNTHESIZING state
- Synthesis is in progress

**payload_shape:**
- `inputs_count` (integer, required): number of findings and recommendations received from the Analyze Phase
- `synthesis_scope` (string, required): scope of the synthesis (e.g.: `full`, `partial`, `delta`)

**owner_journey:** Assessment

---

### Synthesize.Completed

| Field | Value |
|---|---|
| **name** | `Synthesize.Completed` |
| **category** | Phase Lifecycle |
| **alters_state** | `true` |
| **new_state** | `SYNTHESIZED` |
| **producer_subtypes** | `[Human, Agent]` |
| **lifecycle_status** | Active |
| **introduced_in** | 1.0.0 |

**description:**
The synthesis of analysis results has been completed. Insights have been consolidated into
high-level conclusions, recommendations have been prioritized, and the Assessment Report
draft is ready for human review and approval. Quality gates on the Report may be executed
at this point.

**preconditions:**
- The Work Item is in the ANALYZED state
- Analysis results have been processed and consolidated
- At least one conclusion and one recommendation have been formulated

**postconditions:**
- The Work Item transitions to the SYNTHESIZED state
- The Assessment Report draft is ready for review and approval
- Quality gates on the Report will be executed before Report.Approved

**payload_shape:**
- `insights_count` (integer, required): number of consolidated insights
- `recommendations_count` (integer, required): number of recommendations in the draft
- `trend_summary` (string, required): summary of identified trends (`improving`, `stable`, `degrading`, `mixed`)

**owner_journey:** Assessment

---

## Assessment Sync — Report

---

### Report.Approved

| Field | Value |
|---|---|
| **name** | `Report.Approved` |
| **category** | Human Decision |
| **alters_state** | `true` |
| **new_state** | `REPORTING` |
| **producer_subtypes** | `[Human]` |
| **lifecycle_status** | Active |
| **introduced_in** | 1.0.0 |

**description:**
A human responsible approved the Assessment Report for publication. The Report has been
reviewed and satisfies the quality criteria — conclusions are evidence-based, recommendations
are specific and assigned, and the analyzed period is documented.

**preconditions:**
- The Work Item is in the SYNTHESIZED state
- Report quality gates have been executed successfully (Gate.Passed on the Timeline)
- The Report has been reviewed by the responsible party

**postconditions:**
- The Work Item transitions to the REPORTING state
- Report publication can be executed (Report.Published will be emitted)

**payload_shape:**
- `approver` (string, required): identity of who approved the Report
- `quality_gates_passed` (integer, required): number of quality gates approved before this decision

**owner_journey:** Assessment

---

### Report.Rejected

| Field | Value |
|---|---|
| **name** | `Report.Rejected` |
| **category** | Human Decision |
| **alters_state** | `true` |
| **new_state** | `SYNTHESIZED` |
| **producer_subtypes** | `[Human]` |
| **lifecycle_status** | Active |
| **introduced_in** | 1.0.0 |

**description:**
The Assessment Report was rejected by the responsible party. The Report did not satisfy the
quality criteria — insufficiently supported conclusions, vague recommendations, or incomplete
analysis. The Work Item returns to the SYNTHESIZED state — a new synthesis must be performed
before submitting for new approval.

**preconditions:**
- The Work Item is in the SYNTHESIZED state
- The Report has been reviewed by the responsible party and does not satisfy the criteria

**postconditions:**
- The Work Item returns to the SYNTHESIZED state
- The rejection reason is recorded on the Timeline
- A new synthesis and new Report.Approved will be required

**payload_shape:**
- `rejector` (string, required): identity of who rejected the Report
- `reason` (string, required): description of the criteria not satisfied

**owner_journey:** Assessment

---

### Report.Published

| Field | Value |
|---|---|
| **name** | `Report.Published` |
| **category** | Phase Lifecycle |
| **alters_state** | `true` |
| **new_state** | `DONE` |
| **producer_subtypes** | `[Human, Agent, System]` |
| **lifecycle_status** | Active |
| **introduced_in** | 1.0.0 |

**description:**
The Assessment Report has been formally published. The Assessment Sync cycle is closed. The
Report is available for consultation and the recommendations are assigned for execution.
The Assessment cycle Timeline remains open for correction events.

**preconditions:**
- The Work Item is in the REPORTING state
- Report.Approved has been recorded on the Timeline
- The Report has been published to the designated artifact

**postconditions:**
- The Work Item transitions to the DONE state
- The Assessment Report is formally published and accessible
- Recommendations are assigned for follow-up

**payload_shape:**
- `report_id` (string, required): unique identifier of the published Report
- `report_location` (string, required): path or reference to the published artifact
- `recommendations_count` (integer, required): number of recommendations in the published Report
- `next_assessment_trigger` (string, required): description of the next Assessment trigger (date or condition)

**owner_journey:** Assessment

---

## Assessment Async — Monitor

---

### Monitor.Activated

| Field | Value |
|---|---|
| **name** | `Monitor.Activated` |
| **category** | Phase Lifecycle |
| **alters_state** | `true` |
| **new_state** | `MONITORING` |
| **producer_subtypes** | `[System, Agent]` |
| **lifecycle_status** | Active |
| **introduced_in** | 1.0.0 |

**description:**
The continuous monitoring cycle has been activated. The system is permanently observing
metrics derived from Delivery and Diligence Timelines, comparing against defined thresholds.
Observation events (Threshold.Crossed, Recommendation.Issued, Evolve.Proposed) may be
emitted during this cycle without altering the Derived State.

**preconditions:**
- A monitoring Work Item has been created for this Async cycle
- Alert thresholds have been configured

**postconditions:**
- The Work Item transitions to the MONITORING state
- Continuous monitoring is active — metrics being observed

**payload_shape:**
- `monitor_cycle_id` (string, required): monitoring cycle identifier (e.g.: `2026-Q3-MONITOR`)
- `metrics_watched` (array of strings, required): metrics being monitored
- `thresholds_count` (integer, required): number of configured thresholds

**owner_journey:** Assessment

---

## Assessment Async — Alert

---

### Alert.Raised

| Field | Value |
|---|---|
| **name** | `Alert.Raised` |
| **category** | Phase Lifecycle |
| **alters_state** | `true` |
| **new_state** | `ALERTED` |
| **producer_subtypes** | `[System, Agent]` |
| **lifecycle_status** | Active |
| **introduced_in** | 1.0.0 |

**description:**
A formal alert has been raised after analysis of crossed thresholds. The situation requires
structured evaluation — an Assessment Sync cycle must be triggered. The alert is recorded
with sufficient severity and context to initiate the Sync immediately.

**preconditions:**
- The Work Item is in the MONITORING state
- One or more Threshold.Crossed have been recorded indicating a situation requiring attention
- The system has determined that a formal alert is warranted (severity or combination of thresholds)

**postconditions:**
- The Work Item transitions to the ALERTED state
- An Assessment Sync cycle must be triggered
- The Monitor.Activated of the next cycle will be emitted after the Sync completes

**payload_shape:**
- `alert_title` (string, required): short alert title
- `alert_description` (string, required): detailed description of the context
- `severity` (string, required): `high`, `medium`, `low`
- `triggering_events` (array of strings, required): ids of the Threshold.Crossed events that motivated this alert

**owner_journey:** Assessment

---

## Observation Events — Human Decision

---

### Recommendation.Issued

| Field | Value |
|---|---|
| **name** | `Recommendation.Issued` |
| **category** | Human Decision |
| **alters_state** | `false` |
| **producer_subtypes** | `[Human, Agent]` |
| **lifecycle_status** | Active |
| **introduced_in** | 1.0.0 |

**description:**
A formal recommendation has been produced during the Assessment cycle. The recommendation
is specific, assigned, prioritized, and evidence-based from the Timeline. It may be emitted
during Analyze or Synthesize (Sync) or during Monitor (Async). Multiple
Recommendation.Issued may occur in the same cycle.

**preconditions:**
- The Work Item is in an active analysis state (ANALYZING, ANALYZED, SYNTHESIZED, or MONITORING)
- The recommendation has a defined responsible party and cited evidence

**postconditions:**
- The recommendation is formally recorded on the Timeline
- The Derived State is not altered

**payload_shape:**
- `recommendation_title` (string, required): recommendation title
- `recommendation_description` (string, required): detailed description with evidence
- `priority` (string, required): `high`, `medium`, `low`
- `assignee` (string, optional): identity of the person responsible for the recommendation
- `evidence_event_ids` (array of strings, optional): ids of events that support the recommendation

**owner_journey:** Assessment

---

### Risk.Identified

| Field | Value |
|---|---|
| **name** | `Risk.Identified` |
| **category** | Human Decision |
| **alters_state** | `false` |
| **producer_subtypes** | `[Human, Agent]` |
| **lifecycle_status** | Active |
| **introduced_in** | 1.0.0 |

**description:**
An operational risk has been formally identified during analysis. The risk is a condition
observed in the Timelines or Findings that, if not addressed, may degrade the operational
model. Recording the risk does not alter the Derived State — it is a formal observation
that may support Recommendations and Evolution Plans.

**preconditions:**
- The Work Item is in an active analysis state
- The risk has been identified based on evidence from Timelines or Findings

**postconditions:**
- The risk is formally recorded on the Timeline with severity and probability
- The Derived State is not altered

**payload_shape:**
- `risk_description` (string, required): detailed description of the identified risk
- `severity` (string, required): `critical`, `high`, `medium`, `low`
- `probability` (string, required): `high`, `medium`, `low`
- `evidence_summary` (string, required): description of the evidence supporting the risk
- `mitigation_suggestion` (string, optional): initial mitigation suggestion

**owner_journey:** Assessment

---

### Opportunity.Identified

| Field | Value |
|---|---|
| **name** | `Opportunity.Identified` |
| **category** | Human Decision |
| **alters_state** | `false` |
| **producer_subtypes** | `[Human, Agent]` |
| **lifecycle_status** | Active |
| **introduced_in** | 1.0.0 |

**description:**
An improvement or evolution opportunity has been formally identified during analysis.
The opportunity is a condition observed in the Timelines or Findings that, if leveraged,
may enhance the operational model. Recording does not alter the Derived State — it is a
formal observation that may originate New Business Intents or Evolution Plans.

**preconditions:**
- The Work Item is in an active analysis state
- The opportunity has been identified based on evidence

**postconditions:**
- The opportunity is formally recorded on the Timeline
- The Derived State is not altered

**payload_shape:**
- `opportunity_description` (string, required): detailed description of the opportunity
- `potential_impact` (string, required): description of the potential impact if leveraged
- `confidence` (string, required): `high`, `medium`, `low`
- `evidence_summary` (string, required): evidence supporting the opportunity

**owner_journey:** Assessment

---

## Cross-cutting Events — Gate

---

### Gate.Passed

| Field | Value |
|---|---|
| **name** | `Gate.Passed` |
| **category** | Gate |
| **alters_state** | `false` |
| **producer_subtypes** | `[System, Agent]` |
| **lifecycle_status** | Deprecated |
| **introduced_in** | 1.0.0 |
| **deprecated_in** | 2.0.0 |
| **deprecation_reason** | Promoted to Shared Type. Do not emit new events with this Journey type — use Shared.Gate.Passed. |
| **replacement_type** | `Shared.Gate.Passed` — see [shared-types.md](../../../events/shared-types.md) |

**description:**
An automated quality gate passed successfully. In the Assessment Journey, gates verify
quality criteria of the cycle itself — completeness of collected data, minimum metric
coverage, recommendation support by evidence. The Derived State is not altered.

**preconditions:**
- The Work Item is in any active state (not DONE, not BLOCKED)
- An automated gate has been executed

**postconditions:**
- The gate is recorded as passing on the Timeline
- The Derived State remains unchanged

**payload_shape:**
- `gate_name` (string, required): gate identifier (e.g.: `data-completeness`, `metric-coverage`, `recommendation-evidence`)
- `duration_ms` (integer, required): execution duration in milliseconds

**notes:**
**Promoted to Shared Type in shared-types v1.0.0.** This Journey type has been Deprecated
since v2.0.0 of the catalog. Historical Timelines referencing this type remain valid — the
type remains in the catalog as a read-only historical reference. New emissions must use
`Shared.Gate.Passed`. Complementary pair: Gate.Failed.

**owner_journey:** Assessment

---

### Gate.Failed

| Field | Value |
|---|---|
| **name** | `Gate.Failed` |
| **category** | Gate |
| **alters_state** | `false` |
| **producer_subtypes** | `[System, Agent]` |
| **lifecycle_status** | Deprecated |
| **introduced_in** | 1.0.0 |
| **deprecated_in** | 2.0.0 |
| **deprecation_reason** | Promoted to Shared Type. Do not emit new events with this Journey type — use Shared.Gate.Failed. |
| **replacement_type** | `Shared.Gate.Failed` — see [shared-types.md](../../../events/shared-types.md) |

**description:**
An automated quality gate failed. The verified criterion was not satisfied. The Work Item
remains in the current state — the Producer must evaluate whether Report.Rejected should
be emitted (in the case of a gate on the Report) or whether the analysis should be
supplemented.

**preconditions:**
- The Work Item is in any active state (not DONE, not BLOCKED)
- An automated gate has been executed and produced a failure result

**postconditions:**
- The gate failure is recorded on the Timeline
- The Derived State remains unchanged

**payload_shape:**
- `gate_name` (string, required): gate identifier
- `reason` (string, required): description of the criterion that failed
- `duration_ms` (integer, required): execution duration in milliseconds

**notes:**
**Promoted to Shared Type in shared-types v1.0.0.** This Journey type has been Deprecated
since v2.0.0 of the catalog. Historical Timelines remain valid. New emissions must use
`Shared.Gate.Failed`. Complementary pair: Gate.Passed.

**owner_journey:** Assessment

---

## Cross-cutting Events — Blocking

---

### Impediment.Declared

| Field | Value |
|---|---|
| **name** | `Impediment.Declared` |
| **category** | Blocking |
| **alters_state** | `true` |
| **new_state** | `BLOCKED` |
| **producer_subtypes** | `[Human, Agent]` |
| **lifecycle_status** | Deprecated |
| **introduced_in** | 1.0.0 |
| **deprecated_in** | 2.0.0 |
| **deprecation_reason** | Promoted to Shared Type. Do not emit new events with this Journey type — use Shared.Impediment.Declared. |
| **replacement_type** | `Shared.Impediment.Declared` — see [shared-types.md](../../../events/shared-types.md) |

**description:**
An external impediment has been declared for the Assessment cycle. Work cannot progress —
it may be lack of access to Timelines, unavailability of analysis systems, or dependency
on external data not yet available.

**preconditions:**
- The Work Item is in any active state (not DONE, not BLOCKED)
- An external impediment has been identified that prevents cycle progression

**postconditions:**
- The Work Item transitions to the BLOCKED state
- Work is suspended until Impediment.Resolved

**payload_shape:**
- `impediment_description` (string, required): description of the impediment and who or what can resolve it
- `blocking_since` (string, required): timestamp when the impediment was identified

**notes:**
**Promoted to Shared Type in shared-types v1.0.0.** This Journey type has been Deprecated
since v2.0.0 of the catalog. Historical Timelines referencing this type remain valid. New
emissions must use `Shared.Impediment.Declared`. Complementary pair: Impediment.Resolved.

**owner_journey:** Assessment

---

### Impediment.Resolved

| Field | Value |
|---|---|
| **name** | `Impediment.Resolved` |
| **category** | Blocking |
| **alters_state** | `false` |
| **producer_subtypes** | `[Human]` |
| **lifecycle_status** | Active |
| **introduced_in** | 1.0.0 |

**description:**
The external impediment has been resolved and the Assessment cycle can resume. The Work Item
returns to the state it was in before the impediment was declared.

The return state is **not hardcoded** — the Consumer uses the Lookback mechanism
(`preBlockedState`) defined in `timeline.md` to calculate the state prior to BLOCKED.
Refined implementation consistent with Diligence. This is the third Journey to confirm
this pattern — the technical convergence of Delivery v2 (`alters_state=false`) was completed on 2026-07-25.

**preconditions:**
- The Work Item is in the BLOCKED state
- The impediment declared in Impediment.Declared has been resolved

**postconditions:**
- The Derived State is **not directly altered** by this event (`alters_state = false`)
- The Consumer uses Lookback to determine the return state (pre-BLOCKED state)
- The impediment resolution is recorded on the Timeline

**payload_shape:**
- `resolution_description` (string, required): description of how the impediment was resolved

**notes:**
**Candidate for promotion as a Shared Type.** Awaiting shared-types v1.1.0 — Delivery v2
converged to `alters_state=false` on 2026-07-25, satisfying the blocking CRT-02.
The promotion of `Shared.Impediment.Resolved` to Active will be the trigger to deprecate
this Journey type. When shared-types v1.1.0 is published, this type will be marked as
Deprecated with `replacement_type: Shared.Impediment.Resolved`. Complementary pair: Impediment.Declared.

**owner_journey:** Assessment

---

## System Events — System

---

### Threshold.Crossed

| Field | Value |
|---|---|
| **name** | `Threshold.Crossed` |
| **category** | System |
| **alters_state** | `false` |
| **producer_subtypes** | `[System, Agent]` |
| **lifecycle_status** | Active |
| **introduced_in** | 1.0.0 |

**description:**
A metric derived from Timelines crossed a predefined threshold during continuous monitoring.
The crossing is recorded as an observation — it does not alter the monitoring cycle state.
Multiple Threshold.Crossed may precede an Alert.Raised. The system evaluates whether the
set of crossed thresholds justifies a formal alert.

**preconditions:**
- The Work Item is in the MONITORING state
- An operational metric derived from Timelines has exceeded the configured threshold value

**postconditions:**
- The threshold crossing is recorded on the Timeline
- The Derived State remains MONITORING
- The system evaluates whether Alert.Raised should be emitted

**payload_shape:**
- `metric_name` (string, required): name of the metric that crossed the threshold (e.g.: `gate_failure_rate`, `cycle_time_p95`)
- `threshold_value` (string, required): configured threshold value
- `actual_value` (string, required): actual measured value that crossed the threshold
- `direction` (string, required): `above` — metric exceeded upper threshold; `below` — fell below lower threshold
- `measurement_window` (string, required): measurement time window (e.g.: `30d`, `7d`)

**owner_journey:** Assessment

---

### Evolve.Proposed

| Field | Value |
|---|---|
| **name** | `Evolve.Proposed` |
| **category** | System |
| **alters_state** | `false` |
| **producer_subtypes** | `[System, Agent]` |
| **lifecycle_status** | Active |
| **introduced_in** | 1.0.0 |

**description:**
An incremental evolution proposal has been generated during continuous monitoring — without
needing a full Assessment Sync cycle. The system or agent identified a specific, localized,
low-risk improvement that can be proposed directly for evaluation. The Derived State remains
MONITORING.

**preconditions:**
- The Work Item is in the MONITORING state
- The system identified an incremental evolution opportunity with sufficient evidence

**postconditions:**
- The evolution proposal is recorded on the Timeline
- The Derived State remains MONITORING
- The proposal may be accepted or ignored — it does not automatically trigger Assessment Sync

**payload_shape:**
- `proposal_title` (string, required): short proposal title
- `proposal_description` (string, required): detailed description of the proposed evolution
- `target_journey` (string, optional): target Journey of the proposal (`Delivery`, `Diligence`, `Framework`)
- `evidence_summary` (string, required): summary of evidence supporting the proposal

**owner_journey:** Assessment

---

## Reference flows

### Happy path — complete Assessment Sync

```
Timeline: Assessment-2026-Q2
────────────────────────────────────────────────────
Assessment Sync
  1. Collect.Started      → COLLECTING
     [trigger: cadence, window: 2026-Q2]
  2. Gate.Passed          (data-completeness)
  3. Collect.Completed    → COLLECTED (45 timelines, complete)
  4. Analyze.Started      → ANALYZING
  5. Recommendation.Issued (alters_state=false)
     [Lead Time P95 increased 28% — investigate Bootstrap]
  6. Opportunity.Identified (alters_state=false)
     [Gate Failure Rate decreasing — positive pattern]
  7. Analyze.Completed    → ANALYZED
     [4 metrics calculated, 3 patterns, 2 findings correlated]
  8. Synthesize.Started   → SYNTHESIZING
  9. Synthesize.Completed → SYNTHESIZED
     [3 insights, 2 recommendations, trend=mixed]
 10. Gate.Passed          (recommendation-evidence)
 11. Report.Approved      → REPORTING
 12. Report.Published     → DONE
────────────────────────────────────────────────────
Final Derived State: DONE
Events alters_state=true: 8 | false: 4
```

### Flow with Report rejection

```
Timeline: Assessment-2026-Q3
────────────────────────────────────────────────────
  1. Collect.Started      → COLLECTING
  2. Collect.Completed    → COLLECTED
  3. Analyze.Started      → ANALYZING
  4. Analyze.Completed    → ANALYZED
  5. Synthesize.Started   → SYNTHESIZING
  6. Synthesize.Completed → SYNTHESIZED
  7. Gate.Failed          (recommendation-evidence)
     [2 recommendations without cited evidence]
  8. Report.Rejected      → SYNTHESIZED [rejection: insufficient evidence]
  [re-synthesis with supplemented evidence]
  9. Synthesize.Started   → SYNTHESIZING
 10. Synthesize.Completed → SYNTHESIZED
 11. Gate.Passed          (recommendation-evidence)
 12. Report.Approved      → REPORTING
 13. Report.Published     → DONE
────────────────────────────────────────────────────
Synthesis cycles: 2
```

### Monitoring flow with alert

```
Timeline: Monitor-2026-Q3
────────────────────────────────────────────────────
Assessment Async
  1. Monitor.Activated    → MONITORING
     [metrics: gate_failure_rate, cycle_time, block_time]
  2. Threshold.Crossed    (gate_failure_rate: threshold=15%, actual=23%)
     (alters_state=false)
  3. Threshold.Crossed    (cycle_time_p95: threshold=5d, actual=8d)
     (alters_state=false)
  4. Evolve.Proposed      (alters_state=false)
     [proposal: revise lint gate criteria — 40% of failures are lint]
  5. Alert.Raised         → ALERTED (severity=high)
     [two critical thresholds crossed simultaneously]
────────────────────────────────────────────────────
→ Assessment Sync triggered (Assessment-2026-Q3-Alert)
→ new Monitor.Activated in the next cycle
```

### Flow with impediment — Lookback in action

```
Timeline: Assessment-2026-Q4
────────────────────────────────────────────────────
  1. Collect.Started      → COLLECTING
  2. Impediment.Declared  → BLOCKED
     [access to Delivery Timelines denied — expired credentials]
  3. Impediment.Resolved  → alters_state=false
     [Lookback → returns COLLECTING]
  4. Collect.Completed    → COLLECTED
  5. Analyze.Started      → ANALYZING
  ...

Lookback at pos 3:
  Impediment.Declared found at pos 2
  Search before pos 2: pos 1 = Collect.Started, new_state=COLLECTING (≠ BLOCKED)
  Return state: COLLECTING ✓
────────────────────────────────────────────────────
```

---

*All 19 Event Types in this catalog satisfy Event Type Schema v1.0.0.*
*Catalog version: 2.0.0. Active: 16. Deprecated: 3 (Gate.Passed, Gate.Failed, Impediment.Declared). Impediment.Resolved: Active — awaiting shared-types v1.1.0 for formal deprecation.*
