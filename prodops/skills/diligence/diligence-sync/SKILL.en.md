---
name: diligence/diligence-sync
description: Event-driven cycle triggered by a product decision. Captures the decision as an OBC, attaches a Work Item, promotes it through the backlog hierarchy, and closes it when the OBC reaches Operational. Runs for a specific OBC.
---

# DILIGENCE SYNC

Reactive Diligence cycle. Executed when a product decision (Assessment, Discovery, Operation signal) requires capture and tracking.

**Trigger:** decision that triggers the cycle — OBC identifier provided by the caller.
**Flow:** Capture → Attach → Promote → Close
**Scope:** one OBC per execution.

## Steps

| Step | Responsibility | File |
|---|---|---|
| **Capture** | Create or update the OBC from the decision. Canonical state only in Markdown. | [steps/capture/SKILL.md](steps/capture/SKILL.md) |
| **Attach** | Verify or create the Work Item in the external backlog referencing the OBC. | [steps/attach/SKILL.md](steps/attach/SKILL.md) |
| **Promote** | Advance the item through the backlog hierarchy, checking prerequisites at each transition. | [steps/promote/SKILL.md](steps/promote/SKILL.md) |
| **Close** | Close the Work Item when the OBC reaches Operational state. | [steps/close/SKILL.md](steps/close/SKILL.md) |

To run an isolated step: `/diligence diligence-sync <step> <obc-id>`.

## Post-conditions

Completed when **all** of the following are true:

- OBC exists in `prodops/artifacts/obcs/<obc-id>.md` with updated state
- Work Item exists in the external backlog referencing the OBC
- Work Item is in the correct position in the hierarchy (or blocker recorded)
- If OBC is Operational: Work Item closed

## Guardrails

- Stop at any blocker — record the missing artifact, the responsible journey, and the concrete action before stopping.
- Never skip a Promote transition without recording the missing prerequisite and its canonical artifact.
- Never make product decisions — those belong to Assessment.
- If infrastructure is missing (label, field) during Attach/Promote: invoke `workspace-reconciliation` before continuing.

## References

→ [Diligence SKILL.md](../SKILL.md)
→ [Diligence journey README](../../../framework/journeys/diligence/README.md)
