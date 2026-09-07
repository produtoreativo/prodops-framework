[Português](SKILL.md)

---
name: evidence
description: Captures, structures, and links evidence throughout the lifecycle. Use to register Upstream Evidence (experiment evidence packages) and Downstream Evidence (Release Trail, Observable Events), ensuring traceability from the commitment made to the value delivered.
---

# Evidence Skill

## Purpose

Use this skill to produce, structure, and link verifiable evidence throughout the canonical lifecycle.

Evidence in ProdOps is not optional documentation — it is proof that what was committed was delivered (Downstream) or that what was explored produced learning (Upstream). Without evidence, the system cannot distinguish delivery from intention.

This skill operates in two distinct contexts:

- **Upstream Evidence:** experiment evidence — what was tested, how, and what was concluded
- **Downstream Evidence:** delivery evidence — what was delivered, how it was validated, and what is operating in production

---

## When to Use

**Upstream Evidence:**
- When concluding an experiment and assembling the Decision Package
- When recording results from interviews, benchmarks, spikes, or prototypes
- When the Evidence Threshold declared in `experiment.md` needs to be verified
- To ensure the CommitmentGate has verifiable substrate

**Downstream Evidence:**
- When concluding CI Sync (Finish) and producing quality evidence
- When concluding CI Async (Validate / Promote) and updating the Release Trail
- When Observable Events need to be registered or verified in production
- To link operational evidence to the Released OBC

---

## Required Reading

Before starting, read:

- `prodops/framework/lifecycle.en.md` — Evidence and Context Discovery stages
- `prodops/framework/glossary.en.md` — terms Evidence, Upstream Evidence, Downstream Evidence, Observable Events, Release Trail
- `prodops/framework/obc.md` — sections "OBC in Upstream" and "OBC in Downstream"

---

## Upstream Evidence

### Evidence Package Structure

An experiment's Evidence Package must contain:

| Item | Location | Description |
|---|---|---|
| Original hypothesis | `experiment.md` — Hypothesis section | What was tested and why |
| Method | `experiment.md` — Methodology section | How the hypothesis was tested |
| Produced artifacts | `experiment.md` — Findings section | Code, prototypes, metrics, outputs |
| Observed result | `experiment.md` — Findings section | What was observed, with data |
| Conclusion | `experiment.md` — Recommendation section | Hypothesis confirmed, refuted, or inconclusive |
| Supporting material | `evidence/` in the experiment | Command outputs, payloads, captures — only when relevant |

### Evidence Threshold Verification

If `experiment.md` declares an Evidence Threshold (sufficiency criterion):

1. Read the declared criterion.
2. Verify each item in the criterion is satisfied with a concrete reference in the Evidence Package.
3. Record the verification result in the "Decision Package" section of `experiment.md`.

If the Evidence Threshold is not satisfied: do not convene the CommitmentGate. Return to the experiment.

### Upstream-trail Record

When finalizing the Evidence Package, record in the experiment's `upstream-trail.md`:
- Evidence Package completion date
- List of produced artifacts
- Evidence Threshold verification result
- Status: ready for CommitmentGate (or blocked, with reason)

---

## Downstream Evidence

### Release Trail

The Release Trail is the append-only log that documents each phase of the Delivery journey. It is the primary evidence that delivery was performed as committed.

**Release Trail entry structure:**

```markdown
## <YYYY-MM-DD> — <Phase>

**work-item-id:** <issue-number>
**iteration-id:** <iteration-id>
**correlation-id:** <uuid>
**status:** <completed | failed | blocked>

<summary: what was done, main evidence, next step>
```

**Location:** `prodops/artifacts/trails/sessions/YYYY-MM-DD-<session-id>.md`

**Release Trail rules:**
1. Never modify existing entries — the trail is append-only.
2. Every completed or blocked phase must generate an entry before advancing.
3. Always include: `work-item-id`, `correlation-id`, `status`, and timestamp.
4. In case of regression (Downstream → Upstream): record the suspension reason before closing.

---

### Observable Events

Observable Events are signals emitted by the system in production that prove the committed behavior is operating.

**When recording Observable Events as evidence:**

1. Read the Observable Events declared in the OBC at `prodops/artifacts/obcs/<slug>.md`.
2. Verify each declared event is being emitted in production (confirm via Datadog, logs, or configured observability tool).
3. Record the verification in the Release Trail or in the Released OBC.
4. If any Observable Event is not emitting: open a follow-up issue and record in the Release Trail.

**Evidence stage exit condition:** Complete Release Trail + Observable Events verified operating in production.

---

## Linking Evidence to the OBC

All evidence must be linked to the OBC that originated it:

| Evidence type | Where to link |
|---|---|
| Upstream Evidence (Decision Package) | "Evidence" section of the OBC in experiment |
| Release Trail | "Evidence" section of the Released OBC |
| Confirmed Observable Events | "Observability" section of the Released OBC |
| Outcome metrics | "KPIs / Expected Results" section of the Released OBC |

The Released OBC must be readable as complete proof that the cycle was honored — from intention to operational evidence.

---

## Operating Rules

1. Evidence is not retrospective documentation — it must be produced at the time of work, not reconstructed after.
2. Never mark the Evidence Package as complete without verifying the Evidence Threshold (when declared).
3. Never close the Evidence stage without a complete Release Trail and verified Observable Events.
4. Do not duplicate evidence — each evidence artifact references the OBC that originated it; the OBC references the artifacts.
5. Supporting material in `evidence/` is for technical details — the main argument must be in `experiment.md` or the Release Trail.

---

## Expected Outputs

**Upstream Evidence:**
- `experiment.md` with complete Evidence Package and verifiable Decision Package
- `upstream-trail.md` updated with Evidence Package status
- Evidence Threshold verified (when declared)

**Downstream Evidence:**
- Release Trail updated with entries for each completed phase
- Observable Events verified in production
- OBC updated with references to evidence

---

## Guardrails

- Never fabricate evidence — record only what was observed and verified.
- Never mark OBC as Released without concrete evidence of production operation.
- Never omit failure or blocking entries from the Release Trail — the trail must reflect what actually happened.
- Do not confuse "code merged" with "capability delivered" — delivery is only complete when the Release Trail is closed and Observable Events are operating.

---

## References

→ [Lifecycle — Evidence stage](../../framework/lifecycle.en.md)
→ [Glossary — Evidence](../../framework/glossary.en.md)
→ [OBC](../../framework/obc.md)
→ [Commitment Skill](../commitment/SKILL.en.md)
→ [Outcome Skill](../outcome/SKILL.en.md)
→ [Discovery Journey — experiments](../../framework/journeys/discovery/README.en.md)
→ [Downstream Skill](../downstream/SKILL.md)
