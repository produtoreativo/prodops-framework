---
name: diligence
description: Synchronize OBC state across backlogs and tools. Runs event-driven cycle (diligence-sync) or proactive drift-scan cycle (diligence-async). Never touches product code.
---

# DILIGENCE

Diligence is the transversal journey that keeps the ProdOps work system synchronized and consistent. It never implements software, never creates implementation Pull Requests, and never modifies product code. Its scope is: OBCs, backlogs, management artifacts, and external tools.

## Commands

| Command | Scope | Orchestrator |
|---|---|---|
| `/diligence diligence-sync <obc-id>` | Capture → Attach → Promote → Close for the given OBC | [diligence-sync/SKILL.md](diligence-sync/SKILL.md) |
| `/diligence diligence-async` | Scan → Flag → Repair across all active OBCs and Issues | [diligence-async/SKILL.md](diligence-async/SKILL.md) |
| `/diligence full <obc-id>` | diligence-sync for the OBC + diligence-async | — |
| `/diligence workspace-reconciliation` | Inspect → Reconcile → Verify of the GitHub Workspace. Invocable by the user and by the cycles. | [workspace-reconciliation/SKILL.md](workspace-reconciliation/SKILL.md) |

When scope is omitted, use `diligence-sync` and report that choice explicitly.

## Steps

When invoked with a step argument (`/diligence diligence-sync capture`), execute only that step.

| Command | Step | File |
|---|---|---|
| diligence-sync | `capture` | [diligence-sync/steps/capture/SKILL.md](diligence-sync/steps/capture/SKILL.md) |
| diligence-sync | `attach` | [diligence-sync/steps/attach/SKILL.md](diligence-sync/steps/attach/SKILL.md) |
| diligence-sync | `promote` | [diligence-sync/steps/promote/SKILL.md](diligence-sync/steps/promote/SKILL.md) |
| diligence-sync | `close` | [diligence-sync/steps/close/SKILL.md](diligence-sync/steps/close/SKILL.md) |
| diligence-async | `scan` | [diligence-async/steps/scan/SKILL.md](diligence-async/steps/scan/SKILL.md) |
| diligence-async | `flag` | [diligence-async/steps/flag/SKILL.md](diligence-async/steps/flag/SKILL.md) |
| diligence-async | `repair` | [diligence-async/steps/repair/SKILL.md](diligence-async/steps/repair/SKILL.md) |
| workspace-reconciliation | `inspect` | [workspace-reconciliation/steps/inspect/SKILL.md](workspace-reconciliation/steps/inspect/SKILL.md) |
| workspace-reconciliation | `reconcile` | [workspace-reconciliation/steps/reconcile/SKILL.md](workspace-reconciliation/steps/reconcile/SKILL.md) |
| workspace-reconciliation | `verify` | [workspace-reconciliation/steps/verify/SKILL.md](workspace-reconciliation/steps/verify/SKILL.md) |

## Inputs

- Active OBC: `prodops/artifacts/obcs/<obc-id>.md`
- Iteration Plan: `prodops/artifacts/plans/iteration-plan.md`
- BDD Features: `prodops/artifacts/bdd/`
- Risks: `prodops/artifacts/risks/risks.md`
- Work Item Schema: `prodops/framework/execution-mapping/work-item-schema.md`
- Execution Matrix: `prodops/framework/execution-mapping/matrix.md`

## Diligence Sync flow

1. **Capture** — create or update the OBC from the decision that triggered the cycle. Canonical state lives only in Markdown.
2. **Attach** — verify or create the Work Item referencing the OBC in the external backlog.
3. **Promote** — advance the item through the backlog hierarchy, verifying preconditions at each transition.
4. **Close** — close the Work Item when the OBC reaches Operational state.

Stop at any blocker. Record the missing artifact, the responsible journey, and the concrete action before stopping.

## Diligence Async flow

