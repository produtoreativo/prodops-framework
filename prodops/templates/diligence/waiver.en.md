---
id: WVR-YYYY-NNNN
title: "[DESCRIPTIVE TITLE — replace]"
status: "[Proposed|Approved|Active|Expired|Revoked|Rejected|Closed]"
finding_id: "[FND-YYYY-NNNN — exactly one Finding per Waiver]"
scope: "[what exactly is being waived — be specific; broad scope will be rejected]"
reason: "[business or technical justification for the Waiver — why immediate Remediation is not possible]"
risk_accepted: "[risk being explicitly accepted during the Waiver's validity period]"
approved_by: "[role/identity of the approver — must have authority for the type of condition]"
approved_at: ""
valid_from: ""
expires_at: "[MANDATORY — a Waiver without expiry is INVALID. No exceptions.]"
review_date: ""
conditions:
  - "[condition that must be maintained while the Waiver is active]"
compensating_controls:
  - "[compensating control in effect during the Waiver's validity period]"
evidence_ids:
  - "[EVD-YYYY-NNNN — Evidence of formal approval; mandatory]"
revoked_at: ""
revoked_by: ""
---

<!-- → Canonical model: prodops/framework/journeys/diligence/model/waiver.md -->
<!-- → Usage instructions: prodops/artifacts/diligence/README.md -->
<!-- WARNING: A Waiver without an expiry date is INVALID. This rule has no exceptions. -->
<!-- WARNING: Renewal generates a NEW Waiver with a new ID. Never edit expires_at retroactively. -->
<!-- WARNING: Finding remains visible and traceable while Waived — Waiver does not delete the Finding. -->
<!-- WARNING: A Waiver cannot be activated without a PR with an identifiable approver. -->

# Reason

<!-- Full justification for temporarily accepting this condition.
     Why can the Remediation not be completed before the Waiver expires?
     Must be specific, not generic ("no time" is not adequate justification).
     E.g.: "The fix requires a full Assessment with Risk Owner review (estimated: 2 weeks).
            The Release planned for 2026-07-28 has an unavoidable regulatory deadline.
            The feature has undergone informal technical review without incidents in the past 30 days." -->

# Scope

<!-- What exactly is being waived.
     Be specific about: which condition, which artifact, which period, which operations.
     Broad or vague scope is grounds for rejection.
     E.g.: "Waives the formal Reliability Plan requirement for OBC credit-card-v2
            exclusively for Release 2026-07-28 (tag v1.4.0).
            Does not apply to future Releases or other OBCs." -->

# Risk Accepted

<!-- Description of the risk being accepted during the Waiver's validity period.
     What could go wrong while this Waiver is active.
     Do not minimize — the accepted risk must be stated honestly.
     E.g.: "Absence of formal reliability criteria may leave latent failures
            in high-load scenarios undetected before the Release.
            Risk partially mitigated by the compensating controls below." -->

# Conditions

<!-- Conditions that must be maintained for the Waiver to remain valid.
     If a condition is violated, the Waiver may be revoked.
     E.g.:
     - No production incident related to the feature during the validity period
     - Enhanced monitoring with alerts at <100ms latency maintained active
     - Tech Lead reviewing metrics daily until expiration -->

# Compensating Controls

<!-- Alternative controls in effect while the Waiver is active.
     How the risk is being mitigated in the absence of full Remediation.
     E.g.:
     - Manual reliability review performed by Tech Lead on 2026-07-22 (no critical findings)
     - Observability dashboard configured with specific alerts for this feature
     - Automated rollback configured to revert in case of degradation above 5% -->

# Approval

<!-- Record of formal approval.
     Must reference the PR or document where the approval occurred.
     E.g.:
     Approver: Tech Lead + Product Owner
     Date: 2026-07-23
     Approval Pull Request: https://github.com/org/repo/pull/145
     Approval evidence: [EVD-2026-0005](../evidence/EVD-2026-0005.en.md) -->

# Validity

<!-- Validity period of this Waiver.
     All fields are mandatory.
     
     From (valid_from): YYYY-MM-DD
     Until (expires_at): YYYY-MM-DD [MANDATORY]
     Intermediate review date (review_date): YYYY-MM-DD [recommended]
     
     What happens on expiry:
     - Waiver → Expired
     - Finding → Acknowledged (returns to normal treatment flow)
     - Block is reactivated if the Check that generated the Finding still returns Fail
     - New decision required: new Remediation or new Waiver with new justification -->

# Review

<!-- How and when this Waiver will be reviewed before expiry.
     What will determine whether it should be renewed, closed, or revoked.
     E.g.: "Review on 2026-07-25 (review_date) with the Tech Lead.
            Criteria for non-renewal: no incidents + Reliability Plan started.
            Criteria for early revocation: any incident related to the feature." -->

# Revocation

<!-- Fill in only if the Waiver is revoked before expiry.
     Reason for revocation, date, who revoked it.
     
     E.g.:
     Revoked on: 2026-07-26
     Revoked by: Tech Lead
     Reason: Latency incident detected on 2026-07-25 — maintenance condition violated.
     Consequence: Finding returns to Acknowledged, block reactivated immediately. -->

# Evidence

<!-- Evidence related to this Waiver.
     Categories:
     - Approval evidence (mandatory): proof of formal approval with identifiable approver
     - Compensating controls evidence: proof that controls are active
     - Evidence collected during validity: monitoring, reviews, etc.
     
     Reference by EVD-YYYY-NNNN with relative link.
     E.g.:
     - [EVD-2026-0005](../evidence/EVD-2026-0005.en.md) — Approval: PR #145 approved by Tech Lead and PO
     - [EVD-2026-0006](../evidence/EVD-2026-0006.en.md) — Observability dashboard configured -->

# Trail

<!-- Append-only record of all relevant changes.
     NEVER overwrite previous entries.
     Format:
     - YYYY-MM-DD HH:MM [role/agent]: <event> — <justification>
     
     E.g.:
     - 2026-07-23 10:00 [Product Context Engineer]: Proposed — Remediation impossible before Release
     - 2026-07-23 11:00 [Tech Lead]: Approved — reviewed; compensating controls confirmed
     - 2026-07-23 11:00 [Product Owner]: Approved — risk explicitly accepted; PR #145 approved
     - 2026-07-23 11:30 [diligence-async]: Active — Waiver activated; Finding → Waived
     - 2026-07-28 00:00 [system]: Expired — expires_at reached; Finding → Acknowledged -->
