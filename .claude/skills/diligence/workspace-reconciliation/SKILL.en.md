---
name: diligence/workspace-reconciliation
description: Orchestrate Inspect → Reconcile → Verify to align the GitHub Workspace with the Canonical Specification. Entry point for any caller (Bootstrap, Diligence Async, Diligence Sync). Never runs standalone as a third cycle.
---

# WORKSPACE RECONCILIATION — Orchestrator

Workspace Reconciliation is a **capability**, not a cycle. It is invoked by Bootstrap, Diligence Async, and Diligence Sync as a sub-routine to align the GitHub Workspace infrastructure with the Canonical Specification.

**Two managed projects:**
- `ProdOps — template` — canonical org template (source for copies)
- `ProdOps — <repo-name>` — managed project for the current repository

## Action

### 1. Read the caller context

Identify who invoked this capability:
- **Bootstrap** → run Inspect → Reconcile → Verify in full sequence. Return Conformance Report to Bootstrap.
- **Diligence Async** → run Inspect first; if Workspace Drift is detected, run Reconcile → Verify; if no drift, run only Verify to confirm and update the manifest.
- **Diligence Sync** → run Inspect to identify the specific gap that caused the blocker; run Reconcile only for that gap; run Verify.

If the caller cannot be identified, run the full sequence: Inspect → Reconcile → Verify.

### 2. Run Inspect

Read the Canonical Specification (`prodops/framework/github-workspace.md`) and the Actual Workspace (real GitHub state via API). Produce a Drift Report.

Follow: [steps/inspect/SKILL.md](steps/inspect/SKILL.md)

**Expected output:** Drift Report in the format:

```
=== DRIFT REPORT — <data> ===

LABELS (<N> ausentes, <N> divergentes): ...
MILESTONES (<N> ausentes): ...
TEMPLATE (ProdOps — template): ...
PROJETO GERENCIADO (ProdOps — <repo-name>): ...
```

### 3. Check for Workspace Drift

- **No drift:** skip Reconcile and go directly to Verify (confirm and update manifest).
- **With drift:** run Reconcile before Verify.

### 4. Run Reconcile (if Workspace Drift detected)

Execute the creations and updates identified by Inspect. For gaps that cannot be automated, open a tracking Issue.

Follow: [steps/reconcile/SKILL.md](steps/reconcile/SKILL.md)

**Mandatory order:** Labels → Template → Managed Project → Milestones. The managed project depends on the template existing.

### 5. Run Verify

Programmatically confirm the state of all categories and update the sync manifest.

Follow: [steps/verify/SKILL.md](steps/verify/SKILL.md)

**Expected output:** Conformance Report:

```
╔══════════════════════════════════════════════════════════════╗
║  CONFORMIDADE — <data>                                       ║
║  Repositório: <owner>/<repo>  |  Project: #<N>              ║
╠══════════════════════════════════════════════════════════════╣
║  Labels        ✅ CONFORME    — <N> labels em conformidade   ║
║  Custom Fields ✅ CONFORME    — 8/8 campos                   ║
║  Views         ✅ CONFORME    — 5/5 views                    ║
║  Milestones    ✅ N/A         — nenhum OBC com release       ║
╠══════════════════════════════════════════════════════════════╣
║  Resultado geral: CONFORME | PARCIAL | NÃO CONFORME          ║
╠══════════════════════════════════════════════════════════════╣
║  Automation Opportunities (se houver)                        ║
║  - <ação> — aguardando autorização para Browser Automation   ║
╠══════════════════════════════════════════════════════════════╣
║  Known Platform Limitations (se houver)                      ║
║  - group_by: GitHub API não suporta (REST 404, sem GraphQL)  ║
╠══════════════════════════════════════════════════════════════╣
║  Próxima Ação (se Automation Opportunities presentes)        ║
║  Posso executar via Browser Automation. Deseja que execute?  ║
╚══════════════════════════════════════════════════════════════╝
```

When there is no Workspace Drift: report "Desired state satisfied. No reconciliation actions required." — never "Reconcile skipped."

### 6. Return to caller

Deliver the Conformance Report to the caller with:
- Overall result: `CONFORME`, `PARCIAL`, or `NÃO CONFORME`
- Issues opened for gaps that cannot be automated (with number and link)
- "Automation Opportunities" section for actions achievable via Browser Automation awaiting authorization
- "Known Platform Limitations" section for demonstrated API limitations with tracking via Issue
- Product Owner pending actions (e.g. Milestone creation) referenced by Issue — never as a floating instruction

When there is no Workspace Drift: report "Desired state satisfied. No reconciliation actions required." — never "Reconcile skipped."

## Post-conditions

Completed when **all** of the following are true:

- Drift Report produced by Inspect
- Reconcile executed if Workspace Drift was detected
- Verify executed and Conformance Report produced
- Sync manifest updated with the verified state
- Caller received the Conformance Report

## Guardrails

- **Never operate on manual projects** — any project without the `ProdOps — ` prefix is ignored.
- **Never run as a standalone cycle** — this capability is always invoked by a caller.
- **Mandatory order:** Inspect → (Reconcile if drift) → Verify. Never invert.
- **Identify projects by exact name, never by number.**
- **Sync manifest is updated only by Verify** — never by Inspect or Reconcile.
- **Automation First (Principle 8)** — try API → MCP → CLI → SDK → Browser Automation before declaring any limitation. Manual Exception only when everything fails, always with a tracking Issue opened. See [automation-first.md](../../../framework/automation-first.md).

## References

→ [Capability README](../../../framework/journeys/diligence/workspace-reconciliation.md)
→ [Canonical Specification](../../../framework/github-workspace.md)
→ [GitHub Sync Manifest](../../../artifacts/trails/github-sync-manifest.md)
