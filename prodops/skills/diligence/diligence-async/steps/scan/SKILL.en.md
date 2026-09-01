---
name: diligence/scan
description: Read all active OBCs and compare declared state with backlogs and external tools. Produces a divergence list. Does not repair — only identifies gaps.
---

# DILIGENCE ASYNC → SCAN

Execute only the Scan step of the Diligence Async flow.

**Responsibility:** scan all active OBCs and identify divergences between the canonical state (Markdown) and the state in external tools and backlogs. Scan does not repair anything — it produces a gap report so that Flag can classify them and Repair can fix them.

## Action

### 1. Verify Business Signals in the tracking list

Read `prodops/artifacts/product/backlogs/tracking-list.md` and inspect the `Issue` column and status of each entry:

```
For each table row:
  - If Issue == "—" or missing AND the Signal status indicates an active operation (e.g.: Capturando, Em triagem, Promovendo) → divergence: Business Signal with active operation and no traceable Work Item
  - If Issue == "—" or missing AND the Signal is passive (no active operation) → not a divergence
  - If Issue == "#NNN" → verify via gh whether the Issue exists and is in the correct state
```

> **N:M Principle:** A Business Signal may have zero or more Work Items over its lifetime. The absence of an Issue is NOT a divergence in itself — it is only a divergence when there is an active operation identified with no traceable Work Item.

```bash
gh issue view <number> --repo produtoreativo/payments-api --json state,title
```

| Signal | Divergence |
|---|---|
| Signal with active operation AND `Issue` column empty or `—` | Business Signal with active operation and no Work Item — Attach required |
| Signal without active operation AND `Issue` column empty | Not a divergence — normal state |
| Issue closed with operation still in progress | Issue state diverges from the operation in progress |
| Non-existent Issue (404) with active operation | Referenced Issue does not exist — Attach required |

Record each gap with the affected tracking list row and the corrective action.

### 2. Verify conformance of existing Issues

List all open Issues and verify:

```bash
gh issue list --repo <owner>/<repo> --state all --json number,title,labels --limit 200
```

For each Issue, verify:

| Check | Divergence signal |
|---|---|
| Title follows `[artifact-id]: description` | Title starts with `[Operation] —` (old pattern) |
| Label `operation:<value>` present | Issue without `operation:*` label |
| Label `artifact-type:<value>` present | Issue without `artifact-type:*` label |

Issues with old pattern or without canonical labels → divergence `[ ] Média` — Repair updates title and adds labels.

### 3. Verify Issue membership in the managed project

Get the project number for `ProdOps — <repo-name>`:

```bash
gh project list --owner <owner> --format json \
  | jq '.projects[] | select(.title == "ProdOps — <repo-name>") | .number'
```

If the project does not exist: record as a scan limitation — not as an OBC divergence. Workspace Reconciliation must be run first.

List all items that are members of the managed project:

```bash
gh project item-list <project-number> --owner <owner> --format json \
  | jq '[.items[].content.number]'
```

For each open Issue with label `journey:*` or `operation:*`, check whether the number is in the members list:

| Signal | Divergence |
|---|---|
| Issue with `journey:*` label missing from list | Issue without project membership — Attach required |
| Issue with `operation:*` label missing from list | Issue without project membership — Attach required |

Record each gap:

```
OBC: <obc-id se identificável pelo título do Issue>
Gap: Issue #N ("título") não é membro do projeto ProdOps — <repo-name>
Severidade: Média
Ação corretora: gh project item-add <project-number> --owner <owner> --url <issue-url>
Responsável: Diligence
```

If `gh project item-list` fails due to permission or inaccessible project: record as a limitation — not as an OBC divergence.

### 4. List all active OBCs

```bash
ls prodops/artifacts/obcs/
```

For each OBC: read the file and extract the declared state (Draft, Committed, In Delivery, Operational).

### 5. Verify consistency of each OBC

For each active OBC, verify the following checks:

