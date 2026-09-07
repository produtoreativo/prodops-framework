[Português](claude-integration.md)

# Claude Code Integration — ProdOps Architecture

This document describes the complete architecture of the Claude Code integration with the ProdOps Framework — how agents, skills, hooks, rules, and the context layer work together to cover the canonical lifecycle.

→ For the canonical lifecycle, see [`lifecycle.en.md`](lifecycle.en.md).
→ For skills, see [`prodops/skills/README.en.md`](../skills/README.en.md).
→ For agents, see [`prodops/agents/`](../agents/).

---

## Overview

```
Consumer Repo
├── CLAUDE.md                          ← main instruction (Wave 3)
├── .claude/
│   ├── agents/                        ← materialized agents (Wave 2)
│   │   ├── pce-agent.md
│   │   ├── tpm-agent.md
│   │   ├── pre-agent.md
│   │   ├── pqe-agent.md
│   │   ├── downstream-agent.md
│   │   └── diligence-agent.md
│   ├── rules/                         ← lifecycle rules (Wave 3)
│   │   ├── prodops-lifecycle.md
│   │   ├── prodops-skills.md
│   │   └── prodops-guardrails.md
│   ├── hooks/                         ← gate validators (Wave 4)
│   │   ├── check-commitment-gate.sh
│   │   ├── check-readiness-gate.sh
│   │   ├── check-evidence-package.sh
│   │   └── check-work-item-schema.sh
│   └── settings.json                  ← permissions + registered hooks
├── prodops/
│   ├── skills/                        ← canonical skills (Wave 1)
│   │   ├── intent/
│   │   ├── commitment/
│   │   ├── product-context/
│   │   ├── evidence/
│   │   ├── outcome/
│   │   ├── upstream/
│   │   ├── downstream/
│   │   └── diligence/
│   ├── agents/                        ← agent source
│   ├── runtime/
│   │   ├── runtime.yaml               ← canonical skill path registry
│   │   └── tools/
│   │       └── derive-context/        ← context generator (Wave 5)
│   └── artifacts/
│       └── context/
│           └── prodops-context.yaml   ← lifecycle state snapshot (Wave 5)
```

---

## Integration Layers

### Layer 1 — Skills (Wave 1)

Skills are authoritative execution rules for each action in the lifecycle. Each skill is self-contained: it defines when to use it, required reading, execution flow, outputs, and guardrails.

| Skill | Lifecycle stage | Invocation |
|---|---|---|
| `intent` | Business Signal → Product Intent | `/intent` |
| `commitment` | CommitmentGate + Readiness Gate | `/commitment` |
| `product-context` | Current state reading | `/product-context` |
| `upstream` | Any work in Upstream mode (without delivery commitment) | `/upstream` |
| `downstream` | Committed delivery cycle in Downstream mode (CI Sync + CI Async) | `/downstream` |
| `evidence` | Evidence (Upstream + Downstream) | `/evidence` |
| `outcome` | Business + Product Outcome | `/outcome` |
| `diligence` | Cross-cutting synchronization | `/diligence` |

**Resolution rule:** all skill paths are declared in `prodops/runtime/runtime.yaml` (section `skills:`). Read the runtime.yaml before invoking any skill.

---

### Layer 2 — Agents (Wave 2)

Agents are orchestrators that read skills and execute their flow. Each agent specializes in a lifecycle domain.

| Agent | Base skill | Responsibility |
|---|---|---|
| `pce-agent` | `product-context` | Capability state reading and consolidation |
| `tpm-agent` | `commitment` | CommitmentGate + Readiness Gate |
| `pre-agent` | `evidence` | Evidence Package + Release Trail |
| `pqe-agent` | `outcome` | Business Outcome + Product Outcome |
| `downstream-agent` | `downstream` | Full CI Sync + CI Async |
| `diligence-agent` | `diligence` | OBC and workspace synchronization |

**Materialization:** agents in `prodops/agents/` are copied to `.claude/agents/` by `materialize-agents.sh` (or by `install-claude.sh`).

---

### Layer 3 — `.claude/` Adapter (Wave 3)

The `.claude/` adapter is the Claude Code entry point in the consumer repo.

**`CLAUDE.md`** — main instruction:
- Entry point table by action (which skill or agent to use)
- Resolution rule via `runtime.yaml`
- Lifecycle mapping
- Restriction on modifying canonical artifacts

