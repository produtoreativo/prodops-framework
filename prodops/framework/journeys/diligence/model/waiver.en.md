# Waiver — Canonical Definition

## Definition

> **A Waiver is an explicit, justified, limited and temporary authorization to accept a condition recorded in a Finding without immediately executing its complete Remediation.**

---

## Fundamental principles

- **Waiver does not delete the rule.** The rule remains in force; only immediate application is suspended.
- **Waiver does not declare that the condition is correct.** The Finding remains a divergence — the Waiver only authorizes temporarily coexisting with it.
- **Waiver does not eliminate the Finding.** The Finding remains visible, trackable and with its own status (Waived).
- **Waiver temporarily changes the treatment mode.** While the Waiver is active, the condition does not block operations that it would normally block.
- **Expired Waiver returns the Finding to the normal flow.** The Finding returns to requiring treatment — either a new Remediation or a new Waiver with new justification.

---

## ID format

```
WVR-YYYY-NNNN
```

- `WVR`: immutable prefix of the Waiver entity
- `YYYY`: approval year (four digits)
- `NNNN`: four-digit sequential per year (0001–9999)

Examples: `WVR-2026-0001`, `WVR-2026-0012`

---

## Schema

| Field | Conceptual type | Cardinality | Rules and notes |
|---|---|---|---|
| `id` | string | 1 | Format WVR-YYYY-NNNN; immutable; unique in the system |
| `finding_id` | string | 1 | Exactly one Finding; one Waiver addresses one specific Finding |
| `reason` | text | 1 | Required; business or technical justification for temporarily accepting the condition |
| `scope` | text | 1 | Required; what exactly is being waived — must be explicit and limited |
| `approved_by` | string | 1 | Role or identity with authority to approve the Waiver for the condition type in question |
| `approved_at` | datetime | 1 | Immutable after approval; date and time of formal approval |
| `valid_from` | date | 1 | Start date of validity |
| `expires_at` | date | 1 | **Required.** No exceptions at this stage. Explicit and limited expiration date |
| `conditions` | list of strings | 0..N | Conditions that must be maintained while the Waiver is active |
| `compensating_controls` | list of strings | 0..N | Controls in place while the Waiver is active to mitigate the risk of the accepted condition |
| `review_date` | date | 0..1 | Optional intermediate review date before expiration |
| `status` | enum | 1 | See state flow below |
| `revoked_at` | datetime | 0..1 | Set if the Waiver is revoked before expiration |
| `revoked_by` | string | 0..1 | Role or identity that revoked; required if `revoked_at` is filled |
| `evidence` | Evidence ID | 1 | Evidence of formal approval; required |

---

## Mandatory rules

Every Waiver must contain:

1. **Reference to the Finding** — `finding_id` filled; exactly one Finding
2. **Justification** — `reason` describing why the condition is being temporarily accepted
3. **Owner** — role responsible for monitoring the Waiver
4. **Authorized approver** — `approved_by` with role authorized for this class of condition
5. **Explicit scope** — `scope` precisely describing what is being waived
6. **Validity period** — `valid_from` and `expires_at` filled
7. **Accepted risk** — `reason` must include description of the risk being accepted
8. **Compensating controls** — `compensating_controls` when applicable to the risk
9. **Review date** — `review_date` recommended for Waivers with validity exceeding 30 days
10. **Approval Evidence** — `evidence` filled with EVD of the formal approval

---

## Expiration rule

**Waiver without `expires_at` is invalid.** This rule has no exceptions at this stage of the Framework. Permanent Waivers are not allowed.

When creating a Waiver, the expiration date must be:
- Realistic: sufficient time to complete the Remediation
- Limited: do not use indefinitely long deadlines as a substitute for Remediation
- Justified: the reason for the deadline must be documented in `reason`

---

## Expired Waiver

When a Waiver expires:

1. The Waiver status changes to **Expired**
2. The Finding **returns to Acknowledged status** (or Open, if Acknowledged never occurred)
3. A signal must be generated to notify the owner
4. The Finding resumes blocking operations that it would block without the Waiver
5. **No Waiver is automatically renewed** — a new conscious and justified decision is needed
6. The new decision can be: (a) new Remediation, (b) new Waiver with new justification, or (c) formal acceptance as documented residual risk

---

## Active Waiver uniqueness

**Only one Waiver can be active per Finding per scope per period.** If conditions have changed and a new Waiver is needed before the previous one expires, the current Waiver must be explicitly revoked before a new one is approved.

---

## Revocation

A Waiver can be revoked before expiring when:
- The condition changed and the original justification is no longer valid
- The risk of the condition increased
- Compensating controls were not maintained
- A Remediation was completed before expiration
- A governance decision determines that the Waiver is no longer acceptable

When revoking: `revoked_at` and `revoked_by` required; revocation reason documented in Finding trail; Finding returns to normal treatment flow.

---

## Checks with `waiver_allowed: false`

Some Checks can declare that no Waiver is acceptable for the conditions they detect. When `waiver_allowed: false`:

- No Waiver can suspend the block generated by this Check
- The generated Finding must be resolved by complete Remediation
- No authorization, regardless of how high the hierarchical level, can substitute for Remediation

This declaration is used with extreme care — only for cases where the condition represents risk that cannot be managed by temporary acceptance. Conceptual examples (without claiming to be a complete catalog):
- Deliberate and irreversible loss of traceability
- Promotion without mandatory documented approval in a regulatory context

Do not create a catalog of non-waivable rules at this stage.

---

## State flow

```
Proposed → Approved → Active → Expired → (Finding returns to Acknowledged)
                             → Revoked  (explicit revocation with reason)
         → Rejected  (approver declined)
         → Closed    (Finding Verified eliminating need; or proper closure)
```

| State | Meaning | Who can transition |
|---|---|---|
| **Proposed** | Waiver requested; awaiting formal approval | Diligence or owner |
| **Approved** | Approved; awaiting start of validity | Authorized approver |
| **Active** | In effect; Waiver suspends block per policy | Automatic when `valid_from` is reached |
| **Expired** | `expires_at` was reached; Finding returns to normal flow | Automatic by temporality |
| **Revoked** | Revoked before expiration with explicit reason | Governance process |
| **Rejected** | Approver declined the proposal with justification | Authorized approver |
| **Closed** | Properly closed: Finding resolved or formal documented closure | Diligence after Finding Verified |

---

## Relationship with Finding and Remediation

```
Finding (FND-2026-XXXX)
   │ Finding identified and Acknowledged
   │
   ├── Remediation proposed but cannot be executed immediately
   │
   └── Waiver (WVR-2026-XXXX) created and approved
         │ Finding → Waived
         │ Block suspended (if waiver_allowed: true)
         │ Finding remains visible and trackable
         │
         ├── Waiver expires → Finding → Acknowledged → new decision
         │
         └── Remediation completed → Finding → Resolved → Verified
               → Waiver → Closed
```

---

## References

→ [`README.md`](README.md) — entity model and relationships
→ [`finding.md`](finding.md) — entity that the Waiver addresses
→ [`evidence.md`](evidence.md) — Evidence of Waiver approval
→ [`remediation.md`](remediation.md) — alternative to Waiver when correction is possible
→ [`check.md`](check.md) — definition of `waiver_allowed` in the Check
