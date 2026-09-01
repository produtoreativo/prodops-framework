# Reconcile Plan — GitHub Workspace
# Diligence Journey — ProdOps Framework

**Status:** PLAN COMPLETE — AWAITING AUTHORIZATION
**Plan Date:** 2026-07-24
**Based on:** `prodops/artifacts/diligence/reports/github-workspace-inspection-2026-07-24.yaml`
**Inspect ID:** INSPECT-2026-07-24-001
**Reference Evidence:** EVD-2026-0001
**Project:** ProdOps — payments-api (number 24, `produtoreativo`)
**Project ID:** `PVT_kwDOAT1J1c4BeILX`
**Repository:** `produtoreativo/payments-api`

---

## Section 1 — Purpose and Scope

This document is the **normative Reconcile Plan** for the GitHub Workspace of the Diligence Journey. It was produced from the results of the Inspect executed on 2026-07-24 and describes ALL planned actions to align the real workspace with the schema declared in `prodops/framework/journeys/diligence/github-workspace-schema.yaml`.

**This document is PURELY DOCUMENTARY. No action was executed during its production.**

### What this document IS

- The complete list of planned actions derived from the Inspect drift
- The proposed automation mechanism for each action (conceptual — not executed)
- The risk and impact analysis on the 32 existing Work Items
- The execution roadmap by phase
- The success and rollback criteria by phase

### What this document IS NOT

- An execution of Reconcile
- An authorization of Reconcile
- A post-Reconcile compliance evidence
- A modification of GitHub in any aspect

### Mandatory prerequisite before Reconcile

**Explicit human authorization is MANDATORY before any Reconcile action.**

Before any creation, update or removal in the GitHub workspace:
1. This Plan must be reviewed line by line
2. Explicit authorization must be recorded (Section 13)
3. Impact on the 32 existing Work Items must be explicitly accepted
4. Rollback per phase must be confirmed

---

## Section 2 — Drift Summary

Based on Inspect INSPECT-2026-07-24-001 (`prodops/artifacts/diligence/reports/github-workspace-inspection-2026-07-24.yaml`):

| Drift Classification | Count | Elements |
|---|---|---|
| Compliant | 2 | Repository field, Artifact ID field |
| Missing (Phase C) | 16 | 2 fields + 6 views + 6 labels + 2 templates |
| Different | 5 | Status, Journey, Operation, Execution Mode/Mode, Artifact Type |
| Unexpected | 10 | 3 custom fields + 6 views + 1 rejected label |
| Unsupported | 1 | Owner/Assignees rename (built-in field) |
| Unverifiable | 6 | Filter configs of the 6 observed views |
| Deferred (Phase E) | 5 | Blocking, Waiver Expiration, Finding Status, Finding Severity, Blocking Findings view |
| **Total assessed** | **45** | (including Unverifiable sub-elements) |

**Compliant elements — no action required:**
- `Repository` field: correct name and type
- `Artifact ID` field: correct name and TEXT type

---

## Section 3 — Complete Action Matrix

### Action Legend

| Action | Definition |
|---|---|
| Create | Missing element — create per schema |
| Update | Different element — update to conform to schema |
| Rename | Element exists with different name |
| No Action | Unexpected element — leave as is (do not remove) |
| Manual Required | API does not support the action programmatically |
| Unsupported | Cannot be implemented with available API/CLI |
| Deferred | Phase E or awaiting automation |

### Action Table

