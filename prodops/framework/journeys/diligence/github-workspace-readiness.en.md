# Readiness Protocol — GitHub Workspace
# Diligence Journey — ProdOps Framework

> **Version:** 1.0.0
> **Created on:** 2026-07-24
> **Status:** Specification — not implementation
> **Scope:** Prepares the Workspace Reconciliation Capability for execution
> **Normative language:** English
> **Source of truth for:** Specify → Inspect → Plan → Authorize → Reconcile → Verify sequence

---

## Section 1 — Purpose

This document prepares the Workspace Reconciliation Capability for execution.
It defines the canonical protocols for Inspect, Plan, Reconcile and Verify,
the readiness matrix of all workspace elements, the implementation
phases and the anti-patterns to avoid.

**What this document specifies:**
- The mandatory canonical sequence before any workspace creation
- The Inspect protocol as a read-only operation
- The Reconcile plan as an authorized and documented process
- The Verify protocol as confirmation with Evidence
- The readiness matrix of all fields, labels, views and templates
- The anti-patterns that violate the sequence or canonical process

**What this document does NOT specify:**
- GitHub CLI commands to execute — those belong to the authorized Reconcile Plan
- The real state of the workspace — that is the output of Inspect
- Automations or GitHub Actions — those belong to Phase E
- Canonical entities (Finding, Waiver, etc.) — those live in `artifacts/diligence/`

**The canonical implementation sequence prohibits any creation before Inspect.**

No label, field, view or template should be created in the GitHub workspace before
a formal Inspect has been executed and produced a report. Creating before
Inspecting generates risk of conflict with existing elements, label duplication,
and untrackable drift.

---

## Section 2 — Canonical sequence

The implementation sequence is mandatory and does not admit reversal:

```
Specify   ← github-workspace.md (completed)
   ↓         github-workspace-schema.yaml (completed — this step)
   ↓
Inspect   ← read-only reading of real state of GitHub workspace
   ↓         produces: drift report (Compliant / Missing / Different / etc.)
   ↓         does NOT create, does NOT modify, does NOT remove anything
   ↓
Plan      ← calculate drift from Inspect
   ↓         produces: authorized action plan (Create / Update / Deferred / etc.)
   ↓         each action has: mechanism, risk, reversibility, rollback
   ↓
Authorize ← explicit human approval is MANDATORY before any creation
   ↓         the plan is approved line by line or as a set
   ↓         without authorization = no Reconcile
   ↓
Reconcile ← creation or correction of elements per authorized plan
   ↓         Automation First: API → SDK → CLI → MCP → Web-Assisted → Manual
   ↓         each action is trackable with Evidence
   ↓
Verify    ← DIL-WSP-001 + post-Reconcile comparison with schema
   ↓         produces: Evidence (EVD-YYYY-NNNN) with before and after snapshot
   ↓         any Fail → Finding before marking Verify complete
```

### Why this order matters

**Creating before Inspecting** is a high-risk anti-pattern because:

1. **Conflict with existing elements** — The workspace may already have labels with similar
   names used by other teams in other flows. Creating without Inspecting generates
   duplication or overwrites existing conventions without traceability.

2. **Unexpected ≠ Invalid** — Elements that exist in the workspace but are not in the
   expected schema may belong to legitimate flows of other journeys. Inspecting
   first reveals these elements for conscious decision.

3. **Rollback risk without Evidence** — Without a snapshot of the state before Inspect,
   it is not possible to revert inadvertent creations with confidence. Rollback Evidence
   starts with the pre-Reconcile snapshot.

4. **Authorization without basis** — Authorizing a Reconcile without real workspace data is
   authorizing based on assumptions, not facts. Inspect produces the facts.

5. **DIL-WSP-001 requires declared state** — The verification Check compares the
   observed state with the expected state (this schema). Without intermediate Inspect, there is no
   way to produce comparable conformance Evidence.

---

## Section 3 — Inspect protocol

### What Inspect IS

