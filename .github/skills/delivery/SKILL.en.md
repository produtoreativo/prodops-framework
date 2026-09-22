---
name: delivery
description: Execute the full Delivery + Diligence demo flow for the active Iteration Plan. Use when running a governed demo with CloudEvents, GitHub Project sync, and Datadog metric emission.
argument-hint: "[--demo] [--with-diligence] [--demo-run-id <id>] [--fast]"
---

# DELIVERY

Executes the Delivery + Diligence flow for the active Iteration Plan.

## Flags

| Flag | Behavior |
|---|---|
| `--demo` | Enables visual delays between events (default: 4s) |
| `--with-diligence` | Runs Diligence Capture → Attach after Delivery |
| `--demo-run-id <id>` | Sets the isolation ID (default: auto-generated) |
| `--fast` | Disables delays (technical rehearsal mode) |

## Execution

### 1. Load the Iteration Plan

Read `prodops/artifacts/plans/iteration-plan-pilot.md` and print the plan header:

```
═══════════════════════════════════════════════════════════════
  ITERATION PLAN — IP-001 (Operational Pilot Phase 2)
  Product: payments-api
═══════════════════════════════════════════════════════════════

  Features selected for this run (Block 1):
  ┌────┬──────────────────────────────────────────┬──────────────┐
  │ #  │ Feature                                  │ Final State  │
  ├────┼──────────────────────────────────────────┼──────────────┤
  │ 76 │ FTR-001: Invoice PIX — Happy Path        │ DONE         │
  │ 77 │ FTR-002: Invoice Cartão                  │ VALIDATING   │
  │ 78 │ FTR-003: Payment Confirmation            │ HACKING      │
  └────┴──────────────────────────────────────────┴──────────────┘

  Planned events per Feature:
    #76 → 15 events (Bootstrap→Hack→Sync→Finish→Ship→Validate→Promote)
    #77 → 11 events (Bootstrap→Hack→Sync→Finish→Ship→Validate)
    #78 →  3 events (Bootstrap→Hack.Started)

  Diligence (--with-diligence):
    Each Feature: Capture.Started → Capture.Completed → Attach.Started → Attach.Completed
    Total: 12 Diligence events

  Reference: prodops/artifacts/plans/iteration-plan-pilot.md
═══════════════════════════════════════════════════════════════
```

### 2. Generate the demo-run-id (if not provided via `--demo-run-id`)

Format: `exp-014-demo-YYYY-MM-DD-HHMM` (UTC)

### 3. Run the script

```bash
bash prodops/runtime/scripts/demo-delivery-with-diligence.sh \
  [flags passed by user] \
  --demo-run-id <demo-run-id>
```

If the user invoked `/delivery --demo --with-diligence`, pass `--demo --with-diligence`.
If invoked with just `/delivery`, pass no flags (fast/rehearsal mode).

### 4. Create the iteration-plan-snapshot

After execution, save to:
`prodops/artifacts/experiments/014-diligence-tracks-delivery/evidence/recordings/<demo-run-id>/iteration-plan-snapshot.md`

Content:
- iteration-id, product, execution date
- demo-run-id used
- features table with correlation IDs captured from output
- events per feature
- validate-demo.sh result (if executed)

### 5. Run validate-demo.sh

```bash
bash prodops/runtime/scripts/validate-demo.sh --demo-run-id <demo-run-id>
```

## Constraints

- Never expose credentials in output
- Internal script: `prodops/runtime/scripts/demo-delivery-with-diligence.sh`
- Iteration Plan: `prodops/artifacts/plans/iteration-plan-pilot.md`
- GitHub Project: https://github.com/orgs/produtoreativo/projects/25
- Datadog Dashboard: https://app.datadoghq.com/dashboard/jhq-ztv-3pv
