# Operational Entity Model — Diligence

This directory contains the canonical definition of the Diligence journey's operational entities: **Check**, **Finding**, **Evidence**, **Remediation** and **Waiver**.

---

## Overview

The Diligence operational entities formalize the lifecycle of a divergence detected in the ProdOps work system: from the rule that detects it (Check), through the persistent record of the condition (Finding), the proofs that support it (Evidence), the operation that corrects it (Remediation) and the explicit authorization to temporarily accept it without immediate correction (Waiver).

These entities live primarily in the **Knowledge Space** — they are trackable documents and records. The connection with the **Execution Space** (Work Items, GitHub Issues) is explicit, tracked and intentional, but not automatic.

---

## Relationship diagram

```
Check
   │ evaluates a rule
   ▼
Finding
   │ records a concrete divergence
   ├──────────────► Evidence
   │                 proves detection, impact or resolution
   │
   ├──────────────► Remediation
   │                 executes or guides the correction
   │
   └──────────────► Waiver
                     authorizes temporary or exceptional acceptance
```

---

## Cardinalities

```
Check 1 ────── N Finding
  (one Check can detect multiple Findings over time)

Finding N ──── N Evidence
  (one Finding can have multiple Evidence records; one Evidence can support multiple Findings)

Finding N ──── N Remediation
  (one Finding can have multiple Remediations; one Remediation can correct multiple Findings)

Finding 1 ──── 0..N Waiver
  (only one active Waiver per Finding per scope per period)

Remediation N ─ N Work Item
  (one Remediation can generate multiple Work Items; one Work Item can implement multiple Remediations)

Finding N ──── N Work Item
  (one Finding can be tracked by multiple Work Items; one Work Item can treat multiple Findings)

Evidence N ─── N Finding
  (bidirectional relationship — one Evidence can support multiple Findings)
```

---

## Knowledge Space vs. Execution Space

### Knowledge Space

Canonical definitions, persistent records and formal justifications live in the Knowledge Space:

- **Check definitions**: versioned declarative rules specifying what to evaluate
- **Finding reports**: persistent records of divergences with state, trail and resolution
- **Waiver documents**: formal justifications, approvals and validity conditions
- **Evidence documents**: referenceable proofs of detection, impact or resolution
- **Remediation plans**: planned and trackable operations for correction

### Execution Space

Execution work on operational entities lives in the Execution Space:

- **Work Items to execute Checks**: when a Check requires human or coordinated operation
- **Work Items to investigate Findings**: when Finding investigation requires trackable work
- **Work Items to apply Remediations**: when the Remediation generates execution tasks
- **Work Items to review Waivers**: when a Waiver review requires coordination

**Fundamental principle:** not every Finding automatically requires the creation of a GitHub Issue. Work Item creation occurs when there is an active trackable operation being executed. A Finding can be resolved directly by Diligence without generating a separate Work Item.

---

## Finding deduplication

### Update existing Finding when:

- The same Check detects the same condition in the same subject in the same scope
- The condition was not resolved since the last detection
- The existing Finding is in state: Open, Acknowledged or In Remediation

When updating: record `last_detected_at`, increment occurrence count, update impact if changed, add new Evidence.

### Create new Finding when:

- The subject is different
- The violated rule is different
- The root cause is different
- The scope is independent
- The previous Finding is Closed and the recurrence represents a new relevant condition

**Never automatically reopen a Closed Finding without preserving the new occurrence record as a distinct event.**

---

## Blocking policy

A Finding can block work system operations (promotion, Iteration Plan entry, Release, state change, automatic reconciliation).

For a block to be valid, ALL criteria below must be simultaneously satisfied:

1. The Check is marked with `blocking: true`
2. There is a canonical normative source that defines the violated rule
3. The violation condition was confirmed (not just suspected)
4. Sufficient Evidence was collected
5. The severity is compatible with blocking (Info never blocks)
6. There is a documented resolution instruction
7. There is an identified owner or escalation target

A **valid Waiver** can suspend the block when the Check policy allows.

Severity Critical **does not** automatically imply impossibility of Waiver. Some rules can declare `waiver_allowed: false` — in these cases, no Waiver is accepted.

---

## Integration with Diligence cycles

### diligence-sync

- **Capture**: produces initial Evidence (artifact state when recorded); may create Finding if capture reveals immediate divergence
- **Attach**: relates Work Items to existing Findings when trackable work exists
- **Promote**: executes Readiness Checks (may block); Readiness Findings prevent advancement
- **Close**: produces completion Evidence; may create or update Finding when closure reveals unresolved condition

### diligence-async

- **Scan**: executes declared Checks; collects Evidence of detected state
- **Flag**: creates or updates Findings based on Scan results; classifies severity and action
- **Repair**: executes or relates authorized Remediations; creates Work Items when necessary

### Workspace Reconciliation

- **Inspect**: produces structural Evidence of workspace state; may reveal structural Findings
- **Reconcile**: executes authorized Remediation in the workspace
- **Verify**: produces verification Evidence; updates Finding to Verified when condition was resolved

---

## Five usage examples of the model

### Example 1 — Work Item without Artifact ID