Inspect is a strictly **read-only** operation that reads the real state of the
GitHub workspace and compares it with the expected state declared in
`prodops/framework/journeys/diligence/github-workspace-schema.yaml`.

Inspect produces a divergence report that serves as mandatory input
for the Reconcile Plan.

### What Inspect is NOT

- **Not creation** — no label, field, view or template is created during Inspect
- **Not modification** — no existing element is altered
- **Not removal** — no element is removed, even if Unexpected
- **Not authorization** — Inspect identifies divergences; the decision to act is human
- **Not Reconcile** — identifies drift, does not correct it

### Complete Inspect scope

| Category | What to verify |
|---|---|
| Project Fields | Existence, types, single_select options |
| Field options | Exact values of enums (Journey, Cycle, Phase, Operation, etc.) |
| Views | Existence, filters, groupings, orderings, visible fields |
| Labels | Existence and configuration of repository labels |
| Issue Templates | Existence and structure of body templates |
| PR Templates | Existence and structure of PR body templates |
| Automations | GitHub Actions and workflows related to the workspace |
| Manifest entries | References in `prodops/exec/manifest.yaml` |
| Permissions | Access permissions to the Project |

### Inspect output

The Inspect output is a Markdown file in the reports directory:

```
prodops/artifacts/diligence/reports/github-workspace-inspection-YYYY-MM-DD.md
```

### Drift taxonomy

| Classification | Definition | Implies automatic removal? |
|---|---|---|
| **Compliant** | Observed state corresponds to expected state in schema | N/A |
| **Missing** | Expected element in schema does not exist in real workspace | No — action: Create after authorization |
| **Unexpected** | Element exists in workspace but is not in expected schema | No — investigate use before deciding |
| **Different** | Element exists with configuration diverging from expected schema | No — Update after authorization |
| **Unsupported** | Expected state cannot be implemented with available API | No — Deferred + limitation documentation |
| **Unverifiable** | Inspect could not confirm the state (API inaccessible, missing permission) | No — treat as Missing for planning |

**Critical rule about Unexpected:** Unexpected elements may belong to legitimate flows
of other journeys, other teams or other projects. Unexpected does not mean
invalid. Before proposing removal of any Unexpected element, investigate:
1. Which Issues, PRs or Actions reference the element
2. Which team is owner of the element
3. Whether there are dependencies from other flows
4. The git history of the configuration file

### Inspect report template

The generated report must follow this conceptual structure:

```markdown
# GitHub Workspace Inspection Report
Date: YYYY-MM-DD
Executor: {name}
Schema: prodops/framework/journeys/diligence/github-workspace-schema.yaml
Specification: prodops/framework/journeys/diligence/github-workspace.md

## Summary
- Compliant: N
- Missing: N
- Unexpected: N
- Different: N
- Unsupported: N
- Unverifiable: N
- Total elements inspected: N

## Fields
### Expected: {field_name}
- Classification: work_item_canonical | base_existing | derived | rejected
- Status: Compliant | Missing | Different | Unsupported | Unverifiable
- Expected type: single_select | text | date | boolean
- Expected options: [list if single_select]
- Observed: {config or "NOT FOUND"}
- Notes: ...

## Labels
### Expected: {label_name}
- Status: Compliant | Missing | Different
- Expected color: {color}
- Observed: {color or "NOT FOUND"}

## Views
### Expected: {view_name}
- Status: Compliant | Missing | Different | Unsupported | Unverifiable
- Expected filter: {filter}
- Observed filter: {filter or "NOT FOUND"}
- Notes: ...

## Templates
### Expected: {template_name}
- Status: Compliant | Missing | Different
- Notes: ...

## Drift Summary
| Element | Category | Status | Recommended Action |
|---|---|---|---|
| Field: Journey | work_item_canonical | Missing | Create after authorization |
| Field: Blocking | derived | Deferred | Do not create — wait for Phase E |
| Label: diligence | approved | Missing | Create after authorization |
| ... | ... | ... | ... |

## Unexpected Elements
| Element | Type | Identified Use | Recommendation |
|---|---|---|---|
| label: xyz | Label | Issues of another flow | Do not remove — investigate |

## API Limitations Identified
- {limitation_1}
- {limitation_2}

## Evidence References
- EVD-{YYYY}-{NNNN} — workspace snapshot via GitHub API at {timestamp}

## Next Step
Produce Reconcile Plan based on this Drift Summary.
```

