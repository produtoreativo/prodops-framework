---
name: diligence/workspace-reconciliation/reconcile
description: Create or update Labels, Template project, and Managed project to match the Canonical Specification. Tries every API path. On API failure, creates a tracking Issue. Never leaves a gap without a trail entry. Never touches manual projects. Idempotent.
---

# WORKSPACE RECONCILIATION → RECONCILE

Execute only the Reconcile step of the Workspace Reconciliation capability.

**Responsibility:** execute what can be automated and, for what cannot, record a tracking Issue. Never finishes without declaring the status of all categories. It is idempotent — it can be re-executed without side effects.

**Principle:** no gap without a tracking Issue. No floating instructions — the instruction for the human goes in the Issue body.

**Mandatory execution order:** Labels → Template → Managed Project → Milestones. The managed project depends on the template — never invert.

## Action

### 1. Read the Inspect Drift Report

Obtain the Drift Report produced by the Inspect step. If Inspect was not run in this cycle, run it first.

### 2. Labels — create missing and fix divergent

For each `LABEL AUSENTE`, create in order: `operation:` family → `artifact-type:` → `journey:`:

```bash
gh label create "<nome>" \
  --repo <owner>/<repo> \
  --color "<cor-sem-hash>" \
  --description "<descrição>"
```

For each `LABEL DIVERGENTE`:

```bash
gh label edit "<nome>" \
  --repo <owner>/<repo> \
  --color "<cor-correta>" \
  --description "<descrição-correta>"
```

### 3. Canonical template — create, configure, and mark

#### 3a. If `TEMPLATE AUSENTE` in the Drift Report — create empty project and make public

```bash
NUMBER=$(gh project create \
  --owner <owner> \
  --title "ProdOps — template" \
  --format json | jq '.number')

# PUBLIC by default — private only with explicit directive
gh project edit $NUMBER --owner <owner> --visibility PUBLIC
```

Record the returned number for the next sub-steps.

If `TEMPLATE PRIVADO` in the Drift Report (project exists but is private):

```bash
gh project edit <template-number> --owner <owner> --visibility PUBLIC
```

#### 3b. Provision canonical fields in the template

For each canonical field missing from the template (whether newly created or outdated):

**Priority 1 — CLI:**

```bash
gh project field-create <template-number> \
  --owner <owner> \
  --name "<nome>" \
  --data-type "<TEXT|SINGLE_SELECT|NUMBER|DATE|ITERATION>"
```

**Priority 2 — GraphQL `createProjectV2Field` (fallback):**

```bash
gh api graphql -f query='
  mutation {
    createProjectV2Field(input: {
      projectId: "<template-id>"
      dataType: <TEXT|SINGLE_SELECT|NUMBER|DATE|ITERATION>
      name: "<nome>"
    }) { projectV2Field { ... on ProjectV2Field { id name dataType } } }
  }'
```

**Priority 3 — Check enum before giving up:**

```bash
gh api graphql -f query='{ __type(name: "ProjectV2CustomFieldType") { enumValues { name } } }'
```

If the required type appears in the enum: retry with Priority 2.

**For `Evidence Required`:** create as SINGLE_SELECT with option `Required` (color: RED):

```bash
gh api graphql -f query='
  mutation {
    createProjectV2Field(input: {
      projectId: "<project-id>"
      dataType: SINGLE_SELECT
      name: "Evidence Required"
      singleSelectOptions: [{ name: "Required", color: RED, description: "Evidence is required (true)" }]
    }) { projectV2Field { ... on ProjectV2SingleSelectField { id name options { id name } } } }
  }'
```

> **GitOps decision (2026-07-22):** CHECKBOX is not in the `ProjectV2CustomFieldType` enum. SINGLE_SELECT adopted as a permanent fallback until the API evolves. Empty field = false; `Required` = true. ProdOps conceptual model unchanged. See Issue #57 (closed) for full rationale.
>
> Monitor: `gh api graphql -f query='{ __type(name: "ProjectV2CustomFieldType") { enumValues { name } } }'` — if CHECKBOX appears in the enum, migrate.

#### 3c. Mark the template as a template

```bash
gh project mark-template <template-number> --owner <owner>
```

