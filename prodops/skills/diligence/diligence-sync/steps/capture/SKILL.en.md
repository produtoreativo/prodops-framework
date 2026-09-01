---
name: diligence/capture
description: Create or update an OBC from the decision that triggered the Diligence Sync cycle. Use when an Assessment decision, Discovery experiment, or Operation signal requires canonical state to be recorded before Work Items are created.
---

# DILIGENCE SYNC → CAPTURE

Execute only the Capture step of the Diligence Sync flow.

**Responsibility:** record the canonical state of the OBC in the Markdown file. Capture does not create Work Items — it only stabilizes knowledge before Attach can track it.

## Action

### 1. Identify the trigger

Identify the decision or event that triggered the cycle:
- Discovery experiment completed with a decision made
- Assessment decision recorded in `prodops/framework/journeys/assessment/`
- New Operation signal that changes the state of an existing OBC
- Strategic Roadmap change

### 2. Locate or create the OBC

If the OBC already exists at `prodops/artifacts/obcs/<obc-id>.md`:
- Read the full file
- Update the status field and add an entry to the decision history

If the OBC does not exist:
- Verify that a canonical trigger exists and is documented: completed experiment, recorded Assessment decision, Operation signal that justifies the OBC, or authorized operation
- Create the file following the template available in `prodops/templates/` (if it exists)
- Fill in: identifier, originating Business Intent, initial state, recorded decision
- **Do not create an OBC without a canonical trigger** — Capture records decisions already made, it does not invent content or business commitments

### 3. Record the decision

In the OBC body, record:
- Decision date
- Decision made and rationale
- Journey that produced the decision (Assessment, Discovery, Operation)
- Reference to the source artifact (experiment.md, risks.md, trail)

### 4. Commit the artifact

For OBC:
```bash
git add prodops/artifacts/obcs/<obc-id>.md
git commit -m "docs(diligence): capture OBC state from <trigger>"
```

For Business Signal (tracking list):
```bash
git add prodops/artifacts/product/backlogs/tracking-list.md
git commit -m "docs(diligence): capture business signal — <descrição curta>"
```

### 5. Evaluate need for Attach for Business Signals

When the captured artifact is a **Business Signal** (entry in the tracking list), evaluate whether there is an active operation in progress on the Signal. If an active operation is identified (e.g.: exploration, triage, promotion to Business Intent) and no traceable Work Item exists, flag Attach as the next step.

The absence of a Work Item is not automatically a divergence. Work Items are created when there is identified work on the Signal — not automatically upon recording the Signal.

Explicitly record before finishing: "Business Signal captured — [there is/there is no] active operation identified — [Attach required / Attach not required at this time]."

## Post-conditions

Completed when **all** of the following are true:

- Artifact committed with updated canonical state
- Decision recorded with date, rationale, and reference to the source artifact
- If Business Signal: need for Attach evaluated based on the existence of an active operation
- No Work Item created in this step (responsibility of Attach)

## Guardrails

- Do not create Work Items in this step — that is Attach.
- Do not invent decisions that are not documented in the source artifact.
- Do not end the diligence-sync cycle after Capture when the artifact is a Business Signal with an active operation identified — Attach is the next step in that case.
- Do not modify BDD Features or Reliability Plan — that is the responsibility of Delivery or Assessment.
- If the OBC requires a new product decision to be updated, stop and surface it as a blocker.

## Out of scope

- `capture` **does not** create Work Items — that is Attach.
- `capture` **does not** move items in the backlog — that is Promote.
- `capture` **does not** close Work Items — that is Close.
- `capture` **does not** scan all OBCs — that is Scan.