---

## Section 4 — Reconcile Plan

### Mandatory inputs

The Reconcile Plan requires:

1. **Declared schema** — `github-workspace-schema.yaml` (expected state)
2. **Inspect report** — drift between expected and real
3. **Human authorization** — explicit approval before any creation
4. **Automation First compliance** — declared mechanism per action

Without these four inputs, Reconcile must not be started.

### Action classification

| Action | Definition | Requires authorization |
|---|---|---|
| **Create** | Missing element — create per schema | Yes |
| **Update** | Different element — update to conform to schema | Yes |
| **Rename** | Element exists with different name — rename carefully | Yes (medium risk) |
| **Deprecate** | Element no longer needed — signal, do not remove | Yes |
| **Remove** | Unexpected element confirmed as invalid — remove with rollback | Yes (high risk) |
| **No Action** | Compliant — do not touch | N/A |
| **Manual Required** | API does not support programmatic creation — documented instruction | Yes |
| **Unsupported** | Cannot be implemented with available API/CLI | N/A — Deferred |
| **Deferred** | Implementation deferred (e.g., derived fields need automation) | N/A |

### Structure of each action in the plan

For each action in the Reconcile plan, document:

```yaml
- target: "{element name}"
  category: field | label | view | template | manifest
  action: Create | Update | Rename | Deprecate | Remove | No Action | Manual Required | Unsupported | Deferred
  current_state: "{state observed in Inspect or NOT FOUND}"
  expected_state: "{state declared in schema}"
  reason: "{why this action is necessary}"
  risk: Low | Medium | High
  reversible: true | false
  automation_mechanism: "gh api graphql | GitHub CLI project field-create | GitHub CLI label command | web-assisted | manual"
  approval_required: true
  validation_check: DIL-WSP-001
  rollback: "{how to revert if necessary}"
  evidence_required: "{EVD-YYYY-NNNN — before snapshot + API response}"
```

### Conservative removal policy

Before including any removal action in the plan:

1. Identify use — search Issues, PRs and Actions that reference the element
2. Identify owner — which team uses the element and in which flow
3. Verify dependencies — other elements that depend on the element
4. Produce Evidence — record the impact analysis as EVD-*
5. Obtain explicit authorization from the element's owner
6. Define rollback with verifiable steps
7. Verify git history to understand the origin of the element

### Automation First order

For each Reconcile action, try in this order:

1. **GitHub official API** — `gh api graphql` (Project v2) or REST API
2. **GitHub official SDK** — JavaScript SDK, Go or equivalent authorized
3. **GitHub CLI** — field, label and view creation commands for Project via `gh`
4. **MCP integration** — authorized MCP integration with creation scope
5. **Web-assisted** — human executes documented step-by-step instructions
6. **Manual instruction** — documented step-by-step; last resort; always with
   tracking Issue open for later confirmation

No action should skip steps in this order without documenting the reason.

### Known limitations to verify during Inspect

The following limitations are known or suspected and must be verified during Inspect:

| Potential limitation | What to verify | Impact if confirmed |
|---|---|---|
| Views via API | Whether GitHub API supports programmatic View creation in Project v2 | Views may need Web-Assisted creation |
| Formula type field | Whether fields with formulas (e.g., derived Blocking) are natively supported | Blocking field may need external automation |
| single_select field options via CLI | Whether `gh project field-create` supports single_select options | Option creation may need direct API |
| Permissions to create fields | Whether the token has permission to create custom fields in the Project | May require Project admin permission |
| Templates via API | Whether Issue and PR templates are programmable via API | Templates may need Web-Assisted creation |

---

## Section 5 — Verify protocol

### What Verify IS