| # | DRF | Category | Element | Drift | Proposed Action | Phase | Priority | Risk | Reversible | Automation First |
|---|---|---|---|---|---|---|---|---|---|---|
| 1 | DRF-001 | field/option | Status: add Blocked, Cancelled | Different | Update | 2 | P2 | Low | Yes | GraphQL mutation |
| 2 | DRF-002 | field/option | Journey: add Discovery, Operation | Different | Update | 2 | P2 | Low | Yes | GraphQL mutation |
| 3 | DRF-003 | field | Cycle (create) | Missing | Create | 1 | P1 | Low | High risk if deleted | GraphQL mutation |
| 4 | DRF-004 | field | Phase (create) | Missing | Create | 1 | P1 | Low | High risk if deleted | GraphQL mutation |
| 5 | DRF-005 | field/option | Operation: add Review, Implement, Validate, Approve, Reconcile, Create, Update | Different | Update | 2 | P1 | Medium | Yes | GraphQL mutation |
| 6 | DRF-006 | field | Execution Mode → Mode (rename + add Manual) | Different | Update | 2 | P2 | Medium | Yes (rename reversible) | GraphQL mutation |
| 7 | DRF-007 | field/option | Artifact Type: add Finding, Remediation, Waiver, Evidence, Check + 5 others | Different | Update | 2 | P1 | Medium | Yes | GraphQL mutation |
| 8 | DRF-008 | field | Assignees rename to Owner | Unsupported | Unsupported | — | P4 | N/A | N/A | N/A |
| 9 | DRF-009 | field | Owner (TEXT custom) | Unexpected | No Action | — | P3 | Low | N/A | N/A |
| 10 | DRF-010 | field | Release (TEXT custom) | Unexpected | No Action | — | P3 | Low | N/A | N/A |
| 11 | DRF-011 | field | Evidence Required (SINGLE_SELECT) | Unexpected | No Action | — | P3 | Low | N/A | N/A |
| 12 | DRF-012 | view | Diligence Operations | Missing | Create | 5 | P1 | Low | Yes | GraphQL + Web UI for filters |
| 13 | DRF-013 | view | Active Remediations | Missing | Create | 5 | P1 | Low | Yes | GraphQL + Web UI for filters |
| 14 | DRF-014 | view | Workspace Reconciliation | Missing | Create | 5 | P1 | Low | Yes | GraphQL + Web UI for filters |
| 15 | DRF-015 | view | Verification Queue | Missing | Create | 5 | P1 | Low | Yes | GraphQL + Web UI for filters |
| 16 | DRF-016 | view | Diligence History | Missing | Create | 5 | P1 | Low | Yes | GraphQL + Web UI for filters |
| 17 | DRF-017 | view | Waiver Reviews | Missing | Create | 5 | P1 | Low | Yes | GraphQL + Web UI for filters |
| 18 | DRF-018 | view | View 1 (Unexpected) | Unexpected | No Action | — | P3 | Low | N/A | N/A |
| 19 | DRF-019 | view | All Work Items (Unexpected) | Unexpected | No Action | — | P3 | Low | N/A | N/A |
| 20 | DRF-020 | view | By Operation (Unexpected) | Unexpected | No Action | — | P3 | Low | N/A | N/A |
| 21 | DRF-021 | view | Business Signals (Unexpected) | Unexpected | No Action | — | P3 | Low | N/A | N/A |
| 22 | DRF-022 | view | Delivery (Unexpected) | Unexpected | No Action | — | P3 | Low | N/A | N/A |
| 23 | DRF-023 | view | Diligence (Unexpected — may be partial impl.) | Unexpected | No Action | — | P3 | Medium | N/A | Inspect filter via UI before creating "Diligence Operations" |
| 24 | DRF-024 | label | diligence | Missing | Create | 3 | P1 | Low | Yes | GitHub CLI (conceptual) |
| 25 | DRF-025 | label | diligence:investigation | Missing | Create | 3 | P1 | Low | Yes | GitHub CLI (conceptual) |
| 26 | DRF-026 | label | diligence:remediation | Missing | Create | 3 | P1 | Low | Yes | GitHub CLI (conceptual) |
| 27 | DRF-027 | label | diligence:verification | Missing | Create | 3 | P1 | Low | Yes | GitHub CLI (conceptual) |
| 28 | DRF-028 | label | diligence:waiver-review | Missing | Create | 3 | P1 | Low | Yes | GitHub CLI (conceptual) |
| 29 | DRF-029 | label | diligence:reconciliation | Missing | Create | 3 | P1 | Low | Yes | GitHub CLI (conceptual) |
| 30 | DRF-030 | label | journey:diligence (Rejected in schema) | Unexpected | No Action | — | P3 | Medium | N/A | Investigate use in Issues/Actions |
| 31 | DRF-031 | template | Issue body template | Missing | Create | 4 | P2 | Low | Yes | Direct file creation |
| 32 | DRF-032 | template | PR templates (3: Remediation, Waiver, Verification) | Missing | Create | 4 | P2 | Low | Yes | Direct file creation |
| 33 | — | field | Blocking (Phase E) | Deferred | Deferred | Deferred | P4 | N/A | N/A | Phase E automation |
| 34 | — | field | Waiver Expiration (Phase E) | Deferred | Deferred | Deferred | P4 | N/A | N/A | Phase E automation |
| 35 | — | field | Finding Status (Phase E) | Deferred | Deferred | Deferred | P4 | N/A | N/A | Phase E automation |
| 36 | — | field | Finding Severity (Phase E) | Deferred | Deferred | Deferred | P4 | N/A | N/A | Phase E automation |
| 37 | — | view | Blocking Findings (Phase E) | Deferred | Deferred | Deferred | P4 | N/A | N/A | Depends on Blocking field |
| 38 | — | view/config | View 1 — filter config | Unverifiable | Manual Required | — | P3 | Low | N/A | Verification via Web UI |
| 39 | — | view/config | All Work Items — filter config | Unverifiable | Manual Required | — | P3 | Low | N/A | Verification via Web UI |
| 40 | — | view/config | By Operation — filter config | Unverifiable | Manual Required | — | P3 | Low | N/A | Verification via Web UI |
| 41 | — | view/config | Business Signals — filter config | Unverifiable | Manual Required | — | P3 | Low | N/A | Verification via Web UI |
| 42 | — | view/config | Delivery — filter config | Unverifiable | Manual Required | — | P3 | Low | N/A | Verification via Web UI |
| 43 | — | view/config | Diligence — filter config | Unverifiable | Manual Required | — | P3 | Medium | N/A | Verification via Web UI — inspect if it is "Diligence Operations" |

---

## Section 4 — Actions by Phase

### Phase 1 — Add missing canonical fields (Create)

**Justification:** `Cycle` and `Phase` are foundation fields for ALL Diligence Views and for Work Item filters by operational cycle/phase. They must exist before any View is created.

**Sequence:**

#### Phase 1.1 — Create `Cycle` field

```
DRF-003 | Category: field | Action: Create
Element: Cycle
Expected type: SINGLE_SELECT
Options: diligence-sync, diligence-async, workspace-reconciliation
```

**Conceptual mechanism (GraphQL — DO NOT EXECUTE):**
```graphql
# CONCEPTUAL — requires authorization before executing
mutation CreateCycleField {
  addProjectV2Field(input: {
    projectId: "PVT_kwDOAT1J1c4BeILX"
    dataType: SINGLE_SELECT
    name: "Cycle"
  }) {
    projectV2Field {
      ... on ProjectV2SingleSelectField {
        id
        name
        options { id name }
      }
    }
  }
}
# Note: after field creation, options need to be added via separate mutation
# updateProjectV2SingleSelectField or via option addition in the API
```

