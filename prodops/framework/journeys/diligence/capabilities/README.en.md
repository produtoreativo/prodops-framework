# Diligence Capabilities

Capabilities are reusable competencies consumed by the Diligence cycles and by Bootstrap. They define **what is done**, not when or by whom.

**Capabilities are not cycles.** None of the Capabilities listed here have their own independent trigger. They are invoked as subroutines by the diligence-sync, diligence-async cycles, and by Bootstrap.

→ See [ontology.md](../../../ontology.md) for the canonical definition of Capability.
→ See [README.md](../README.md) for the Diligence journey overview.

---

## Capability Catalog

| Capability | Summary purpose | Consumed by |
|---|---|---|
| Backlog Synchronization | Keep OBC state consistent across all levels of the backlog hierarchy | Capture, Promote, Repair |
| Work Item Management | Create, update and close Work Items with canonical schema | Attach, Close, Repair |
| Readiness Verification | Verify prerequisites before an item advances or enters Delivery | Promote, Scan |
| Divergence Detection | Identify gaps between canonical artifacts and external tools | Scan, Flag |
| Artifact Evolution | Update management artifacts when decisions change the work state | Capture, Repair, Close |
| Workspace Reconciliation | Align GitHub Workspace to the Canonical Specification | Bootstrap, Diligence Async, Diligence Sync |

---

## Backlog Synchronization

**Definition:** Competency responsible for keeping the state of each OBC synchronized across all levels of the ProdOps backlog hierarchy and the corresponding external tools.

**Responsibility:** Ensure that the state recorded in the canonical artifact (OBC Markdown file) is correctly reflected in the Product Tracking List, Product Backlog, Icebox, Iteration Backlog, Iteration Plan and GitHub Project.

**Inputs:**
- Current OBC state (Markdown file)
- Current item state in external backlogs
- Transition criteria per backlog level

**Outputs:**
- Synchronized state between artifact and backlogs
- Block record when transition criterion is not satisfied
- Divergence report when there is an irreconcilable inconsistency automatically

**Consumer cycles:** diligence-sync (Capture, Promote), diligence-async (Repair)

**Related journeys:** Delivery (consumes synchronized backlogs), Assessment (produces decisions that trigger synchronization), Operation (produces signals that update backlogs)

**Sources of truth:**
- OBC state: `prodops/artifacts/obcs/`
- Backlog hierarchy: `prodops/framework/backlogs.md`
- Transition criteria: `prodops/framework/artifact-governance.md`

**Limits:**
- Does not prioritize the backlog — prioritization is the Product Owner's responsibility
- Does not alter the canonical OBC state — only synchronizes derived representations
- Does not create new backlog levels outside the canonical hierarchy

**Usage examples:**
- OBC transitions from Draft to Refining → Backlog Synchronization moves the item to Icebox
- OBC transitions to Committed → Backlog Synchronization moves the item to the Iteration Backlog
- Diligence Async detects item in the Iteration Plan with OBC in Draft state → Backlog Synchronization signals divergence

**Anti-patterns:**
- Moving a backlog item without verifying canonical transition criteria
- Using the GitHub Project as the source of truth for OBC state
- Synchronizing in reverse (from GitHub Project to the Markdown artifact)

---

## Work Item Management

**Definition:** Competency responsible for creating, updating, linking and closing Work Items in the Execution Space, ensuring that each Work Item respects the canonical schema and correctly references the artifact, the operation and the journey.

**Responsibility:** Maintain Execution Space traceability: each active operation on an artifact must have a Work Item with complete schema; each closed Work Item must record the delivery or conclusion; Work Items without a valid reference must be identified and corrected.

**Inputs:**
- Source artifact (OBC, Business Signal, Business Intent)
- Active operation identified
- Canonical Work Item schema

**Outputs:**
- Work Item created with filled fields: `artifact_type`, `artifact_id`, `operation`, `journey`, canonical title
- Work Item updated with correct state and references
- Work Item closed with reference to the Release Trail or operation conclusion
- Report of invalid or orphan Work Items

**Canonical title:**

```
[Artifact ID]: concise description
```

The operation and artifact type go in the Issue's fields and labels — not in the title.

**Consumer cycles:** diligence-sync (Attach, Close), diligence-async (Repair)

**Related journeys:** Delivery (creates implementation Work Items), Assessment (may initiate analysis Work Items), Operation (may initiate incident response Work Items)

**Sources of truth:**
- Canonical schema: `prodops/framework/execution-mapping/work-item-schema.md`
- N:M cardinality: `prodops/framework/knowledge-vs-execution.md`

