# GitHub Workspace — Diligence Journey
# ProdOps Framework

> **Version:** 1.0.0
> **Created on:** 2026-07-24
> **Status:** Specification — v1 reference implementation
> **Normative language:** English
> **Source of truth for:** Representation of Diligence entities in the GitHub Execution Space

---

## Section 1 — Purpose

This document specifies how the Diligence Journey uses the GitHub workspace
to represent, track and operate Work Items linked to canonical entities
(Finding, Remediation, Waiver, Evidence, Check).

**What this document specifies:**
- The canonical separation between Knowledge Space and Execution Space
- Criteria for Work Item creation per entity type
- The canonical schema for Work Items of the Diligence Journey
- Fields, labels, views and templates specific to Diligence
- Policies for editing, authority and drift detection
- The role of Workspace Reconciliation as a Capability of this Journey

**What this document does NOT specify:**
- The implementation of automations — those belong to Phase E
- GitHub Actions workflows
- The content of canonical entities (Finding, Remediation, etc.) — those live in `model/`
- The operational protocols Inspect/Reconcile/Verify — those belong to `workspace-reconciliation.md`

---

## Section 2 — Principles

1. **GitHub represents operations on entities, not the entities themselves.** Finding, Remediation, Waiver, Evidence and Check live in the Knowledge Space (`prodops/artifacts/diligence/`). GitHub Work Items represent planned, authorized, in-progress or completed operations on these entities.

2. **A Finding can exist without a Work Item.** A passive Finding (no active investigation, remediation or verification required at this moment) does not justify creating an Issue. Creating Issues "for coverage" violates the N:M model.

3. **Knowledge Space is the source of truth for entity state.** If `FND-2026-0007.md` says `status: Resolved`, the Finding is Resolved — regardless of the status of any associated Work Item.

4. **The Project organizes operations, not entities.** The Diligence Project view shows active, planned or completed operations — not a register of all existing Findings.

5. **N:M cardinality is preserved.** One Work Item can address multiple Findings, Remediations or Waivers. One Finding can generate multiple Work Items (investigation, remediation, verification). Forcing 1:1 is an anti-pattern.

6. **No artificial Issues.** The Project must not create Issues to guarantee 100% visual coverage of Findings. Findings without active operations are visible via `registry.yaml`, reports and direct queries — not via artificial Issues.

7. **Manual edits create drift.** Any edit to the GitHub Project that contradicts a canonical file is detected as drift by DIL-WSP-001. The canonical file always wins.

8. **Entity state ≠ operation state.** Work Item Status = Done does not mean Finding Status = Verified. They are distinct states with distinct semantics.

9. **Declared direction per field.** Each field has a declared source of truth (Section 11). Fields owned by the Knowledge Space must not be edited in the Project.

10. **Workspace Reconciliation is the only authorized reconciliation path.** Changes to workspace configuration (fields, labels, views) require execution of the Workspace Reconciliation Capability with explicit authorization.

---

## Section 3 — Entities in Knowledge Space

Canonical Diligence entities live in the Knowledge Space:

| Entity | ID prefix | Canonical location |
|---|---|---|
| Check | DIL-CAT-NNN | `prodops/framework/journeys/diligence/checks/catalog.yaml` |
| Finding | FND-YYYY-NNNN | `prodops/artifacts/diligence/findings/FND-*.md` |
| Evidence | EVD-YYYY-NNNN | `prodops/artifacts/diligence/evidence/EVD-*.md` |
| Remediation | RMD-YYYY-NNNN | `prodops/artifacts/diligence/remediations/RMD-*.md` |
| Waiver | WVR-YYYY-NNNN | `prodops/artifacts/diligence/waivers/WVR-*.md` |

These entities are never "stored" in GitHub Project fields. The Project refers to them via ID — not replaces them.

---

## Section 4 — Operations in Execution Space

```
Knowledge Space                    Execution Space
─────────────────                  ────────────────────────────────
FND-2026-0007.md  ──referenced──►  Issue: "RMD-2026-0003: fix field"
                                   Issue: "FND-2026-0007: verify resolution"

RMD-2026-0003.md  ──referenced──►  Issue: "RMD-2026-0003: implement correction"
                                   PR: "RMD-2026-0003: apply fix to schema"

WVR-2026-0001.md  ──referenced──►  Issue: "WVR-2026-0001: waiver review"
                                   PR: "WVR-2026-0001: approve waiver"
```

The Work Item's `Artifact ID` field stores the canonical ID of the primary entity.
The Work Item body lists all related entities (N:M).

---

## Section 5 — Criteria for Work Item creation

### Finding

**Create Work Item when:**
- Active investigation is underway (Investigate operation)
- Remediation is being planned or executed (Repair operation)
- Independent verification is in progress (Verify operation)
- Waiver proposal is being reviewed (Approve Waiver operation)

**Do NOT create Work Item when:**
- Finding is informational (severity: Info) with no active operation
- Finding is Not Applicable (closed without action required)
- Finding exists but no decision has been made yet (passive Open)
- Creating "for coverage" so all Findings appear in the Project

### Remediation

Create Work Item when the Remediation transitions to In Progress or has a specific execution operation. One Remediation can generate multiple Work Items (implementation + verification).