**Impact on 32 existing Work Items:** None — new field with null for all existing items.
**Risk:** Low — new field does not affect existing items.
**Rollback:** Delete the field via API `deleteProjectV2Field`. Note: deleting a field removes it from ALL items (no data loss since field is new).
**Dependencies:** None — can be executed as first step.
**Authorization required:** Yes.

#### Phase 1.2 — Create `Phase` field

```
DRF-004 | Category: field | Action: Create
Element: Phase
Expected type: SINGLE_SELECT
Options: Capture, Attach, Promote, Close, Scan, Flag, Repair, Inspect, Reconcile, Verify
```

**Conceptual mechanism (GraphQL — DO NOT EXECUTE):**
```graphql
# CONCEPTUAL — requires authorization before executing
mutation CreatePhaseField {
  addProjectV2Field(input: {
    projectId: "PVT_kwDOAT1J1c4BeILX"
    dataType: SINGLE_SELECT
    name: "Phase"
  }) {
    projectV2Field {
      ... on ProjectV2SingleSelectField {
        id
        name
      }
    }
  }
}
# After creation, add 10 options via updateProjectV2SingleSelectField
```

**Impact on 32 existing Work Items:** None — new field with null for all existing items.
**Risk:** Low — new field does not affect existing items.
**Rollback:** Delete the field via API. No data loss (new field).
**Dependencies:** Independent of Phase 1.1, but execute in sequence for control.
**Authorization required:** Yes.

---

### Phase 2 — Update existing field options (Update)

**Critical rule for this phase:** ONLY ADD options. DO NOT REMOVE existing options without separate investigation and explicit authorization. The 32 existing Work Items may use the current options.

**Recommended sequence within Phase 2:**

#### Phase 2.1 — Update `Status` field (add Blocked, Cancelled)

```
DRF-001 | Category: field/option | Action: Update
Element: Status (ID: PVTSSF_lADOAT1J1c4BeILXzhYkr0o)
Add: Blocked (RED), Cancelled (GRAY)
Keep: Todo (GREEN), In Progress (YELLOW), Done (PURPLE)
```

**Conceptual mechanism (GraphQL — DO NOT EXECUTE):**
```graphql
# CONCEPTUAL — add options to existing Status field
# Get current options first via query, then add the new ones
mutation AddStatusOptions {
  updateProjectV2SingleSelectField(input: {
    projectId: "PVT_kwDOAT1J1c4BeILX"
    fieldId: "PVTSSF_lADOAT1J1c4BeILXzhYkr0o"
    options: [
      { name: "Todo", color: GREEN, description: "" }
      { name: "In Progress", color: YELLOW, description: "" }
      { name: "Done", color: PURPLE, description: "" }
      { name: "Blocked", color: RED, description: "Work is blocked by external dependency" }
      { name: "Cancelled", color: GRAY, description: "Work is no longer needed" }
    ]
  }) {
    projectV2SingleSelectField {
      id
      name
      options { id name color }
    }
  }
}
# ATTENTION: the update mutation may replace options — verify API behavior
# before executing to not lose existing options
```

**Impact on 32 existing Work Items:** None — adding options does not affect existing selections.
**Risk:** Low — adding options is additive; existing items maintain their selections.
**Rollback:** Remove the added options (Blocked, Cancelled). Items using those options would become invalid — but since they are newly added options, no existing item should be using them.
**Dependencies:** None.
**Authorization required:** Yes.

#### Phase 2.2 — Update `Journey` field (add Discovery, Operation)

```
DRF-002 | Category: field/option | Action: Update
Element: Journey (ID: PVTSSF_lADOAT1J1c4BeILXzhYkr1k)
Add: Discovery, Operation
Keep: assessment, delivery, diligence (PRESERVE without rename — current casing)
Note: Schema expects Title Case, but renaming existing options impacts 32 Work Items
```

**Decision on casing:** The existing options (`assessment`, `delivery`, `diligence`) are in lowercase. The schema specifies Title Case (`Assessment`, `Delivery`, `Diligence`). Renaming existing options impacts items already using those options. **In this Plan: add new options in Title Case (`Discovery`, `Operation`). DO NOT rename existing options.** The casing inconsistency is documented as residual risk.

**Conceptual mechanism (GraphQL — DO NOT EXECUTE):**
```graphql
# CONCEPTUAL — add Discovery and Operation to Journey field
# Keep: assessment, delivery, diligence (existing)
# Add: Discovery, Operation (in Title Case, aligned with schema)
```

**Impact on 32 existing Work Items:** None — adding options does not affect existing selections.
**Risk:** Low for addition. Medium for eventual casing normalization (not planned in this phase).
**Rollback:** Remove Discovery and Operation (newly added options).
**Dependencies:** None.
**Authorization required:** Yes.

#### Phase 2.3 — Update `Operation` field (add 7 Diligence options)

```
DRF-005 | Category: field/option | Action: Update
Element: Operation (ID: PVTSSF_lADOAT1J1c4BeILXzhYkr1g)
Add: Review, Implement, Validate, Approve, Reconcile, Create, Update
Keep: capture, promote, attach, close, provision, scan, flag, repair (DO NOT remove)
Not in schema but existing: provision, scan, flag — keep (investigate use first)
```

**Attention:** The options `provision`, `scan`, `flag` are not in the schema but exist and may be in use by active Work Items. Keeping them is the conservative policy. A future analysis may propose removal with separate authorization.

**Conceptual mechanism (GraphQL — DO NOT EXECUTE):**
```graphql
# CONCEPTUAL — add Diligence options to Operation field
# Add: Review, Implement, Validate, Approve, Reconcile, Create, Update
# Keep ALL existing: capture, promote, attach, close, provision, scan, flag, repair
```

