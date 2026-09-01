# Framework Gaps — Gaps Identified in Execution

> **Purpose:** Continuous record of gaps, ambiguities, and implicit behaviors discovered during real ProdOps execution. Each entry indicates what the Framework lacks to make the process more predictable, automatable, and less dependent on tacit knowledge.
>
> **Source:** Real interactions between PM/PO and the ProdOps agent. Not a feature backlog — it is input for Framework evolution.
>
> **Format per entry:** context → what the Framework does not say → what it should say → impact if omitted.

---

## GAP-001 — `runtime.yaml` uses a fixed `pilot-issue` instead of `active-issue` per iteration

**Context:** During the transition from iteration v0.1.0 to v0.2.0 (Boleto), the runtime continued pointing to issue #76 (PIX) because `pilot-issue` was a fixed field in `runtime.yaml`.

**What the Framework does not say:** How to switch the active work between iterations.

**What it should say:** The field should be called `active-issue` and be updated by `/readiness` when declaring readiness for a new feature.

**Impact if omitted:** Events emitted during `/downstream` update the GitHub Project and Datadog for the wrong issue.

**Status:** Fixed in `runtime.yaml` (v0.3.0 → `active-issue`) and in scripts `bootstrap-happy-path.sh`, `bootstrap-runtime.sh`, `runtime-doctor.sh`.

---

## GAP-002 — Downstream does not automatically update `runtime.yaml` when declaring readiness

**Context:** The `runtime.yaml` had to be manually updated to `active-issue: 40`. Downstream Readiness generates the `context.md` but does not touch the runtime config.

**What it should say:** The Readiness step should include: "update `github.active-issue` in `runtime.yaml` before emitting the first event."

**Status:** Open gap. The `/readiness` skill includes this instruction but there is no automation.

---

## GAP-003 — Milestone was not part of the canonical Readiness flow

**Context:** Issue #40 was added to the Project without a milestone. There was no gate that checked whether the issue had a milestone before starting Bootstrap.

**What it should say:** The Downstream Readiness Gate should include: "issue associated with the active iteration milestone".

**Status:** Resolved. Milestone included as Gate 6 in the `/readiness` skill.

---

## GAP-004 — Adding the issue to the GitHub Project was not an explicit Downstream step

**Context:** Issue #40 was created but was not in Project #25. It was added manually.

**What it should say:** Downstream Readiness should verify and execute `addProjectV2ItemById` automatically.

**Status:** Resolved. Gate 7 in the `/readiness` skill covers verification and automatic addition.

---

## GAP-005 — Closing a previous milestone has no gate or instruction in the Framework

**Context:** When creating milestone `v0.2.0`, the previous milestone `v0.1.0-runtime-pilot` was still open.

**What it should say:** When starting a new iteration, check whether there is an open milestone without active issues and suggest closing it.

**Status:** Open gap. Candidate for verification in Diligence Sync or in the iteration opening step.

---

## GAP-006 — Iteration Plan has no consistency gate with GitHub Issues

**Context:** The Iteration Plan was updated (Boleto as "Entered", others as "Exited") but the GitHub issues were not changed.

**What it should say:** When changing an item's status to "Exited", propagate to the milestone, Project, and issue labels.

**Status:** Open gap.

---

## GAP-007 — Business Signal has no explicit flow for "feature already exists"

**Context:** BS-MAGS-001 discovered that boleto was already implemented. The Framework does not define the path "Signal → Investigation → Already exists → Downstream" without full Discovery.

**Status:** Open gap. Candidate for addition in the `/upstream` skill.

---

## GAP-008 — `runtime.yaml` does not document its own lifecycle

**Context:** The file has no comments explaining the purpose of each field, who updates it, when, and with what command.

**Status:** Open gap. Requires creation of `prodops/runtime/README.md`.

---

## GAP-009 — ADRs have no canonical location or standardized format in the Framework

**Context:** Architecture decisions live in `prodops/artifacts/architecture/decision-trail.md` — narrative, without numbering, without a template.

**Status:** Open gap. Candidate for a template in `prodops/templates/architecture/decision-record.md`.

---

## GAP-010 — The Framework does not define Business Case as an explicit artifact

**Context:** There is no template or instruction for composing OBC + Experiments + Reliability Plan + cost into a structured Business Case for project approval.