### Waiver

Create Work Item for the review and approval operation. One Waiver = at most one active review Work Item.

### Evidence

Evidence does not generate standalone Work Items. Evidence is collected as part of other operations (Repair, Verify, Approve Waiver) and is referenced in the body of the associated Work Item.

### Check

Check does not generate Work Items in normal operation. Exceptions:
- Workspace Reconciliation (review and update of Checks in the catalog)
- Updating a Check as part of a formal change process

---

## Section 6 — Cardinalities

| Canonical entity | Work Items (active) | Notes |
|---|---|---|
| Finding | 0..N | 0 when no active operation; N when multiple parallel operations |
| Remediation | 0..N | 0 when planned but not started; N when multiple implementation steps |
| Waiver | 0..1 | Normally 0 (passive) or 1 (active review) |
| Evidence | 0 | Never generates standalone Work Item |
| Check | 0..1 | Only during explicit revision operation |

---

## Section 7 — Canonical operations

Operations available in the Operation field and their meaning for Diligence:

| Operation | Used for | Creates Work Item |
|---|---|---|
| Investigate | Active investigation of a Finding | Yes |
| Repair | Implementation of a Remediation | Yes |
| Verify | Independent verification of a Finding or Remediation | Yes |
| Approve Waiver | Waiver review and approval process | Yes |
| Collect Evidence | Explicit collection of Evidence (when tracked separately) | Contextual |
| Reconcile | Workspace Reconciliation Capability | Yes |
| Capture | diligence-sync — Capture phase | Yes (if needed) |
| Attach | diligence-sync — Attach phase | Yes (if needed) |
| Promote | diligence-sync — Promote phase | Yes (if needed) |
| Close | diligence-sync — Close phase | Yes (if needed) |
| Scan | diligence-async — Scan phase | Yes (if needed) |
| Flag | diligence-async — Flag phase | Yes (if needed) |

**Recommendation for Approve Waiver:** This operation should appear in the Operations enum alongside Investigate, Repair, Verify. A Waiver review is a formal Diligence operation that deserves explicit tracking.

**Recommendation for Collect Evidence:** This operation can be added when there is a recurring pattern of creating Work Items specifically for Evidence collection in complex audits.

---

## Section 8 — Work Item schema

### Canonical title format

```
{Artifact ID}: {clear description of the operation}
```

Examples:
- `RMD-2026-0003: fix artifact_id fields in Work Items without reference`
- `FND-2026-0007: verify resolution after RMD-2026-0003`
- `WVR-2026-0001: review waiver for DIL-OPS-004`
- `INSPECT-2026-07-24-001: GitHub workspace inspection — Phase C`

### Required fields

| Field | Values | Notes |
|---|---|---|
| Title | `{ID}: {description}` | Canonical title format |
| Journey | Diligence | Fixed for all Diligence Work Items |
| Cycle | diligence-sync \| diligence-async \| workspace-reconciliation | Cycle that generated the Work Item |
| Phase | Capture \| Attach \| Promote \| Close \| Scan \| Flag \| Repair \| Inspect \| Reconcile \| Verify | Cycle phase |
| Operation | Investigate \| Repair \| Verify \| Approve Waiver \| Collect Evidence \| Reconcile \| ... | Specific operation |
| Artifact Type | Finding \| Remediation \| Waiver \| Evidence \| Check | Type of primary entity |
| Artifact ID | FND-YYYY-NNNN \| RMD-YYYY-NNNN \| ... | ID of primary canonical entity |

### Contextual fields

| Field | When to use |
|---|---|
| Mode | Sync \| Async \| Manual — when the mode of execution matters for routing |
| Status | Todo \| In Progress \| Done \| Cancelled — standard Project status |
| Owner | Role responsible for the operation (not necessarily the entity owner) |
| Repository | When the Work Item is associated with a specific repository |
| Blocking | Derived — do NOT edit manually |
| Waiver Expiration | Derived from `expires_at` of WVR file — do NOT edit manually |
| Finding Status | Derived from `status` in FND file — do NOT edit manually |
| Finding Severity | Derived from `severity` in FND file — do NOT edit manually |

### Traceability extension fields in the body

The Work Item body must contain the `ProdOps References` section:

```markdown
## ProdOps References
- Primary: `{Artifact ID}` ({Artifact Type})
- Related:
  - Finding: `FND-YYYY-NNNN`
  - Finding: `FND-YYYY-NNNN`
  - Remediation: `RMD-YYYY-NNNN`
  - Waiver: `WVR-YYYY-NNNN`
  - Evidence: `EVD-YYYY-NNNN`
  - Check: `DIL-CAT-NNN@version`
```

### Related fields for N:M

When one Work Item addresses multiple entities:
- Primary (`Artifact ID` + `Artifact Type`): the main entity that justified creating the Work Item
- Related (body section): all other entities addressed by this Work Item

---

## Section 9 — References

### primary_reference schema

```yaml
primary_reference:
  artifact_id: "FND-2026-0007"          # canonical ID of the main entity
  artifact_type: Finding                 # entity type
  operation: Repair                      # operation being performed
  journey: Diligence
  cycle: diligence-async
  phase: Repair
  mode: Async
```

