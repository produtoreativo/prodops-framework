---
name: diligence/repair
description: Execute corrections identified by Flag — update OBCs, create missing Work Items, close orphaned ones. Never touches product code or creates implementation PRs.
---

# DILIGENCE ASYNC → REPAIR

Execute only the Repair step of the Diligence Async flow.

**Responsibility:** execute the corrections identified by Flag, restoring consistency between canonical artifacts and external tools. Repair never modifies product code and never creates implementation Pull Requests.

## Action

### 1. Read the pending items list from Flag

Obtain the items classified as repairable by Diligence. Ignore items with `BLOCKED` status — those belong to other journeys.

### 2. Execute repairs in severity order

For each item, apply the corresponding corrective action:

**Missing Work Item:** execute the Attach step for the affected OBC.

```
→ prodops/skills/diligence/diligence-sync/steps/attach/SKILL.md
```

**Issue with canonical labels outside the managed project:**

```bash
gh project item-add <project-number> \
  --owner <owner> \
  --url https://github.com/<owner>/<repo>/issues/<issue-number>
```

Verify membership after adding:

```bash
gh project item-list <project-number> --owner <owner> --format json \
  | jq '.items[] | select(.content.number == <issue-number>) | .id'
```

If the managed project does not exist: register blocker — escalate to Workspace Reconciliation before continuing.

**Open Work Item with Operational OBC:** execute the Close step for the affected OBC.

```
→ prodops/skills/diligence/diligence-sync/steps/close/SKILL.md
```

**OBC absent from Iteration Plan with satisfied preconditions:** execute the Promote step for the affected OBC.

```
→ prodops/skills/diligence/diligence-sync/steps/promote/SKILL.md
```

**Outdated management artifact (Iteration Plan, Roadmap, Product Backlog):** update the artifact directly, recording the date and the decision that originated the change.

**OBC without correct canonical state:** execute the Capture step for the affected OBC.

```
→ prodops/skills/diligence/diligence-sync/steps/capture/SKILL.md
```

### 3. Stop on items requiring a product decision

When a repair cannot be executed without a product decision:
- Record the blocker with the affected OBC, the gap, and the responsible journey
- Do not invent the decision
- Escalate to Assessment or Discovery according to the gap type

### 4. Commit per repair group

```bash
git add prodops/artifacts/obcs/
git add prodops/artifacts/plans/
git commit -m "docs(diligence): repair divergences from async scan"
```

### 5. Record the result

For each repaired item: affected OBC, action executed, date.
For each unrepaired item: reason and responsible journey.

## Events — mandatory emission

Before executing any correction, emit:

```json
{
  "event": "Diligence.Repair.Started",
  "work-item-id": "<work-item-id>",
  "iteration-id": "<iteration-id>",
  "correlation-id": "<correlation-id>",
  "execution-id": "<new-uuid>",
  "actor": { "player": "<player>", "agent": "diligence-repair-agent" },
  "payload": {}
}
```

When an individual repair is blocked and cannot proceed without a product decision, emit:

```json
{
  "event": "Diligence.Block.Declared",
  "work-item-id": "<obc-work-item-id>",
  "iteration-id": "<iteration-id>",
  "correlation-id": "<correlation-id>",
  "execution-id": "<new-uuid>",
  "actor": { "player": "<player>", "agent": "diligence-repair-agent" },
  "payload": { "obc-id": "<obc-id>", "reason": "<blocker reason>" }
}
```

When a Diligence blocker is resolved and the repair can continue, emit:

```json
{
  "event": "Diligence.Block.Resolved",
  "work-item-id": "<obc-work-item-id>",
  "iteration-id": "<iteration-id>",
  "correlation-id": "<correlation-id>",
  "execution-id": "<new-uuid>",
  "actor": { "player": "<player>", "agent": "diligence-repair-agent" },
  "payload": { "obc-id": "<obc-id>" }
}
```

After all repairs are completed (or explicitly blocked), emit:

```json
{
  "event": "Diligence.Repair.Completed",
  "work-item-id": "<work-item-id>",
  "iteration-id": "<iteration-id>",
  "correlation-id": "<correlation-id>",
  "execution-id": "<new-uuid>",
  "actor": { "player": "<player>", "agent": "diligence-repair-agent" },
  "payload": {
    "items-repaired": <number>,
    "items-blocked": <number>
  }
}
```

## Post-conditions

Completed when:

- All repairable items have been corrected or had their blocker explicitly recorded
- No product code was modified
- No implementation Pull Request was created

## Guardrails

- Never modify product code — scope is exclusively ProdOps artifacts and backlogs.
- Never create implementation Pull Requests.
- Stop and escalate items that require a product decision before repairing.
- Do not silence repair failures — explicitly record what could not be corrected and why.

## Out of scope

- `repair` **does not** implement features — never.
- `repair` **does not** resolve divergences that require an Assessment or Discovery decision.
- `repair` **does not** substitute running Downstream readiness for items blocked by missing Delivery artifacts.