1. **Scan** — read all active OBCs and Issues, compare declared state against external tools, and verify title and label conformance.
2. **Flag** — classify divergences by severity and corrective action.
3. **Repair** — execute corrections for repairable items; escalate blocked items.

## Workspace Reconciliation

Compares the Canonical Specification (`prodops/framework/github-workspace.md`) against the Actual Workspace (real GitHub state via API) and reconciles divergences.

1. **Inspect** — read spec and actual state; produce Drift Report.
2. **Reconcile** — create missing labels, custom fields, views, repo↔project links. Never removes without confirmation. For non-automatable gaps: open an Issue.
3. **Verify** — confirm conformance post-Reconcile, produce Conformance Report, and update sync manifest.

Invocable by the user (`/diligence workspace-reconciliation`) and by cycles (Bootstrap, Diligence Async, Diligence Sync). Always returns the Conformance Report to the caller.

## Guardrails

- Never implement software or modify product code.
- Never create implementation Pull Requests.
- Never make product decisions — those belong to Assessment.
- Never skip a Promote transition without recording the missing precondition and its canonical artifact.
- Never invent OBCs, BDD Features, or risks without a documented canonical trigger. Diligence CAN create or register an OBC when an explicit canonical trigger exists: a completed experiment with a recorded decision, a documented Assessment decision, an Operation signal that justifies the artifact, or an active authorized operation. What Diligence never does: invent content, intent, or business commitment.
- Always use the canonical Work Item title pattern: `[Artifact ID]: description`. Declare `operation:<value>` and `artifact-type:<value>` as Issue labels.
- Always fill in `artifact_type`, `artifact_id`, `operation`, and `journey` when creating Work Items.
- Stop and surface a blocker when a divergence requires a product decision to be resolved.

### Guardrails for the managed project

- **The managed project is identified by name `ProdOps — <repo-name>`, never by number.** The number changes with each creation — the name is the contract.
- **Manual projects are untouchable.** Any project whose name does not start with `ProdOps — ` is ignored by Diligence. Do not create fields, views, or Issues in them without explicit user directive.
- **Creation is automatic via API.** If the managed project does not exist, `gh project create` is the path — do not open an Issue for that.
- **Template strategy:** once the managed project is fully configured, `gh project mark-template` + `gh project copy` enables bootstrapping new repositories without manual configuration.
- **PUBLIC visibility by default** — every managed project (`ProdOps — template`, `ProdOps — <repo>`) is created and maintained as PUBLIC. Change to PRIVATE only upon explicit directive. Workspace verifies and Provision corrects automatically.

### Workspace Reconciliation guardrails

- **Workspace Reconciliation is a command** — invocable directly by the user with `/diligence workspace-reconciliation` or by cycles (Bootstrap, Async, Sync).
- **Automation First (Principle 8)** — try API → MCP → CLI → SDK → Browser Automation before declaring impossibility. Never instruct the user to execute actions manually without first demonstrating that all automation options have been exhausted. See [automation-first.md](../../framework/automation-first.md).
- **No gap without a tracking Issue** — any action that cannot be automated generates an Issue with title `infra: <description>`, labels `operation:provision` and `journey:diligence`, and body containing the API error, the required action, and the resolution criterion.
- **Never declare "manual action" as floating text** — instructions to the human go in the Issue body, not as agent output messages. The agent output lists Automation Opportunities and Known Platform Limitations.
- **Sync manifest as the source of truth** — the manifest records: CONFORME (verified via API in this cycle), PARCIAL (Issue #X opened with documented gap), or NÃO CONFORME (automatable problem not resolved).
- Temporary Reconcile scripts created in the scratchpad must be documented in the manifest History with path and result.

## References

→ [Diligence journey README](../../framework/journeys/diligence/README.md)
→ [Execution Mapping](../../framework/execution-mapping/README.md)
→ [Work Item Schema](../../framework/execution-mapping/work-item-schema.md)
→ [Mapping Matrix](../../framework/execution-mapping/matrix.md)
