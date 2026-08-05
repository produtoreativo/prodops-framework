# Changelog — ProdOps Framework

All notable changes to the ProdOps Framework are documented here.

Format: [Semantic Versioning](https://semver.org/). Each entry links to the source
export from `payments-api` (empirical upstream) when applicable.

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