### Representation per surface

| Surface | Representation |
|---|---|
| GitHub Project field | `Artifact ID = FND-2026-0007`, `Artifact Type = Finding` |
| Issue title | `RMD-2026-0003: implement correction for FND-2026-0007` |
| Issue body | `## ProdOps References` section with all related IDs |
| Issue labels | `diligence`, `diligence:remediation` |
| Pull Request | `## Diligence References` with involved entities |

---

## Section 10 — GitHub Project fields

### Base existing fields (pre-existing in the Project)

| Field | Type | Current values | v1 decision |
|---|---|---|---|
| Status | single_select | Todo, In Progress, Done, Cancelled | Keep as-is |
| Repository | automatic | GitHub | Keep as-is |
| Owner | automatic | Assignee | Keep as-is |
| Journey | single_select | Assessment, Foundation, Diligence, ... | Add Diligence if missing |
| Cycle | single_select | Existing cycles | Add diligence-sync, diligence-async, workspace-reconciliation |
| Phase | single_select | Existing phases | Add Capture, Attach, Promote, Close, Scan, Flag, Repair, Inspect, Reconcile, Verify |
| Operation | single_select | Existing operations | Add Investigate, Approve Waiver, Collect Evidence, Reconcile |
| Mode | single_select | Sync, Async, Manual | Confirm existing values |
| Artifact ID | text | ID of canonical entity | Keep as-is |
| Artifact Type | single_select | Existing types | Add Finding, Remediation, Waiver, Evidence, Check |

### Diligence-specific derived fields

| Field | Type | Source of derivation | Phase | v1 decision |
|---|---|---|---|---|
| Blocking | single_select (Yes/No) | Calculated from Check + Finding + Waiver | Phase E | Do NOT create without automation |
| Waiver Expiration | date | `expires_at` in WVR file | Phase E | Do NOT create without automation |
| Finding Status | single_select | `status` in FND file | Phase E | Evaluate need — may be deferred |
| Finding Severity | single_select | `severity` in FND file | Phase E | Evaluate need — may be deferred |

### Rejected fields (do not create)

| Field | Reason for rejection |
|---|---|
| Check Result | History of executions requires multiple values; high drift risk; Evidence is sufficient |
| Finding ID | Redundant with Artifact ID when Artifact Type = Finding |
| Remediation ID | Redundant with Artifact ID when Artifact Type = Remediation |
| Waiver ID | Redundant with Artifact ID when Artifact Type = Waiver |
| Check ID | Redundant with Artifact ID when Artifact Type = Check |

---

## Section 11 — Field authority table

| Field | Source of truth | Edit direction | Expected drift |
|---|---|---|---|
| Artifact ID | KS (canonical file) | KS → Project | Low |
| Artifact Type | KS (canonical file) | KS → Project | Low |
| Journey | Schema (this document) | Schema → Project | Low |
| Cycle | Schema (this document) | Schema → Project | Low |
| Phase | Schema (this document) | Schema → Project | Low |
| Operation | Schema (this document) | Schema → Project | Low |
| Mode | Schema (this document) | Schema → Project | Low |
| Status | ES (Project) | Project → reports | Medium |
| Owner | ES (Project) | Project → reports | Low |
| Repository | Automatic (GitHub) | N/A | None |
| Blocking | KS (derived) | KS → Project (automation) | High without automation |
| Waiver Expiration | KS (WVR file) | KS → Project (automation) | High without automation |
| Finding Status | KS (FND file) | KS → Project (automation) | High without automation |
| Finding Severity | KS (FND file) | KS → Project (automation) | High without automation |

---

## Section 12 — Editing policy

### KS-owned fields: do NOT edit in the Project

Fields whose source of truth is the Knowledge Space (canonical files) must not be edited directly in the Project:

- `Artifact ID` — reflects the canonical entity ID; editing creates immediate drift
- `Artifact Type` — reflects the entity type; editing creates classification error
- `Blocking` — derived from Check + Finding + Waiver; editing does not change canonical state
- `Waiver Expiration` — derived from `expires_at` in WVR file; editing does not extend the Waiver
- `Finding Status` — derived from `status` in FND file; editing does not alter entity state
- `Finding Severity` — derived from `severity` in FND file; editing does not alter entity state

### ES-owned fields: can edit in the Project

Fields whose source of truth is the Execution Space (Project) can be edited directly:

- `Status` — operation progress; valid values: Todo, In Progress, Done, Cancelled
- `Owner` — responsible for the operation; can change as team changes
- `Journey`, `Cycle`, `Phase`, `Operation`, `Mode` — can be corrected if incorrectly classified at creation

### Critical distinction

| Edit | Effect | Allowed? |
|---|---|---|
| `Blocking = No` in Project without Waiver | Does not alter canonical entity; creates drift detected by DIL-WSP-001 | No |
| Creating canonical Waiver with `expires_at` | Alters entity; `blocking_effective` recalculated | Yes |
| `Finding Status = Verified` in Project without canonical verification | Creates drift; entity remains Resolved | No |
| Updating `status: Verified` in FND file after independent verification | Alters entity correctly | Yes |
| `Waiver Expiration` in Project without changing WVR file | Creates drift; WVR file remains authoritative | No |

