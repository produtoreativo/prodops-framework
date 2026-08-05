# Changelog — ProdOps Framework

All notable changes to the ProdOps Framework are documented here.

Format: [Semantic Versioning](https://semver.org/). Each entry links to the source
export from `payments-api` (empirical upstream) when applicable.

---

## [1.1.0] — 2026-08-05

### Added

- `prodops/runtime/` — Reference Implementation (RI) of the ProdOps delivery runtime,
  validated with Datadog and GitHub integrations. Consumers copy `runtime.yaml.example`,
  fill in their config, and extend in their own repo.
  - `catalog/events.yaml` — 47-event canonical catalog covering Delivery and Diligence journeys
  - `consumer/` — `derive-state.sh`, `derive-diligence-state.sh`
  - `datadog/` — `send.sh` (metrics publisher), `runtime-dashboard.json`, `dashboards/v3.4.0.json`
  - `dispatcher/` — `dispatch.sh` (subscription router), `trail.sh` (GitHub trail comments)
  - `docs/contract.md` — CloudEvent contract reference
  - `github/sync.sh` — idempotent GitHub Project v2 field sync
  - `producer/emit.sh` — CloudEvent factory
  - `subscriptions/delivery-diligence.yaml` — canonical subscription declarations
  - `timeline/append.sh` — append-only CloudEvent timeline writer
  - `tools/emit-event/` — complete 5-step CLI tool with JSON-in/JSON-out contract,
    unit tests (01–10), chain tests, and cross-player conformance test suite
  - `tools/restart-feature/` — non-destructive Delivery Journey restart tool
  - `scripts/` — `validate-event.sh`, `runtime-doctor.sh`, `project-cleanup.sh`,
    `create-github-views.sh`
  - `runtime.yaml.example` — consumer configuration template

### Changed (RI generalization)

- `datadog/send.sh`: removed `../api/.env` credential fallback; `DD_API_KEY` must
  be set as an environment variable
- `scripts/runtime-doctor.sh`: same credential change; removed `EXP-013` experiment
  label from banner
- `dispatcher/trail.sh`: translated all 13 event message templates from Portuguese
  to English; removed hardcoded branch name from sync message
- `tools/emit-event/scripts/emit-event`: removed hardcoded `"experiment":"EXP-015"`
  from evidence `_meta` block
- `tools/restart-feature/scripts/restart-feature`: added `--iteration-id` parameter;
  removed three hardcoded `"IP-EXP016-F03-RESTART"` iteration ID values

---

## [1.0.0] — 2026-08-05

### Breaking changes

- Removed duplicate root-level layout (`framework/`, `journeys/`, `skills/`,
  `templates/`, `execution-model/`). All canonical content now lives under `prodops/`.
- Removed product-specific experiments leaked from `payments-api`
  (`journeys/discovery/experiments/001–007`).

### Added

- `prodops/framework/artifact-types.md` + `.en.md` — canonical artifact type reference
- `prodops/framework/principles.md` + `.en.md` — 11 canonical ProdOps principles
- `prodops/framework/ontology.md` + `.en.md` — framework ontology
- `prodops/framework/positioning.md` — framework positioning document
- `prodops/skills/diligence/` — full Diligence Sync, Diligence Async, Workspace Reconciliation
- `prodops/skills/upstream/steps/deploy-to-sandbox/` — sandbox deploy step
- `consumers.yaml` — consumer registry for CI propagation

### Structure

```
prodops-framework/
  prodops/
    framework/     ← canonical framework docs
    skills/        ← canonical skills
    templates/     ← canonical templates
    scripts/       ← doctor.sh, validate-manifest.sh, validate-export-manifest.sh
  LICENSE
  README.md / README.en.md
  CHANGELOG.md
  consumers.yaml
```

---

## [0.1.0] — 2026-08-04

Initial export from `payments-api` empirical upstream via `export-framework.sh`.
Established base structure for framework distribution.
