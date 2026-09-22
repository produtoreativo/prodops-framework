---
name: diligence/workspace-reconciliation/verify
description: Confirm that the GitHub repository state matches the Canonical Specification across all 4 categories. Reads Views via GraphQL. Updates the sync manifest with the verified conformance state. Produces the Conformance Report.
---

# WORKSPACE RECONCILIATION → VERIFY

Execute only the Verify step of the Workspace Reconciliation capability.

**Responsibility:** programmatically confirm the state of all 4 categories after Reconcile and update the sync manifest with the verified result. Verify is the sole source that updates the manifest with data confirmed via API.

## Action

### 1. Verify Labels

```bash
gh label list --repo <owner>/<repo> --json name,color,description --limit 200
```

Compare with the Canonical Specification. Count: conforming, missing, divergent.

### 2. Verify Milestones

```bash
gh api /repos/<owner>/<repo>/milestones --jq '[.[] | {title, state}]'
```

Compare with OBCs in the Iteration Plan that have a release defined. For each missing Milestone, record as pending Product Owner action.

### 3. Verify Custom Fields

```bash
gh project field-list <number> --owner <owner> --format json
```

Verify which canonical fields exist. `Evidence Required` (CHECKBOX): check if it exists among the returned fields. If missing, record as `PENDENTE — Issue #X documentado` (open a tracking Issue if one does not already exist).

### 4. Verify Views via GraphQL

```bash
gh api graphql -f query='
query {
  organization(login: "<owner>") {
    projectV2(number: <N>) {
      views(first: 20) {
        nodes { id name }
      }
    }
  }
}'
```

Compare returned names with the canonical list. For each canonical view: `CONFORME` if it exists, `PENDENTE — Issue #X documentado` if missing (open a tracking Issue if one does not already exist). Extra (non-canonical) views detected: record in "Automation Opportunities" as candidates for removal via Browser Automation.

### 5. Produce Conformance Report

```
╔══════════════════════════════════════════════════════════════╗
║  CONFORMIDADE — <data>                                       ║
║  Repositório: <owner>/<repo>  |  Project: #<N>              ║
╠══════════════════════════════════════════════════════════════╣
║  Labels        ✅ CONFORME    — <N> labels em conformidade   ║
║                ⚠️  PARCIAL    — <N> ausentes: <lista>        ║
║                                                              ║
║  Milestones    ✅ N/A         — nenhum OBC com release       ║
║                ⚠️  PENDENTE   — v1.2 ausente (Product Owner) ║
║                                                              ║
║  Custom Fields ✅ CONFORME    — 8/8 campos                   ║
║                ⚠️  PARCIAL    — Evidence Required            ║
║                               PENDENTE — Issue #X           ║
║                                                              ║
║  Views         ✅ CONFORME    — 5/5 views                    ║
║                ⚠️  PENDENTE   — 3 views ausentes             ║
║                               PENDENTE — Issue #X           ║
║                                                              ║
║  Project       ✅ CONFORME    — Project #<N> acessível       ║
║                ⚠️  AUSENTE    — DIVERGENTE — reconcile req.  ║
╠══════════════════════════════════════════════════════════════╣
║  Resultado geral: CONFORME | PARCIAL | NÃO CONFORME          ║
╠══════════════════════════════════════════════════════════════╣
║  Automation Opportunities                                    ║
║  - Remover "View 1" — aguardando autorização Browser Auto.   ║
║  - Remover "test-view" — aguardando autorização Browser Auto.║
╠══════════════════════════════════════════════════════════════╣
║  Known Platform Limitations                                  ║
║  - group_by: GitHub API não suporta (REST 404, sem GraphQL)  ║
╠══════════════════════════════════════════════════════════════╣
║  Next Action                                                 ║
║  Can execute via Browser Automation. Do you want to proceed? ║
╚══════════════════════════════════════════════════════════════╝
```

**Result criterion:**
- `CONFORME` — all 4 categories with no pending automatable divergences. When there is no Workspace Drift: report "Desired state satisfied. No reconciliation actions required." — never "Reconcile skipped."
- `PARCIAL` — divergences with an open tracking Issue (Views, Checkbox, Milestones) but no automatable items remaining
- `NÃO CONFORME` — Labels or Fields that are still automatable and divergent (Reconcile was not run or failed); or project missing (requires `gh project create` — DIVERGENTE, not "manual action")

### 5b. Verify open infrastructure Issues

```bash
gh issue list --repo <owner>/<repo> \
  --label "operation:provision,journey:diligence" \
  --state open \
  --json number,title,state
```

Include in the Conformance Report: list of open `infra:` Issues with number and title. Open Issues indicate documented gaps — they are not process failures, they are explicit tracking.

### 6. Update the sync manifest

Write to `prodops/artifacts/trails/github-sync-manifest.md`:
- Status of each category based on the API verification from this cycle
- For PARCIAL categories: reference the tracking Issue (e.g. `PARCIAL — ver Issue #63`)
- Mark `[x]` for views and fields confirmed via API as existing
- Add a line to the History with: date, executor, result, open Issues

## Post-conditions

Completed when **all** of the following are true:

- All 4 categories verified via API
- Conformance Report produced with an explicit result (`CONFORME`, `PARCIAL`, or `NÃO CONFORME`)
- Sync manifest updated with the state verified in this cycle

## Guardrails

- **Verify all 4 categories** — do not skip any even if the manifest indicates prior conformance.
- Never mark a category as `CONFORME` in the manifest without having verified it via API in this execution.
- Clearly distinguish between `PENDENTE — Issue #X documentado` (gap with tracking) and `NÃO CONFORME automatizável` (requires re-running Reconcile). Never use `PENDENTE manual` as a status — every pending item must have a tracking Issue.
- **Automation First (Principle 8)** — a missing project is always `DIVERGENTE — reconcile required` (automatable via `gh project create`), never "mandatory manual action". See [automation-first.md](../../../../../framework/automation-first.md).
- Always include "Automation Opportunities" and "Known Platform Limitations" sections in the Conformance Report when applicable.
- Updating the manifest is mandatory — Verify without manifest update is not complete.

## Out of scope

- `verify` **does not** fix divergences — that is Reconcile.
- `verify` **does not** verify individual Issues — that is Scan (Diligence Async).
