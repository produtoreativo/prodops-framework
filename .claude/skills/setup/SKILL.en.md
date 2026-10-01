---
name: setup
description: Configures a newly installed ProdOps repository — fills runtime.yaml placeholders, provisions canonical labels, creates the GitHub Project, and prepares the .env. Idempotent — executes only pending steps. Should be the first skill invoked in any new repo.
---
<!-- MATERIALIZED FILE — prodops/skills/setup/SKILL.en.md -->

# Setup Skill

Orchestrates the complete setup of a repository after ProdOps installation.
Detects what is still in virgin state and executes only those steps —
never overwrites existing configuration.

**Run `/setup` before any other skill** in a freshly installed repo.

---

## When to Use

- Immediately after `install-prodops.sh` in a new repo
- When any `runtime.yaml` value is still a placeholder (`YOUR_*` or `project-number: 0`)
- To diagnose what is missing in an existing repo

**Invocation:** `/setup`

---

## Mandatory Reading

1. `prodops/runtime/runtime.yaml` — current configuration state
2. `prodops/framework/github-workspace.md` — canonical list of labels and fields

---

## Moment 1 — State Diagnosis

Read `prodops/runtime/runtime.yaml` and classify each field:

| Field | Pending if... |
|---|---|
| `github.owner` | value is `YOUR_ORG` |
| `github.repository` | value is `YOUR_REPO` |
| `cloud-events.source` | contains `YOUR_ORG` or `YOUR_REPO` |
| `github.project-number` | value is `0` |
| `datadog.service` | value is `YOUR_SERVICE` |

Also check:
- 38 canonical labels present in the repo (`gh label list`)
- `.env` present and in `.gitignore`

Report the full diagnosis before executing any step.
If no field is pending: report "Setup already complete" and stop.

---

## Moment 2 — Fill runtime.yaml

For each pending field identified in M1:

**`owner` and `repository`:**
```bash
git remote get-url origin
# https://github.com/ORG/REPO.git  →  owner=ORG, repository=REPO
# git@github.com:ORG/REPO.git      →  owner=ORG, repository=REPO
```

**`cloud-events.source`:**
```
https://github.com/<owner>/<repository>
```

**`datadog.service`:**
Use `<repository>` as default value. The operator can override later.

**`project-number`:**
Do not change here — will be filled by `/provision` in Moment 4.

Update `prodops/runtime/runtime.yaml` with the inferred values.
Do not commit yet — the single commit happens in Moment 4 after project-number is filled.

---

## Moment 3 — Provision Canonical Labels

Create 38 canonical labels via `gh label create`. Idempotent — skip already
existing labels without error.

**Family `operation` — color `#0075ca`:**
`operation:capture`, `operation:create`, `operation:define`, `operation:refine`,
`operation:update`, `operation:prototype`, `operation:review`, `operation:approve`,
`operation:validate`, `operation:split`, `operation:merge`, `operation:promote`,
`operation:implement`, `operation:experiment`, `operation:release`,
`operation:archive`, `operation:deprecate`, `operation:discard`,
`operation:cancel`, `operation:provision`

**Family `artifact-type` — color `#e4e669`:**
`artifact-type:business-signal`, `artifact-type:business-intent`,
`artifact-type:global-obc`, `artifact-type:local-obc`, `artifact-type:bdd-feature`,
`artifact-type:architecture`, `artifact-type:iteration-plan`,
`artifact-type:reliability-plan`, `artifact-type:release-trail`,
`artifact-type:experiment`, `artifact-type:evidence`,
`artifact-type:risk-register`, `artifact-type:context-capsule`

**Family `journey` — color `#d93f0b`:**
`journey:discovery`, `journey:assessment`, `journey:delivery`,
`journey:operation`, `journey:diligence`

```bash
# Creation pattern (idempotent):
gh label create "operation:capture" \
  --repo <owner>/<repository> \
  --color "0075ca" \
  --description "ProdOps operation: capture" 2>/dev/null || true
```

Repeat for all 38 labels. Confirm count at the end.

---

## Moment 4 — Run `/provision`

Check if `project-number` is still `0`. If so, invoke the `/provision` skill:

1. Locate `ProdOps — template` via `gh project list --owner <owner>`
2. `gh project copy <template-number> --source-owner <owner> --target-owner <owner> --title "ProdOps — <repository>"`
3. `gh project edit <number> --owner <owner> --visibility PUBLIC`
4. Link to repository via GraphQL `linkProjectV2ToRepository`
5. Update `project-number` in `runtime.yaml`

If `project-number` ≠ 0: skip this moment — project already provisioned.

After the project is provisioned (or confirmed existing): make the **single commit**
for all `runtime.yaml` changes accumulated in Moments 2 and 4:

```
chore(prodops): setup inicial — runtime.yaml + GitHub Project
```

---

## Moment 5 — Configure .env

1. Check if `.env` exists at the repository root
2. If it does not exist and `.env.example` exists: copy `.env.example` → `.env`
3. If `.env.example` does not exist: create empty `.env` with instruction comment
4. Check if `.env` is in `.gitignore` — if not: add it and commit separately
5. Report which `DD_*` variables still have placeholder or empty values

Never commit `.env`. Never log its contents.

---

## Moment 6 — Validate

Run the final conformance checklist:

| Item | Check |
|---|---|
| `runtime.yaml` without `YOUR_*` | `grep -c YOUR_ prodops/runtime/runtime.yaml` == 0 |
| `project-number` ≠ 0 | field read |
| 38 labels present | `gh label list --limit 60 \| grep -cE "^(operation\|artifact-type\|journey):"` == 38 |
| `.env` present | `test -f .env` |
| `.env` in `.gitignore` | `grep -q "^\.env" .gitignore` |
| GitHub Project linked | GraphQL query `ProjectV2.repositories` |

Report result:

```
Setup — COMPLETE
```

or

```
Setup — PARTIAL
Pending:
  - <item>: <reason>
  - ...
Action: fix manually or re-run /setup
```

---

## Guardrails

- **Never overwrite** already configured (non-placeholder) values in `runtime.yaml`
- **Never commit `.env`** — check `.gitignore` before any `git add`
- **Never invent** `owner` or `repository` — infer exclusively from remote origin
- **Never skip** Moment 6 — setup is only considered complete after validation
- **Never run `/provision`** if `project-number` ≠ 0

---

## References

→ [github-workspace.md](../../../prodops/framework/github-workspace.md) — canonical label list
→ [/provision](../provision/SKILL.md) — sub-step of Moment 4
→ [runtime.yaml](../../../prodops/runtime/runtime.yaml) — file configured by this skill
→ [install-prodops.sh](../../../prodops/scripts/install-prodops.sh) — installation script that precedes this skill