**Limits:**
- Does not create Work Item for passive artifact (without active operation)
- Does not maintain the same Work Item indefinitely for the entire artifact lifetime — each active operation has its own
- Does not use Issue as source of truth for OBC

**Usage examples:**
- Diligence Sync — Attach: Committed OBC with active Delivery, no Work Item → Work Item Management creates Issue with complete schema
- Diligence Sync — Close: OBC transitions to Operational, Release Trail confirmed → Work Item Management closes the Issue with reference to the delivery
- Diligence Async — Repair: Work Item with invalid artifact_id → Work Item Management records divergence and escalates

**Anti-patterns:**
- Creating an Issue for each artifact (violates N:M)
- Treating absence of Issue as automatic divergence for passive artifacts
- Reusing the same Work Item for multiple distinct operations

---

## Readiness Verification

**Definition:** Competency responsible for verifying that all canonical prerequisites are satisfied before an item advances in the backlog hierarchy or enters Delivery.

**Responsibility:** Ensure that no item advances without the entry criteria of the target level being satisfied. When a criterion is not satisfied, block the transition, record the block with the missing artifact and escalate if necessary.

**Inputs:**
- Item candidate for transition
- Target level in the backlog hierarchy
- Canonical entry criteria per level
- Current OBC state and associated artifacts (BDD Feature, Reliability Plan)

**Outputs:**
- Precondition validation (all criteria satisfied)
- Block recorded (criterion not satisfied, missing artifact identified)
- Escalation (criterion requires human decision)

**Consumer cycles:** diligence-sync (Promote), diligence-async (Scan — preventive verification)

**Related journeys:** Delivery (beneficiary of the verification), Assessment (produces Reliability Plan and BDD when required)

**Sources of truth:**
- Criteria per level: `prodops/framework/backlogs.md`
- Transition criteria: `prodops/framework/artifact-governance.md`
- Reliability Plan conditional gate: `prodops/framework/backlogs.md`

**Limits:**
- Does not evaluate the business merit of the item — only verifies the presence and state of artifacts
- Does not approve OBC on its own
- Does not decide whether a Reliability Plan is necessary — only verifies its presence when it has already been decided it is necessary

**Usage examples:**
- Item candidate for Iteration Plan: Readiness Verification verifies OBC Committed + BDD Feature Committed + documented risks
- Item with risk qualifying for Reliability Plan: Readiness Verification verifies whether the Reliability Plan exists and has been reviewed
- Diligence Async — Scan: item in Iteration Plan without committed BDD Feature → Readiness Verification records divergence

**Anti-patterns:**
- Blocking item for absence of Reliability Plan when no risk trigger has been identified
- Requiring committed BDD Feature for entry into the Iteration Backlog (not a requirement — only for the Iteration Plan)
- Advancing item ignoring criteria due to deadline pressure

---

## Divergence Detection

**Definition:** Competency responsible for proactively identifying gaps, inconsistencies and divergences between the canonical state of artifacts in the Knowledge Space and the observed state in the Execution Space and external tools.

**Responsibility:** Detect drift before it causes confusion, rework or decisions based on outdated state. Distinguish legitimate absence from incomplete relationship. Do not repair during detection — only identify and characterize.

**Inputs:**
- Current state of all active OBCs (`prodops/artifacts/obcs/`)
- Current state of external backlogs and GitHub Project
- GitHub Workspace (Labels, Fields, Views, Projects)
- Canonical Specification (`prodops/framework/github-workspace.md`)
- Open Work Items and their references

**Outputs:**
- List of divergences with: affected artifact, gap type, severity, nature (legitimate absence or incomplete/invalid relationship)
- Explicit distinction between legitimate absence and real divergence
- Identification of items requiring Workspace Reconciliation

**Consumer cycles:** diligence-async (Scan, Flag)

**Related journeys:** All journeys (any journey can produce drift that Divergence Detection identifies)

**Sources of truth:**
- Canonical artifact state: `prodops/artifacts/`
- Artifact-Work Item relationship model: `prodops/framework/knowledge-vs-execution.md`
- Workspace specification: `prodops/framework/github-workspace.md`

**Limits:**
- Does not repair divergences during detection — repair belongs to the Repair phase
- Does not classify historical trails with old vocabulary as normative divergences
- Does not classify absence of Work Item as divergence when there is no active operation

**Usage examples:**
- OBC with Operational state and Work Item still open → Divergence Detection identifies: Close was not executed
- Open Work Item with artifact_id that does not correspond to any active OBC → Divergence Detection identifies: invalid reference
- Canonical label absent in GitHub → Divergence Detection identifies: Workspace Drift