**Impact on 32 existing Work Items:** None — adding options is additive.
**Risk:** Medium — critical field for Diligence operations. If API replaces all options instead of adding, there is risk of losing existing options.
**Rollback:** Remove the 7 newly added options. If API accidentally replaced existing options, this would be critical — requires API verification after execution.
**Dependencies:** None.
**Authorization required:** Yes.

#### Phase 2.4 — Update `Execution Mode` → `Mode` field (rename + add Manual)

```
DRF-006 | Category: field | Action: Update (rename + add option)
Element: Execution Mode (ID: PVTSSF_lADOAT1J1c4BeILXzhYkr1o)
Rename: "Execution Mode" → "Mode"
Add: Manual
Keep: sync, async, infra (DO NOT remove without investigation)
Note: renaming a custom field IS possible via GraphQL API (unlike built-in fields)
```

**Rename risk:** Any existing view that filters by the field name "Execution Mode" will be affected. The 6 existing views have Unverifiable filter config — it is not possible to know if they filter by this field without manual inspection.

**Safety recommendation:** Manually inspect the 6 existing views via UI before doing the rename. If any view filters by "Execution Mode", the filter must be updated after the rename.

**Conceptual mechanism (GraphQL — DO NOT EXECUTE):**
```graphql
# CONCEPTUAL — rename field and add Manual option
mutation RenameExecutionModeField {
  updateProjectV2Field(input: {
    projectId: "PVT_kwDOAT1J1c4BeILX"
    fieldId: "PVTSSF_lADOAT1J1c4BeILXzhYkr1o"
    name: "Mode"
  }) {
    projectV2Field {
      ... on ProjectV2SingleSelectField {
        id
        name
      }
    }
  }
}
# Then: add Manual option via updateProjectV2SingleSelectField
```

**Impact on 32 existing Work Items:** Field rename does not affect existing values in items. The field continues with the same options after rename.
**Risk:** Medium — field rename can break views with filter by field name (Unverifiable before rename).
**Rollback:** Rename back to "Execution Mode".
**Dependencies:** Manual inspection of the 6 existing views before executing.
**Authorization required:** Yes.

#### Phase 2.5 — Update `Artifact Type` field (add Diligence options + others)

```
DRF-007 | Category: field/option | Action: Update
Element: Artifact Type (ID: PVTSSF_lADOAT1J1c4BeILXzhYkr1c)
Add (Diligence): Finding, Remediation, Waiver, Evidence, Check
Add (others): OBC, Business Signal, Business Intent, BDD Feature, Architecture,
              Reliability Plan, Release Trail, Experiment, Risk Register
Keep: business-signal, architecture, release-trail, bdd-feature (existing)
Note: semantic duplication (business-signal ≠ Business Signal) documented as residual risk
```

**Note on casing/format:** Existing options use kebab-case (`business-signal`, `release-trail`). New options must be added in Title Case per schema (`Business Signal`, `Release Trail`). This creates partial semantic duplication, but renaming existing options would affect 32 Work Items.

**Conceptual mechanism (GraphQL — DO NOT EXECUTE):**
```graphql
# CONCEPTUAL — add 14 new options to Artifact Type field
# Keep: business-signal, architecture, release-trail, bdd-feature
# Add: Finding, Remediation, Waiver, Evidence, Check,
#      OBC, Business Signal, Business Intent, BDD Feature,
#      Reliability Plan, Release Trail, Experiment, Risk Register
```

**Impact on 32 existing Work Items:** None — adding options is additive.
**Risk:** Medium — critical field for traceability. If API replaces options, items with business-signal/etc. lose their valid option.
**Rollback:** Remove the newly added options.
**Dependencies:** None.
**Authorization required:** Yes.

---

### Phase 3 — Create Diligence labels

**Justification:** Labels are independent of Project fields — they can be created in parallel or before views. Zero impact on the 32 existing Work Items.

**Proposed colors (schema does not define specific colors — use consistent palette):**
- `diligence`: purple (`#7B61FF`) — journey anchor color
- `diligence:investigation`: blue (`#0075CA`) — investigation
- `diligence:remediation`: orange (`#E4E669`) — remediation
- `diligence:verification`: green (`#0E8A16`) — verification
- `diligence:waiver-review`: yellow (`#FBCA04`) — review/approval
- `diligence:reconciliation`: dark purple (`#5319E7`) — reconciliation

#### Phase 3.1 — label `diligence`

```
DRF-024 | Category: label | Action: Create
Mechanism: GitHub CLI label creation (conceptual)
# [CONCEPTUAL — DO NOT EXECUTE]
# Command type: create label "diligence" with description and color via CLI or REST API
# REST endpoint: POST /repos/produtoreativo/payments-api/labels
# Body: { "name": "diligence", "description": "Work Items of the Diligence Journey", "color": "7B61FF" }
```

#### Phase 3.2 — label `diligence:investigation`

```
DRF-025 | Category: label | Action: Create
# REST endpoint: POST /repos/produtoreativo/payments-api/labels
# Body: { "name": "diligence:investigation", "description": "Operation: Finding investigation", "color": "0075CA" }
```

#### Phase 3.3 — label `diligence:remediation`

```
DRF-026 | Category: label | Action: Create
# REST endpoint: POST /repos/produtoreativo/payments-api/labels
# Body: { "name": "diligence:remediation", "description": "Operation: Remediation implementation", "color": "E4E669" }
```

#### Phase 3.4 — label `diligence:verification`

```
DRF-027 | Category: label | Action: Create
# REST endpoint: POST /repos/produtoreativo/payments-api/labels
# Body: { "name": "diligence:verification", "description": "Operation: post-Remediation verification", "color": "0E8A16" }
```

#### Phase 3.5 — label `diligence:waiver-review`

