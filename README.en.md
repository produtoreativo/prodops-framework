# ProdOps Framework

**ProdOps** is an operational model for product teams that separates permanent knowledge artifacts — OBC, BDD, Business Intent, Signal, Architecture, Plans, Trails, Evidence — from ephemeral GitHub execution — Issues, PRs, Releases.

> **Origin:** The Framework was created and validated in production in the [`payments-api`](https://github.com/produtoreativo/payments-api) product. The canonical documentation lives in [`prodops-framework`](https://github.com/produtoreativo/prodops-framework). Product artifacts stay in the product repository.

> **Current status:** Framework and Runtime are being co-developed in this repo and in the RI [`payments-api`](https://github.com/produtoreativo/payments-api) in parallel — synchronized at every change — while the content matures toward Release Candidate. Once RC is declared, `payments-api` becomes a pure consumer and this repository becomes the sole source of authority.
>
> → Latest release: [v1.5.0](https://github.com/produtoreativo/prodops-framework/releases/tag/v1.5.0)
> → RI (payments-api): [produtoreativo/payments-api](https://github.com/produtoreativo/payments-api)

> **Language note:** This framework is authored in Portuguese. See [why this project is in Portuguese](language.md).

---

## Architecture

```
ProdOps Framework  →  ProdOps Portfolio  →  ProdOps Workspace  →  Product Repository
```

The Framework is level zero — it defines vocabulary, principles, flow, and the operating model. Portfolios, Workspaces, and Product Repositories adopt it without modifying its canonical definitions.

→ [Full architecture and definitions](framework/operating-model.en.md#prodops-architecture)

---

## Core principle

```
A ProdOps artifact is NEVER a GitHub Issue.

Knowledge Space (permanent)       Execution Space (ephemeral)
───────────────────────────────   ──────────────────────────────
OBC, BDD, Intent, Signal,         Issues, PRs, Discussions,
Architecture, Plans, Evidence     Releases, Milestones

Markdown always prevails over GitHub.
```

→ [Knowledge vs Execution](framework/knowledge-vs-execution.en.md)
→ [Execution Mapping](framework/execution-mapping/README.en.md)

---

## Official flow

```
Origin Stream → Business Signal → Global or Local Flow
  → Local OBC Draft in Product Backlog
  → Mode: Upstream (exploration) | Downstream (commitment)
  → Discovery + Assessment → OBC Committed
  → Iteration Plan → Delivery → Operation
```

→ [Full flow explained](framework/flow.en.md)
→ [The four Origin Streams](framework/origin-streams.en.md)

---

## Framework documentation

| Document | Description |
|---|---|
| [framework/principles.en.md](framework/principles.en.md) | Foundational principles |
| [framework/glossary.en.md](framework/glossary.en.md) | Canonical terms |
| [framework/flow.en.md](framework/flow.en.md) | Official Framework flow |
| [framework/origin-streams.en.md](framework/origin-streams.en.md) | The four Origin Streams |
| [framework/operating-model.en.md](framework/operating-model.en.md) | Full operating model |
| [framework/knowledge-vs-execution.en.md](framework/knowledge-vs-execution.en.md) | Knowledge × Execution separation |
| [framework/execution-mapping/README.en.md](framework/execution-mapping/README.en.md) | Execution Mapping capability |
| [framework/backlogs.en.md](framework/backlogs.en.md) | Backlogs and Work Item types |
| [framework/artifact-governance.en.md](framework/artifact-governance.en.md) | Artifact governance |

---

## How to install in a new repository

From the root directory of the target repository:

```bash
bash <(curl -fsSL \
  https://raw.githubusercontent.com/produtoreativo/prodops-framework/master/prodops/scripts/install-prodops.sh) \
  --version v1.5.0
```

Or, if you prefer to clone first:

```bash
gh repo clone produtoreativo/prodops-framework /tmp/prodops-framework
bash /tmp/prodops-framework/prodops/scripts/install-prodops.sh --version v1.5.0 --target /path/to/repo
```

**After installation:**

1. Create `prodops/exec/manifest.yaml` — product operational configuration (paths, gates, skills, github, diligence)
2. Create artifact directories: `prodops/artifacts/obcs/`, `prodops/artifacts/bdd/`, `prodops/artifacts/plans/`, etc.
3. Enable commit hooks:
   ```bash
   git config core.hooksPath prodops/framework/journeys/delivery/capabilities/commit-workflow/hooks
   ```
4. Verify the installation:
   ```bash
   bash prodops/scripts/doctor.sh
   ```

→ Philosophy and extension rules: [prodops/framework/contributor-philosophy.en.md](prodops/framework/contributor-philosophy.en.md)

---

## How to keep in sync

```bash
# Update to a new version (opens PR)
bash prodops/scripts/sync-from-framework.sh --version v1.5.0

# Check for drift without changes
bash prodops/scripts/sync-from-framework.sh --check
```

---

## Product Repository portal

*This section is relevant when you are reading this README inside a Product Repository.*

| Area | Description |
|---|---|
| [framework/](framework/) | Canonical framework — do not modify per product |
| [artifacts/business/intents/](artifacts/business/intents/) | Registered Business Intents |
| [journeys/](journeys/) | The 5 journeys: Discovery, Delivery, Operation, Assessment, Diligence |
| [artifacts/](artifacts/) | Produced artifacts: OBCs, BDD Features, plans, trails, evidence |
| [templates/](templates/) | Centralized templates by area |
| [skills/](skills/) | Executable skills for agents |