**Anti-patterns:**
- Classifying every Business Signal without Issue as a divergence
- Classifying absence of Reliability Plan as divergence when item has no risk trigger
- Marking as divergence historical trails with vocabulary from a previous Framework version

---

## Artifact Evolution

**Definition:** Competency responsible for updating management artifacts (Iteration Plan, Roadmap, Product Backlog entries) when Assessment decisions, Discovery results or OBC state changes alter the work context.

**Responsibility:** Ensure that management artifacts reflect the current state of the work. Does not rewrite OBC content, BDD Features or Reliability Plans — those are modified only by the competent journeys. Updates derived representations and progress records.

**Inputs:**
- Assessment decision or Discovery result
- OBC state change
- Operation signal (incident, risk, evidence)
- Current management artifacts

**Outputs:**
- Updated Iteration Plan (entry, exit, status)
- Updated Roadmap (item state, dates, decisions)
- Updated Product Backlog (item state)
- Decision record in the corresponding artifact

**Consumer cycles:** diligence-sync (Capture, Close), diligence-async (Repair)

**Related journeys:** Assessment (produces decisions that trigger evolution), Discovery (produces results that trigger evolution), Operation (produces signals that trigger evolution), Delivery (consumes evolved artifacts)

**Sources of truth:**
- Iteration Plan: `prodops/exec/iteration-plans/`
- Roadmap: corresponding file in `prodops/exec/`
- OBC: `prodops/artifacts/obcs/`

**Limits:**
- Does not rewrite OBC content — only updates derived representations and management metadata
- Does not invent artifact content — records only what was decided by the competent journey
- Does not make decisions about OBC state — only records decisions already made

**Usage examples:**
- Assessment decides Reliability Plan is needed → Artifact Evolution records the decision in the Iteration Plan and updates the corresponding field
- OBC transitions to Operational → Artifact Evolution updates the Roadmap entry with the completion date
- Discovery concludes experiment with a decision to discontinue → Artifact Evolution updates the item status in the Product Backlog

**Anti-patterns:**
- Rewriting OBC success criteria during synchronization
- Updating the Iteration Plan with information not confirmed by any journey
- Using Artifact Evolution to correct Assessment decisions the agent considers incorrect

---

## Workspace Reconciliation

**Definition:** Competency responsible for aligning the GitHub Workspace (Labels, Custom Fields, Views, managed projects) to the Canonical Specification, detecting and correcting Workspace Drift.

**Classification: Capability — it is not a Cycle, it is not a Phase of any Cycle.**

This Capability is invoked as a subroutine. It has no independent trigger. It returns a Conformance Report to the caller.

→ **See full specification in [workspace-reconciliation.md](../workspace-reconciliation.md)**

**Responsibility:** Keep the GitHub Workspace infrastructure in conformance with the Canonical Specification, so that Diligence cycles and Delivery can operate on consistent fields, labels and projects.

**Inputs:**
- Canonical Specification (`prodops/framework/github-workspace.md`)
- Current GitHub Workspace state (read via API)

**Outputs:**
- Drift Report (Inspect)
- Corrections applied (Reconcile)
- Conformance Report: CONFORMANT / PARTIAL / NON-CONFORMANT (Verify)

**Internal steps (not Cycle Phases):** Inspect → Reconcile → Verify

**Consumer cycles:** Bootstrap, diligence-async (Repair), diligence-sync (Attach, Promote when necessary)

**Related journeys:** Delivery (depends on labels and fields for Work Items), Diligence (depends on infrastructure to operate), Bootstrap (precondition for new repositories)

**Sources of truth:**
- Canonical Specification: `prodops/framework/github-workspace.md`
- Sync manifest: `prodops/artifacts/trails/github-sync-manifest.md` (created by the product)

**Limits:**
- Does not operate on manual projects (outside the `ProdOps — ` scope)
- Inspect does not modify anything — pure read
- Reconcile never removes without confirmation
- Does not alter Knowledge Space artifact content

**Usage examples:**
- Bootstrap of new repository: Workspace Reconciliation ensures infrastructure is ready before any Delivery
- Diligence Async detects missing canonical label: Workspace Reconciliation invoked by Repair
- Diligence Sync — Attach fails due to missing required field: Workspace Reconciliation invoked before resuming Attach

**Anti-patterns:**
- Invoking Workspace Reconciliation as an independent cycle (it has no independent trigger)
- Confusing the internal steps Inspect/Reconcile/Verify with Phases of a Diligence Cycle
- Using Workspace Reconciliation to fix OBC or Work Item content