---

## Section 13 — Finding Status × Work Item Status

Finding status (in the canonical file) and Work Item status (in the Project) are independent:

| Finding Status (KS) | Work Item Status (ES) | Interpretation |
|---|---|---|
| Open | In Progress | Active investigation |
| Open | Todo | Planned but not started |
| Resolved | Done | Implementation Work Item completed; verification pending |
| Resolved | In Progress | Verification Work Item in progress |
| Verified | Done | Verification Work Item completed; Finding confirmed Verified |
| Waived | Done | Waiver approved; Work Item closed |

**Example 1:** Finding is Resolved (implementation done) but verification Work Item is still In Progress — both states are correct simultaneously.

**Example 2:** Finding is Open but investigation Work Item is Done (investigation closed without active Remediation) — both states are correct simultaneously.

---

## Section 14 — Labels

### Proposed Diligence labels

| Label | Purpose | Applied to |
|---|---|---|
| `diligence` | Identifies any Work Item of the Diligence Journey | All Diligence Issues and PRs |
| `diligence:investigation` | Active investigation of a Finding | Investigation Issues |
| `diligence:remediation` | Active implementation of a Remediation | Remediation Issues and PRs |
| `diligence:verification` | Independent verification of implementation or Finding | Verification Issues |
| `diligence:waiver-review` | Waiver review and approval process | Waiver Issues and PRs |
| `diligence:reconciliation` | Workspace Reconciliation operation | Reconciliation Issues |
| `diligence:evidence-collection` | Explicit Evidence collection (deferred) | Deferred |

### What labels cannot represent

Labels are metadata for routing and filtering — not canonical states or entity identifiers:
- Label does not replace canonical ID (`diligence:finding-FND-2026-0007` is not acceptable)
- Label does not replace entity status (Finding status lives in the canonical file)
- Label does not authorize (Waiver via label only is not a canonical Waiver)

### Existing labels to reuse

Labels already existing in the repository that can be reused for Diligence without creating specific new ones. Verify during Inspect.

### Rejected labels (do not create)

| Label | Reason |
|---|---|
| `journey:diligence` | Redundant with Journey field; conflicts with field nomenclature |
| `artifact-type:finding` | Redundant with Artifact Type field |
| `artifact-type:remediation` | Redundant with Artifact Type field |
| `operation:repair` | Too granular; conflicts with Operation field |
| `blocking:yes` | Derived field — not a label |

---

## Section 15 — Pull Requests

### Remediation PR

For a Remediation that corrects configuration files, code or documents:

- Title: `{RMD-ID}: {brief description of the correction}`
- Labels: `diligence`, `diligence:remediation`
- Primary reference: `Artifact ID = RMD-YYYY-NNNN`, `Artifact Type = Remediation`
- Body: `## Diligence References` section listing all involved entities

### Waiver PR

For proposing and approving a canonical Waiver:

- Title: `{WVR-ID}: approve waiver for {FND-ID}`
- Labels: `diligence`, `diligence:waiver-review`
- Body: `## Diligence References` + content of the proposed `WVR-*.md` file for review
- Approval via PR review = canonical Evidence of approval

### Verification PR

For corrections identified during independent verification:

- Title: `{RMD-ID}: apply corrections after verification`
- Labels: `diligence`, `diligence:verification`
- Body: reference to Finding + Remediation + verification Evidence

### PR body template (conceptual)

```markdown
## Diligence References
- Primary: `{Artifact ID}` ({Artifact Type})
- Related:
  - Finding: `FND-YYYY-NNNN` — {brief status}
  - Remediation: `RMD-YYYY-NNNN` — {brief status}
  - Evidence: `EVD-YYYY-NNNN` — {type}
  - Check: `DIL-CAT-NNN@version`

## Summary
{description of what this PR does}

## Verification
- [ ] Check `{DIL-CAT-NNN}` was re-executed and returned Pass
- [ ] Evidence `EVD-YYYY-NNNN` was created and referenced
- [ ] Canonical entity updated (`FND-*.md` / `RMD-*.md` / `WVR-*.md`)
```

---

## Section 16 — Releases

A GitHub Release can serve as Evidence for a Remediation or a set of corrections:

- A Release tag serves as `artifact_ref` in `EVD-*.md` (Evidence of implementation)
- The Release does NOT automatically transition Finding to Verified
- Independent verification after the Release is still required before Verified
- `EVD-*.md` referencing the Release is created separately with canonical ID

---

## Section 17 — Issue body template

```markdown
## Context
{brief description of the condition or operation being tracked}

## ProdOps References
- Primary: `{Artifact ID}` ({Artifact Type})
- Related:
  - Finding: `FND-YYYY-NNNN`
  - Remediation: `RMD-YYYY-NNNN`
  - Waiver: `WVR-YYYY-NNNN`
  - Evidence: `EVD-YYYY-NNNN`
  - Check: `DIL-CAT-NNN@version`

## Objective
{what needs to be done in this Work Item}

## Completion criteria
- [ ] {criterion 1}
- [ ] {criterion 2}
- [ ] Evidence collected: `EVD-YYYY-NNNN`

## Notes
{additional context, API limitations, blockers, observations}
```

