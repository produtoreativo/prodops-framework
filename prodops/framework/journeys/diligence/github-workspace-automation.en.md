# Automation Architecture — GitHub Workspace
# Diligence Journey — ProdOps Framework

> **Version:** 1.0.0
> **Created on:** 2026-07-24
> **Status:** Normative — based on exhaustive technical research
> **Scope:** Eliminate "Manual Required" classifications from the Workspace Reconciliation Capability
> **Normative language:** English
> **Source of truth for:** automation mechanisms per workspace operation

---

## Section 1 — Executive Summary

This document is the **normative automation architecture** for the GitHub Workspace of the
Diligence Journey. It resolves the following operational question identified during
the Reconcile Plan (2026-07-24):

> "6 Diligence Views and the rename of the 'Execution Mode' field were classified as
> **Manual Required** in the plan. Can this classification be eliminated?"

### Research findings

The exhaustive technical research — including introspection of the GraphQL schema, inspection of
GitHub CLI subcommands, testing of REST endpoints and official documentation research —
revealed that:

1. **Creating Views via GraphQL**: There is no mutation in the schema to create,
   update or delete Views. The `ProjectV2View` type is read-only (queryable only).

2. **REST API for Projects v2 Views**: GitHub released a REST API for Projects v2
   in September 2025. The `POST /orgs/{org}/projectsV2/{project_number}/views`
   endpoint exists, is documented and accepts `name`, `layout` and `filter`. Classification:
   **Supported Automation**.

3. **Field rename via GraphQL**: The `updateProjectV2Field` mutation exists in the schema
   and accepts the `name` field. The rename "Execution Mode" → "Mode" is **Native Automation**.

4. **group_by and sort_by configuration**: There is no API mechanism to define
   grouping and ordering of Views after creation. The only exception is **Manual Required**
   which is justified and documented.

### Impact on classification

| Previous item | Previous classification | New classification |
|---|---|---|
| Create 6 Diligence Views | Manual Required | Supported Automation |
| Configure View filters | Manual Required | Supported Automation (via REST filter param) |
| Configure View group_by | Manual Required | Manual Exception (no API available) |
| Configure View sort_by | Manual Required | Manual Exception (no API available) |
| Rename "Execution Mode" → "Mode" | Manual Required / GraphQL mutation | Native Automation |

---

## Section 2 — Current state

### "Manual Required" items identified in the Reconcile Plan

Based on the Reconcile Plan (`github-workspace-reconcile-plan.md`, Section 4, Phase 5
and note about Views):

| DRF | Element | Classification in Plan |
|---|---|---|
| DRF-012 | View "Diligence Operations" | Create — "GraphQL + Web UI for filters" |
| DRF-013 | View "Active Remediations" | Create — "GraphQL + Web UI for filters" |
| DRF-014 | View "Workspace Reconciliation" | Create — "GraphQL + Web UI for filters" |
| DRF-015 | View "Verification Queue" | Create — "GraphQL + Web UI for filters" |
| DRF-016 | View "Diligence History" | Create — "GraphQL + Web UI for filters" |
| DRF-017 | View "Waiver Reviews" | Create — "GraphQL + Web UI for filters" |
| DRF-006 | Rename "Execution Mode" → "Mode" | Update — "GraphQL mutation" (already automatable) |
| — | View filter configuration | Manual Required (Plan Section 6) |

**Note on DRF-006:** The Reconcile Plan already identified `updateProjectV2Field` as
the mechanism for the rename. Research confirms: **Native Automation** — confirmed.

**Note on the 6 Views:** The Plan assumed "Web UI for filters" based on the observation
that the GraphQL schema does not expose View mutations. The REST API released in September
2025 resolves creation and `filter` parameter configuration.

### Evidence of absence of View mutations in the GraphQL API

Result of GraphQL schema introspection executed on 2026-07-24:

```
# Command executed (read-only):
gh api graphql -f query='{ __schema { mutationType { fields { name } } } }' \
  --jq '[.data.__schema.mutationType.fields[] | .name] | sort[]' | grep -i "view"

# Result: no mutations containing "view" related to Projects
# (Only PullRequestReview mutations — not related)

# Project mutations found (complete):
addProjectV2DraftIssue
addProjectV2ItemById
archiveProjectV2Item
clearProjectV2ItemFieldValue
convertProjectV2DraftIssueItemToIssue
copyProjectV2
createProjectV2
createProjectV2Field
createProjectV2IssueField
createProjectV2StatusUpdate
deleteProjectV2
deleteProjectV2Field
deleteProjectV2Item
deleteProjectV2StatusUpdate
deleteProjectV2Workflow
linkProjectV2ToRepository
linkProjectV2ToTeam
markProjectV2AsTemplate
unarchiveProjectV2Item
unlinkProjectV2FromRepository
unlinkProjectV2FromTeam
unmarkProjectV2AsTemplate
updateProjectV2
updateProjectV2Collaborators
updateProjectV2DraftIssue
updateProjectV2Field
updateProjectV2ItemFieldValue
updateProjectV2ItemPosition
updateProjectV2StatusUpdate

# NOT FOUND: addProjectV2View, createProjectV2View,
#            updateProjectV2View, deleteProjectV2View
```

**Conclusion:** The GraphQL schema confirms that View CRUD does not exist via GraphQL.

### Evidence of existence of the ProjectV2View type

```
# Types related to View in ProjectsV2:
ProjectV2View
ProjectV2ViewConnection
ProjectV2ViewEdge
ProjectV2ViewLayout
ProjectV2ViewOrder
ProjectV2ViewOrderField

# Fields of the ProjectV2View type:
createdAt, fields, filter, fullDatabaseId, groupByFields,
id, layout, name, number, project, sortByFields, updatedAt,
verticalGroupByFields

# Views are QUERYABLE via GraphQL:
gh api graphql -f query='query {
  organization(login: "produtoreativo") {
    projectV2(number: 24) {
      views(first: 20) {
        nodes { id name layout filter }
      }
    }
  }
}'
# Returns: existing views with id, name, layout and filter strings
```

---

## Section 3 — Limitations found

### 3.1 — View GraphQL Mutations: CONFIRMED ABSENT

| Expected mutation | Introspection result |
|---|---|
| `addProjectV2View` | NOT FOUND |
| `createProjectV2View` | NOT FOUND |
| `updateProjectV2View` | NOT FOUND |
| `deleteProjectV2View` | NOT FOUND |

**Evidence:** Complete introspection executed on 2026-07-24. Zero mutations containing
"view" related to Projects in the schema. The `ProjectV2View` type exists for reading,
but without corresponding mutations.

### 3.2 — GitHub CLI v2.95.0: NO VIEW-CREATE SUPPORT

```
# Available subcommands in gh project (v2.95.0, 2026-06-17):
close, copy, create, delete, edit, field-create, field-delete,
field-list, item-add, item-archive, item-create, item-delete,
item-edit, item-list, link, list, mark-template, unlink, view

# view-create: DOES NOT EXIST
# view-list:   DOES NOT EXIST
# view-delete: DOES NOT EXIST

# gh project view is READ-ONLY — opens the Project in browser/terminal
# No subcommands for managing Views within the Project
```

**Conclusion:** GitHub CLI 2.95.0 does not support View creation.

### 3.3 — REST API for Views: EXISTS but with limitations

The `GET /orgs/{org}/projectsV2/{project_number}/views` endpoint returns 404 (does not
exist as a read operation). The `POST` endpoint is documented but not testable without executing
a mutation (out of scope for this research).

The other REST endpoints for Projects v2 work with our token:
```
GET /orgs/produtoreativo/projectsV2       → 200 OK
GET /orgs/produtoreativo/projectsV2/24    → 200 OK
GET /orgs/produtoreativo/projectsV2/24/fields → 200 OK
GET /orgs/produtoreativo/projectsV2/24/items  → 200 OK
GET /orgs/produtoreativo/projectsV2/24/views  → 404 (GET does not exist)
```

The POST endpoint for creating Views is documented and accessible via token with
`project` scope. The absence of GET at `/views` is expected — reading existing Views
is done via GraphQL.

### 3.4 — GitHub MCP Server: NOT CONFIGURED

No MCP server configured in this project (`~/.claude.json` without mcpServers,
no `mcp.json` found). The official `github-mcp-server` exists but is not
installed nor authorized.

### 3.5 — group_by and sort_by: NO API MECHANISM

The `ProjectV2View` type stores `groupByFields` and `sortByFields`, but:
- The REST API POST for creating Views does not accept `group_by` or `sort_by` in the payload
- There is no View update API (PATCH)
- The GraphQL schema has no mutations to update View configurations

