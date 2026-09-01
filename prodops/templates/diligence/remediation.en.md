---
id: RMD-YYYY-NNNN
title: "[DESCRIPTIVE TITLE — replace]"
status: "[Proposed|Approved|In Progress|Implemented|Verified|Rejected|Cancelled]"
strategy: "[Correct|Prevent|Contain|Compensate|Migrate|Document|Reconcile|Retire]"
finding_ids:
  - "[FND-YYYY-NNNN]"
owner: "[role responsible for execution]"
priority: "[High|Medium|Low — independent of Finding severity]"
target_date: ""
work_item_references: []
expected_result: "[what the system state will look like after successful remediation]"
verification_check_id: "[DIL-CATEGORY-NNN — Check to re-execute to verify resolution]"
evidence_required: "[what must be collected to prove remediation completion]"
residual_risk: "[residual risk if Remediation is partial or cannot be fully completed]"
started_at: ""
completed_at: ""
verified_at: ""
---

<!-- → Canonical model: prodops/framework/journeys/diligence/model/remediation.md -->
<!-- → Usage instructions: prodops/artifacts/diligence/README.md -->
<!-- CRITICAL NOTE: Remediation Implemented ≠ Finding Verified. -->
<!-- Verification is an independent step, performed by someone other than the implementer, with its own Evidence. -->

# Objective

<!-- What this Remediation intends to resolve.
     Describe the expected state after completion.
     Reference the addressed Findings with context. -->

# Findings Addressed

<!-- List of Findings with a brief context for each.
     Reference by ID with relative link. E.g.:
     - [FND-2026-0001](../findings/FND-2026-0001.en.md) — 'owner' field absent in OBC feature-x
     - [FND-2026-0002](../findings/FND-2026-0002.en.md) — 'owner' field absent in OBC feature-y
     
     Note: A single Remediation can address multiple Findings (N:M relationship). -->

# Strategy

<!-- Primary strategy chosen and justification.
     Available strategies:
     - Correct: directly fix the divergent condition
     - Prevent: introduce a mechanism that prevents recurrence
     - Contain: limit the impact without eliminating the cause
     - Compensate: compensating control when direct correction is not possible
     - Migrate: move to a structure that does not have the problem
     - Document: formalize implicit or missing knowledge
     - Reconcile: align divergent representations to a single source of truth
     - Retire: eliminate the problematic artifact or element
     
     Secondary strategies (if any):
     E.g.: "Primary: Correct (fix missing fields). Secondary: Prevent (add schema validation to CI)." -->

# Plan

<!-- Planned steps to execute this Remediation.
     Specific enough to be executable.
     Include execution order when relevant.
     E.g.:
     1. Read prodops/artifacts/obcs/feature-x.md
     2. Add 'owner' field with value 'Product Context Engineer'
     3. Commit change in the current operation branch
     4. Repeat for feature-y.md
     5. Execute Check DIL-ART-004 to verify resolution -->

# Work Items

<!-- Work Items related to the execution of this Remediation.
     Reference by URL or GitHub Issue number.
     Remember: N:M relationship — a single Work Item can implement multiple Remediations.
     E.g.:
     - GitHub Issue #92: https://github.com/org/repo/issues/92
     
     If no Work Item was created (direct operation by the agent):
     - "No Work Item created — operation executed directly by Diligence" -->

# Expected Result

<!-- Expected system state after the Remediation.
     Must be specific and verifiable.
     E.g.: "Both OBC files will contain the 'owner' field with a valid value as per the canonical
            schema in prodops/framework/journeys/diligence/model/finding.md.
            Check DIL-ART-004 will return Pass for both subjects." -->

# Verification

<!-- Independent verification criterion.
     - Check to re-execute (ID and name)
     - Evidence to collect
     - Who verifies (must be different from who implemented)
     - When to verify
     
     E.g.: "Check DIL-ART-004 must return Pass for both OBCs.
            Evidence: Check output after correction (EVD-YYYY-NNNN to be created).
            Verified by: Product Context Engineer or diligence-async in the next Scan.
            Deadline: by 2026-07-25." -->

# Evidence

<!-- Evidence collected during and after the Remediation.
     Reference by EVD-YYYY-NNNN with relative link.
     
     Evidence categories for this Remediation:
     - Implementation evidence (proves the action was executed)
     - Verification evidence (proves the condition was resolved — independent)
     
     E.g.:
     - [EVD-2026-0003](../evidence/EVD-2026-0003.en.md) — snapshot of files before correction
     - [EVD-2026-0004](../evidence/EVD-2026-0004.en.md) — Check output after correction (verification) -->

# Residual Risk

<!-- If the Remediation is partial, document:
     - What remains pending
     - What risk remains after implementation
     - Whether a Follow-up Remediation is needed
     
     If the Remediation is complete: "No residual risk identified." -->

# Trail

<!-- Append-only record of decisions, state changes, and approvals.
     NEVER overwrite previous entries.
     Format:
     - YYYY-MM-DD HH:MM [role/agent]: <event> — <justification>
     
     E.g.:
     - 2026-07-23 15:00 [diligence-async]: Proposed — detected during Scan, Remediation proposed automatically
     - 2026-07-23 15:30 [Product Context Engineer]: Approved — reviewed and approved for execution
     - 2026-07-24 09:00 [Product Context Engineer]: In Progress — starting field corrections
     - 2026-07-24 09:15 [Product Context Engineer]: Implemented — fields corrected in both OBCs
     - 2026-07-24 09:30 [diligence-async]: Verified — Check DIL-ART-004 re-executed, result Pass -->
