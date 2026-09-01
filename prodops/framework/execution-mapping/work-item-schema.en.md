# Work Item Schema

A **Work Item** is any GitHub resource (Issue, PR, Discussion, Release) that represents an operation being executed on one or more Knowledge Space Artifacts.

Every Work Item must explicitly declare its canonical fields.

→ [Execution Mapping](README.en.md)
→ [Mapping Matrix](matrix.en.md)

---

## Canonical fields

### Mandatory fields

| Field | Type | Description | Example |
|---|---|---|---|
| `artifact_type` | enum | Type of the primary affected artifact | `Local OBC` |
| `artifact_id` | string | Identifier or path of the artifact | `feature-name-v2` |
| `operation` | enum | Operation being executed | `Refine` |
| `journey` | enum | ProdOps journey in progress | `Discovery` |

### Contextual fields

| Field | Type | Description | Example |
|---|---|---|---|
| `execution_mode` | enum | Execution mode | `Upstream` |
| `owner` | string | Primary responsible party | `Product Manager` |
| `status` | enum | Work Item state | `In Progress` |
| `priority` | enum | Priority | `High` |
| `release` | string | Target release (when applicable) | `v2.1.0` |
| `repository` | string | Repository containing the artifact | `product-repository` |

### Traceability fields

| Field | Type | Description | Example |
|---|---|---|---|
| `depends_on` | list | Work Items that must be completed first | `[#234, #198]` |
| `blocked_by` | list | Work Items blocking this one | `[#301]` |
| `related_artifacts` | list | Secondary artifacts also affected | `[bdd/feature-name.feature]` |

### Evidence fields

| Field | Type | Description | Example |
|---|---|---|---|
| `evidence_required` | boolean | Whether the operation should produce evidence | `true` |
| `evidence_location` | string | Path where evidence will be stored | `artifacts/obcs/feature-name-v2.md#evidence` |

---

## Canonical enums

### artifact_type
```
Business Signal
Business Intent
Global OBC
Local OBC
BDD Feature
Architecture
Iteration Plan
Reliability Plan
Release Trail
Experiment
Evidence
Risk Register
Context Capsule
# Diligence — canonical entities (added on 2026-07-24)
Finding
Remediation
Waiver
Check
```

### operation
```
# Family: Creation
Create
Capture
Define

# Family: Refinement
Refine
Update
Prototype

# Family: Review and Approval
Review
Approve
Validate

# Family: Structure
Split
Merge
Promote

# Family: Execution
Implement
Experiment
Release
Reconcile    # align real state to the declared canonical state (added on 2026-07-24)
             # primary use: Workspace Reconciliation (Diligence Capability)
             # semantics: no existing operation covers "detect and correct
             #            divergence between declared state and observed state"

# Family: Closure
Archive
Deprecate
Discard
Cancel
```

#### Rationale — Addition of `Reconcile`

The `Reconcile` operation was added on 2026-07-24 as a result of operation convergence analysis for the Diligence Journey (see
`prodops/framework/journeys/diligence/github-workspace-schema.yaml`).

No existing operation covers the semantics of "aligning real state to the declared canonical state":
- `Update` — updates content with new information; does not imply drift detection
- `Implement` — develops code; does not imply comparison against a specification
- `Validate` — verifies against criteria; it is the Verify step of the process, not the Reconcile
- `Repair` — name of a Diligence Async phase; it is not a Work Item operation

`Reconcile` has primary use in Workspace Reconciliation (a Diligence Capability) and may be used in other contexts where real state needs to be aligned to expected state in a traceable way.

**Operations NOT added and their rationale:**
- `Approve Waiver` — redundant with `Approve + Artifact Type = Waiver`; composite operations create vocabulary inconsistency in the enum
- `Collect Evidence` — redundant with `Capture + Artifact Type = Evidence`; Capture already exists and covers the semantics of recording/capturing
- `Repair` — name of a Diligence Async phase; `Implement` covers the semantics of implementing a correction as a Work Item
- `Investigate` — synonym for `Review` in the operational context; minimize vocabulary