---

## Section 18 — Planned Views

| View | Filter | Grouping | Purpose |
|---|---|---|---|
| Diligence Operations | Journey = Diligence AND Status ≠ Done | Cycle | Complete overview of active operations |
| Active Remediations | Artifact Type = Remediation AND Status = In Progress | Phase | Track remediation progress |
| Blocking Findings | Blocking = Yes AND Status ≠ Done | Severity | Prioritize blocking items (Phase E — requires Blocking field) |
| Waiver Reviews | `diligence:waiver-review` label AND Status ≠ Done | — | Active waiver approvals |
| Workspace Reconciliation | Cycle = workspace-reconciliation | Phase | Reconciliation operations progress |
| Verification Queue | `diligence:verification` label AND Status = Todo | — | Pending verifications |
| Diligence History | Journey = Diligence AND Status = Done | Cycle | Completed operations audit |

**Phase C:** Create all views except Blocking Findings (requires derived Blocking field).
**Phase E:** Create Blocking Findings view after Blocking field is implemented.

---

## Section 19 — Findings without Work Item

Findings without active Work Items are visible via:

1. **`prodops/artifacts/diligence/registry.yaml`** — complete index of all Findings with their statuses
2. **Periodic reports** — generated from `registry.yaml` and exported to `reports/`
3. **Static pages** — generated from entities; no GitHub dependency
4. **Direct queries** — query over `registry.yaml` or `FND-*.md` files with structured result

**The Project must NOT create artificial Issues to guarantee visual coverage of all Findings.**

### Planned solutions for complete visibility

| Solution | Approach | Status |
|---|---|---|
| Derived dashboard | Generated from `registry.yaml`; read-only; no Work Item creation | Planned |
| Aggregated report | Generated periodically; exported as Markdown in `reports/` | Planned |
| Generated page | Static generation from entities; no GitHub automation | Planned |
| Read integration | Query over files with structured result | Planned |

---

## Section 20 — Blocking

The `blocking_effective` field is derived — calculated from canonical entities, not manually editable:

```
blocking_effective =
  check.blocking = true
  AND finding.status ∈ {Open, Acknowledged, In Remediation}
  AND check.scope applicable to context
  AND NOT (waiver.status = Active AND waiver.expires_at > now)
```

**A user cannot set `Blocking = No` manually in the Project to suspend a rule.**

Suspending blocking requires a canonical Waiver:
- `waiver_allowed: true` in the Check (`catalog.yaml`)
- `WVR-YYYY-NNNN.md` file with Active status, all required fields filled, `expires_at` in the future
- Referenced approval Evidence

If the `Blocking` field is present in the Project as a derived field:
- It is read-only — not editable in the Project
- It is updated by automation that reads canonical entities
- Manual edit → drift → DIL-STR or DIL-OPS Finding detected by DIL-WSP-001

---

## Section 21 — Waiver

The Waiver is a canonical entity in the Knowledge Space (`WVR-YYYY-NNNN.md`). In GitHub:

- A Work Item can exist for the Waiver review or approval operation
- The `Waiver Expiration` field (if present in the Project) is derived from the `expires_at` field in the file
- Expiration cannot be updated only in the Project — requires change in the canonical file (with authorization) or formal renewal (new `WVR-YYYY-NNNN` with new ID)
- When the Waiver expires: `blocking_effective` returns to `true` for the associated Finding
- The Project CAN signal proximity to expiration as an operational alert
- The `WVR-YYYY-NNNN.md` file remains source of truth — expired, but preserved

**Waiver Renewal:**
- Renewal is creation of a new Waiver with a new ID (`WVR-YYYY-NNNN+1`)
- The previous Waiver remains with Expired status — never retroactively modified
- The review Work Item can be closed; a new Work Item can be created for the new Waiver if needed

---

## Section 22 — Check Result

A Check can be executed multiple times on the same subject. Therefore:

- Check Result is NOT a permanent property of a Finding or Work Item
- If represented as a derived field, it must reflect: most recent result + Check ID + version + timestamp + reference to Evidence
- The history of Check executions is in Evidence files (`EVD-YYYY-NNNN.md`), not in Project fields
- The field would be a "window" to the most recent Evidence, not a historical record

**Decision for v1:** Check Result as a Project field is **not recommended**. The reference to Evidence (`EVD-*`) in the Issue body is sufficient to track execution. A dedicated field can be added when there is a demonstrated need for filtering or grouping by Check result.

**Justification:**
- Execution history requires multiple values — a single field is not adequate
- The value changes with each execution — high drift risk without reliable automation
- Evidence already captures result, timestamp, and context with adequate structure

---

## Section 23 — Workspace Reconciliation

This document (`github-workspace.md`) is the **expected state** that the Workspace Reconciliation Capability uses as source of truth for its operations.

**Inspect:** Reads the current state of the GitHub workspace (fields, labels, views, templates) and compares with this document. Does not modify anything during Inspect. Generates divergence report.

**Reconcile:** After authorization, creates or corrects what was identified in Inspect, using the Automation First mechanism (API → MCP → CLI → SDK → Browser Automation). Each action is trackable.

