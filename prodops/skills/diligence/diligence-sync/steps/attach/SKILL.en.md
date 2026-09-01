---
name: diligence/attach
description: Verify or create a Work Item in the external backlog referencing the OBC, operation, and journey. Use after Capture has stabilized the canonical OBC state.
---

# DILIGENCE SYNC → ATTACH

Execute only the Attach step of the Diligence Sync flow.

**Responsibility:** ensure that work on the OBC is traceable in external backlogs. Attach does not change the OBC state — it only creates or verifies the Work Item that represents the work being executed on it.

## Phase: Attach.Started

**Moment:** after verifying the input context, before any backlog action.

Emit:

```json
{
  "event": "Diligence.Attach.Started",
  "work-item-id": "<work-item-id>",
  "iteration-id": "<iteration-id>",
  "correlation-id": "<correlation-id>",
  "execution-id": "<new-uuid>",
  "actor": { "player": "<player>", "agent": "diligence-agent" },
  "payload": {}
}
```

## Phase: Attach.Completed

**Moment:** after all post-conditions are satisfied — before reporting success to the caller.

Emit using the **same `correlation-id`** from Attach.Started:

```json
{
  "event": "Diligence.Attach.Completed",
  "work-item-id": "<work-item-id>",
  "iteration-id": "<iteration-id>",
  "correlation-id": "<same-uuid-as-started>",
  "execution-id": "<new-uuid>",
  "actor": { "player": "<player>", "agent": "diligence-agent" },
  "payload": {}
}
```

Do not emit `Attach.Completed` if the Work Item does not exist or if the project is inaccessible.

---

## Action

### 1. Check if an active Work Item exists

Search the external backlog (GitHub Issues, Jira, Linear) for Work Items that:
- Reference the OBC's `artifact_id`
- Are open (status not closed/done)

If an active Work Item exists: verify that the required fields are correct (`artifact_type`, `artifact_id`, `operation`, `journey`). Update if necessary. **Do not create a duplicate.**

### 2. Create Work Item if missing

Create a Work Item with the required fields from the canonical schema:

| Field | Value |
|---|---|
| `artifact_type` | `Local OBC` |
| `artifact_id` | OBC identifier (e.g. `observability-datadog`) |
| `operation` | operation in progress (e.g. `Refine`, `Promote`, `Review`) |
| `journey` | `Diligence` |

→ Full schema at `prodops/framework/execution-mapping/work-item-schema.md`

Canonical title: `[Artifact ID]: concise description`

Example: `observability-datadog: avançar para Iteration Plan`

Required labels:
```
operation:promote
artifact-type:local-obc
journey:diligence
```

### 3. Record link in the OBC (optional)

If the OBC has a traceability section, add a reference to the created Work Item.

### 4. Add the Issue to the managed project

Get the project number for `ProdOps — <repo-name>` from the sync manifest:

```bash
grep "número\|number" prodops/artifacts/trails/github-sync-manifest.md
# fallback:
gh project list --owner <owner> --format json \
  | jq '.projects[] | select(.title == "ProdOps — <repo-name>") | .number'
```

Check if the Issue is already a member of the project (idempotency):

```bash
gh project item-list <project-number> --owner <owner> --format json \
  | jq '.items[] | select(.content.number == <issue-number>) | .id'
```

If the result is empty, the Issue is not a member — add it:

**Priority 1 — CLI:**

```bash
gh project item-add <project-number> \
  --owner <owner> \
  --url https://github.com/<owner>/<repo>/issues/<issue-number>
```

**Priority 2 — GraphQL (fallback if CLI fails):**

```bash
ISSUE_ID=$(gh api graphql -f query='
  { repository(owner: "<owner>", name: "<repo>") {
      issue(number: <issue-number>) { id }
  }}' --jq '.data.repository.issue.id')

PROJECT_ID=$(gh api graphql -f query='
  { organization(login: "<owner>") {
      projectV2(number: <project-number>) { id }
  }}' --jq '.data.organization.projectV2.id')

gh api graphql -f query='
  mutation {
    addProjectV2ItemById(input: {
      projectId: "'"$PROJECT_ID"'"
      contentId: "'"$ISSUE_ID"'"
    }) { item { id } }
  }'
```

If the managed project does not exist or is inaccessible: record a blocker —
`WORKSPACE NÃO CONFORMANTE — executar Workspace Reconciliation antes de Attach`.
Do not fail silently.

## Post-conditions

Completed when:

- An active Work Item exists referencing the OBC with all required fields populated
- No duplicate Work Item was created
- Issue is a member of the `ProdOps — <repo-name>` project — or blocker recorded explicitly if project is inaccessible

## Guardrails

- Do not create a Work Item without `artifact_type`, `artifact_id`, `operation`, and `journey`.
- Check for duplicates before creating — a duplicate Work Item is a divergence, not a correction.
- Check membership before adding to the project — explicit idempotency avoids noise in logs.
- If project is inaccessible: record a blocker — do not fail silently.
- Do not move the item in the backlog — that is Promote.
- Do not modify the OBC Markdown in this step — that is Capture.

## Out of scope

- `attach` **does not** create the OBC — that is Capture.
- `attach` **does not** verify readiness for Delivery — that is Promote.
- `attach` **does not** close Work Items — that is Close.
- `attach` **does not** configure Custom Fields on the project item (Artifact Type, Operation, Journey as Project fields) — those are visualization fields, not canonical traceability fields.