Verify is the formal confirmation that Reconcile produced the expected state.
It is not verifying that commands returned exit code 0 — it is confirming that the real
workspace state corresponds to the declared schema.

Verify:
- Executes a new Inspect (post-Reconcile snapshot)
- Compares with the schema — each element must be Compliant
- For each Deferred element: explicitly documents what was deferred and why
- Executes DIL-WSP-001 (Workspace Schema Conforms to Declared Configuration)
- Records Evidence (EVD-YYYY-NNNN) with all mandatory components
- Updates `registry.yaml` if necessary

### What Verify is NOT

- **Not correction** — if something is wrong after Reconcile, open Finding and new Reconcile
- **Not tolerance** — Missing elements after Reconcile = Fail in DIL-WSP-001
- **Not superficial** — verify real state via API, not just command return values
- **Not automatic** — Verify requires Evidence with snapshots and explicit result

### Verify steps

1. Execute Inspect again (post-Reconcile snapshot)
2. Compare each element with the schema — all must be Compliant
3. For each element still Missing or Different: Fail in DIL-WSP-001
4. For each Deferred element: explicitly document with justification
5. Execute DIL-WSP-001 and record result (Pass / Fail / Warning)
6. If Fail or Warning: create Finding before marking Verify complete
7. Record Evidence (EVD-YYYY-NNNN) with the components below
8. Update `registry.yaml` with reference to Evidence

### Mandatory minimum Evidence for Verify

| Component | Description |
|---|---|
| `snapshot_before` | Inspect output pre-Reconcile (workspace state before) |
| `authorized_plan` | Document of approved plan with executed actions |
| `commands_or_mechanism` | Mechanism used (API calls, CLI commands, web-assisted steps) |
| `api_responses` | Real responses from API calls |
| `snapshot_after` | Inspect output post-Reconcile (workspace state after) |
| `dil_wsp_001_result` | Explicit result: Pass / Fail / Warning |
| `limitations_noted` | What could not be verified and why |
| `deferred_items` | What was explicitly deferred (derived fields, etc.) |
| `approver` | Who authorized the Reconcile |

### Finding vs. Verify

If DIL-WSP-001 returns Fail or Warning after the Reconcile:

1. **Do not mark Verify as complete** — incomplete Verify is not Verify
2. **Create Finding** — `FND-YYYY-NNNN.md` documenting the residual divergence
3. **Decide:** remediate immediately (new mini-Reconcile) or temporary Waiver
4. **Only after divergences resolved:** mark Verify as complete
5. **Exception:** Deferred elements with documented justification do not generate Fail

---

## Section 6 — Implementation phases

### Phase A — Canonical schema (completed)

Current phase — preparation of expected state:

- ✓ Operations converged (`work-item-schema.md` updated with `Reconcile`)
- ✓ Artifact types for Diligence added (Finding, Remediation, Waiver, Check)
- ✓ Fields classified in schema (base_existing, work_item_canonical, derived, rejected)
- ✓ Labels evaluated (approved, rejected, deferred)
- ✓ Views planned by implementation phase
- ✓ Templates specified (conceptual)
- ✓ `github-workspace-schema.yaml` created
- ✓ `github-workspace-readiness.md` created
- ✓ `manifest.yaml` updated

### Phase B — Inspect (next step)

Read-only snapshot of real GitHub workspace:

- Execute Inspect against GitHub workspace with adequate authentication
- Cover all scopes declared in schema (fields, labels, views, templates)
- Produce report in `prodops/artifacts/diligence/reports/`
- No creation or modification permitted in this phase

### Phase C — Reconcile without derived automation

Elements eligible for Phase C (do not require automation):

**Fields:**
- Operation options: Review, Implement, Validate, Approve, Capture, Attach, Reconcile, Promote, Close, Create, Update
- Artifact Type options: Finding, Remediation, Waiver, Evidence, Check (add if Missing)
- Journey option: Diligence (confirm if Missing)
- Cycle options: diligence-sync, diligence-async, workspace-reconciliation
- Phase options: Capture, Attach, Promote, Close, Scan, Flag, Repair, Inspect, Reconcile, Verify
- Mode options: Sync, Async, Manual