**Verify:** Executes DIL-WSP-001 and other structural workspace Checks. Records verification Evidence (`EVD-YYYY-NNNN`). Updates associated Finding if any.

**This document is the INPUT for Workspace Reconciliation, not the output.**

The order of precedence for Inspect:
1. This document (`github-workspace.md`) — design specification
2. `prodops/exec/manifest.yaml` — machine-readable declared configuration

Any divergence between this document and the real workspace state is a candidate for authorized reconciliation.

---

## Section 24 — Anti-patterns

1. **Finding as Issue** — Finding is a Knowledge Space entity; Issue represents work on it. Creating an Issue that "is" the Finding violates the KS/ES separation and makes the Issue number the entity identifier.

2. **Issue created for every Finding** — Violates N:M cardinality; pollutes the Project with ghost work items; a passive artifact does not require a Work Item.

3. **Evidence only in comments** — Issue comments have no own ID, are not immutable, not referenceable by canonical ID. Evidence with its own identity requires an `EVD-YYYY-NNNN.md` file.

4. **Waiver only as label** — A label does not constitute formal approval; has no `expires_at`, `approved_by`, `risk_accepted` or approval Evidence. A valid Waiver is a canonical file signed by an approver.

5. **Approval only by status change** — Changing Work Item status from "In Review" to "Done" does not approve a Waiver. Canonical approval requires a `WVR-YYYY-NNNN.md` file with all fields and approval Evidence.

6. **Issue number as Finding ID** — Issue #42 is not the same as `FND-2026-0007`. Canonical IDs are immutable and tool-independent. If the repository migrates, the Issue ID changes; the Finding ID does not.

7. **Same status for Finding and Work Item** — "Issue Done" does not mean "Finding Resolved". They are independent states with distinct semantics.

8. **Closing Finding when Issue closes** — Work Item closes when the operation ends. Finding transitions state only when canonical criteria are satisfied (Evidence, independent verification, etc.).

9. **Marking Verified when PR is merged** — A merged PR can be implementation Evidence for a Remediation, but it is not independent verification of the original condition. Finding is only Verified after a verification Check with Pass result and independent Evidence.

10. **Editing severity only in the Project** — Finding Severity in the file is the source of truth. Editing the derived field in the Project creates immediate silent drift.

11. **Editing expiration only in the Project** — `Waiver Expiration` in the Project is derived from `expires_at` in the `WVR-YYYY-NNNN.md` file. Editing only the Project does not alter the canonical Waiver — it creates drift that DIL-WSP-001 detects.

12. **Creating one field per Check** — A "Check ID" field per Check type in the Project is an anti-pattern. The generic `Artifact ID` field with `Artifact Type = Check` serves the same purpose without field proliferation.

13. **Creating one field per Finding** — A specific "Finding ID" field in addition to `Artifact ID` is redundant. When `Artifact Type = Finding`, the `Artifact ID` already carries the Finding ID.

14. **Recording Check history in a text field** — History of Check executions (multiple results, timestamps, Evidence) does not fit in a Project text field. Independent Evidence is the correct mechanism.

15. **Using View as source of truth** — Views are filters over Work Items. "The Blocking Findings View is empty" does not mean there are no blocking Findings — it means there are no active Work Items associated with them.

16. **Requiring all Findings to appear in the Project** — Findings without active operations must not appear in the Project. Trying to create 100% visual coverage via Issues violates the N:M model and pollutes the Execution Space.

17. **Using label as ID** — `label:finding-FND-2026-0007` is not a canonical identifier. Labels change, are renamed, deleted. Canonical IDs are permanent.

18. **Representing Remediation and Finding in the same concept** — Finding records the condition; Remediation plans the correction. They are distinct entities with distinct states. "This Finding is in Remediation" is one state; "This Remediation is implemented" is another state — both coexist with different semantics.

19. **Duplicating canonical information without authority** — Copying `Finding Status` to a Project field without declared automation creates two records of the same data without a clear precedence rule. Drift is guaranteed.

20. **Bidirectional synchronization without per-field rule** — Bidirectional synchronization without source of truth declaration per field results in conflicts. Each field has a declared owner (Section 11). Bidirectional synchronization is only valid when each field has a uniquely defined direction.

21. **Manually disabling Blocking** — The `Blocking` field is derived. Editing it directly in the Project does not alter the canonical entity. Suspending blocking requires a canonical Waiver — not field editing.

22. **Treating an expired Waiver as active** — A Waiver with `expires_at` in the past and still `Active` status is a violation of DIL-TMP-001. Not tolerable via Waiver (`waiver_allowed: false` for this Check). The Finding immediately returns to normal flow.

23. **Creating Views before schema** — Views are derived representations of fields. Creating a "Blocking Findings" View before having the `Blocking` field configured results in an empty or inoperative View. Schema first, Views after.

24. **Creating a third Cycle for Workspace Reconciliation** — Workspace Reconciliation is a Capability invoked by existing cycles (diligence-sync, diligence-async) and Bootstrap. It is not an independent third Cycle. Treating it as a Cycle creates orchestration confusion.

---

## Section 25 — Examples

