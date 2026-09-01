# Upstream Experiments

## Purpose

This document indexes all Upstream experiments executed for this product.

Experiments reduce uncertainty before implementation advances to Downstream.

Each experiment must answer one main question.

Do not duplicate experiment content here.

Reference the experiment directory.

---

# Workflow

```text
Business Question

↓

Experiment

↓

Learning

↓

Decision

↓

Assessment

↓

Downstream
```

---

# Experiment Status

| ID | Capability | Status | Recommendation | Next Step |
|----|------------|--------|----------------|-----------|
| 001 | Credit Card Lifecycle | 🟡 In Progress | Hosted subset for Assessment; saved card/new card need decisions | Decide token storage and PCI boundary |
| 002 | Sandbox Funding | 🟡 In Progress | Wait for external dependency | Collect Asaas Sandbox evidence |
| 003 | Hosted vs Tokenized | 🟡 In Progress | Advance to Downstream | Prepare Downstream intake for hosted card |
| 004 | Checkout Gateway Feature Flag Readiness | 🟡 In Progress | Wait for external dependency | Collect Checkout Feature Flag evidence |
| 005 | Datadog Native AWS Instrumentation | ✅ Completed | Advance to Downstream after confirming AWS pipeline parameters | Validate SAM deploy with Datadog Extension layer and Secrets Manager secret |
| 006 | Upstream Trail per Experiment | ✅ Completed | Keep as Upstream operating standard | Use directory layout for new experiments |
| 009 | Serverless Maturity Assessment | ✅ Completed | Run EXP-010 (Datadog), EXP-011 (DynamoDB), EXP-012 (CI/CD) in sequence | Present Decision Package to PM and Tech Lead; start EXP-010 |
| 010 | Datadog Activation in Staging | ✅ Completed | Move to Downstream — activate in production | Add STAGING_DATADOG_API_KEY to GitHub; confirm visual in Datadog UI |
| 011 | DynamoDB Optimization | ✅ Completed | Move to Downstream — apply in production via EXP-012 pipeline | Deploy to production via deploy-production.yml |
| 012 | Production CI/CD Pipeline | ✅ Completed | Move to Downstream — configure GitHub Environment `production` and execute first deploy | Configure Required Reviewers and PRODUCTION_* secrets on GitHub |

---

# Status Legend

| Icon | Meaning |
|------|---------|
| ⏳ | Planned |
| 🟡 | In Progress |
| ✅ | Completed |
| 🚀 | Promoted to Downstream |
| ❌ | Cancelled |

---

# Recommendations

Each completed experiment must end with exactly one recommendation.

Possible recommendations:

- Advance to Downstream
- Run another Upstream experiment
- Wait for business decision
- Wait for external dependency
- Discard capability

---

# Promotion Rules

A capability may advance to Downstream only when:

- The business behavior is understood.
- The main technical uncertainties are resolved.
- The Reliability Plan impacts are documented.
- The OBC is sufficiently defined.
- The BDD scenarios are defined.
- The Validation Workbench demonstrates the expected business flow.
- The Assessment approves the capability.

---

# Current Focus

Capability under current investigation:

**Credit Card Payment via Asaas** + **Serverless Operational Maturity**

Active experiments:

**001 - Credit Card Payment Lifecycle with Asaas**

Operational maturity roadmap completed (EXP-009 → 010 → 011 → 012):

- **EXP-009**: Serverless Maturity Assessment ✅
- **EXP-010**: Datadog Activation in Staging ✅
- **EXP-011**: DynamoDB Optimization ✅
- **EXP-012**: Production CI/CD Pipeline ✅

Next steps:

- Configure GitHub Environment `production` and execute first production deploy
- Continue 002 with Asaas Sandbox evidence
- Prepare Downstream intake for hosted card payment after Product and Tech Lead approval
- Run focused experiment on saved-card token storage after Security/Architecture input

---

# Completed Experiments

Move completed experiments here after promotion.

| ID | Capability | Downstream Release |
|----|------------|--------------------|

---

# Notes

Experiments are intentionally small.

When a new question arises, create a new experiment instead of expanding an existing one.

The goal is to keep each experiment focused on reducing a single uncertainty.

New experiments should use this structure:

```text
prodops/artifacts/experiments/NNN-short-slug/
  experiment.md
  upstream-trail.md
  evidence/
```

Flat files restored from legacy paths are historical artifacts. Keep them readable, but do not create new experiments in that format.