**Labels:**
- `diligence`
- `diligence:investigation`
- `diligence:remediation`
- `diligence:verification`
- `diligence:waiver-review`
- `diligence:reconciliation`

**Templates:**
- Issue body template (ProdOps References section)
- PR Remediation body template
- PR Waiver body template
- PR Verification body template

**Views:**
- Diligence Operations
- Active Remediations
- Workspace Reconciliation
- Verification Queue
- Diligence History
- Waiver Reviews (without Waiver Expiration field — acceptable for v1)

**Elements NOT eligible for Phase C:**
- `Blocking` field (requires derivation automation)
- `Waiver Expiration` field (requires synchronization automation)
- `Finding Status` field (requires synchronization automation)
- `Finding Severity` field (requires synchronization automation)
- `Blocking Findings` view (requires derived Blocking field)

### Phase D — Verify

After Reconcile of Phase C:

1. Execute Inspect again (post-Reconcile snapshot)
2. Compare with schema — all Phase C elements must be Compliant
3. For each Deferred element (derived fields): explicitly document
4. Execute DIL-WSP-001 and record result
5. Record Evidence (EVD-YYYY-NNNN) with complete components
6. If Fail: create Finding before concluding

### Phase E — Derived automation

Only after Phase D is verified and completed:

- `Blocking` field — automation that reads Check + Finding + Waiver and calculates blocking_effective
- `Waiver Expiration` field — synchronization of `expires_at` from `WVR-*.md` file to Project
- `Finding Status` field — synchronization of `status` from `FND-*.md` file to Project
- `Finding Severity` field — synchronization of `severity` from `FND-*.md` file to Project
- `Blocking Findings` view — available after derived Blocking field implemented
- Waiver expiration alerts — periodic verification of `expires_at` proximity
- Findings dashboard — independent tool that reads `registry.yaml`; no relation to Project

---

## Section 7 — Readiness matrix

| Element | Specified | Depends on Inspect | Depends on approval | Depends on automation | Ready for Reconcile |
|---|---|---|---|---|---|
| Field: Status | Yes (base_existing) | Yes | Yes | No | Phase C |
| Field: Repository | Yes (base_existing) | Yes | Yes | No | Phase C |
| Field: Owner | Yes (base_existing) | Yes | Yes | No | Phase C |
| Field: Journey | Yes (work_item_canonical) | Yes | Yes | No | Phase C |
| Field: Cycle | Yes (work_item_canonical) | Yes | Yes | No | Phase C |
| Field: Phase | Yes (work_item_canonical) | Yes | Yes | No | Phase C |
| Field: Operation | Yes (work_item_canonical) | Yes | Yes | No | Phase C |
| Field: Mode | Yes (work_item_canonical) | Yes | Yes | No | Phase C |
| Field: Artifact ID | Yes (work_item_canonical) | Yes | Yes | No | Phase C |
| Field: Artifact Type | Yes (work_item_canonical) | Yes | Yes | No | Phase C |
| Field: Blocking | Yes (derived) | Yes | Yes | Yes | Phase E |
| Field: Waiver Expiration | Yes (derived) | Yes | Yes | Yes | Phase E |
| Field: Finding Status | Yes (derived) | Yes | Yes | Yes | Phase E |
| Field: Finding Severity | Yes (derived) | Yes | Yes | Yes | Phase E |
| Field: Check Result | Rejected (v1) | N/A | N/A | N/A | No |
| Field: Finding ID | Rejected | N/A | N/A | N/A | No |
| Field: Remediation ID | Rejected | N/A | N/A | N/A | No |
| Field: Waiver ID | Rejected | N/A | N/A | N/A | No |
| Field: Check ID | Rejected | N/A | N/A | N/A | No |
| Label: diligence | Yes | Yes | Yes | No | Phase C |
| Label: diligence:investigation | Yes | Yes | Yes | No | Phase C |
| Label: diligence:remediation | Yes | Yes | Yes | No | Phase C |
| Label: diligence:verification | Yes | Yes | Yes | No | Phase C |
| Label: diligence:waiver-review | Yes | Yes | Yes | No | Phase C |
| Label: diligence:reconciliation | Yes | Yes | Yes | No | Phase C |
| Label: diligence:evidence-collection | Deferred | N/A | N/A | N/A | Deferred |
| Label: journey:diligence | Rejected | N/A | N/A | N/A | No |
| Label: artifact-type:* | Rejected | N/A | N/A | N/A | No |
| Label: operation:* | Deferred | N/A | N/A | N/A | Deferred |
| Template: Issue body | Specified | Yes | Yes | No | Phase C |
| Template: PR Remediation | Specified | Yes | Yes | No | Phase C |
| Template: PR Waiver | Specified | Yes | Yes | No | Phase C |
| Template: PR Verification | Specified | Yes | Yes | No | Phase C |
| View: Diligence Operations | Specified | Yes | Yes | No | Phase C |
| View: Active Remediations | Specified | Yes | Yes | No | Phase C |
| View: Workspace Reconciliation | Specified | Yes | Yes | No | Phase C |
| View: Verification Queue | Specified | Yes | Yes | No | Phase C |
| View: Diligence History | Specified | Yes | Yes | No | Phase C |
| View: Waiver Reviews | Specified | Yes | Yes | No | Phase C |
| View: Blocking Findings | Specified | Yes | Yes | Yes | Phase E |
| Operations enum (Reconcile) | Yes | Yes | Yes | No | Phase C |
| Artifact Type enum (Finding, etc.) | Yes | Yes | Yes | No | Phase C |
| Capability: Workspace Reconciliation | Yes (Capability) | Yes | Yes | No | Phase B/C |
| Findings Dashboard | Not specified | N/A | N/A | Yes | Phase E+ |