**Status:** Open gap. Candidate for a new template in Discovery Upstream.

---

## GAP-011 — Downstream Readiness does not verify whether the architecture was impacted and documented

**Context:** There is no gate that checks whether the feature introduces a structural change requiring an update to `architecture/overview.md`.

**What it should say:** Finish (or PR checklist) should include: "if the feature introduces a new module, route, table, event, or integration, update `overview.md` before the PR is approved."

**Status:** Open gap. Candidate for a gate in the Finish checklist.

---

## GAP-012 — CI Async did not trigger a staging deploy for feature branches

**Context:** The `staging-deploy.yml` workflow only triggered on push to `main` and a hardcoded branch. The `/ship` skill had no instruction on how to trigger the deploy.

**Status:** Fixed. `staging-deploy.yml` updated with `workflow_dispatch`. `/ship` skill updated with triggering step and wait.

---

## GAP-013 — There was no isolated readiness command in Downstream

**Context:** There was no way to verify gates without starting Bootstrap.

**Status:** Resolved. `/readiness` skill created in `prodops/skills/readiness/SKILL.md`.

---

## GAP-014 — `no_mocks` gate scans `api/src` in addition to `api/test`, blocking legitimate unit tests

**Context:** During DS-40 CI Sync, the Finish agent created `invoice.service.spec.ts` in `api/src/` with `jest.fn()` and `.mockReturnValue()` to mock injected dependencies (InvoiceRepository, AsaasService) — correct practice for service-layer unit tests. The `no_mocks` gate in `manifest.yaml` scans `[api/src, api/test]`, causing CI to fail on two consecutive pushes.

**What the Framework does not say:** The distinction between "mock in acceptance test" (prohibited — violates the No Mocks Rule) and "mock of injected dependency in unit test" (allowed — isolates the layer under test). The `manifest.yaml` does not document that the rule only applies to `api/test/`.

**What it should say:** The `no_mocks` gate should scan only `api/test/`. Unit tests in `api/src/**/*.spec.ts` may use `jest.fn()` to create doubles of injected dependencies — this does not violate the No Mocks Rule, which prohibits replacing real implementations in acceptance tests.

**Impact if omitted:** Any unit test created in `api/src/` with dependency mocks will fail the CI gate, forcing incorrect workarounds (such as moving tests to `api/test/` or eliminating unit test isolation).

**Status:** Fixed. `manifest.yaml` updated: `in: [api/test]` (removed `api/src`). Patterns expanded to also cover `.mockRejectedValue(`, `.mockResolvedValue(`, `.mockImplementation(`.

---

## GAP-015 — hack-start stashes uncommitted changes, discarding skill and framework edits made during readiness

**Context:** During DS-40 preparation, changes were made to `prodops/skills/downstream/SKILL.md` (Downstream ID, no-argument mode, command table) and `prodops/skills/readiness/SKILL.md` (new skill). These changes were in the working tree without a commit. When the `hack-start` agent executed, it ran `git stash` of the uncommitted changes before creating the `feat/40-create-invoice-boleto` branch, preserving them in the stash but making them invisible in the feature branch. The `framework-gaps.md` file was also lost (it was not in the stash).

**What the Framework does not say:** Skills and framework artifacts changed during Readiness/Downstream must be committed before `hack-start` runs. There is no explicit instruction about what to do with working tree changes that are not part of the feature scope.

**What it should say:** The `/readiness` skill should include: "commit any skill, framework, or ProdOps changes in the current branch before invoking `/downstream ci-sync`. The `hack-start` will stash any pending changes." Additionally, changes in `prodops/skills/` and `prodops/framework/` made during the session must be committed in a separate commit before hack-start.

**Impact if omitted:** Framework changes remain in the stash (recoverable but invisible), while files created but not versioned by git (such as `framework-gaps.md`) are permanently lost.

**Status:** Mitigated in this session via `git show stash@{0}:<path> > <path>` to restore individual files. Requires adding explicit instruction in the `/readiness` skill and the `hack-start` skill.

---

## GAP-016 — No Event Type exists for failure during Ship (Ship.Failed absent from catalog)

**Context:** The consolidated operating model defines that Ship detects failures during autonomous PR flow observation (CI check, merge, Staging deploy) and stops progression. However, the Delivery Journey events catalog (`prodops/framework/journeys/delivery/events/catalog.md`) and the runtime events catalog (`prodops/runtime/catalog/events.yaml`) define no `Ship.Failed` or equivalent.

