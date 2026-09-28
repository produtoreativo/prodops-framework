[Português](mcp-boundaries.md)

# MCP Boundaries — ProdOps Framework

Defines what is the responsibility of MCP (Model Context Protocol) versus repository artifacts versus canonical framework definitions. The separation is necessary so that the canon does not depend on the availability of external systems.

---

## Fundamental principle

> **MCP exposes current state and tools. It never defines canonical concepts.**

Lifecycle definitions, glossary terms, governance rules, and artifact structure reside exclusively in `prodops/framework/` and `prodops/skills/`. MCP accesses external operational state — it is never the source of truth about what the framework *means*.

---

## Boundary matrix

| Information | Canonical source | MCP tool | Note |
|---|---|---|---|
| OBC definition, CommitmentGate, lifecycle | `prodops/framework/` | ❌ Never via MCP | Immutable canon; MCP may be unavailable |
| Current OBC state (Draft/Refining/etc.) | `prodops/artifacts/obcs/<slug>.md` | ❌ Read locally | Markdown file is source of truth |
| GitHub Issues — state, labels, assignees | `gh issue view` (Bash) or MCP GitHub | ✅ External state | Complements artifacts; does not replace them |
| PRs — status, checks, review | MCP GitHub / `gh pr view` | ✅ External state | CI/CD state does not live in artifacts |
| Observability metrics (DORA, SLOs) | MCP Datadog / observability | ✅ External state | Read only; never written via MCP |
| Runtime events / Observable Events | MCP runtime or `prodops/runtime/` | ✅ External state | Emission via skills, not directly via MCP |
| Current Iteration Plan | `prodops/artifacts/plans/iteration-plan.md` | ❌ Read locally | Markdown file is source of truth |
| Release Trail | `prodops/artifacts/trails/` | ❌ Append-only locally | Never delegate writes to MCP |
| AWS / infrastructure / lambdas / queues | MCP AWS or CLI | ✅ External state | State reads; provisioning requires a gate |
| Secrets / credentials | Vault / AWS Secrets Manager via MCP | ✅ With restriction | Never in artifacts; never in agent memory |

---

## Usage rules

### MCP may be used to

1. **Read external state** that does not exist in local artifacts (GitHub, CI/CD, observability, cloud).
2. **Emit events** when the corresponding skill explicitly instructs it (`prodops-emit-event`).
3. **Query metrics** for Outcome verification (DORA, SLOs, alerts).
4. **Resolve external dependencies** declared in risks or the Reliability Plan.

### MCP must never be used to

1. **Replace reading canonical artifacts** — never use MCP to "discover" the state of an OBC or an iteration; read the Markdown file.
2. **Define what a concept means** — if MCP returns a value different from the canonical definition, the canonical definition prevails.
3. **Write to Release Trail or upstream-trail** — these are append-only via skills, not via external tools.
4. **Bypass gates** — never use MCP availability as a gate bypass criterion.

---

## Evaluated integrations

### GitHub (MCP or `gh` CLI)

**Legitimate use:** query the state of Issues, PRs, checks, labels, assignees, and project boards.

**Limitation:** GitHub is the Canonical Operational Representation — a reflection of the canonical state in `prodops/artifacts/`. If they diverge, the Markdown artifact prevails. Diligence is responsible for resolving divergences (`diligence-sync` skill).

### CI/CD

**Legitimate use:** read pipeline status, test results, and deploy gates.

**Limitation:** a pipeline result does not substitute a canonical gate (Quality Gate, Readiness Gate). A green pipeline is evidence, not a gate.

### Datadog / Observability

**Legitimate use:** read current SLO, error rate, latency, and active alerts for Outcome verification and Observable Events.

**Limitation:** external metrics inform Outcome verification; they do not define acceptance criteria (which live in the OBC and Reliability Plan).

### AWS / Runtime

**Legitimate use:** read the state of lambdas, queues, and databases to diagnose Observable Events or for the Reliability Plan.

**Limitation:** provisioning and infrastructure changes require an explicit gate (Readiness Gate or CommitmentGate for SLO changes).

---

→ **Next:** [`claude-integration.en.md`](claude-integration.en.md)
→ **Reference:** [`automation-first.en.md`](automation-first.en.md), [`runtime/`](../runtime/)
