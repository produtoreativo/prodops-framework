# Remediation — Canonical Definition

## Definition

> **Remediation is the planned and trackable operation intended to remove, reduce or control the condition recorded in a Finding.**

A Remediation is not just text recommending a correction. It is the record of the operational response by Diligence or the owner to the Finding: what will be done, who will do it, how it will be verified and what the expected result is. A Remediation can generate one or more Work Items — but it is an entity distinct from the Work Item.

---

## ID format

```
RMD-YYYY-NNNN
```

- `RMD`: immutable prefix of the Remediation entity
- `YYYY`: creation year (four digits)
- `NNNN`: four-digit sequential per year (0001–9999)

Examples: `RMD-2026-0001`, `RMD-2026-0042`

---

## Fundamental principles

- **Remediation ≠ Work Item.** The Remediation is the plan and record of the corrective operation (Knowledge Space). The Work Item is the trackable execution unit in the Execution Space. The relationship is N:M: one Remediation can generate multiple Work Items; one Work Item can implement multiple Remediations.

- **Remediation Implemented ≠ Finding Verified.** The implementation of the Remediation (Implemented state) does not automatically mean that the Finding's condition was resolved. Verification is an independent step, carried out by someone who did not execute the Remediation, with Evidence collected after implementation.

- **A Remediation can apply to multiple Findings.** A single corrective operation (e.g., updating a glossary document) can resolve multiple Findings in the Documentation category.

- **A Finding can have multiple Remediations.** When the correction requires multiple parallel or sequential strategies.

---

## Schema

| Field | Conceptual type | Cardinality | Rules and notes |
|---|---|---|---|
| `id` | string | 1 | Format RMD-YYYY-NNNN; immutable; unique in the system |
| `title` | string | 1 | Required; summarizes the correction operation clearly |
| `description` | text | 1 | Required; describes what will be done, how and why it resolves the condition |
| `finding_ids` | list of Finding IDs | 1..N | Required; minimum 1 Finding; lists all Findings this Remediation addresses |
| `strategy` | enum | 1 primary | See strategy taxonomy below; may indicate secondary strategies |
| `owner` | string | 1 | Role responsible for execution and monitoring |
| `status` | enum | 1 | See state flow below |
| `priority` | enum | 0..1 | Separate from Finding severity; depends on context: Critical, High, Medium, Low |
| `target_date` | date | 0..1 | Target completion date; independent of Finding's `target_date` |
| `work_items` | list of Work Item refs | 0..N | References to execution Work Items; updated as Work Items are created |
| `expected_result` | text | 1 | Describes what constitutes success — system state after successful Remediation |
| `verification_check` | string | 0..1 | Check ID to be re-executed to verify resolution |
| `evidence_required` | text | 1 | What must be collected to prove completion and verify resolution |
| `residual_risk` | text | 0..1 | If the Remediation is partial, documents what remains unresolved |
| `started_at` | datetime | 0..1 | Set when status transitions to In Progress |
| `completed_at` | datetime | 0..1 | Set when status transitions to Implemented |
| `verified_at` | datetime | 0..1 | Set when status transitions to Verified |

---

## Strategy taxonomy

| Strategy | Definition | Example use |
|---|---|---|
| **Correct** | Removes the current cause or condition — eliminates the problem at the source | Update `artifact_id` field in Work Item with invalid reference; correct incorrect vocabulary in normative document |
| **Prevent** | Prevents recurrence of the condition — changes the process or mechanism so it does not happen again | Add automated field validation Check to the diligence-async cycle |
| **Contain** | Limits impact while the definitive correction does not exist — does not resolve but prevents worsening | Add notice in affected document indicating content is under review |
| **Compensate** | Adds alternative control — does not remove the condition but creates equivalent safeguard | Additional manual tests while Reliability Plan is not complete |
| **Migrate** | Moves structure or data to the correct model — when the condition exists due to obsolete design | Migrate OBCs from old format to updated canonical template |
| **Document** | Resolves exclusively a documentation gap — when the condition exists only in documentation | Create missing glossary entry; document unwritten protocol |
| **Reconcile** | Aligns sources, configurations or representations — when multiple sources diverge | Workspace Reconciliation to restore missing field in GitHub Project; synchronize state between OBC and GitHub Project |
| **Retire** | Removes an obsolete or invalid element — when the condition exists because of something that should not exist | Close orphaned Work Item referencing non-existent OBC; remove obsolete label |

A Remediation can combine strategies, but must indicate the primary strategy. Secondary strategies are optional.

---

## State flow

```
Proposed → Approved → In Progress → Implemented → Verified
                                               ↑
                                  (independent verification of implementation)
         → Rejected (with justification)
         → Cancelled (with documented reason)
```

| State | Meaning | Who can transition | Conditions |
|---|---|---|---|
| **Proposed** | Remediation identified and documented; awaiting approval | Diligence (creation) | Required fields filled |
| **Approved** | Approved for execution | owner or governance process | Responsible party identified, target_date defined if applicable |
| **In Progress** | Execution in progress | owner | Work Items created or operation started |
| **Implemented** | Correction applied; awaiting independent verification | owner or Diligence | Implementation Evidence collected; `completed_at` filled |
| **Verified** | Independent verification confirms condition was resolved | Diligence (independent verification) | Verification Evidence collected; Check re-executed if applicable; `verified_at` filled |
| **Rejected** | Decided that this Remediation will not be executed | owner or governance process | Justification documented; Finding remains open with new decision needed |
| **Cancelled** | Execution abandoned after approval | owner | Reason documented; `residual_risk` updated; Finding remains open |

### Special cases

**Partial implementation:** If the Remediation is partially executed, do NOT mark as Implemented. Document what was done, what remains in `residual_risk` and keep status at In Progress until implementation is complete — or create a separate Remediation for the remaining part.

**Independent verification:** Verification (Verified) is always independent from implementation. Whoever executed the Remediation does not verify their own Remediation. The verification Evidence is distinct from the implementation Evidence.

**Who approves:** Depends on context and Remediation scope. For workspace Remediations, Diligence can approve autonomously. For Remediations that alter canonical artifact content, approval requires the competent journey (Assessment, Product Owner, Tech Lead).

**Who cancels:** The owner can cancel with documented reason. The governance process can cancel when the condition was superseded by another decision.

---

## Relationship with Work Items

The Remediation is an entity of the Knowledge Space. The Work Items that execute the Remediation are entities of the Execution Space.

```
Remediation (Knowledge Space)
   │
   ├── Work Item #101: update artifact_id in Work Item #57
   └── Work Item #102: validate update and re-execute Check
```

| Cardinality | Direction |
|---|---|
| One Remediation can have 0 Work Items | When the correction is executed directly by Diligence without separate tracking |
| One Remediation can have N Work Items | When the correction requires multiple parallel or sequential tasks |
| One Work Item can implement N Remediations | When a single operation resolves multiple Findings |

**Principle:** the Remediation is not replaced by the Work Item. When the Work Item closes, the Remediation may be Implemented — but only becomes Verified after independent verification with Evidence.

---

## References

→ [`README.md`](README.md) — entity model and relationships
→ [`finding.md`](finding.md) — entity that originates the Remediation
→ [`evidence.md`](evidence.md) — implementation and verification Evidence
→ [`check.md`](check.md) — Check re-executed for verification
→ [`waiver.md`](waiver.md) — alternative when Remediation cannot be executed immediately
→ [`../diligence-async.md`](../diligence-async.md) — Repair phase executes Remediations
→ [`../workspace-reconciliation.md`](../workspace-reconciliation.md) — Capability that executes workspace Remediations