If the command does not exist or fails:

```bash
gh api graphql -f query='
  mutation {
    markProjectV2AsTemplate(input: { projectId: "<template-id>" }) {
      projectV2 { id title }
    }
  }' 2>&1
```

If both fail: record as a note in the manifest — does not create an Issue (it is informational, does not block the copy).

#### 3d. Views in the template — create via REST API

> **Verified 2026-07-22:** views can be created via REST `POST /orgs/{org}/projectsV2/{N}/views`. Correct endpoint: `projectsV2` (not `projects`). GraphQL has no equivalent mutation.

For each canonical view missing from the template:

```bash
curl -s -X POST \
  "https://api.github.com/orgs/<owner>/projectsV2/<template-number>/views" \
  -H "Authorization: Bearer $(gh auth token)" \
  -H "Accept: application/vnd.github+json" \
  -d '{"name": "<nome>", "layout": "table", "filter": "<filtro-ou-omitir>"}'
```

Canonical views to create in the template:

```bash
TOKEN=$(gh auth token)
N=<template-number>

# All Work Items (no filter)
curl -s -X POST "https://api.github.com/orgs/<owner>/projectsV2/$N/views" \
  -H "Authorization: Bearer $TOKEN" -H "Accept: application/vnd.github+json" \
  -d '{"name":"All Work Items","layout":"table"}'

# By Operation (no filter)
curl -s -X POST "https://api.github.com/orgs/<owner>/projectsV2/$N/views" \
  -H "Authorization: Bearer $TOKEN" -H "Accept: application/vnd.github+json" \
  -d '{"name":"By Operation","layout":"table"}'

# Business Signals
curl -s -X POST "https://api.github.com/orgs/<owner>/projectsV2/$N/views" \
  -H "Authorization: Bearer $TOKEN" -H "Accept: application/vnd.github+json" \
  -d '{"name":"Business Signals","layout":"table","filter":"label:artifact-type:business-signal"}'

# Delivery
curl -s -X POST "https://api.github.com/orgs/<owner>/projectsV2/$N/views" \
  -H "Authorization: Bearer $TOKEN" -H "Accept: application/vnd.github+json" \
  -d '{"name":"Delivery","layout":"table","filter":"label:journey:delivery"}'

# Diligence
curl -s -X POST "https://api.github.com/orgs/<owner>/projectsV2/$N/views" \
  -H "Authorization: Bearer $TOKEN" -H "Accept: application/vnd.github+json" \
  -d '{"name":"Diligence","layout":"table","filter":"label:journey:diligence"}'
```

**`group_by`:** Known Platform Limitation — GitHub API does not support configuring `group_by` on views (REST PATCH returns 404, no equivalent GraphQL mutation). Record in the Conformance Report under "Known Platform Limitations". Automation Opportunity: configuration can be done via Browser Automation — record in "Automation Opportunities" and request user authorization before executing. Never instruct the user to configure manually. See Principle 8 — [Automation First](../../../../../framework/automation-first.md).

### 4. Managed project — create via copy or provision missing fields

#### 4a. If `PROJETO GERENCIADO AUSENTE` — copy from template and make public

**Prerequisite:** the template must exist (step 3 completed).

```bash
NUMBER=$(gh project copy <template-number> \
  --source-owner <owner> \
  --target-owner <owner> \
  --title "ProdOps — <repo-name>" \
  --format json | jq '.number')

# PUBLIC by default — gh project copy inherits source visibility, verify and force
gh project edit $NUMBER --owner <owner> --visibility PUBLIC
```

Record the returned number in the sync manifest.

**Required after copy — link the project to the repository:**

> `gh project copy` copies fields and views, but **does not** link the project to the repository. The link must be created explicitly via GraphQL.

```bash
# Obtain IDs of the newly created project and the repository
PROJECT_ID=$(gh api graphql -f query='
  { organization(login: "<owner>") { projectV2(number: '"$NUMBER"') { id } } }
' --jq '.data.organization.projectV2.id')

REPO_ID=$(gh api graphql -f query='
  { repository(owner: "<owner>", name: "<repo-name>") { id } }
' --jq '.data.repository.id')

# Link
gh api graphql -f query='
  mutation {
    linkProjectV2ToRepository(input: {
      projectId: "'"$PROJECT_ID"'"
      repositoryId: "'"$REPO_ID"'"
    }) {
      repository { nameWithOwner }
    }
  }'
```