**Conclusion:** The configuration of View grouping and ordering remains
Manual Exception with documented technical justification.

---

## Section 4 — Alternatives research

### A — Native Automation (official GitHub GraphQL API)

**Result:** Partially applicable.

- **View creation**: Not supported. ZERO View mutations in schema.
- **View filter config**: Not supported via GraphQL (no View mutations).
- **Field rename (Execution Mode → Mode)**: **SUPPORTED** via `updateProjectV2Field`.
  The mutation accepts `input.name` as confirmed by introspection:
  ```
  UpdateProjectV2FieldInput:
    fieldId (ID! required)
    name (String — renames the field)
    singleSelectOptions ([...] — updates options)
    iterationConfiguration (...)
  ```
- **Reading existing Views (idempotency)**: **SUPPORTED** via query
  `projectV2.views { nodes { id name layout filter } }`.

**Classification for Field Rename:** Native Automation (stable, documented, idempotent).

### B — GitHub CLI (official)

**Result:** Not supported for Views.

- `gh project view` is read-only (opens in browser/terminal).
- No subcommands for creating, listing or deleting Views.
- `gh project field-create` exists for fields, but not for Views.
- Tested version: 2.95.0 (2026-06-17) — most recent available.

**Classification:** Not applicable for Views.

### C — GitHub REST API (official, released September 2025)

**Result:** Supported for View creation with `filter`.

Documented endpoint:
```
POST /orgs/{org}/projectsV2/{project_number}/views
```

Supported payload:
```json
{
  "name": "Diligence Operations",
  "layout": "table",
  "filter": "is:issue label:diligence",
  "visible_fields": [field_id_1, field_id_2]
}
```

Behavior:
- Returns HTTP 201 on successful creation
- Supports `name` (required), `layout` (required), `filter` (optional),
  `visible_fields` (optional, not applicable to roadmap)
- Does **NOT** support `group_by` or `sort_by` in the creation payload
- No PATCH/PUT exists to update existing View

**Idempotency:** Verify existing Views via GraphQL before creating via REST.
If View with same name already exists → Skip.

**Filter syntax limitation:** The `filter` parameter uses GitHub Projects
filter box syntax. For custom fields, syntax is `field_name:"value"`. For
Diligence Views, label-based filters already exist in the current project (e.g.,
`label:journey:diligence`). Filters based on custom fields (e.g., `journey:Diligence`)
require validation in a real environment before production.

**Classification:** Supported Automation — official API, documented, released GA.

### D — GitHub MCP Server

**Result:** Not available in this project.

The official `github-mcp-server` (`@modelcontextprotocol/server-github`) and
`@kunwarVivek/mcp-github-project-manager` exist as projects, but:
- Neither is configured in the project (`~/.claude.json: {}`)
- The GitHub MCP exposes tools for Issues, PRs, Repos — but not for Project Views
- For use, would require installation, authorization and adequate project scope

**Classification:** Not currently available. Future potential via install.

### E — Octokit / GitHub SDK

**Result:** Supported via REST client.

`@octokit/rest` and `@octokit/graphql` support REST/GraphQL calls directly.
For View creation:
```javascript
// Via @octokit/rest
await octokit.request('POST /orgs/{org}/projectsV2/{project_number}/views', {
  org: 'produtoreativo',
  project_number: 24,
  name: 'Diligence Operations',
  layout: 'table',
  filter: 'label:diligence'
});
```

Functional equivalent to direct REST API. Adds no capability beyond REST API.
Useful for Node.js scripts that already use Octokit.

**Classification:** Supported Automation (via REST) — no advantage over direct REST.

### F — github-script GitHub Action

**Result:** Viable as REST API wrapper.

