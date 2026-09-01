---
name: diligence/close
description: Close the Work Item when the OBC reaches Operational state and update management artifacts. Use when the Release Trail confirms the delivery is complete.
---

# DILIGENCE SYNC → CLOSE

Execute only the Close step of the Diligence Sync flow.

**Responsibility:** close the Work Item when the OBC reaches Operational state, ensuring that management artifacts reflect the final state of the delivered work.

## Action

### 1. Confirm Operational state in the Release Trail

Check in `prodops/artifacts/trails/sessions/` whether the delivery was recorded in the Release Trail with:
- Confirmed scope
- Executed validation
- Completion date

### 2. Update the OBC

In the file `prodops/artifacts/obcs/<obc-id>.md`:
- Update the status field to `Operational`
- Record the completion date and reference to the Release Trail

### 3. Close the Work Item

Close the Work Item in the external backlog with:
- Comment referencing the Release Trail entry
- Final status: Done/Closed/Operacional

### 4. Update management artifacts

If the item was represented in the Roadmap or Product Backlog, update to reflect Operational state.

### 5. Commit

```bash
git add prodops/artifacts/obcs/<obc-id>.md
git commit -m "docs(diligence): close OBC <obc-id> — Operational"
```

## Events — mandatory emission

Before any Close work, emit:

```json
{
  "event": "Diligence.Close.Started",
  "work-item-id": "<work-item-id>",
  "iteration-id": "<iteration-id>",
  "correlation-id": "<correlation-id>",
  "execution-id": "<new-uuid>",
  "actor": { "player": "<player>", "agent": "diligence-close-agent" },
  "payload": {}
}
```

After OBC updated to Operational, Work Item closed, and commit done, emit:

```json
{
  "event": "Diligence.Close.Completed",
  "work-item-id": "<work-item-id>",
  "iteration-id": "<iteration-id>",
  "correlation-id": "<correlation-id>",
  "execution-id": "<new-uuid>",
  "actor": { "player": "<player>", "agent": "diligence-close-agent" },
  "payload": {}
}
```

Do not emit `Close.Completed` if the OBC was not updated or the Work Item was not closed.

## Post-conditions

Completed when:

- OBC with status `Operational` in the Markdown file
- Work Item closed in the external backlog with reference to the Release Trail
- Management artifacts updated

## Guardrails

- Do not close without evidence in the Release Trail — the OBC is not Operational without a recorded delivery.
- Do not close Work Items from other OBCs in the same step.
- Do not modify BDD Features or code — Close is a traceability step, not an implementation step.

## Out of scope

- `close` **does not** validate the delivery — that is Validate (Delivery CI Async).
- `close` **does not** create Release Trail entries — that is Promote (Delivery CI Async).
- `close` **does not** detect orphaned Work Items from other OBCs — that is Scan.