**Summary:** 30 elements ready for Phase C, 5 elements for Phase E, 8 elements rejected, 3 elements deferred.

---

## Section 8 — Anti-patterns

The anti-patterns below represent violations of the canonical readiness process
and implementation of the GitHub Workspace. Each has a documented consequence.

1. **Creating labels before Inspect** — Creating labels without Inspecting the real state
   generates risk of duplication with labels from other flows. Inspect reveals
   the real state; creation without Inspect is a gamble, not a process.

2. **Treating Inspect as Reconcile** — Inspect is read-only. Any creation, modification
   or removal executed during Inspect contaminates the process and makes the report
   unreliable as a snapshot of the real state.

3. **Skipping human authorization** — Executing Reconcile without explicit human approval
   creates unauthorized changes in the workspace. Authorization is not bureaucracy — it is the
   responsibility contract for each executed action.

4. **Automatically removing Unexpected elements** — Unexpected does not mean invalid.
   Automatically removing Unexpected elements destroys configurations of other legitimate
   flows. The policy is always conservative: investigate before deciding.

5. **Creating derived fields before automation** — Creating fields like Blocking, Waiver
   Expiration or Finding Status without synchronization automation creates fields with static
   values that immediately drift from the canonical entities.

6. **Manually editing the Blocking field** — Blocking is derived. Editing it in the Project
   does not alter the canonical entity. Suspending blocking requires a valid canonical Waiver.
   Manual editing = immediate drift and Finding by DIL-WSP-001.

7. **Creating Views before fields** — Views filter over fields. Creating a
   "Blocking Findings" view before having the Blocking field configured results in an
   inoperative View. Field schema first, Views after.

8. **Confusing Workspace Reconciliation with Cycle** — Workspace Reconciliation is a
   Capability invoked by the existing cycles, not an independent third Cycle.
   Classifying reconciliation Work Items with Journey = "WorkspaceReconciliation"
   is a violation of DIL-CON-001 (non-canonical vocabulary).

9. **Verifying only command exit codes** — Verify is not confirming that the CLI
   creation command returned exit 0. It is confirming via API that the element exists with the exact
   configuration expected by the schema. Exit 0 can mask incorrect configuration.

