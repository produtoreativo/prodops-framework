# ProdOps Framework — Agent Guide

> **This repository is the canonical framework** (`produtoreativo/prodops-framework`).
> Changes arrive via export PRs from the empirical upstream (`payments-api`).
> Do not edit canonical scripts directly here — changes belong in the upstream.

---

## WARNING: CRITICAL RULE — RUNTIME VERSION FOLLOWS THE FRAMEWORK

**Every time the framework version number is incremented, the following
files MUST be updated to the same value — no exceptions:**

| File | Field to update |
|---|---|
| `prodops/scripts/setup-wsl.sh` | `PRODOPS_VERSION="vX.Y.Z"` |
| `prodops/scripts/setup-mac.sh` | `PRODOPS_VERSION="vX.Y.Z"` |
| `prodops/runtime/runtime.yaml.example` | `framework-version: "vX.Y.Z"` |
| `CHANGELOG.md` | entry for the new version |

The gate `prodops/scripts/validate-export-manifest.sh` automatically fails if
`PRODOPS_VERSION` in any script diverges from the version in `framework-lock.yaml`.

**Check these files before approving any export PR.**

---

## Export PR review protocol

Every export PR comes from `payments-api` via `export-framework.sh`. When reviewing:

1. Confirm that `PRODOPS_VERSION` in `setup-wsl.sh` = PR version
2. Confirm that `PRODOPS_VERSION` in `setup-mac.sh` = PR version
3. Confirm that `CHANGELOG.md` has an entry for the exported version
4. Confirm that no product-specific files leaked:
   - `prodops/artifacts/**` → must never appear
   - `prodops/exec/**` → must never appear
5. Approve and merge

---

## Repository structure

```
prodops-framework/
  prodops/
    framework/     ← canonical framework documentation
    skills/        ← canonical skills (bootstrap, hack, sync, finish, ship...)
    templates/     ← canonical templates
    scripts/       ← installation and validation scripts
    runtime/       ← Runtime Reference Implementation (RI)
  AGENTS.md        ← this file (managed by upstream via export)
  CLAUDE.md        ← instruction for Claude Code (managed via export)
  CHANGELOG.md     ← version history
  consumers.yaml   ← consumer registry for CI propagation
```

---

## What can be edited directly in this repo

- `consumers.yaml` — register/remove framework consumers
- `CHANGELOG.md` — editorial notes after an export merge (rarely)
- `README.md`, `README.en.md` — general framework documentation

**Never edit directly:** `prodops/scripts/*.sh`, `prodops/skills/**`,
`prodops/framework/**`, `prodops/runtime/**`. Those changes belong to the
empirical upstream (`payments-api`) and arrive here via export.