### Example 1 — Informational Finding without Work Item

**Scenario:** DIL-CON-001 detects use of the term "Business Signal Issue" in a historical document during diligence-async Scan.

**Canonical state:**
- Finding created: `FND-2026-0001.md` with `severity: Info`, `status: Open`, `dimension: Conceptual`
- Assessment: historical, non-normative document — Finding can be classified as Not Applicable or recorded as Info for historical tracking
- No Work Item created

**In the Project:**
- `FND-2026-0001` does not appear in the Project
- `registry.yaml` has the Finding entry
- Periodic report lists the Finding

**Lesson:** Finding without active operation = invisible in the Project = correct. Visibility via `registry.yaml` and reports — not via artificial Issue.

---

### Example 2 — Active Remediation with multiple Findings

**Scenario:** DIL-TRC-001 detects two active Work Items without `artifact_id` filled.

**Canonical state:**
- `FND-2026-0007.md` — Finding about Work Item A without reference
- `FND-2026-0008.md` — Finding about Work Item B without reference
- `RMD-2026-0003.md` — Remediation addressing both: fix fields in both Work Items

**Work Item created:**
```
Title: RMD-2026-0003: fix artifact_id fields in Work Items without reference
Artifact Type: Remediation
Artifact ID: RMD-2026-0003
Operation: Repair
Journey: Diligence
Cycle: diligence-async
Phase: Repair
```

**In the body:**
```markdown
## ProdOps References
- Primary: `RMD-2026-0003` (Remediation)
- Related:
  - Finding: `FND-2026-0007`
  - Finding: `FND-2026-0008`
  - Check: `DIL-TRC-001@1`
```

**In the Project:** Work Item appears with Artifact Type = Remediation, Artifact ID = RMD-2026-0003. The Project shows the **operation**, not the Findings directly.

**Lesson:** Remediation as primary reference; Findings as related references. N:M preserved. Project shows operation, not canonical entity.

---

### Example 3 — Multiple Findings, one Remediation, collective verification

**Scenario:** Three workspace drift Findings (DIL-WSP-001) were corrected in a single reconciliation operation. One Remediation covers all three.

**Canonical state:**
- `FND-2026-0010.md`, `FND-2026-0011.md`, `FND-2026-0012.md` — workspace Findings
- `RMD-2026-0005.md` — collective Remediation: reconfigure Project fields and labels

**Work Items:**
1. Implementation Issue: `RMD-2026-0005: execute workspace reconciliation` (Done)
2. Verification Issue: `RMD-2026-0005: verify reconciliation result` (In Progress)

**Findings maintain their own states:**
- `FND-2026-0010.md`: status = Resolved (after implementation)
- `FND-2026-0011.md`: status = Resolved
- `FND-2026-0012.md`: status = Resolved
- None is Verified — awaiting independent verification (Issue 2 above)

**Lesson:** One Work Item can address multiple Findings. Findings maintain their own independent states. Collective verification via second Work Item — not one Work Item per Finding.

---

### Example 4 — Waiver with approaching expiration

**Scenario:** `WVR-2026-0002.md` was approved to suspend DIL-OPS-004 for 90 days. 15 days remain until expiration.

**Canonical state:**
- `WVR-2026-0002.md`: `status: Active`, `expires_at: 2026-09-01`
- Approval Evidence: `EVD-2026-0008.md` (approval PR)
- `FND-2026-0005.md`: `status: Waived`, `waiver: WVR-2026-0002`

**In the Project (if Waiver Expiration field is configured):**
- Review Work Item: `WVR-2026-0002: review expiration and compensating controls` (Todo)
- `Waiver Expiration` field = `2026-09-01` (derived from file)
- Label: `diligence:waiver-review`

**What does NOT happen:**
- `waiver-active` label does not replace the canonical file
- Expiration field in the Project cannot be manually updated to extend deadline
- Changing Work Item status to Done does not renew the Waiver

**When it expires:**
- `WVR-2026-0002.md` → status: Expired
- `FND-2026-0005.md` → status: Acknowledged (returns to normal flow)
- `blocking_effective` returns to `true` if the Check is blocking
- Renewal = new `WVR-2026-0003.md` with new approval Evidence

**Lesson:** Canonical Waiver lives in the file. Project can signal alert. Approval and renewal always via file with Evidence — never via label or status.

---

### Example 5 — Remediation implemented, verification pending

**Scenario:** `RMD-2026-0003` was implemented via PR. The developer closed the implementation Issue. The Finding is not yet Verified.

**Canonical state:**
- `FND-2026-0007.md`: `status: Resolved` (condition was corrected, awaiting verification)
- `RMD-2026-0003.md`: `status: Implemented`
- PR merged with implementation Evidence: `EVD-2026-0012.md`

**In the Project:**
- Implementation Issue: Done (closed)
- Verification Issue: `RMD-2026-0003: verify implementation independently` (Todo)

**What does NOT happen:**
- `FND-2026-0007.md` does NOT go to `status: Verified` because the implementation Issue closed
- `FND-2026-0007.md` does NOT go to `status: Verified` because the PR was merged
- The Verification Queue has the verification Issue as pending