**What the Framework does not say:** How to signal via event that Ship detected a failure during observation — CI failed, merge did not occur, or Staging deploy failed.

**What it should say:** An Event Type `Ship.Failed` (or `Shared.Gate.Failed` with Ship context) should be emitted when Ship detects failure, allowing the Diligence Journey to detect the BLOCKED state and initiate a reconciliation cycle.

**Impact if omitted:** Failures during Ship are recorded only as text in the Release Trail, without event-driven propagation. The Diligence Journey cannot automatically react to the Ship failure state. The Work Item state remains SHIPPING indefinitely without a canonical failure signal.

**Status:** Open gap. Do not create events — document only. Candidate for the next evolution of the Delivery Journey events catalog.

---

## GAP-017 — Ship.Started and Finish.Started emitted by skills but absent from the Event Types catalog

**Context:** The `prodops/skills/finish/SKILL.md` and `prodops/skills/ship/SKILL.md` skills emit `Delivery.Finish.Started` and `Delivery.Ship.Started` respectively. However, the Delivery Journey events catalog (`prodops/framework/journeys/delivery/events/catalog.md`) only lists `Finish.Completed` and `Ship.Completed` — there is no formal definition of `Finish.Started` or `Ship.Started` as Event Types.

**What the Framework does not say:** The catalog does not define the preconditions, postconditions, payload_shape, or alters_state of the Started events for Finish and Ship. Only the Completed events have a formal definition.

**What it should say:** All events emitted by skills must have a corresponding entry in the Event Types catalog with a complete schema.

**Impact if omitted:** Consumers that process Delivery Journey events have no formal schema for `Finish.Started` and `Ship.Started`. Event validation is incomplete. The Timeline may contain uncataloged events.

**Status:** Open gap. Do not create events — document only. Candidate for the next catalog version (v2.1.0 or v3.0.0).

---

## GAP-018 — The events catalog uses "homologação" and "produção" — ambiguous with the consolidated environments model

**Context:** The Delivery Journey events catalog (`catalog.md`) uses the terms "homologation environment" (Ship.Completed) and "production" (Promote.Completed, Promote.Approved). The consolidated operating model defines: Staging (ephemeral per Feature), Sandbox (shared, Release Candidate), and Production (outside the Journey).

**What the Framework does not say:** Whether "homologação" in the catalog is equivalent to Staging or Sandbox. Whether "production" in Promote.Completed means Promote takes to Production (wrong in the new model) or Sandbox.

**What it should say:** The descriptors of catalog events must use canonical terms: Staging, Sandbox, Production — not "homologação" and "produção" generically.

**Impact if omitted:** Ambiguity between the events catalog and the operating model. Agents that read the catalog may infer that Promote takes to Production, contradicting the consolidated operating model that places Production outside the Delivery Journey.

**Status:** Open gap. Do not alter the events catalog in this cycle — document only. Candidate for the next catalog version.

---

## GAP-019 — The name `release-trail.md` designates two artifacts from different layers

**Context:** During the Finish refactoring (branch `refine/11-finish-v2`), 7 trail files were found outside `prodops/artifacts/trails/sessions/`. Upon inspection, they were two distinct artifacts with the same name: 3 were real session trails (session UUID, convention `YYYY-MM-DD-<session-id>.md`) that had been written inside `iterations/<version>/trails/`; the other 4 were TDD evidence scoped by iteration or card (`# Release Trail — v0.9.0`), without any session identity.

**What the Framework does not say:** That "Release Trail" designates exclusively the append-only session log. There is no canonical name for the artifact that consolidates test evidence of a delivery within an iteration, so it inherited the Framework concept's name.

**What it should say:** Release Trail is Framework ontology — addressed by session ID, lives in `trails/sessions/`. The per-iteration/card trail is a product artifact — addressed by version or slug, lives in `iterations/<version>/`. They are different layers in the `contributor-philosophy.md` table ("trail templates → Runtime" vs "product trail texts → Product") and must not share a name.

**Impact if omitted:** An agent that reads `iterations/v0.9.0/release-trail.md` may infer that trails are scoped by iteration and start writing session trails there — that is exactly what happened with the 3 files found. The name collision propagates the location error.

