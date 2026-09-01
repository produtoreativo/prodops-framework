---
name: diligence/diligence-async
description: Proactive drift-scan cycle. Reads all active OBCs and Issues, identifies divergences, and repairs what can be automated. Runs across the entire active backlog, not for a specific OBC.
---

# DILIGENCE ASYNC

Proactive Diligence cycle. Executed periodically or when systemic drift is detected — without a specific OBC trigger.

**Trigger:** proactive, scheduled, or called after systemic drift detection.
**Flow:** Scan → Flag → Repair
**Scope:** all active OBCs and Issues in the repository.

## Steps

| Step | Responsibility | File |
|---|---|---|
| **Scan** | Read all active OBCs and Issues; compare declared state against external tools; verify title and label conformance. Produces a list of divergences. | [steps/scan/SKILL.md](steps/scan/SKILL.md) |
| **Flag** | Classify divergences by severity and corrective action. Categorizes what is repairable vs. what requires a product decision. | [steps/flag/SKILL.md](steps/flag/SKILL.md) |
| **Repair** | Execute corrections for repairable items; escalate blocked items. If Workspace Drift detected: invoke `workspace-reconciliation`. | [steps/repair/SKILL.md](steps/repair/SKILL.md) |

To execute an isolated step: `/diligence diligence-async <step>`.

## Post-conditions

Completed when **all** of the following are true:

- All active OBCs and Issues verified against actual tool state
- Divergences classified by severity
- Repairable items corrected or with a tracking Issue opened
- Escalated items documented with OBC, gap, and responsible journey

## Guardrails

- Stop before Repair when a divergence requires a product decision — escalate with the affected OBC, the gap, and the responsible journey.
- Never make product decisions — surface blockers to the user.
- If Workspace Drift detected during Scan/Repair: invoke `workspace-reconciliation` to reconcile infrastructure before continuing.
- Never invent OBCs, BDD Features, or risks — only synchronize what already exists.

## References

→ [Diligence SKILL.md](../SKILL.md)
→ [Diligence journey README](../../../framework/journeys/diligence/README.md)
