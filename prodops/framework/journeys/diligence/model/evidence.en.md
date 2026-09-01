# Evidence — Canonical Definition

## Definition

> **Evidence is a persistent and referenceable proof used to demonstrate the detection, impact, correction or verification of a condition evaluated by Diligence.**

Evidence is not informal annotation. Evidence is not an Issue comment. Evidence is a structured record with identity, source, temporality and reference to what it proves. One Evidence can support multiple Findings; one Finding can be supported by multiple Evidence records.

---

## ID format

```
EVD-YYYY-NNNN
```

- `EVD`: immutable prefix of the Evidence entity
- `YYYY`: collection year (four digits)
- `NNNN`: four-digit sequential per year (0001–9999)

Examples: `EVD-2026-0001`, `EVD-2026-0042`

---

## What Evidence can prove

Evidence can be collected to demonstrate any of the conditions below:

| What it proves | When it is collected |
|---|---|
| **Check result** | During execution of a Check; documents what was observed |
| **Finding existence** | Demonstrates that the condition described in the Finding actually exists |
| **Impact** | Demonstrates consequences of the condition if not resolved |
| **Remediation execution** | Demonstrates that the corrective action was applied |
| **Resolution** | Demonstrates that the condition was eliminated |
| **Verification** | Demonstrates independent verification that the resolution is valid |
| **Waiver validity** | Demonstrates that the Waiver was approved by the correct responsible parties |

---

## Evidence types

| Type | Definition | Examples |
|---|---|---|
| **Document** | Markdown file, text or specification documenting state | OBC file, Reliability Plan, glossary file |
| **Log** | Output of process, system or pipeline | CI/CD output, deploy log, Check execution log |
| **Metric** | Measurable value collected from observability system | Error rate, P99 latency, availability |
| **Test Result** | Result of automated test execution | BDD report, coverage, pytest/jest output |
| **Command Output** | Output of reproducibly executed CLI command | `gh issue view 57 --json body,labels`, `gh project field-list` |
| **API Response** | Captured API call response | GitHub API JSON response, external API response |
| **Screenshot** | Screen capture of visual state | GitHub Project View state, observability dashboard |
| **Pull Request** | PR that implements or documents a change | PR #42 with the Remediation changes |
| **Commit** | Commit that records a specific change | Commit hash with the applied fix |
| **Release** | Release or Release Trail documenting delivery | Release v2.1.0, Release Trail entry |
| **Dashboard** | Observability dashboard or panel | SLO dashboard, alerts panel |
| **Approval** | Formal approval record | PR approval, reviewer sign-off, Waiver approval |
| **Decision Record** | Decision record made by competent journey | Assessment decision, Architecture Decision Record |
| **Conformance Report** | Conformance report produced by Workspace Reconciliation | CONFORMANT / PARTIAL / NON-CONFORMANT |
| **Observation** | Human observation recorded when automated Evidence is not possible | Manual review note, field observation |

### Preference hierarchy

When multiple Evidence types are possible for the same condition, prefer in the following order (Automation First):

1. **Command Output / API Response** — reproducible, verifiable, automatable
2. **Test Result / Log** — system-generated, traceable
3. **Document / Metric** — referenceable, stable
4. **Dashboard / Conformance Report** — visual but structured
5. **Screenshot** — visual; difficult to verify automatically
6. **Observation** — last resort; requires justification for why automated Evidence was not possible

---

## Schema

| Field | Conceptual type | Cardinality | Rules and notes |
|---|---|---|---|
| `id` | string | 1 | Format EVD-YYYY-NNNN; immutable; unique in the system |
| `type` | enum | 1 | One of the types listed above |
| `description` | text | 1 | Required; describes what the Evidence demonstrates and why it is relevant |
| `source` | string | 1 | Where the Evidence comes from: system, tool, process or responsible party |
| `collected_at` | datetime | 1 | Immutable after creation; set at collection time |
| `collected_by` | string | 1 | Identifier of the agent or person who collected: Check ID, agent ID, or human identifier |
| `subject` | string | 1 | What is being evidenced: Finding ID, Check ID, Remediation ID, Waiver ID, or artifact |
| `related_finding` | list of Finding IDs | 0..N | Findings this Evidence supports; may be empty (Evidence of Check without associated Finding) |
| `related_check` | string | 0..1 | Check ID of the execution that generated this Evidence |
| `integrity` | string | 0..1 | Hash or verification mechanism when applicable (e.g., SHA256 of file, digital signature) |
| `valid_until` | date | 0..1 | Expiration date; required for temporal Evidence (Waiver, metrics, dynamic states) |
| `location` | string | 1 | Stable reference to content: file path, URL, reproducible command, reference to commit |

---

## Sufficiency criteria

Quantity of Evidence is not sufficiency. Evidence is sufficient when it satisfies ALL criteria below:

| Criterion | Description |
|---|---|
| **Relevance** | The Evidence is directly related to the condition being evaluated; it is not generic evidence |
| **Reliable source** | Comes from a system, tool or process with authority over the data |
| **Adequate temporality** | Was collected at a moment relevant to the condition (not excessively old) |
| **Reproducible or verifiable** | Can be verified by another agent or reviewed by a human without depending on interpretation |
| **Supports the conclusion** | The content of the Evidence supports the assertion made about the condition |
| **Not contradicted** | There is no Evidence from a higher-authority source that contradicts the conclusion |

---

## Evidence conflict

When Evidence from reliable sources diverges about the same condition, the Check result must be **Indeterminate** — NOT silent choice between sources.

The conflict must be recorded explicitly:

- Identify the two (or more) conflicting Evidence records
- Document what they contradict each other about
- Record the conflict in the trail of the affected Finding
- Escalate for human decision before concluding

**Never silently choose** between conflicting sources. Silent choice hides a model or data problem that needs to be resolved.

---

## Immutability

Historical Evidence **must not be overwritten**. Once recorded, Evidence represents the state of the system at the time of collection — retroactively altering that record destroys the historical trail.

When a new collection is needed (e.g., re-verification after Remediation):

- Create new Evidence with new ID (`EVD-YYYY-NNNN`)
- Reference the previous Evidence when relevant
- Record in the Finding trail that the new Evidence replaces or complements the previous one for a given conclusion

The previous Evidence remains in the record — what changes is which Evidence supports the current conclusion.

---

## Evidence expiration

Temporal Evidence must have `valid_until` declared when the information can change and validity depends on when it was collected.

Examples of Evidence that **must** have `valid_until`:
- Dynamic system state (metrics, SLOs, deploy state)
- Waiver approval (valid for the Waiver period)
- Workspace Conformance Report (can quickly become outdated)
- Assessment decision that may be reviewed

Evidence without `valid_until` is treated as permanently valid — use with care.

When Evidence expires:
- Associated Finding must be re-evaluated
- New Evidence must be collected if the condition is still relevant
- Finding may return to Open or Acknowledged if resolution Evidence expired

---

## References

→ [`README.md`](README.md) — entity model and relationships
→ [`finding.md`](finding.md) — entity that Evidence supports
→ [`check.md`](check.md) — entity that generates Evidence during execution
→ [`remediation.md`](remediation.md) — entity whose execution must be evidenced
→ [`waiver.md`](waiver.md) — entity whose approval must be evidenced