### journey
```
Discovery
Assessment
Delivery
Operation
Diligence
```

### execution_mode
```
Upstream
Downstream
N/A
```

### status
```
Open
In Progress
Blocked
In Review
Done
Cancelled
```

### priority
```
Critical
High
Medium
Low
```

---

## GitHub Project — Recommended configuration

For the **Portfolio GitHub Project** and the **Product Repository GitHub Project**, the recommended custom fields are:

```yaml
custom_fields:
  - name: Artifact Type
    type: single_select
    options:
      # Knowledge Space — product and portfolio artifacts
      - Business Signal
      - Business Intent
      - Global OBC
      - Local OBC
      - BDD Feature
      - Architecture
      - Iteration Plan
      - Reliability Plan
      - Release Trail
      - Experiment
      - Evidence
      - Risk Register
      # Diligence — canonical entities (added on 2026-07-24)
      - Finding       # FND-YYYY-NNNN
      - Remediation   # RMD-YYYY-NNNN
      - Waiver        # WVR-YYYY-NNNN
      - Check         # DIL-CATEGORY-NNN

  - name: Artifact ID
    type: text
    description: >
      Slug or relative path of the artifact (e.g., feature-name-v2).
      For Diligence entities: FND-YYYY-NNNN, RMD-YYYY-NNNN,
      WVR-YYYY-NNNN, EVD-YYYY-NNNN, DIL-CAT-NNN.
      IDs are immutable after creation and independent of Issue numbers.

  - name: Operation
    type: single_select
    options:
      # Family: Creation
      - Create
      - Capture
      - Define
      # Family: Refinement
      - Refine
      - Update
      - Prototype
      # Family: Review and Approval
      - Review
      - Approve
      - Validate
      # Family: Structure
      - Split
      - Merge
      - Promote
      # Family: Execution
      - Implement
      - Experiment
      - Release
      - Reconcile   # added on 2026-07-24 — see rationale in the Enums section
      # Family: Closure
      - Archive
      - Deprecate
      - Discard
      - Cancel

  - name: Journey
    type: single_select
    options: [Discovery, Assessment, Delivery, Operation, Diligence]

  - name: Execution Mode
    type: single_select
    options: [Upstream, Downstream, "N/A"]

  - name: Owner
    type: text

  - name: Release
    type: text
    description: "Target version (e.g., v2.1.0)"

  - name: Evidence Required
    type: checkbox
```

#### Additional fields for the Diligence Journey

Work Items of the Diligence Journey use additional traceability fields declared in the schema `prodops/framework/journeys/diligence/github-workspace-schema.yaml`:

```yaml
diligence_fields:
  - name: Cycle
    type: single_select
    options: [diligence-sync, diligence-async, workspace-reconciliation]

  - name: Phase
    type: single_select
    options: [Capture, Attach, Promote, Close, Scan, Flag, Repair, Inspect, Reconcile, Verify]

  - name: Mode
    type: single_select
    options: [Sync, Async, Manual]
```

#### Examples — Diligence Journey

```yaml
# Example 1: Finding investigation Work Item
artifact_type: Finding
artifact_id: FND-2026-0007
operation: Review
journey: Diligence
cycle: diligence-async
phase: Scan
mode: Async
owner: Diligence Owner

# Example 2: Remediation implementation Work Item
artifact_type: Remediation
artifact_id: RMD-2026-0003
operation: Implement
journey: Diligence
cycle: diligence-async
phase: Repair
mode: Async
owner: Software Engineer

# Example 3: Post-Remediation verification Work Item
artifact_type: Remediation
artifact_id: RMD-2026-0003
operation: Validate
journey: Diligence
cycle: diligence-async
phase: Verify
mode: Async
owner: PRE  # independent verifier from the implementer

# Example 4: Waiver approval Work Item
artifact_type: Waiver
artifact_id: WVR-2026-0001
operation: Approve
journey: Diligence
cycle: diligence-async
phase: Repair
mode: Async
owner: Product Owner  # approver with authority

# Example 5: Workspace Reconciliation Work Item
artifact_type: Check
artifact_id: DIL-WSP-001
operation: Reconcile
journey: Diligence
cycle: workspace-reconciliation
phase: Reconcile
mode: Manual
owner: Platform Engineer
```