**Status:** Mitigated in `refine/11-finish-v2`. The 4 aggregates were renamed to `iteration-trail*.md` and `release-trail.md` gained the section "Release Trail ≠ Iteration Trail". The Framework still needs to formally name this artifact — today `iteration-trail` is a product convention, not a Framework definition.

---

## GAP-020 — Quality gates couple tool, credential, and endpoint to the product

**Context:** The gates `scripts/check-code-analysis.sh` and `scripts/check-dependencies.sh` implement static analysis and dependency verification, but hardcode the tool choice and local topology: `sonarqube` container, `localhost:9000`, scanner image, and reading of `SNYK_TOKEN` from `api/.env`.

**What the Framework does not say:** Where the gate definition ends (what needs to be verified before a PR merges) and where the implementation choice begins (which tool, which endpoint, which credential). The `contributor-philosophy.md` table covers "credentials and endpoints → Product", but does not say which layer defines the gate itself.

**What it should say:** The Framework defines which gate classes exist (static analysis, dependencies, coverage, acceptance) and the exit code contract. The Runtime provides an opinionated reference implementation. The product provides credentials, endpoints, and thresholds.

**Impact if omitted:** Each product reimplements the same gates from scratch, and the RI cannot export quality verification without dragging along the tool choice.

**Status:** Open gap. **Do not promote to Runtime in this cycle** — the gates have a single real consumer, and `contributor-philosophy.md` (question 2) requires two real cases before generalizing. Document only; reassess when a second consumer exists.

---

## GAP-021 — `materialize-skills.sh` assumed one skill = one file

**Context:** The script only materialized `prodops/skills/<skill>/SKILL.md` for the three players. When `finish` and `hack` became multi-file (`steps/<step>/SKILL.md`), the sub-steps never reached `.claude/`, `.agents/`, and `.github/` — but the materialized `SKILL.md` continued linking to them with paths relative to the origin. The result was dangling links in all players, with no error signal: `--check` only compares the top-level `SKILL.md` and reported "up-to-date".

**What the Framework does not say:** That a skill can be multi-file, and that materialization is responsible for the entire subtree — not just the entry file.

**What it should say:** The unit of materialization is the skill directory, not the `SKILL.md`. Any file referenced by relative path from the skill must exist at the destination, otherwise the contract read by the player is incomplete.

**Impact if omitted:** Codex and Copilot read a `SKILL.md` that instructs them to open `steps/validate/SKILL.md` and do not find the file. The agent executes the phase without the sub-step definition, or invents the behavior. Silent because the drift gate did not look at the subtree.

**Status:** Fixed in `refine/11-finish-v2`. `materialize-skills.sh` gained `materialize_steps()`, called even when the top-level `SKILL.md` is up-to-date (the parent being current says nothing about the children). Fixes `finish` (multi-file introduced in this branch) and also `hack`, which had the same latent defect since before.

---

## GAP-022 — Materialized skills link outside their own directory

**Context:** The `SKILL.md` files of `finish`, `hack`, `sync`, `upstream`, and `ship` reference files outside the skill directory — `../references/engineering/tdd-prodops/`, `../../framework/journeys/delivery/phases/`. At the origin (`prodops/skills/`) these paths resolve. At the materialized destination (`.claude/`, `.agents/`, `.github/`) there is no sibling `framework/` or shared `references/`, so 153 links are dangling. The defect predates `refine/11-finish-v2` — it was already in `master`.

**What the Framework does not say:** What the boundary of a materialized skill is. If the `SKILL.md` is a self-contained contract that the player reads in isolation, it cannot depend on files outside its own tree; if it can, materialization needs to bring the dependencies along.

**What it should say:** One of two things — either the skill is self-contained and all external references become inline content / absolute repository links, or the unit of materialization comes to include the referenced dependencies. The choice changes what `materialize-skills.sh` does and what `--check` validates.

**Impact if omitted:** Codex and Copilot read a contract that instructs them to consult `../references/engineering/tdd-prodops/red-green-refactor.md` and find nothing. The agent executes the phase without the reference or infers the behavior. Silent: no gate detects it.

**Status:** Open gap. Not fixed in `refine/11-finish-v2` — the fix depends on deciding the boundary of the materialized skill, which is a Framework definition, not a script adjustment. GAP-021 resolved the internal case (subtree of the skill itself); this is the external case.
