---
id: FND-YYYY-NNNN
title: "[DESCRIPTIVE TITLE — replace]"
status: Open
severity: "[Critical|High|Medium|Low|Info]"
primary_dimension: "[Conceptual|Structural|Traceability|Operational|Temporal]"
secondary_dimensions: []
category: "[Artifact|Backlog|Work Item|Execution Mapping|Documentation|Workspace|Readiness|Reliability|Observability|Security|Release|Evidence|Governance]"
check_id: "[DIL-CATEGORY-NNN or null if detected manually]"
detected_at: "YYYY-MM-DDTHH:MM:SS-03:00"
last_detected_at: "YYYY-MM-DDTHH:MM:SS-03:00"
detected_by: "[diligence-sync|diligence-async|manual:<role>]"
owner: "[role responsible for resolution]"
target_date: ""
subjects:
  - type: "[Artifact|Work Item|Pull Request|Release|Project|View|Field|Label|Workflow|Repository|Workspace|Capability|Journey|Document|Link|Configuration]"
    reference: "[URI, path, or stable reference]"
    system: "[github|local|external]"
artifact_references: []
execution_references: []
source_of_truth: "[canonical document that defines the rule]"
impact: "[what breaks or is at risk if not resolved]"
evidence_ids: []
remediation_ids: []
waiver_ids: []
occurrence_count: 1
recurrence_of: ""
---

<!-- → Canonical model: prodops/framework/journeys/diligence/model/finding.md -->
<!-- → Usage instructions: prodops/artifacts/diligence/README.md -->

# Summary

<!-- Concise summary of the condition found — 1 to 3 lines. -->

# Condition Detected

<!-- Detailed description of the observed condition.
     What was found, where, and in what context.
     Be specific: which file, which field, which value, which state. -->

# Expected Condition

<!-- What should be true according to the source of truth.
     Cite the normative document with the full path.
     E.g.: "As per prodops/framework/ontology.md, the status field must contain one of the values: [...]" -->

# Impact

<!-- Consequences if this condition is not resolved.
     Indicate whether there is a transition blocker and which transition.
     Indicate operational, traceability, or conformance impact. -->

# Subjects

<!-- Details of the affected subjects.
     The front matter lists the types; describe each one here with full context.
     E.g.:
     - File: prodops/artifacts/obcs/feature-x.md
       Context: OBC in Draft state, 'owner' field absent since the last edit
     -->

# Evidence

<!-- Evidence collected to support this Finding.
     
     For inline Evidence (small, exclusive, not reused):
       Include the data directly here. E.g.:
       - Observed value: status="in-delivery"
       - Expected value: status="In Delivery" (as per ontology.md)
       - Observed at: 2026-07-23T14:30:00-03:00
     
     For independent Evidence (own file in evidence/):
       Reference by ID and relative link. E.g.:
       - [EVD-2026-0001](../evidence/EVD-2026-0001.en.md) — Command Output of gh issue view
     
     Do not include secrets, credentials, or sensitive data. -->

# Remediation

<!-- Planned or in-progress remediations.
     Reference by ID with relative link. E.g.:
     - [RMD-2026-0001](../remediations/RMD-2026-0001.en.md) — Correct: restore owner field
     
     If no Remediation exists yet: document the immediate possible action or the required decision. -->

# Waiver

<!-- Active waiver, if any.
     Reference by ID with relative link. E.g.:
     - [WVR-2026-0001](../waivers/WVR-2026-0001.en.md) — valid until 2026-08-01
     
     If no Waiver: leave empty or "None." -->

# Resolution

<!-- Fill in when status = Resolved or Verified.
     What was done, when, by whom.
     Proof evidence: reference by ID.
     E.g.: "Owner field restored with value 'Product Context Engineer' on 2026-07-24.
            Verification: [EVD-2026-0002](../evidence/EVD-2026-0002.en.md)" -->

# Verification

<!-- Fill in when status = Verified.
     Check re-executed: which Check, when, result.
     Verification evidence: reference by ID.
     Who verified (must be different from who implemented).
     E.g.: "DIL-ART-004 re-executed on 2026-07-24, result: Pass.
            Evidence: [EVD-2026-0002](../evidence/EVD-2026-0002.en.md)
            Verified by: Product Context Engineer (independent of implementation)" -->

# Trail

<!-- Append-only record of all relevant state changes.
     NEVER overwrite previous entries.
     Format:
     - YYYY-MM-DD HH:MM [role/agent]: <change> — <justification>
     
     E.g.:
     - 2026-07-23 14:30 [diligence-async]: Open — detected during periodic Scan; Check DIL-ART-004
     - 2026-07-23 15:00 [Product Context Engineer]: Acknowledged — reviewed and confirmed
     - 2026-07-24 09:00 [Product Context Engineer]: Resolved — field corrected, awaiting verification
     - 2026-07-24 09:30 [diligence-async]: Verified — Check re-executed, result Pass
     - 2026-07-24 09:30 [diligence-async]: Closed — verification complete, Finding closed
     -->