1. Traceability Check (DIL-TRC-001) executes during Scan
2. High Finding created: "Work Item #57 does not have a valid Artifact ID" (FND-2026-0001)
3. Evidence: output of `gh issue view 57 --json body,labels` showing missing field
4. Proposed Remediation: update Work Item fields with artifact reference (RMD-2026-0001)
5. Remediation Work Item created and executed
6. Check executed again → Pass
7. Finding updated with verification Evidence → Verified → Closed

### Example 2 — Passive Business Signal without Issue

1. Check evaluates: "Does Business Signal #BS-042 have an active operation without Work Item?"
2. Result: Not Applicable (passive signal — no authorized active operation)
3. No Finding created
4. Proves that absence of Issue is not an automatic divergence

### Example 3 — Required field removed from GitHub Project

1. Structural Check (DIL-STR-007): "Does field 'operation' exist in the GitHub Project?"
2. Medium Finding created (FND-2026-0002): "Required field 'Operation' missing from GitHub Project"
3. Evidence: before (gh project field-list output with field) and after (without field)
4. Workspace Reconciliation invoked as Remediation
5. Reconcile: restore field following Canonical Specification
6. Verify: conformance Evidence after reconciliation
7. Finding → Verified → Closed

### Example 4 — Reliability Plan absent when required

1. Blocking Readiness Check (DIL-OPS-003): "Does Reliability Plan exist for item with financial movement?"
2. High Finding created (FND-2026-0003), block on Iteration Plan promotion
3. Evidence: OBC file + Assessment decision referencing need for Reliability Plan
4. Remediation: create/complete Reliability Plan after authorized decision (RMD-2026-0002)
5. Evidence proves satisfied criteria (document created and reviewed)
6. Promotion re-evaluated → Check returns Pass → Finding → Verified → Closed

### Example 5 — Temporary Waiver for known divergence

1. High Finding acknowledged (FND-2026-0004): circular dependency between two artifacts
2. Correction requires refactoring that cannot be completed before the planned Release
3. Waiver approved with 14-day validity (WVR-2026-0001), compensating control defined
4. Finding remains visible with Waived status; promotion block suspended
5. Waiver expires → Finding returns to requiring treatment (status changes to Acknowledged)
6. New decision needed: new Remediation or new Waiver with updated justification

---

## Anti-patterns (16)

| # | Anti-pattern | Why it is wrong |
|---|---|---|
| 1 | Turning every Finding into an Issue | Violates the N:M model; pollutes the Execution Space with ghost work; Finding is a Knowledge Space entity |
| 2 | Using Issue number as Finding ID | Finding IDs are immutable and tool-independent; GitHub migration would break all traceability |
| 3 | Deleting a resolved Finding | Loses historical trail; makes audit impossible; recurrences lose context |
| 4 | Closing Finding without Evidence | Evidence is what differentiates verified resolution from declaration; without Evidence, the Finding is not truly resolved |
| 5 | Considering implemented Remediation as automatically verified | Implementation and verification are independent steps; the Remediation may fail or be partial |
| 6 | Creating Waiver without expiration | Waiver without expiration is permanent treatment of a divergence that should be resolved; masks technical debt indefinitely |
| 7 | Renewing Waiver automatically | Expired Waiver requires a new conscious and justified decision; automatic renewal eliminates control |
| 8 | Using severity as synonym for priority | Severity describes intrinsic impact; priority depends on context, deadline, correction cost and current risk |
| 9 | Creating Finding without subject | Finding without identified subject is untraceable and unresolvable |
| 10 | Generating new Finding on every execution of the same Check for the same subject | Duplicates Findings; loses recurrence count; makes trend monitoring impossible |
| 11 | Overwriting historical Evidence | Evidence is immutable once recorded; new collection generates new Evidence; history is preserved |
| 12 | Silently choosing between conflicting sources | Conflicting sources must generate Indeterminate result or escalation; silent choice hides a model or data problem |
| 13 | Blocking without normative source | Blocking requires identified canonical rule; blocking without normative basis is arbitrary and uncontestable |
| 14 | Treating Check Error as proven violation | Error means the Check could not execute; may generate operational Finding about the mechanism failure, not about the original rule |
| 15 | Treating Indeterminate as Pass | Indeterminate means insufficient evidence; it is not confirmation of conformance |
| 16 | Allowing GitHub Project to be source of truth for Finding | Finding lives in the Knowledge Space (Markdown file or persistent record); the GitHub Project can mirror state but is not the canonical source |

---

## References

→ [`finding.md`](finding.md) — canonical Finding definition
→ [`check.md`](check.md) — canonical Check definition
→ [`evidence.md`](evidence.md) — canonical Evidence definition
→ [`remediation.md`](remediation.md) — canonical Remediation definition
→ [`waiver.md`](waiver.md) — canonical Waiver definition
→ [`../README.md`](../README.md) — Diligence journey overview
→ [`../diligence-sync.md`](../diligence-sync.md) — synchronous cycle
→ [`../diligence-async.md`](../diligence-async.md) — asynchronous cycle
→ [`../workspace-reconciliation.md`](../workspace-reconciliation.md) — reconciliation capability
→ [`../../../knowledge-vs-execution.md`](../../../knowledge-vs-execution.md) — KS vs. ES principle