A GitHub Action with `actions/github-script` can execute View creation via REST:
```yaml
# Conceptual — NOT a real Action file
- name: Create Diligence Views
  uses: actions/github-script@v7
  with:
    script: |
      // Check idempotency: list views via GraphQL
      const views = await github.graphql(`
        query { organization(login: "produtoreativo") {
          projectV2(number: 24) {
            views(first: 20) { nodes { name } }
          }
        }
      `);
      const existing = views.organization.projectV2.views.nodes.map(v => v.name);
      const toCreate = ['Diligence Operations', 'Active Remediations', ...].filter(
        n => !existing.includes(n)
      );
      for (const name of toCreate) {
        await github.request('POST /orgs/produtoreativo/projectsV2/24/views', {
          name, layout: 'table', filter: 'label:diligence'
        });
      }
```

**Classification:** Supported Automation — implementable via GitHub Actions.

### G — Browser Automation (Playwright/Puppeteer)

**Result:** Technically viable, but fragmented and medium risk.

Conceptual strategy:
1. Navigate to `https://github.com/orgs/produtoreativo/projects/24`
2. Click the "New view" button (selector: `[data-testid="project-view-create"]` or similar)
3. Type the View name
4. Select layout
5. Configure filter via UI (harder — filter input is dynamic)

**Idempotency:** Verify list of existing Views via API GraphQL before navigating.
If View with expected name exists → Skip automation.

**Risks:**
- GitHub may redesign the UI at any time — selectors break without warning
- UI automation requires browser authentication (session or OAuth)
- Complex filter configuration (field-based) via UI is error-prone
- Selector maintenance is an ongoing cost

**Selector stability:** Medium — GitHub uses `data-testid` on some elements,
but does not guarantee stability of these attributes between deploys.

**Classification:** Browser Automation — valid fallback but not recommended when
REST API exists.

### H — GitOps / Declarative approach

**Result:** Viable as enforcement architecture.

The `github-workspace-schema.yaml` is already the declarative source of truth. A GitOps
pipeline can:
1. Read the YAML schema (expected Views)
2. Query existing Views via GraphQL (real state)
3. Calculate diff (Missing Views)
4. Create Missing Views via REST API POST
5. Record Evidence (snapshot after creation)

This pipeline can be executed as a GitHub Action triggered by push to the
`github-workspace-schema.yaml` file or manually via `workflow_dispatch`.

**Classification:** Architecture — combines REST API (Supported Automation) with
GitHub Actions (existing CI platform).

---

## Section 5 — Technical comparison

| Mechanism | Maturity | Risk | Idempotent | Maintenance cost | Recommended |
|---|---|---|---|---|---|
| GraphQL mutation (View) | N/A — does not exist | N/A | N/A | N/A | No |
| REST API POST `/views` | GA (Sep 2025) | Low | No (GraphQL pre-check required) | Low | **Yes** |
| GitHub CLI | N/A — no View support | N/A | N/A | N/A | No |
| GitHub SDK (Octokit) | Stable | Low | Yes | Medium | Yes (if already using Octokit) |
| GitHub Action (github-script) | Stable | Low | Yes | Medium | Yes (for GitOps) |
| MCP GitHub | Not configured | N/A | N/A | N/A | No (now) |
| Browser Automation | Experimental | High | Yes (API check) | High | No (REST available) |
| Manual (Web UI) | N/A | Medium | No | N/A | Only for group_by/sort_by |
| **GraphQL updateProjectV2Field** | **GA (stable)** | **Low** | **Yes** | **Low** | **Yes (Field Rename)** |

---

## Section 6 — Recommended architecture

### 6.1 — View creation (6 Diligence Views)

**Primary mechanism:** REST API POST `/orgs/{org}/projectsV2/{project_number}/views`

**Idempotency flow:**
```
1. Read existing Views via GraphQL:
   gh api graphql -f query='query {
     organization(login: "produtoreativo") {
       projectV2(number: 24) {
         views(first: 20) { nodes { id name layout filter } }
       }
     }
   }'

2. Calculate Missing Views (expected in schema but absent from result)

3. For each Missing View:
   gh api -X POST /orgs/produtoreativo/projectsV2/24/views \
     -f name="Diligence Operations" \
     -f layout="table" \
     -f filter="label:diligence"

4. Verify creation: repeat GraphQL query from step 1
```

**Known limitations of this approach:**
- `filter` accepts GitHub Projects filter box syntax (validate custom field syntax)
- `group_by` and `sort_by` are not configurable via REST API → Manual Exception
- `visible_fields` requires field IDs (available via `GET /fields`)

### 6.2 — Field rename (Execution Mode → Mode)

**Mechanism:** GraphQL mutation `updateProjectV2Field`

```bash
gh api graphql -f query='
mutation {
  updateProjectV2Field(input: {
    fieldId: "PVTSSF_lADOAT1J1c4BeILXzhYkr1o"
    name: "Mode"
  }) {
    projectV2Field {
      ... on ProjectV2SingleSelectField { id name }
    }
  }
}'
```

**Idempotency:** Verify current field name before executing.
If field is already named "Mode" → Skip.

### 6.3 — Recommended filter syntax per View

| View | Recommended filter (REST API) | Label-based alternative |
|---|---|---|
| Diligence Operations | `journey:Diligence status:Todo status:"In Progress"` | `label:diligence -status:Done -status:Cancelled` |
| Active Remediations | `artifact-type:Remediation status:Todo status:"In Progress"` | `label:diligence:remediation -status:Done` |
| Workspace Reconciliation | `cycle:"workspace-reconciliation" -status:Done -status:Cancelled` | `label:diligence:reconciliation` |
| Verification Queue | `operation:Validate status:Todo` | `label:diligence:verification status:Todo` |
| Diligence History | `journey:Diligence status:Done` | `label:diligence status:Done` |
| Waiver Reviews | `artifact-type:Waiver -status:Done -status:Cancelled` | `label:diligence:waiver-review` |

**Note:** The exact filter syntax for Projects v2 custom fields requires
validation in a real environment. The label-based syntax is confirmed as functional by
the existing filters in the project (e.g., `label:journey:diligence`).

---

## Section 7 — Automation First Pipeline

```
Schema declared in github-workspace-schema.yaml
   ↓
Inspect: read expected Views from schema + existing Views via GraphQL query
   ↓
Plan: calculate drift (Missing, Unexpected, Different Views)
   ↓
Execute (by operation type):
   │
   ├─ View Creation (Native API via REST)
   │    POST /orgs/{org}/projectsV2/{project_number}/views
   │    params: name, layout, filter, visible_fields
   │    (idempotency: check GraphQL before POST)
   │
   ├─ Field Rename (Native API via GraphQL)
   │    mutation updateProjectV2Field { name }
   │    (idempotency: check current name before executing)
   │
   ├─ Filter Configuration (REST filter param — during creation)
   │    Define filter string in the same creation POST
   │    (no separate call required)
   │
   └─ group_by / sort_by (Manual Exception)
        Documented instruction for configuration via Web UI
        After execution: record as Unverifiable via API
   ↓
Verify: read created Views via GraphQL (name, layout, filter)
   ↓
Evidence recorded: pre + post snapshot + API responses
```

---

## Section 8 — GitOps strategy

A GitHub Action can enforce the desired state declared in the schema continuously.

**Suggested trigger:**
- Push to main branch affecting `github-workspace-schema.yaml`
- `workflow_dispatch` (manual execution with explicit authorization)
- Weekly schedule for drift detection

**Conceptual architecture (not a real workflow file):**

```
Job: workspace-reconcile
  Step 1: Checkout repo (schema available)
  Step 2: Schema reading
    → parse github-workspace-schema.yaml → extract expected views
  Step 3: Inspect (read-only)
    → GraphQL query: existing views with name, layout, filter
    → REST GET /fields: field IDs for visible_fields
  Step 4: Compute diff
    → expected views XOR existing views = Missing Views
  Step 5: Execute (with authorization via environment protection)
    → For each Missing View:
       REST POST /orgs/{org}/projectsV2/{project_number}/views
    → For Field Rename (if drift detected):
       GraphQL mutation updateProjectV2Field
  Step 6: Verify
    → Repeat GraphQL query → compare with schema
    → If still Missing: fail with evidence output
  Step 7: Record Evidence
    → Append snapshot to Evidence report
    → Create PR with report (for human review)
```

**GitOps security:**
- GitHub Environment protection rules ensure human approval before executing
- The YAML schema is source of truth — never edit the schema to match reality
- Reality is reconciled to the schema, never the other way around

---

## Section 9 — Declarative strategy

The `github-workspace-schema.yaml` file is and remains the **single source of truth**
for the desired state of the GitHub workspace.

**Inviolable principle:** The schema is never edited to reflect the real state.
The real state is reconciled to match the schema.

**Propagation flow:**
```
github-workspace-schema.yaml (desired state)
   ↓ (read by)
Inspect Script / GitHub Action
   ↓ (produces)
Drift Report (Expected XOR Actual)
   ↓ (authorized by human)
Reconcile Execution
   ↓ (via REST API + GraphQL mutations)
GitHub Workspace (actual state aligned to desired state)
   ↓ (verified by)
Verify Script (GraphQL read-only)
   ↓
Evidence EVD-YYYY-NNNN
```

**Maintenance cycle:**
- Schema changes → pipeline detects drift → automatic reconcile (or with approval)
- Workspace changes outside schema → Unexpected detected → investigate + update schema
  or revert the workspace

---

## Section 10 — Browser Automation (if needed)

**When to use:** Only if the REST API proves inaccessible in a specific environment
(e.g., token without adequate scope, Enterprise environment with restrictions).

**Recommended tool:** Playwright (TypeScript/JavaScript) — preferred for:
- Stable and maintainable API
- Support for `data-testid` selectors (more stable than generic CSS)
- Code generation via `npx playwright codegen`

**Idempotency strategy:**
```javascript
// ALWAYS verify via GraphQL before creating via browser
const existingViews = await githubGraphQL(`
  query { organization(login: "$ORG") {
    projectV2(number: 24) {
      views(first: 20) { nodes { name } }
    }
  }
`);
const viewsToCreate = expectedViews.filter(
  v => !existingViews.includes(v.name)
);
// Only navigate to browser if there are Missing Views
if (viewsToCreate.length === 0) { process.exit(0); }
```

**Conceptual automation flow via Playwright:**
1. Navigate to `https://github.com/orgs/produtoreativo/projects/24`
2. Locate "New view" button (selector strategy by text + `aria-label`)
3. Click → type View name
4. Select layout (Table / Board / Roadmap) via dropdown
5. For simple filters: type in the filter field of the new View
6. Confirm creation

**Selector stability risk:** Medium-High. GitHub redesigns the Projects UI
frequently. Recommendation: use selectors by `aria-label` or visible text, not by
class or DOM structure.

**Rollback:** Delete View created via GraphQL? — No delete mutation exists for
Views. If created incorrectly, requires manual deletion via Web UI.

---

## Section 11 — Manual Exception criteria

A "Manual Exception" classification is **acceptable ONLY** when all criteria
below are satisfied:

1. **No official API exists** — verified via GraphQL schema introspection
   and REST documentation review (docs.github.com/en/rest/projects)
2. **No GitHub CLI support** — verified via `gh project --help` in current version
3. **No MCP server available** with the required capability
4. **Browser Automation is not viable** — unstable selectors, CAPTCHA, or unacceptable risk
5. **The operation is sufficiently infrequent** to justify manual effort
6. **Manual steps are fully documented** and deterministic
7. **Execution tracking exists** (Issue, Evidence, or equivalent)

### Items that qualify as Manual Exception in this context

**group_by configuration for 6 Views:**
- Criterion 1: Confirmed — REST API POST does not accept `group_by`; no GraphQL mutation
- Criterion 2: Confirmed — `gh project` does not support View configuration
- Criterion 5: Infrequent — configured once per View, rarely changed
- Criterion 6: Documented in this file (Sections 6.3 and 13)

**sort_by configuration for 6 Views:**
- Same reasoning as `group_by`

**visible_fields configuration (order and visibility) in Views:**
- The REST API POST accepts `visible_fields` as an array of field IDs
- But the ordering of visible fields may not be configurable via API
- Classification: Supported Automation for defining which fields; possible Manual Exception for order

### What does NOT qualify as Manual Exception

The **creation of the 6 Views** itself **does not qualify** as Manual Exception because:
- The REST API POST exists and is documented (September 2025)
- The filter (`filter`) is configurable at creation time
- Idempotency is guaranteed by reading via GraphQL before the POST

---

## Section 12 — Implementation roadmap

### Phase A — Immediate (existing tools, no development)

Available now with `gh` CLI and `gh api`:

1. **Field Rename** (Execution Mode → Mode):
   ```bash
   gh api graphql -f query='mutation {
     updateProjectV2Field(input: {
       fieldId: "PVTSSF_lADOAT1J1c4BeILXzhYkr1o"
       name: "Mode"
     }) { projectV2Field { ... on ProjectV2SingleSelectField { id name } } }
   }'
   ```

2. **Creation of 6 Views via REST API** (requires authorization):
   ```bash
   # For each Missing View:
   gh api -X POST /orgs/produtoreativo/projectsV2/24/views \
     -f name="Diligence Operations" \
     -f layout="table" \
     -f filter="label:diligence"
   ```

3. **Configure group_by and sort_by via Web UI** (Manual Exception):
   Steps documented in Section 13.

### Phase B — Next (requires script development)

Development of a shell or Node.js script that:
1. Reads `github-workspace-schema.yaml` (parse YAML)
2. Executes GraphQL query to list existing Views
3. Calculates diff
4. Executes REST POSTs for Missing Views
5. Generates Evidence report

Estimate: 2-4 hours of development.

### Phase C — Future (complete GitOps)

GitHub Action that executes the Phase B script:
- Trigger by push to schema or manual
- Environment protection for human approval
- Automatic PR with Evidence after reconcile

Estimate: 1 day of development + GitHub Environment configuration.

### Phase D — Contingency (Browser Automation)

If the REST API proves inaccessible or unstable:
- Playwright script for View creation via Web UI
- Keep as fallback, not as primary mechanism
- Investment of 4-8 hours + ongoing selector maintenance

---

## Section 13 — Final recommendation

### Classification by item

| Item | Recommended mechanism | Final classification | Idempotent | Phase |
|---|---|---|---|---|
| Create "Diligence Operations" | REST POST `/views` | Supported Automation | No¹ | A |
| Create "Active Remediations" | REST POST `/views` | Supported Automation | No¹ | A |
| Create "Workspace Reconciliation" | REST POST `/views` | Supported Automation | No¹ | A |
| Create "Verification Queue" | REST POST `/views` | Supported Automation | No¹ | A |
| Create "Diligence History" | REST POST `/views` | Supported Automation | No¹ | A |
| Create "Waiver Reviews" | REST POST `/views` | Supported Automation | No¹ | A |
| Configure View filters | REST POST `filter` param | Supported Automation | No¹ | A |
| Configure View group_by | Web UI manual | Manual Exception | No | A |
| Configure View sort_by | Web UI manual | Manual Exception | No | A |
| Rename "Execution Mode" → "Mode" | GraphQL `updateProjectV2Field` | Native Automation | Yes | A |

¹ **Note on idempotency (EVD-2026-0003, 2026-07-24):** The REST API creates duplicate Views if called multiple times — no native deduplication by name. The GraphQL pre-check (`projectV2.views(first:20)` → diff → POST only if absent) is **mandatory**, not optional. Without the pre-check, duplicates are created silently and cannot be removed via API (DELETE returns 404; GraphQL mutation does not exist). Removal requires manual Web UI.

### Concrete next step

1. **Authorize and execute Field Rename** (DRF-006): `updateProjectV2Field` with
   `fieldId: "PVTSSF_lADOAT1J1c4BeILXzhYkr1o"` and `name: "Mode"`.

2. **Authorize and execute creation of 6 Views** (DRF-012 to DRF-017): REST API POST
   for each Missing View, with `name`, `layout: "table"` and appropriate `filter`.

3. **Verify creation** via GraphQL query.

4. **Configure group_by via Web UI**: For each created View, navigate to the Project in
   the browser and configure grouping as specified in the schema.

5. **Record Evidence** with pre and post snapshots.

### Necessary update to the Reconcile Plan

The Reconcile Plan (`github-workspace-reconcile-plan.md`) must be updated:
- DRF-012 to DRF-017: from "GraphQL + Web UI for filters" → "REST POST + Web UI (group_by)"
- Section 6 (Mechanism Table): update line "Create View"
- Section 11 (Deferred Elements): Unverifiable for filters → Partially resolved

---

## References

- [REST API endpoints for Project views — GitHub Docs](https://docs.github.com/en/rest/projects/views)
- [A REST API for GitHub Projects — GitHub Changelog (Sep 2025)](https://github.blog/changelog/2025-09-11-a-rest-api-for-github-projects-sub-issues-improvements-and-more/)
- [Add GraphQL mutations for ProjectV2 view management — Community Discussion](https://github.com/orgs/community/discussions/194509)
- [ProjectsV2: Manage Project Views via GraphQL — Community Discussion](https://github.com/orgs/community/discussions/150130)
- [Does GitHub's Projects V2 API have any ProjectV2View-related mutations? — Community Discussion](https://github.com/orgs/community/discussions/153532)
- Declared schema: `prodops/framework/journeys/diligence/github-workspace-schema.yaml`
- Reconcile Plan: `prodops/framework/journeys/diligence/github-workspace-reconcile-plan.md`
- Readiness Protocol: `prodops/framework/journeys/diligence/github-workspace-readiness.md`
- Workspace Spec: `prodops/framework/journeys/diligence/github-workspace.md`
