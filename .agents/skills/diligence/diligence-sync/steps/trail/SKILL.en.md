---
name: diligence/trail
description: Post a phase trail comment on the iteration tracking issue whenever a key Delivery event is received. Triggered by the dispatcher — never invoked directly by Delivery skills.
---

# DILIGENCE SYNC → TRAIL

**Responsibility:** maintain the phase history on the iteration tracking issue. Trail is the only skill that writes to that issue — Delivery never comments on it directly.

Trail does not emit Diligence events. It does not modify OBCs, backlogs, or timelines. It only posts the right comment, at the right moment, on the right issue.

## Input context

The dispatcher invokes Trail with the context of the Delivery event that triggered it:

| Field | Source |
|---|---|
| `cloud-event-type` | type of the event that triggered the trail |
| `work-item-id` | feature issue number (may be `null` for plan events) |
| `iteration-id` | iteration version (e.g. `v0.10.0`) |
| `correlation-id` | UUID of the current execution |
| `actor.player` | agent in execution |

## Action

### 1. Locate the tracking issue

Resolve `ITERATION_DIR = prodops/artifacts/iterations/<iteration-id>/runtime/` and read `plan-bootstrap.json`:

```bash
PLAN_BOOTSTRAP="prodops/artifacts/iterations/<iteration-id>/runtime/plan-bootstrap.json"
PLAN_ISSUE=$(jq -r '."plan-issue"' "$PLAN_BOOTSTRAP")
```

If `plan-bootstrap.json` does not exist or `plan-issue` is null: **stop silently** — there is no tracking issue registered yet. Do not create an issue, do not emit an error.

### 2. Select the comment template by event

| `cloud-event-type` | Comment title | Emoji |
|---|---|---|
| `prodops.delivery.plan.bootstrap.completed` | Plan Bootstrap — Concluído | 🚀 |
| `prodops.delivery.plan.bootstrap.issue.entered` | Issue Entrou no Plano | 📋 |
| `prodops.delivery.bootstrap.completed` | Bootstrap — Concluído | ⚙️ |
| `prodops.delivery.hack.completed` | Hack — Implementação Concluída | 🔨 |
| `prodops.delivery.sync.completed` | Sync — PR Aprovado e Merged | 🔀 |
| `prodops.delivery.finish.completed` | Finish — Quality Gates Passaram | ✅ |
| `prodops.delivery.ship.completed` | Ship — Deploy Staging Concluído | 🚢 |
| `prodops.delivery.validate.completed` | Validate — Critérios Confirmados | 🔍 |
| `prodops.delivery.plan.validated` | Plan Validated — Gate de Promote Aberto | 🎯 |
| `prodops.delivery.promote.completed` | Promote — DONE | 🏁 |
| `prodops.delivery.block.declared` | ⚠️ BLOQUEIO DECLARADO | 🚨 |
| `prodops.delivery.block.resolved` | Bloqueio Resolvido | ✅ |
| `prodops.delivery.restart.completed` | Restart Concluído | 🔄 |

### 3. Post the comment

```bash
gh issue comment "$PLAN_ISSUE" --body "$(cat <<'COMMENT'
## <emoji> <título> — <YYYY-MM-DD HH:MM UTC>

**Issue:** #<work-item-id> (<DS-ID> · <capability-slug>)
**Event:** `<cloud-event-type>`
**correlation-id:** `<correlation-id>`

<summary in up to 3 lines: what happened in this phase, key evidence>

---
*iteration: <iteration-id> · actor: <actor.player> · diligence.trail*
COMMENT
)"
```

**Special cases:**

- **`plan.bootstrap.completed`** — `work-item-id` is null; omit the Issue line. List the plan issues extracted from `plan-bootstrap.json`:
  ```
  **Issues no plano:** #<issue-1> (<DS-ID-1>), #<issue-2> (<DS-ID-2>)
  ```

- **`plan.bootstrap.issue.entered`** — one call per issue. Inform the DS-ID and slug of the issue that entered.

- **`plan.validated`** — `work-item-id` is null; omit the Issue line. Inform that the Promote gate is open for all issues.

- **`block.declared`** — include the reason for the blocker (field `payload.reason` from the event if available). Use title with red emoji to highlight urgency.

- **`promote.completed`** — include final state `DONE` and confirm that the issue was closed on GitHub.

### 4. Verify output

If `gh issue comment` returns an error:
- Log: `⚠️ diligence.trail: falha ao comentar na issue #<PLAN_ISSUE> — <mensagem de erro>`
- **Do not propagate the error** — a trail failure must not interrupt the Delivery flow.

## Post-conditions

- Comment posted on the `plan-issue` with context of the event that triggered it.
- No repository artifacts modified.
- No Diligence events emitted.

## Guardrails

- Do not comment on `work-item-id` — Trail writes exclusively to the `plan-issue`.
- Do not create the `plan-issue` if it does not exist — that is the responsibility of Plan Bootstrap.
- Do not emit Diligence events.
- Do not modify OBCs, backlogs, timelines, or context capsules.
- Stop silently if `plan-bootstrap.json` does not exist — Trail does not block the flow.
- Do not attempt to post a generic comment when the event is not listed in Section 2's table — ignore silently.

## Out of scope

- `trail` **does not** capture OBC state — that is Capture.
- `trail` **does not** create Work Items — that is Attach.
- `trail` **does not** move items in the backlog — that is Promote.
- `trail` **does not** scan for divergences — that is Scan.
- `trail` **does not** comment on feature issues (`work-item-id`) — that is the responsibility of the Downstream orchestrator (step 6b-ii).