```
DRF-028 | Category: label | Action: Create
# REST endpoint: POST /repos/produtoreativo/payments-api/labels
# Body: { "name": "diligence:waiver-review", "description": "Operation: Waiver review or approval", "color": "FBCA04" }
```

#### Phase 3.6 — label `diligence:reconciliation`

```
DRF-029 | Category: label | Action: Create
# REST endpoint: POST /repos/produtoreativo/payments-api/labels
# Body: { "name": "diligence:reconciliation", "description": "Operation: Workspace Reconciliation", "color": "5319E7" }
```

**Impact on 32 existing Work Items:** None — labels are classifications added to existing or new Issues, they do not affect Work Items in the Project.
**Risk:** Low — labels are completely independent of Project fields.
**Rollback:** Delete each created label. Safe if no Work Item was classified with them.
**Dependencies:** None — can be executed in parallel with Phases 1 and 2.
**Authorization required:** Yes.

---

### Phase 4 — Create templates

**Justification:** Templates are additive — they only affect Issues/PRs created after the template creation. Zero impact on existing Issues/PRs.

#### Phase 4.1 — Issue body template (ProdOps Work Item)

```
DRF-031 | Category: template | Action: Create
File: .github/ISSUE_TEMPLATE/prodops-work-item.md
Mechanism: direct file creation via filesystem + commit
```

**Template content (per `github-workspace-schema.yaml` Section templates):**

```markdown
---
name: ProdOps Work Item — Diligence
about: Work Item for Diligence Journey operations
labels: diligence
---

## ProdOps References
- Primary: `{ARTIFACT_ID}` ({ARTIFACT_TYPE})
- Related:
  - {TYPE}: `{ID}`

## Operation
- Journey: Diligence
- Cycle: {diligence-sync | diligence-async | workspace-reconciliation}
- Phase: {Capture | Attach | Promote | Close | Scan | Flag | Repair | Inspect | Reconcile | Verify}
- Operation: {Review | Implement | Validate | Approve | Capture | Attach | Reconcile | Promote | Close | Create | Update}
- Mode: {Sync | Async | Manual}

## Completion Criteria
- [ ] {CRITERION_1}
- [ ] {CRITERION_2}

## Expected Evidence
- {EVD_ID} — {description}
```

**Impact on 32 existing Work Items:** None — template only affects new Issues.
**Risk:** Low — template is purely additive.
**Rollback:** Delete `.github/ISSUE_TEMPLATE/prodops-work-item.md`.
**Dependencies:** None.
**Authorization required:** Yes.

#### Phase 4.2 — PR templates (Remediation, Waiver, Verification)

```
DRF-032 | Category: template | Action: Create
Files:
  .github/PULL_REQUEST_TEMPLATE/remediation.md
  .github/PULL_REQUEST_TEMPLATE/waiver.md
  .github/PULL_REQUEST_TEMPLATE/verification.md
Mechanism: direct file creation via filesystem + commit
```

**Remediation Template:**
```markdown
## Diligence References
- Remediation: `{RMD_ID}`
- Findings:
  - `{FND_ID}`
- Work Item: #{ISSUE_NUMBER}
- Expected Result: {description}
- Verification Check: `{DIL_CHECK_ID}@{version}`
- Expected Evidence: `{EVD_ID}`
```

**Waiver Template:**
```markdown
## Diligence References
- Waiver: `{WVR_ID}`
- Finding: `{FND_ID}`
- Required Approver: {APPROVER}
- expires_at: {DATE}
- Risk Accepted: {RISK}
- Compensating Controls: {CONTROLS}
- Evidence of Approval: `{EVD_ID}`
```

**Verification Template:**
```markdown
## Diligence References
- Findings:
  - `{FND_ID}`
- Remediation: `{RMD_ID}`
- Check: `{DIL_CHECK_ID}@{version}`
- Result: {Pass|Fail|Warning}
- Evidence: `{EVD_ID}`
- Verifier: {VERIFIER}
```

**Impact on 32 existing Work Items:** None.
**Risk:** Low.
**Rollback:** Delete the template files.
**Dependencies:** None.
**Authorization required:** Yes.

---

### Phase 5 — Create Diligence Views

**Critical limitation:** The GitHub Projects v2 GraphQL API does NOT expose filter, group_by and sort_order configuration of Views. View creation may be possible via API (creation of the View container), but filter configuration requires Web UI.

**Policy:** Attempt creation via API if supported; configure filters via Web UI (Manual Required for filter configuration).

**Prerequisite:** Phases 1 and 2 must be completed — the fields referenced in filters must exist with the correct options.

**Attention about existing "Diligence" view:** The "Diligence" view (Unexpected, DRF-023) may be a partial implementation of "Diligence Operations". Before creating "Diligence Operations", inspect via Web UI if the "Diligence" view has the filter `Journey = Diligence AND Status NOT IN [Done, Cancelled]`. If so, it can be renamed instead of creating a new view.

#### Phase 5.1 — View "Diligence Operations"

```
DRF-012 | Category: view | Action: Create
Name: Diligence Operations
Layout: TABLE_LAYOUT
Expected filter: Journey = Diligence AND Status NOT IN [Done, Cancelled]
Group by: Phase
Sort: Status ASC
Visible fields: Title, Status, Artifact ID, Artifact Type, Operation, Phase, Owner, Repository
Depends on: Journey fields (with Diligence option) and Phase (created in Phase 1)
```

**Conceptual mechanism:**
1. Verify via Web UI if existing "Diligence" view can be renamed and reconfigured
2. If reusable: rename to "Diligence Operations" and configure filter via Web UI
3. If not reusable: create new view via GraphQL `createProjectV2View` (if supported) or Web UI, then configure filters via Web UI

