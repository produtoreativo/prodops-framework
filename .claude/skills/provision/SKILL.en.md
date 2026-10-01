---
name: provision
description: Provisions the product's GitHub Workspace from virgin state — creates the managed project by copying the canonical template, links it to the repository, and records the project-number in runtime.yaml. Executes only when project-number = 0 in runtime.yaml.
---

# Provision Skill

Provisions the product's GitHub Project from the canonical template
(`ProdOps — template`), links it to the repository, and records the
`project-number` in `runtime.yaml`. Entry gate: `project-number: 0`.

**Do not use this skill to update an existing project.** If the project
exists but has drift, use `workspace-reconciliation`.

---

## When to Use

- First product setup (virgin state: `project-number: 0`)
- After deliberate project deletion for re-provisioning

**Invocation:** `/provision`

---

## Mandatory Reading

1. `prodops/runtime/runtime.yaml` — confirm `project-number: 0`, read `owner` and `repository`
2. `prodops/framework/github-workspace.md` — canonical fields and view expected

---

## Moment 1 — Verify Virgin State

Read `runtime.yaml`. If `project-number` ≠ 0: stop and report the current
number. The project already exists — use `workspace-reconciliation` to
diagnose drift.

If `project-number: 0`: proceed.

Record in memory: `owner`, `repository`.

---

## Moment 2 — Locate Canonical Template

```bash
gh project list --owner <owner> --format json
```

Locate the project whose `title` is exactly `ProdOps — template`.
Record the template number.

If not found: stop. Report that the canonical template is absent.
The template must be created via `workspace-reconciliation reconcile`
before provisioning.

---

## Moment 3 — Create Managed Project

```bash
gh project copy <template-number> \
  --source-owner <owner> \
  --target-owner <owner> \
  --title "ProdOps — <repository>"
```

After copying, confirm the new project appears in the listing with
`title: "ProdOps — <repository>"` and record its `number` and `id`.

Make PUBLIC immediately after copying:

```bash
gh project edit <number> --owner <owner> --visibility PUBLIC
```

---

## Moment 4 — Link to Repository

`gh project copy` copies fields and views but **does not** link the project
to the repository. Execute this step mandatorily:

```bash
gh api graphql -f query='
  mutation {
    linkProjectV2ToRepository(input: {
      projectId: "<project-id>"
      repositoryId: "<repo-id>"
    }) { repository { nameWithOwner } }
  }'
```

To obtain the `repositoryId`:

```bash
gh repo view <owner>/<repository> --json id -q '.id'
```

Confirm that `nameWithOwner` in the response corresponds to `<owner>/<repository>`.

---

## Moment 5 — Record project-number in runtime.yaml

Update `prodops/runtime/runtime.yaml`:

```yaml
github:
  owner: <owner>
  repository: <repository>
  project-number: <N>   # real number returned by Moment 3
```

Commit:

```
chore(prodops): provisiona GitHub Project — <repository>
```

---

## Moment 6 — Validate

Verify the final state of the created project:

```bash
gh api graphql -f query='
query {
  node(id: "<project-id>") {
    ... on ProjectV2 {
      title number public
      fields(first: 30) { totalCount }
      views(first: 5) { totalCount nodes { name layout } }
    }
  }
}'
```

Success criteria:

| Item | Expected |
|---|---|
| `title` | `ProdOps — <repository>` |
| `public` | `true` |
| `fields.totalCount` | 27 (13 built-in + 14 custom) |
| `views.totalCount` | 1 |
| view name | `01 — Delivery Timeline` |
| view layout | `BOARD_LAYOUT` |

If any criterion fails: report the deviation and do not proceed to commit.

---

## Known Platform Limitations

- **`group_by` in views:** not configurable via API (REST 404, GraphQL
  without mutation). Configure via UI if needed.
- **DELETE views via REST:** `DELETE /orgs/{org}/projectsV2/{N}/views/{V}`
  returns 404. Use GraphQL:
  `deleteProjectV2View(input: { viewId: "..." }) { __typename }`
- **`gh project copy` does not link to repository:** always execute
  Moment 4 after copying.
- **Visibility inherited from template:** `gh project copy` inherits the
  source visibility — verify and fix with `gh project edit` after copying.

---

## Guardrails

- **Never execute** if `project-number` ≠ 0 — use `workspace-reconciliation`.
- **Never create the project without the canonical template** — the template is a prerequisite.
- **Never commit** the `project-number` without validating Moment 6.
- **Never modify** the canonical template in this skill — use
  `workspace-reconciliation reconcile` to update the template.

---

## References

→ [github-workspace.md](../../framework/github-workspace.md) — canonical spec of fields and views
→ [runtime.yaml](../../runtime/runtime.yaml) — where project-number is recorded
→ [workspace-reconciliation](../diligence/workspace-reconciliation/SKILL.md) — for post-provisioning drift