| Check | Expected | Divergence signal |
|---|---|---|
| Active Work Item | An open GitHub Issue referencing the OBC exists when there is an active operation in progress | OBC with active operation identified and no traceable Work Item |
| BDD Feature | `prodops/artifacts/bdd/<obc-id>.feature` exists when OBC is in Iteration Plan | Item in Iteration Plan without committed BDD Feature |
| Iteration Plan | Committed OBC appears in the Iteration Plan | Committed OBC missing from Iteration Plan |
| Work Item closed | Issue closed when OBC is Operational | Operational OBC with Issue still open |
| Risks | Risks documented in `risks.md` when OBC is in Iteration Plan | Entry in Iteration Plan without a corresponding entry in risks.md |
| Issue state vs OBC | Issue state on GitHub reflects the canonical OBC state | Issue closed with non-Operational OBC; Issue open with labels diverging from OBC state |

### 2a. Read current Issue state on GitHub

For each OBC that has a reference to a GitHub Issue, query the current state via `gh`:

```bash
gh issue view <issue-number> --repo <owner>/<repo> --json state,labels,assignees,title
```

Compare the returned state with the canonical OBC state:

| OBC State | Expected Issue state | Divergence if |
|---|---|---|
| Draft / Committed | open | Issue is closed |
| In Delivery | open | Issue is closed |
| Operational | closed | Issue is open |
| Any | — | Issue title does not reference the OBC's `artifact_id` |

If `gh` is not available or the repository is not accessible, record as a limitation in the report — not as an OBC divergence.

### 6. Produce divergence report

For each divergence found, record:

```
OBC: <obc-id>
Gap: <gap description>
Severidade: Alta | Média | Baixa
Ação corretora sugerida: <concrete action>
Responsável sugerido: Diligence | Assessment | Delivery
```

**Alta:** item in Iteration Plan without BDD Feature or without documented risks
**Média:** OBC committed without Work Item; Work Item open with Operational OBC
**Baixa:** management artifact outdated with no impact on Delivery gate

## Events — mandatory emission

Before any Scan work, emit:

```json
{
  "event": "Diligence.Scan.Started",
  "work-item-id": "<work-item-id>",
  "iteration-id": "<iteration-id>",
  "correlation-id": "<correlation-id>",
  "execution-id": "<new-uuid>",
  "actor": { "player": "<player>", "agent": "diligence-scan-agent" },
  "payload": {}
}
```

For each divergence found, emit **individually** before advancing to Flag:

```json
{
  "event": "Diligence.Divergence.Detected",
  "work-item-id": "<obc-work-item-id>",
  "iteration-id": "<iteration-id>",
  "correlation-id": "<correlation-id>",
  "execution-id": "<new-uuid>",
  "actor": { "player": "<player>", "agent": "diligence-scan-agent" },
  "payload": {
    "obc-id": "<obc-id>",
    "gap": "<descrição do gap>",
    "severity": "Alta | Média | Baixa"
  }
}
```

After all checks are completed (even with no divergences), emit:

```json
{
  "event": "Diligence.Scan.Completed",
  "work-item-id": "<work-item-id>",
  "iteration-id": "<iteration-id>",
  "correlation-id": "<correlation-id>",
  "execution-id": "<new-uuid>",
  "actor": { "player": "<player>", "agent": "diligence-scan-agent" },
  "payload": { "divergences-found": <número> }
}
```

Do not emit `Scan.Completed` if any check could not be executed (e.g.: tool inaccessible) — record the blocker explicitly.

## Post-conditions

Completed when:

- All active OBCs have been verified
- Membership of Issues with canonical labels in the managed project verified
- Divergence report produced (may be empty if no gaps)
- No corrections executed

## Guardrails

- Do not repair anything in this step — produce only the report.
- Do not create Work Items, update OBCs, or close items — that is Repair.
- If the external tool is not accessible (no `gh`, no permission, no Issue number in the OBC), record as a limitation in the report — not as an OBC divergence.
- Do not mark divergences as blockers without first confirming that the artifact or state is truly missing/divergent.
- Verify the current Issue state via API before recording a state divergence — never assume closed or open without querying.

## Out of scope

- `scan` **does not** classify divergences with action priority — that is Flag.
- `scan` **does not** execute corrections — that is Repair.
- `scan` **does not** make product decisions — gaps that require a decision are flagged to Assessment.