**`.claude/rules/`** — lifecycle rules loaded automatically:
- `prodops-lifecycle.md` — 5 rules for mode, CommitmentGate, Evidence, Outcome
- `prodops-skills.md` — skill resolution and stage→skill mapping
- `prodops-guardrails.md` — cross-cutting guardrails (artifacts, gates, Work Items, code)

---

### Layer 4 — Hooks (Wave 4)

Validation scripts executed before critical actions.

| Hook | Trigger | Validation |
|---|---|---|
| `check-commitment-gate.sh` | Before CommitmentGate | Decision Package, OBC Draft, BDD draft |
| `check-readiness-gate.sh` | Before Downstream | 5 readiness gates |
| `check-evidence-package.sh` | Before CommitmentGate | Complete Evidence Package |
| `check-work-item-schema.sh` | PreToolUse on `gh issue create` | Canonical title, required labels |

`check-work-item-schema.sh` is registered in `settings.json` as an automatic PreToolUse hook for every `gh issue create` invocation.

---

### Layer 5 — Context Layer (Wave 5)

`derive-context.sh` generates `prodops/artifacts/context/prodops-context.yaml` — a machine-readable snapshot of the current product state.

**Contents:**
- OBCs by state (Draft, Refining, Committed, In Delivery, Released)
- Active Upstream experiments
- Capabilities in the active iteration

**Usage:**
- `pce-agent` and `product-context` skill consume the file to answer quickly without reading all artifacts
- CI can regenerate automatically after OBC or experiment changes

---

## Agent Decision Flow

When an agent needs to act on a capability:

```
1. Check prodops-context.yaml (if available) for current stage
   ↓ if uncertain
2. Invoke pce-agent (or product-context skill) to determine stage
   ↓
3. Map stage → canonical skill
   ↓
4. Execute gate hook (when applicable) before the action
   ↓
5. Read skill via runtime.yaml and execute its flow
   ↓
6. Produce artifact and update evidence
```

---

## Installation in Consumer Repos

```bash
# 1. Install the ProdOps Framework
bash prodops/scripts/install-prodops.sh

# 2. Install the Claude Code integration
bash prodops/scripts/install-claude.sh

# 3. Generate initial context
bash prodops/runtime/tools/derive-context/scripts/derive-context.sh

# 4. Verify
bash prodops/scripts/doctor.sh
```

`install-claude.sh` creates:
- `.claude/agents/` — materialized agents
- `.claude/rules/` — canonical lifecycle rules
- `.claude/hooks/` — validation scripts
- `.claude/settings.json` — permissions and registered hooks

---

## Evaluation Scenarios

### Scenario 1 — Intent formalization

```
User: "We received feedback that customers want split payments"
→ Agent: What stage? → pce-agent: not registered → recommends /intent
→ intent skill: registers Business Signal → Business Intent → OBC Draft
→ Output: OBC Draft at prodops/artifacts/obcs/split-payment.md
```

### Scenario 2 — CommitmentGate after experiment

```
User: "/commitment commitment-gate 042-split-payment"
→ tpm-agent: verifies preconditions via check-commitment-gate.sh
→ Decision Package OK, OBC Draft OK, BDD draft OK
→ Records "Promote" outcome in upstream-trail.md
→ Moves OBC and BDD to committed paths
→ Updates Iteration Plan
```

### Scenario 3 — Outcome verification

```
User: "Verify outcome of split-payment (Released 30 days ago)"
→ pce-agent: OBC in Released → Outcome stage
→ pqe-agent: reads KPIs from OBC, collects data from Datadog
→ Compares committed vs. measured KPIs
→ Records result in Released OBC
→ Recommends: Archived (if confirmed) or follow-up Business Signal
```

### Scenario 4 — Blocked Downstream

```
User: "/downstream DS-42"
→ downstream-agent: verifies Readiness Gate via check-readiness-gate.sh
→ Gate 1 fails: OBC is not in Committed state
→ Stops with: list of missing gates + concrete action required
→ Does not start Bootstrap
```

---

## References

→ [Lifecycle](lifecycle.en.md)
→ [Glossary](glossary.en.md)
→ [Skills README](../skills/README.en.md)
→ [install-claude.sh](../scripts/install-claude.sh)
→ [derive-context.sh](../runtime/tools/derive-context/scripts/derive-context.sh)
→ [Work Item Schema](execution-mapping/work-item-schema.md)