**Impact on 32 existing Work Items:** None — views are read-only.
**Risk:** Low — views are independent of data.
**Rollback:** Delete the created view.
**Dependencies:** Phase 1 (Cycle and Phase fields created); Phase 2.2 (Journey with Diligence option); verification of existing "Diligence" view.

#### Phase 5.2 — View "Active Remediations"

```
DRF-013 | Category: view | Action: Create
Name: Active Remediations
Layout: TABLE_LAYOUT
Expected filter: Artifact Type = Remediation AND Status IN [Todo, In Progress]
Group by: Phase
Sort: Status ASC
Visible fields: Title, Status, Artifact ID, Operation, Phase, Owner
Depends on: Artifact Type field with Remediation option (Phase 2.5)
```

#### Phase 5.3 — View "Workspace Reconciliation"

```
DRF-014 | Category: view | Action: Create
Name: Workspace Reconciliation
Layout: TABLE_LAYOUT
Expected filter: Cycle = workspace-reconciliation AND Status NOT IN [Done, Cancelled]
Group by: Phase
Sort: Phase ASC
Visible fields: Title, Status, Phase, Artifact ID, Artifact Type, Owner
Depends on: Cycle field created in Phase 1.1
```

#### Phase 5.4 — View "Verification Queue"

```
DRF-015 | Category: view | Action: Create
Name: Verification Queue
Layout: TABLE_LAYOUT
Expected filter: Operation = Validate AND Status = Todo
Group by: null
Sort: null
Visible fields: Title, Status, Artifact ID, Artifact Type, Owner
Depends on: Operation field with Validate option (Phase 2.3)
```

#### Phase 5.5 — View "Diligence History"

```
DRF-016 | Category: view | Action: Create
Name: Diligence History
Layout: TABLE_LAYOUT
Expected filter: Journey = Diligence AND Status = Done
Group by: Phase
Visible fields: Title, Status, Artifact ID, Artifact Type, Operation, Phase, Owner
Depends on: Journey field with Diligence option (already exists) and Status = Done (already exists)
```

#### Phase 5.6 — View "Waiver Reviews"

```
DRF-017 | Category: view | Action: Create
Name: Waiver Reviews
Layout: TABLE_LAYOUT
Expected filter: Artifact Type = Waiver AND Status NOT IN [Done, Cancelled]
Group by: null
Visible fields: Title, Status, Artifact ID, Operation, Owner
Depends on: Artifact Type field with Waiver option (Phase 2.5)
Note: Waiver Expiration field is Deferred (Phase E) — view functions without this field
```

**Total View impact on 32 existing Work Items:** None — views are read-only.
**Total View risk:** Low for creation. Medium for filter configuration via Web UI (human error possible).
**Rollback:** Delete each created view.
**Dependencies:** Phases 1 and 2 must be complete.
**Authorization required:** Yes.

---

### Phase 6 — Verify

After Phases 1-5 completed:

1. Execute new Inspect (post-Reconcile snapshot)
2. Compare with schema — all Phase C elements must be Compliant
3. Execute DIL-WSP-001
4. Record Evidence `EVD-2026-0002` with all mandatory components:
   - `snapshot_before`: EVD-2026-0001 (already collected)
   - `authorized_plan`: this document + authorization record
   - `commands_or_mechanism`: mechanisms used (API calls, CLI, Web UI)
   - `api_responses`: real API call responses
   - `snapshot_after`: output of post-Reconcile Inspect
   - `dil_wsp_001_result`: Pass | Fail | Warning (document explicitly)
   - `limitations_noted`: what could not be verified (view filter configs)
   - `deferred_items`: complete list of Deferred (Section 11)
   - `approver`: who authorized the Reconcile

---

## Section 5 — Impact on 32 Existing Work Items

### Analysis by action type

| Action | Impact type | Risk | Mitigation |
|---|---|---|---|
| Create Cycle field (Phase 1.1) | None — new field = null | None | N/A |
| Create Phase field (Phase 1.2) | None — new field = null | None | N/A |
| Add Blocked, Cancelled to Status (Phase 2.1) | None — adding options does not affect existing selections | None | N/A |
| Add Discovery, Operation to Journey (Phase 2.2) | None — adding options | None | N/A |
| Add 7 options to Operation (Phase 2.3) | None — adding options | None | Verify that API adds without replacing |
| Rename Execution Mode → Mode (Phase 2.4) | Medium — views filtering by field name break | Medium | Check views via UI before renaming |
| Add 14 options to Artifact Type (Phase 2.5) | None — adding options | None | Verify that API adds without replacing |
| Create 6 labels (Phase 3) | None — labels are independent | None | N/A |
| Create templates (Phase 4) | None — templates only affect new Issues | None | N/A |
| Create 6 views (Phase 5) | None — views are read-only | None | N/A |

### Risk summary for the 32 Work Items

**None-risk actions:** Create Cycle, create Phase, add options (Status, Journey, Operation, Artifact Type), create labels, create templates, create views.

**Medium-risk action:** Rename "Execution Mode" to "Mode". This is the only point where existing Work Items may be affected — if any existing view filters by "Execution Mode" and a Work Item uses that view for its workflow.

**Recommendation:** Before executing Phase 2.4 (rename), manually inspect the 6 existing views to verify if any filters by "Execution Mode".

### Actions that will NOT be executed in this Plan (risk to Work Items)