10. **Marking Verify complete with Fail in DIL-WSP-001** — Incomplete Verify is Fail.
    If DIL-WSP-001 returns Fail or Warning, create Finding before marking Verify
    as complete. A silent Fail is not Verify — it is ignoring evidence.

11. **Treating Deferred elements as Missing** — Explicitly Deferred elements
    (like derived fields waiting for automation) are different from Missing.
    Mixing the classifications inflates the number of pending items and confuses the plan.

12. **Planning Reconcile without Inspect** — Planning creation actions based only
    on the schema, without Inspect of the real state, is planning with assumptions. Inspect
    may reveal that elements already exist, exist with different configuration, or
    conflict with existing elements.

13. **Not documenting API limitations** — When the API does not support a programmatic
    creation (e.g., Views via REST), not documenting the limitation means that
    the next executor will try again and fail again. Each identified limitation
    must be documented in the Inspect report.

14. **Authorizing plan without granularity** — "I authorize the complete Reconcile" without reviewing
    each action is blind authorization. The plan must be reviewed action by action, especially
    for removals and updates that affect existing elements.

15. **Creating multiple labels for the same concept** — Creating `diligence`, `journey:diligence`
    and `journey-diligence` for the same purpose is proliferation that confuses operators
    and fragments filters. One concept = one label. The approved list in the schema is canonical.

16. **Bidirectional sync without per-field rules** — Each field has a declared
    source of truth in the schema. Bidirectional sync without per-field rules
    results in authority conflict. The schema declares unidirectional direction per field.

17. **Creating Verify Evidence without before snapshot** — Verify Evidence without the pre-
    Reconcile snapshot does not prove that Reconcile was necessary or that the state improved.
    The `snapshot_before` component is mandatory — not optional.

18. **Treating Workspace Reconciliation as a single step** — Workspace Reconciliation is
    Inspect → Plan → Authorize → Reconcile → Verify. Executing as a single step without
    separating the phases eliminates checkpoints and traceability.

19. **Ignoring Residual Risks during Inspect** — Risks identified in this document
    (like API support for Views, or field types) must be verified during
    Inspect. Ignoring them may result in a Reconcile plan with actions impossible to
    execute automatically.

20. **Confusing operation state with entity state** — Work Item Status = Done
    does not mean Finding Status = Verified. Diligence Labels identify operations,
    not canonical entity states. The schema is clear: entity state lives in the
    canonical file; operation state lives in the GitHub Work Item.

---

## Section 9 — Residual risks before Inspect

The following risks exist before a real Inspect is executed:

| ID | Risk | Level | Mitigation |
|---|---|---|---|
| RR-1 | GitHub API may not support programmatic View creation | Medium | Verify during Inspect; document as Unsupported if confirmed; use Web-Assisted |
| RR-2 | Project fields may exist with names different from expected | Medium | Inspect with case-insensitive search and synonyms; classify as Different, not Missing |
| RR-3 | Labels may conflict with existing labels from other teams | High | Inspect with exhaustive label search; conservative policy for Unexpected removal |
| RR-4 | Formula type field (derived Blocking) may not be natively supported | High | Verify available types in Project v2 during Inspect; may require external automation |
| RR-5 | Insufficient permissions to create custom fields in the Project | High | Verify permissions as part of Inspect; obtain admin permissions before Reconcile |
| RR-6 | GitHub authentication required with correct scope | High | Ensure token with scopes: project, repo, write:org before starting Inspect |
| RR-7 | Decision about operation vocabulary may need team alignment | Medium | Review operations schema with team before Reconcile; Inspect does not create — gives time for discussion |

---

## References

→ [Workspace Specification](github-workspace.md)
→ [Declarative schema](github-workspace-schema.yaml)
→ [Workspace Reconciliation](workspace-reconciliation.md)
→ [Work Item schema](../../execution-mapping/work-item-schema.md)
→ [manifest.yaml](../../../exec/manifest.yaml)
→ [Check catalog](checks/catalog.yaml)
→ [Ontology](../../ontology.md)
→ [Glossary](../../glossary.md)