Verify link after creation:
```bash
gh api graphql -f query='
  { organization(login: "<owner>") {
      projectV2(number: '"$NUMBER"') {
        repositories(first: 5) { nodes { nameWithOwner } }
      }
  }}'
```

Record in sync manifest: `Repo link: <owner>/<repo-name> ✅`.

If `GERENCIADO PRIVADO` in the Drift Report (project exists but is private):

```bash
gh project edit <managed-number> --owner <owner> --visibility PUBLIC
```

#### 4b. If managed project exists but has `FIELD AUSENTE`

Follow the same priority sequence as step 3b (CLI → GraphQL → enum check → Issue).

#### 4c. Views in the managed project

For each missing canonical view, create via REST (same logic as step 3d, replacing the template number with the managed project number):

```bash
curl -s -X POST \
  "https://api.github.com/orgs/<owner>/projectsV2/<managed-number>/views" \
  -H "Authorization: Bearer $(gh auth token)" \
  -H "Accept: application/vnd.github+json" \
  -d '{"name": "<nome>", "layout": "table", "filter": "<filtro>"}'
```

Verify after creation via GraphQL:
```bash
gh api graphql -f query='{ organization(login: "<owner>") { projectV2(number: <N>) { views(first: 20) { nodes { name filter } } } } }'
```

### 5. Milestones — record Issue for Product Owner

For each `MILESTONE AUSENTE` in the Drift Report:

```bash
gh issue list --repo <owner>/<repo> \
  --search "infra: Milestone <versão>" --json number,title,state
# If it doesn't exist:
gh issue create \
  --repo <owner>/<repo> \
  --title "infra: Milestone <versão> required for OBC <obc-id>" \
  --label "operation:provision,artifact-type:release-trail,journey:diligence" \
  --body "## Context
OBC <obc-id> has release <versão> in the Iteration Plan but no Milestone exists.

## Required action (Product Owner)
gh milestone create \"<versão>\" --repo <owner>/<repo> --description \"Release <versão>\"

## Resolution
When created: close this Issue."
```

### 6. Extra labels — list without removing

For each label outside the Canonical Specification, report as a note. Never remove automatically.

### 7. Record result in the sync manifest

Update `prodops/artifacts/trails/github-sync-manifest.md`:
- Template: number, ID, fields present, is-template status
- Managed project: number, ID, fields and views present
- Open Issues referenced by category
- History entry with date, executor, and result

## Post-conditions

Completed when **all** of the following are true:

- Labels created and corrected via API
- Template `ProdOps — template` exists and has canonical fields provisioned
- Template marked as template (or note recorded if it failed)
- Managed project `ProdOps — <repo-name>` exists (created via copy or already existed)
- Automatable fields provisioned in the managed project
- Views: API attempts executed, Issues created for real gaps
- Missing Milestones: Issues created for Product Owner
- Sync manifest updated with template + managed project

## Guardrails

- **Managed projects are PUBLIC by default** — apply `gh project edit --visibility PUBLIC` immediately after creating or copying. Change to PRIVATE only with explicit user directive.
- **Never create fields or views in manual projects** — verify name before any field/view operation.
- **Mandatory order:** template before managed project — the copy depends on the template existing.
- **Automation First (Principle 8)** — try API → MCP → CLI → SDK → Browser Automation before declaring impossibility. See [automation-first.md](../../../../../framework/automation-first.md).
- **No gap without an Issue** — non-automatable divergences generate an Issue with a responsible party and resolution criterion.
- **Never declare "manual action" as floating text** — the instruction goes in the Issue body; Reconcile output lists Automation Opportunities and Known Platform Limitations.
- Never remove labels, views, or fields without explicit confirmation.
- Never create Milestones — create an Issue for the Product Owner.

## Out of scope

- `reconcile` **does not** verify individual Issues — that is Scan (Diligence Async).
- `reconcile` **does not** update labels on existing Issues — that is Repair (Diligence Async).
- `reconcile` **does not** confirm the final result — that is Verify.