GitHub Project's native fields (`Status`, `Priority`, `Assignees`, `Milestone`) complement the custom fields above.

---

## Canonical Work Item title

A Work Item title should follow the pattern:

```
[Artifact ID]: concise description
```

The title is object-oriented — it describes what is being worked on. `Operation` and `Artifact Type` are process details that belong in labels and the body, where they can be read with context.

Examples:
```
feature-name-v2: BDD section incomplete
feature-name-v2: pre-Downstream Assessment
feature-name-v2: new composition capability
architecture-overview: new WorkerService module
platform-billing-v3: decompose into 3 Local OBCs
feature-name.feature: pre-release CI gate
SIG-089: generate Business Intent
```

---

## Canonical Work Item labels

`Operation` and `Artifact Type` are declared as labels to enable search and filter via `gh issue list` and GitHub search.

### Label pattern

```
operation:<value>       # e.g. operation:refine, operation:promote, operation:capture
artifact-type:<value>   # e.g. artifact-type:local-obc, artifact-type:business-signal
```

Values follow the canonical enums in lowercase with hyphens.

### Examples

```bash
gh issue list --label "operation:promote"
gh issue list --label "artifact-type:local-obc"
gh issue list --label "operation:capture" --label "artifact-type:business-signal"
```

### Required labels per Work Item

| Label | Required | Values |
|---|---|---|
| `operation:<value>` | Yes | enums from the `operation` family |
| `artifact-type:<value>` | Yes | enums from `artifact_type` |
| `journey:<value>` | Recommended | enums from `journey` |

---

## Validation

A Work Item is correctly structured when:
- [ ] `artifact_type` is filled with a canonical value
- [ ] `artifact_id` references an artifact that exists in the repository
- [ ] `operation` is filled with an operation allowed for that artifact type (see [Matrix](matrix.en.md))
- [ ] `journey` is filled
- [ ] The title follows the pattern `[Artifact ID]: concise description`
- [ ] Labels `operation:<value>` and `artifact-type:<value>` are present on the Issue

---

---

## Work Item lifecycle in OBC transitions

The OBC state and the Work Item state are **independent**. An OBC state transition does not automatically close or reopen a Work Item. A Work Item tracks a specific operation — when the operation ends, the Work Item closes. The OBC can continue evolving after the Work Item closes.

### Transition matrix

| OBC Transition | Expected Operation | Work Item Action |
|---|---|---|
| Draft → Refining | Explore or Refine | Create Work Item if there is an active operation; do not create if the OBC advances passively |
| Refining → Committed | Commit or Promote | Close refinement Work Item when the operation ends; record promotion if necessary |
| Committed → In Delivery | Implement | Create implementation Work Item when Delivery is started |
| In Delivery → Operational | Validate and Promote | Close completed implementation Work Items; record evidence |
| Operational → Archived | Archive | Create Work Item only for formal archiving operation if necessary |

### Principles

- **OBC state ≠ Work Item state.** An OBC may be Operational and still have open Work Items from post-operation updates.
- **An OBC transition does NOT automatically close or reopen a Work Item.** The Work Item closes when the operation it tracks ends.
- **A Work Item tracks a specific operation.** When the operation ends, the Work Item closes — regardless of the OBC state.
- **A new operation may require a new Work Item.** Previous Work Items remain as history and are NOT reopened when the OBC evolves.
- **The OBC can continue evolving after Work Items are closed.** The Work Item history accumulates in the OBC without new Work Items needing to be opened for every minor change.

---

## References

→ [Execution Mapping](README.en.md)
→ [Mapping Matrix](matrix.en.md)
→ [Knowledge vs Execution](../knowledge-vs-execution.en.md)
