---
name: diligence/promote
description: Advance an OBC through the backlog hierarchy (Icebox → Iteration Backlog → Iteration Plan), checking prerequisites at each transition. Use after Attach has confirmed a Work Item exists.
---

# DILIGENCE SYNC → PROMOTE

Execute only the Promote step of the Diligence Sync flow.

**Responsibility:** move the item through the backlog hierarchy, checking prerequisites for each transition. Promote does not decide priority — the Product Owner decides. Promote verifies whether the required artifacts exist and records the verification result.

## Action

### 1. Identify the current position in the hierarchy

Locate the current state of the OBC:
- `prodops/artifacts/plans/iteration-plan.md` (Iteration Plan)
- `prodops/artifacts/product/backlogs/iteration-backlog.md` (Iteration Backlog)
- `prodops/artifacts/product/backlogs/icebox-backlog.md` (Icebox)

### 2. Verify prerequisites for the target transition

**Transition → Iteration Backlog:**
- [ ] OBC committed in `prodops/artifacts/obcs/`

**Transition → Iteration Plan:**
- [ ] OBC committed
- [ ] BDD Feature committed in `prodops/artifacts/bdd/`
- [ ] Risks documented in `prodops/artifacts/risks/risks.md`
- [ ] Reliability Plan when applicable (money movement, external integration, SLO change, high/critical risk, persistence or security change)

### 3. Execute the transition or record a blocker

If all prerequisites are satisfied:
- Update the Iteration Plan with the item and status `Entrou`
- Record the transition in the OBC (history field or status section)

If any prerequisite is missing:
- Record the gap as a blocker: which artifact is missing, which journey is responsible, which concrete action is needed
- Do not advance the item
- Do not invent the missing artifact

### 4. Commit the updates

```bash
git add prodops/artifacts/plans/iteration-plan.md
git add prodops/artifacts/obcs/<obc-id>.md
git commit -m "docs(diligence): promote <obc-id> to Iteration Plan"
```

## Post-conditions

Completed when:

- Item positioned in the correct hierarchy level with prerequisites verified
- **OR** blocker recorded with missing artifact, responsible journey, and concrete action identified

## Guardrails

- Do not invent OBCs, BDD Features, or risk entries to satisfy a prerequisite.
- Do not advance an item without checking prerequisites — the gate exists to protect Delivery.
- Do not make priority decisions — record the verification result, not the business decision.
- Stop and surface as a blocker when a missing artifact requires a product decision.

## Out of scope

- `promote` **does not** create the OBC or the BDD Feature — those are prerequisites that must exist beforehand.
- `promote` **does not** close Work Items — that is Close.
- `promote` **does not** detect drift in other OBCs — that is Scan.
