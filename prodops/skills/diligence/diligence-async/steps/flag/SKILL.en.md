---
name: diligence/flag
description: Classify divergences from Scan and register them as pending Diligence items with severity and corrective action. Does not repair — only signals.
---

# DILIGENCE ASYNC → FLAG

Execute only the Flag step of the Diligence Async flow.

**Responsibility:** classify the divergences produced by Scan and register them as pending Diligence items. Flag does not repair — it only signals with enough context for Repair to act without ambiguity.

## Action

### 1. Read the Scan report

Obtain the list of divergences produced by the Scan step. If Scan was not executed in this cycle, run it first.

### 2. Classify each divergence

For each divergence, classify the corrective action and the responsible party:

| Gap type | Action | Who can repair |
|---|---|---|
| Committed OBC without Work Item | Attach — create Work Item | Diligence |
| Issue with canonical labels outside the managed project | Attach — add Issue to the project | Diligence |
| Item in Iteration Plan without BDD Feature | Blocker — BDD Feature must be created first | Delivery (Downstream readiness) |
| Item in Iteration Plan without documented risks | Blocker — document risks in risks.md | Assessment |
| Open Work Item with Operational OBC | Close — close Work Item | Diligence |
| Committed OBC absent from Iteration Plan | Promote — verify preconditions and promote | Diligence |
| Outdated management artifact | Artifact Evolution — update artifact | Diligence |

### 3. Register pending items

For each divergence repairable by Diligence, register:

```
[ ] [SEVERITY] OBC: <obc-id> — Gap: <gap> — Action: <corrective action>
```

For divergences that block and require another journey, register with `BLOCKED` status:

```
[B] [SEVERITY] OBC: <obc-id> — Gap: <gap> — Owner: <responsible journey> — Next action: <action>
```

### 4. Prioritize for Repair

Sort repairable items by severity: High → Medium → Low.

## Events — mandatory emission

Before classifying any divergence, emit:

```json
{
  "event": "Diligence.Flag.Started",
  "work-item-id": "<work-item-id>",
  "iteration-id": "<iteration-id>",
  "correlation-id": "<correlation-id>",
  "execution-id": "<new-uuid>",
  "actor": { "player": "<player>", "agent": "diligence-flag-agent" },
  "payload": {}
}
```

After all divergences are classified and the pending items list is produced, emit:

```json
{
  "event": "Diligence.Flag.Completed",
  "work-item-id": "<work-item-id>",
  "iteration-id": "<iteration-id>",
  "correlation-id": "<correlation-id>",
  "execution-id": "<new-uuid>",
  "actor": { "player": "<player>", "agent": "diligence-flag-agent" },
  "payload": {
    "items-flagged": <number>,
    "items-blocked": <number>
  }
}
```

## Post-conditions

Completed when:

- All gaps from Scan have been classified
- Items repairable by Diligence are listed with severity and concrete action
- Blocked items are registered with responsible journey and next action
- No corrections executed

## Guardrails

- Do not repair anything in this step — only signal.
- Do not invent corrective actions that require a product decision.
- Record blockers explicitly — silence about an unresolved gap is a new inconsistency.
- Do not escalate a gap to Assessment without verifying that the artifact is actually missing.

## Out of scope

- `flag` **does not** execute corrections — that is Repair.
- `flag` **does not** make priority decisions — it records technical severity, not the business decision.
- `flag` **does not** read OBCs directly — it consumes the Scan report.