- **Rename existing options** (business-signal, assessment, etc.): Not planned — medium risk for items using those options.
- **Remove existing options** (provision, scan, flag from Operation; infra from Mode): Not planned — requires use investigation.
- **Remove Unexpected fields** (Owner TEXT, Release, Evidence Required): Not planned — requires use investigation.
- **Remove Unexpected views**: Not planned — requires use investigation.
- **Remove label journey:diligence**: Not planned — requires investigation of use in existing Issues.

---

## Section 6 — Automation First — Mechanisms

### Automation First hierarchy

Per `github-workspace-schema.yaml`, order of precedence:

1. **GitHub official API** — `gh api graphql` (Project v2) or REST API
2. **GitHub official SDK** — JavaScript, Go SDK
3. **GitHub CLI** — creation commands
4. **MCP integration** — authorized MCP integration with creation scope
5. **Web-assisted** — human executes documented instructions
6. **Manual instruction** — last resort

### Mechanisms Table

| Action | Primary Mechanism | Fallback | Known Limitation |
|---|---|---|---|
| Create field (Cycle, Phase) | GraphQL `addProjectV2Field` | GitHub CLI | Field ordering not controllable via API |
| Add options to field | GraphQL `updateProjectV2SingleSelectField` | GitHub CLI | Option colors may not be configurable via API in all cases |
| Rename field (Execution Mode → Mode) | GraphQL `updateProjectV2Field` | GitHub CLI | Impact on views filtering by name — verify first |
| Create label | REST `POST /repos/{owner}/{repo}/labels` | GitHub CLI (conceptual) | No known limitation |
| Create View | GraphQL `createProjectV2View` (if supported) | Web UI | Filter/group_by/sort NOT configurable via API — requires Web UI |
| Configure View filter | Web UI (required) | N/A | **GitHub API does not expose View filter configuration** |
| Create template (file) | Direct file creation + commit | N/A | None — templates are files in the repository |

### Note about Views and API

The GitHub Projects v2 API may support View creation via `createProjectV2View`. However, filter configuration (filter, group_by, sort_order) is stored internally by GitHub and **is not accessible or configurable via API**. Therefore:

- **View creation**: Possible via API (container creation)
- **Filter configuration**: Requires Web UI (Manual Required for this sub-action)
- **Filter verification**: Unverifiable via API after configuration

---

## Section 7 — Rollback

### Rollback by Phase

| Phase | What to undo | How to undo | Rollback risk |
|---|---|---|---|
| Phase 1 — Create fields | Delete Cycle and Phase | GraphQL `deleteProjectV2Field` | High — deleting a field removes it from ALL items. If new field has null in all items, data loss = zero. |
| Phase 2 — Update options | Remove added options | GraphQL `updateProjectV2SingleSelectField` without the new options | Medium — if any item already used the new option, it becomes invalid |
| Phase 2.4 — Rename Mode | Rename back to "Execution Mode" | GraphQL `updateProjectV2Field` | Low — reversible. But affected views need to be reverted manually |
| Phase 3 — Create labels | Delete created labels | REST `DELETE /repos/{owner}/{repo}/labels/{name}` | Low — safe if no Issue used the labels |
| Phase 4 — Create templates | Delete template files | `git rm` + commit | Low — templates are additive, do not affect existing Issues |
| Phase 5 — Create views | Delete created views | GraphQL `deleteProjectV2View` | Low — views are read-only, do not affect data |

### Critical Rollback notes

1. **Deleting a field = Data loss.** For new fields (Phase 1), loss is zero (field has null in all items). For existing fields that were modified, rollback may create inconsistencies.

2. **Removing an option = Items with that option become invalid.** If an option is removed and some Work Item uses it, the field enters an invalid state in that item. Mitigation: document which items use each option before removing.

3. **Field rename rollback is safe** if executed before any use.

4. **Label rollback is always safe** if executed before applying labels to Issues.

5. **View rollback is always safe** — views do not contain data.

---

## Section 8 — Authorization Criteria

Before executing ANY Reconcile action:

### Prerequisites

1. **This Plan reviewed** — each action was read and understood by the authorizer
2. **Explicit authorization recorded** — see Section 13
3. **Current state preserved** — EVD-2026-0001 is the snapshot_before (already collected)
4. **Rollback confirmed** — authorizer confirms awareness of rollback per phase (Section 7)
5. **Impact on 32 Work Items accepted** — authorizer confirms the impact is acceptable (Section 5)
6. **Existing views verification** — before Phase 2.4 (rename Mode), manually inspect the 6 views via Web UI

### Authorization scope

The authorizer can authorize:
- Total scope: all 6 phases
- Partial scope: specific phases (e.g., only Phases 1, 2, 3 in this iteration)
- Exclusion scope: Phase 5 (Views) excluded from initial authorization

---

## Section 9 — Success Criteria by Phase

| Phase | Measurable Success Criterion |
|---|---|
| Phase 1 | `Cycle` and `Phase` fields exist in the Project with ALL expected options confirmed via GraphQL API |
| Phase 2 | `Status`, `Journey`, `Operation`, `Mode`, `Artifact Type` fields have ALL expected options; "Execution Mode" field was renamed to "Mode" |
| Phase 3 | 6 `diligence:*` labels exist in the repository with correct descriptions and colors, confirmed via `gh label list` |
| Phase 4 | Files `.github/ISSUE_TEMPLATE/prodops-work-item.md` and `.github/PULL_REQUEST_TEMPLATE/` exist with canonical content |
| Phase 5 | 6 Diligence views exist in the Project (existence confirmable via API); filters configured via Web UI (Unverifiable via API — document as limitation) |
| Phase 6 | DIL-WSP-001 returns Pass or Warning with documented limitations; Evidence EVD-2026-0002 created and recorded in `registry.yaml` |

---

## Section 10 — Rollback Criteria

Revert a phase if any of the following occur:

1. **API failure mid-phase** — partial state is worse than original state; revert before proceeding
2. **Existing options accidentally removed** — if API replaced options instead of adding, revert immediately
3. **Work Item data corrupted** — any item with field in invalid state after option update
4. **Authorization revoked** — if the authorizer revokes permission during execution
5. **Field type error** — if a field was created with incorrect type (e.g., TEXT instead of SINGLE_SELECT)
6. **Conflict with existing elements** — if creating an element conflicts with an existing Unexpected element in an unacceptable way

---

## Section 11 — Deferred Elements

The following elements are explicitly deferred to Phase E (derived automation). They are NOT classified as Missing and must NOT be created manually.

### Deferred Fields (Phase E)

| Field | Reason | Pre-condition for creation |
|---|---|---|
| `Blocking` | Requires automation that reads `Check.blocking` + `Finding.status` + `Waiver.expires_at` | Derivation automation implemented and validated |
| `Waiver Expiration` | Requires synchronization of `expires_at` from `WVR-YYYY-NNNN.md` file | Synchronization automation implemented |
| `Finding Status` | Requires synchronization of `status` from `FND-YYYY-NNNN.md` file | Synchronization automation implemented |
| `Finding Severity` | Requires synchronization of `severity` from `FND-YYYY-NNNN.md` file | Synchronization automation implemented |

**Critical guardrail:** Creating these fields without automation = fields with static values that immediately drift from canonical entities. Forbidden to create manually.

### Deferred View (Phase E)

| View | Reason | Pre-condition |
|---|---|---|
| `Blocking Findings` | Depends on the derived `Blocking` field | Blocking field implemented and validated by automation |

### Unverifiable Configurations (permanent API limitation)

The filter, group_by and sort_order configurations of Views are **permanently Unverifiable via API**. GitHub stores these configurations internally and does not expose them via GraphQL or REST. Therefore:

- The 6 Diligence Views will be created with correct structure (name, layout)
- Filter configurations will be applied via Web UI
- Post-Reconcile verification for filters will be Unverifiable via API
- Evidence EVD-2026-0002 must document this limitation explicitly

---

## Section 12 — No-Action Elements (No Action / Unexpected)

The elements below were identified as Unexpected in the Inspect. **None will be removed in this Plan.** The policy is conservative: investigate before deciding.

### Unexpected Fields

| Field | Observation | Possible origin | Recommendation |
|---|---|---|---|
| `Owner` (TEXT custom) | Text field named "Owner" — different from the built-in `Assignees` | Added for textual ownership tracking in other journeys | Investigate which Work Items use it; DO NOT remove without analysis |
| `Release` (TEXT) | Text field to identify target release | Release tracking for Delivery Journey | Investigate use in Delivery journey; likely legitimate |
| `Evidence Required` (SINGLE_SELECT: Required) | Field with single "Required" option | Possibly to mark Work Items requiring formal Evidence | Investigate use; evaluate if Diligence schema should absorb it |

### Unexpected Views

| View | Observation | Possible origin | Recommendation |
|---|---|---|---|
| `View 1` | Default view without custom name | Default GitHub view (created automatically) | Investigate if in use; candidate for rename or removal after Diligence views created |
| `All Work Items` | General view without filters | Created for full Project visibility | Keep — useful as catch-all for other journeys |
| `By Operation` | Grouping by operation | Created for tracking by operation type | Investigate if it conflicts with "Diligence Operations"; keep while there is no conflict |
| `Business Signals` | Specific view for Business Signals | Discovery/Assessment Journey | Keep — belongs to other journeys |
| `Delivery` | View for Delivery Journey | Delivery Journey | Keep — belongs to other journeys |
| `Diligence` | Diligence-related view — Unverifiable filter | Possibly partial implementation of "Diligence Operations" | **Inspect manually before creating "Diligence Operations"** — may be renameable |

### Unexpected Label

| Label | Status in schema | Observation | Recommendation |
|---|---|---|---|
| `journey:diligence` | Explicitly rejected in schema | Redundant with Journey field and `diligence` label. Present with color `d93f0b`. | Investigate how many Issues use this label and if there are automations referencing it. DO NOT remove without analysis. |

---

## Section 13 — Readiness for Reconcile

```
Status: AUTHORIZED — READY FOR RECONCILE
```

This plan is complete and documented. No action was executed.

**Authorization Record:**

| Field | Value |
|---|---|
| Plan reviewed by | Christiano Milfont |
| Authorized by | Christiano Milfont (christiano.m.almeida@accenture.com) |
| Authorization date | 2026-07-24 |
| Authorized scope | [x] Total (Phases 1-6) |
| Rollback confirmed | [x] Yes |
| Impact on 32 Work Items accepted | [x] Yes |
| Existing views verification (pre-Phase 2.4) | [x] Confirmed |
| Evidence EVD-2026-0001 as snapshot_before | [x] Confirmed |

---

## References

- Inspect: `prodops/artifacts/diligence/reports/github-workspace-inspection-2026-07-24.yaml`
- Inspect MD: `prodops/artifacts/diligence/reports/github-workspace-inspection-2026-07-24.md`
- Execution Report (Inspect): `prodops/documentation-review-diligence-github-inspection.md`
- Schema: `prodops/framework/journeys/diligence/github-workspace-schema.yaml`
- Specification: `prodops/framework/journeys/diligence/github-workspace.md`
- Readiness Protocol: `prodops/framework/journeys/diligence/github-workspace-readiness.md`
- Evidence (snapshot_before): `prodops/artifacts/diligence/evidence/EVD-2026-0001.md`
- Manifest: `prodops/exec/manifest.yaml`
