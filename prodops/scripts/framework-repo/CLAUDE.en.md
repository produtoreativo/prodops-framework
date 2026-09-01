# Claude Code Instructions — ProdOps Framework Repo

Read `AGENTS.md` in full before any action — it is the operational guide for this
repository and contains review rules, versioning rules, and what can be edited here.

## Critical rule: runtime version follows the framework

When working on an export PR or incrementing the framework version, confirm
that **the three files below have exactly the same version number**:

1. `prodops/scripts/setup-wsl.sh` — line `PRODOPS_VERSION="vX.Y.Z"`
2. `prodops/scripts/setup-mac.sh` — line `PRODOPS_VERSION="vX.Y.Z"`
3. `prodops/runtime/runtime.yaml.example` — field `framework-version: "vX.Y.Z"`

If any of them diverge, the gate `validate-export-manifest.sh` will fail and the
export must be blocked until the upstream corrects and re-exports.

## Do not edit canonical scripts here

Scripts in `prodops/scripts/`, skills in `prodops/skills/`, documentation in
`prodops/framework/`, and runtime in `prodops/runtime/` are managed by the
empirical upstream (`payments-api`). Direct edits here will be overwritten
on the next run of `export-framework.sh`.