**To transition to Verified:**
1. Independent verifier (different from implementer) executes DIL-OPS-004
2. Check returns Pass
3. Evidence collected: `EVD-2026-0013.md`
4. `FND-2026-0007.md` → `status: Verified`, `verified_at: ...`, evidence: `[EVD-2026-0013]`

**Lesson:** PR merged ≠ Finding Verified. Issue Done ≠ Finding Verified. Implemented ≠ Verified. Independent verification with Evidence is mandatory.

---

## Section 26 — Future implementation matrix

| Element | Current state | Required change | Can be automated? | Pre-condition |
|---|---|---|---|---|
| Field: Artifact ID | Existing | Confirm Finding/Remediation/etc. type values in enums | Yes (WS Reconciliation) | Approved schema |
| Field: Artifact Type | Existing | Add Diligence values (Finding, Remediation, Waiver, Evidence, Check) | Yes (WS Reconciliation) | Approved schema |
| Field: Journey | Existing | Confirm "Diligence" value in enums | Yes | Approved schema |
| Field: Cycle | Existing | Add diligence-sync, diligence-async values | Yes | Approved schema |
| Field: Operation | Extended | Add Approve Waiver, Collect Evidence | Yes | Operations convergence |
| Field: Phase | Existing | Add Diligence phases (Capture, Attach, Promote, Close, Scan, Flag, Repair, Inspect) | Yes | Approved schema |
| Field: Mode | Existing | Confirm Sync/Async | Yes | Approved schema |
| Field: Blocking | Derived/New | Create as derived field (future automation reads entities and calculates) | Yes (future) | Derivation automation implemented |
| Field: Waiver Expiration | Derived/New | Create as derived field (synchronized from WVR-* file) | Yes (future) | Derivation automation implemented |
| Field: Finding Severity | Derived | Evaluate need — can be deferred; Artifact ID + Artifact Type cover routing | Partial | Sync automation + demonstrated need |
| Field: Finding Status | Derived | Evaluate need — separate from WI Status; high drift without automation | Partial | Sync automation + demonstrated need |
| Field: Check Result | Not recommended | Do not create in v1; Evidence reference in body is sufficient | Not applicable | — |
| Label: diligence | New | Create base label | Yes (WS Reconciliation) | Approved nomenclature |
| Label: diligence:investigation | New | Create operational subclassification | Yes (WS Reconciliation) | Approved labels |
| Label: diligence:remediation | New | Create operational subclassification | Yes (WS Reconciliation) | Approved labels |
| Label: diligence:verification | New | Create operational subclassification | Yes (WS Reconciliation) | Approved labels |
| Label: diligence:waiver-review | New | Create operational subclassification | Yes (WS Reconciliation) | Approved labels |
| Label: diligence:reconciliation | New | Create operational subclassification | Yes (WS Reconciliation) | Approved labels |
| Label: diligence:evidence-collection | New | Create operational subclassification | Yes (WS Reconciliation) | Approved labels |
| View: Diligence Operations | Planned | Create after Journey and Artifact Type fields configured | Partial | Fields implemented |
| View: Active Remediations | Planned | Create after Artifact Type fields configured | Partial | Fields implemented |
| View: Blocking Findings | Planned | Create after derived Blocking field available | Partial | Blocking field implemented |
| View: Waiver Reviews | Planned | Create after labels and fields configured | Partial | Labels + fields implemented |
| View: Verification Queue | Planned | Create after diligence:verification labels available | Partial | Labels implemented |
| View: Diligence History | Planned | Create after other operational Views | Yes | Operational views created |
| Issue body template | Planned | Create conceptual template for ProdOps References | No (manual initially) | Approved schema |
| PR body template | Planned | Create conceptual template for Diligence References | No (manual initially) | Approved schema |
| WS Reconciliation: Inspect | Planned | Implement reading of this document and comparison with real workspace | Partial | github-workspace.md stabilized |
| WS Reconciliation: Reconcile | Planned | Implement controlled creation with Automation First | Yes | Inspect validated + authorization |
| WS Reconciliation: Verify | Planned | Execute DIL-WSP-001 and record Evidence | Yes | Reconcile validated |
| Findings Dashboard | Planned | Create derived report from registry.yaml (Project-independent) | Yes (future) | Registry stabilized |
| Derived fields sync | Planned | Automation reading entities and writing to Project fields | Yes (future) | Fields created + stable schema |
| Waiver expiration (alert) | Planned | Periodic verification automation for expires_at with operational alert | Yes (future) | Waiver Expiration field + automation |

---

## References

→ [Knowledge Space vs. Execution Space](../../knowledge-vs-execution.md)
→ [Execution Mapping](../../execution-mapping/README.md)
→ [Work Item schema](../../execution-mapping/work-item-schema.md)
→ [Diligence Journey](README.md)
→ [Entity model](model/)
→ [Finding](model/finding.md)
→ [Check](model/check.md)
→ [Evidence](model/evidence.md)
→ [Remediation](model/remediation.md)
→ [Waiver](model/waiver.md)
→ [Check catalog](checks/catalog.yaml)
→ [Workspace Reconciliation](workspace-reconciliation.md)
→ [manifest.yaml](../../../exec/manifest.yaml)
