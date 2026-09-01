---
name: diligence/workspace-reconciliation/inspect
description: Read the Canonical Specification and the Actual Workspace state via GitHub API. Produce a Drift Report. Does not create or update anything.
---

# WORKSPACE RECONCILIATION → INSPECT

Execute only the Inspect step of the Workspace Reconciliation capability.

**Responsibility:** compare the Canonical Specification with the Actual Workspace. Inspect does not create or update anything — it produces a complete Drift Report so that Reconcile can act.

**Two managed projects to verify:**
- `ProdOps — template` — canonical org template (source for copies)
- `ProdOps — <repo-name>` — managed project for the current repository

## Action

### 0. Read the sync manifest and the Canonical Specification

```bash
cat prodops/artifacts/trails/github-sync-manifest.md
cat prodops/framework/github-workspace.md
```

Use the manifest as context from previous executions. Do not assume it is up to date — verify via API in all steps.

### 1. Verify Labels

```bash
gh label list --repo <owner>/<repo> --json name,color,description --limit 200
```

Read the spec in `prodops/framework/github-workspace.md` section Labels. For each canonical label, verify:
- Does it exist in the repository?
- Does the color match the spec (without `#`)?
- Does the description match the spec?

Record: `LABEL AUSENTE`, `LABEL DIVERGENTE (cor)`, `LABEL DIVERGENTE (descrição)`.

### 2. Verify Milestones

```bash
gh api /repos/<owner>/<repo>/milestones --jq '[.[] | {title, state, due_on}]'
```

Compare with OBCs that have a release defined in the Iteration Plan. For each missing Milestone:

Record: `MILESTONE AUSENTE: <título> — dono: Product Owner`.

### 3. Verify the canonical org template

Search by the exact name `ProdOps — template`:

```bash
gh project list --owner <owner> --format json \
  | jq '.projects[] | select(.title == "ProdOps — template") | {number, title, id}'
```

**If not found:** record `TEMPLATE AUSENTE`. Reconcile will create and configure it.

**If found:** verify visibility, fields, and mark-template:

```bash
# Visibility
gh project list --owner <owner> --format json \
  | jq '.projects[] | select(.title == "ProdOps — template") | {number, public}'

# Canonical fields
gh project field-list <template-number> --owner <owner> --format json \
  | jq '.fields[] | {name, type}'
```

Record: `TEMPLATE PRIVADO` if `public: false`.
Record: `TEMPLATE FIELD AUSENTE: <nome> (<tipo>)` for each missing field.

### 4. Verify the repository's managed project

Search by the name `ProdOps — <repo-name>`:

```bash
gh project list --owner <owner> --format json \
  | jq '.projects[] | select(.title == "ProdOps — <repo-name>") | {number, title, id}'
```

**If not found:** record `PROJETO GERENCIADO AUSENTE`. Reconcile will create it via a copy of the template.
Do not continue to fields and views.

**If found:** verify visibility, repository link, and canonical fields:

```bash
gh project list --owner <owner> --format json \
  | jq '.projects[] | select(.title == "ProdOps — <repo-name>") | {number, public}'
```

Record: `GERENCIADO PRIVADO` if `public: false`.

**Verify repository link** — `gh project copy` does not link automatically:

```bash
gh api graphql -f query='
{
  organization(login: "<owner>") {
    projectV2(number: <managed-number>) {
      repositories(first: 10) {
        nodes { nameWithOwner }
      }
    }
  }
}'
```

Record: `REPO LINK AUSENTE: <owner>/<repo-name>` if the repository is not in the list.

> **Note:** `gh project copy` copies fields and views, but **does not** link the copied project to the source repository. The link must be created explicitly via `linkProjectV2ToRepository` (Reconcile step 4a).

```bash
gh project field-list <managed-number> --owner <owner> --format json \
  | jq '.fields[] | {name, type}'
```

Record: `FIELD AUSENTE`, `FIELD DIVERGENTE (tipo)`, `FIELD AUSENTE (CHECKBOX — limitação de API)`.

Verify views via GraphQL:

```bash
gh api graphql -f query='
{
  organization(login: "<owner>") {
    projectV2(number: <managed-number>) {
      views(first: 20) { nodes { id name } }
    }
  }
}'
```

Record: `VIEW AUSENTE: <nome>`, `VIEW DIVERGENTE: encontrada "<atual>", esperado "<canônico>"`.

> Projects with other names are manual projects — ignore completely. Never report as Workspace Drift.

### 5. Verify open infrastructure Issues

```bash
gh issue list --repo <owner>/<repo> \
  --label "operation:provision,journey:diligence" \
  --state open \
  --json number,title
```

Use the numbers to annotate the Drift Report: gaps with an open Issue include `(Issue #X)` — Reconcile will not create a duplicate.

### 6. Produce consolidated Drift Report

```
=== DRIFT REPORT — <data> ===

LABELS (<N> ausentes, <N> divergentes):
  LABEL AUSENTE:          operation:capture
  LABEL DIVERGENTE:       journey:delivery — cor atual #abc123, esperado #d93f0b

MILESTONES (<N> ausentes):
  MILESTONE AUSENTE:      v1.2 — OBC create-invoice tem release v1.2 no Iteration Plan

TEMPLATE (ProdOps — template):
  ✅ encontrado — #<N> (id: PVT_...)
  ⚠️ TEMPLATE AUSENTE — Reconcile criará e configurará
  TEMPLATE FIELD AUSENTE: Artifact Type (SINGLE_SELECT)

PROJETO GERENCIADO (ProdOps — payments-api):
  ✅ encontrado — #<N> (id: PVT_...)
  ⚠️ PROJETO GERENCIADO AUSENTE — Reconcile copiará do template
  FIELD AUSENTE:          Evidence Required (CHECKBOX) (Issue #57 já aberto)
  VIEW AUSENTE:           All Work Items — API impossível, criar no template (Issue #58 aberto)
  VIEW AUSENTE:           Diligence — API impossível, criar no template (Reconcile abrirá Issue)

PROJETOS MANUAIS IGNORADOS: "Turma Junho 2026" (#22), "Sprint Junho" (#17)
```

## Post-conditions

Completed when **all** of the following are true:

- Labels verified against the complete Canonical Specification
- Milestones verified against OBCs with a release in the Iteration Plan
- Template `ProdOps — template` verified (existence + fields)
- Managed project `ProdOps — <repo-name>` verified (existence + fields + views)
- Manual projects ignored and listed explicitly in the Drift Report
- Open infrastructure Issues annotated in the Drift Report

## Guardrails

- **Identify projects by exact name, never by number.**
- **Never operate on manual projects** — any project without the `ProdOps — ` prefix is ignored.
- Do not create or update anything in this step.
- Verify the template before the managed project — the template state determines whether the copy is viable.
- If the template does not exist: record it and move on — Reconcile handles creation.
- If the managed project does not exist: record it and do not attempt to verify fields/views.

## Out of scope

- `inspect` **does not** create or update anything — that is Reconcile.
- `inspect` **does not** remove extra labels — removal requires explicit confirmation.
- `inspect` **does not** verify individual Issues — that is Scan (Diligence Async).
- `inspect` **does not** update the sync manifest — that is Verify.
