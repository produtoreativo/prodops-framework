---
id: EVD-YYYY-NNNN
type: "[Document|Log|Metric|Test Result|Command Output|API Response|Screenshot|Pull Request|Commit|Release|Dashboard|Approval|Decision Record|Conformance Report|Observation]"
description: "[concise description of the evidence — what it proves]"
source: "[origin: tool, system, command, or URL]"
collected_at: "YYYY-MM-DDTHH:MM:SS-03:00"
collected_by: "[role/agent that collected it]"
subject: "[what is being evidenced — concrete subject]"
related_finding: []
related_check: ""
integrity: ""
valid_until: ""
location: "[relative path, URI, or reproducible command]"
---

<!-- → Canonical model: prodops/framework/journeys/diligence/model/evidence.md -->
<!-- → Usage instructions: prodops/artifacts/diligence/README.md -->
<!-- WARNING: This file is immutable after creation. -->
<!-- New collection must create a new EVD-YYYY-NNNN with a new ID. -->
<!-- NEVER include secrets, credentials, or sensitive data. Sanitize when necessary. -->

# Description

<!-- What this Evidence proves.
     Relationship with the Finding or Check that originated the collection.
     E.g.: "Proves that the 'owner' field was absent in file FND-2026-0002.md
            at the time of detection by Check DIL-TRC-001 on 2026-07-23." -->

# Source

<!-- Where this data came from.
     Tool, system, command, source URL.
     For Command Output: include the exact command that was executed.
     For API Response: include the endpoint and method.
     E.g.:
     - Tool: GitHub CLI (gh)
     - Command: gh issue view 89 --json body,labels
     - Executed at: 2026-07-23T14:30:00-03:00
     -->

# Content

<!-- The content of the Evidence.
     
     For extensive Command Output, Log, or API Response:
       Include the relevant excerpt here and reference the full file in attachments/ if necessary.
     
     For Document:
       Include the relevant excerpt with sufficient context.
     
     For Metric:
       Include the value, unit, collection period, and observability system.
     
     For Approval or Decision Record:
       Include reference to the PR, meeting, or approval document.
     
     NEVER include:
     - Passwords, tokens, API keys
     - Credentials of any kind
     - Sensitive user data
     - PII (Personally Identifiable Information)
     
     Replace sensitive values with [REDACTED] and document that sanitization was applied. -->

# Integrity

<!-- Hash, signature, or verification mechanism when applicable.
     E.g.:
     - SHA-256 of the captured file: abc123...
     - Verification: git log --format="%H" -- path/to/file (confirms state at commit)
     
     For Evidence without a formal verification mechanism: document the limitation. -->

# Validity

<!-- Validity period of this Evidence.
     If the Evidence is point-in-time (e.g.: command output): document when it was collected.
     If the Evidence can expire (e.g.: metric, certificate, approval): document valid_until.
     If there is no expiry date: justify why the Evidence is valid indefinitely.
     
     E.g.:
     - Collected at: 2026-07-23T14:30:00-03:00
     - Valid until: does not expire (immutable snapshot of the state at the time of detection)
     
     Or:
     - Collected at: 2026-07-23T14:30:00-03:00
     - Valid until: 2026-08-23 (SLO metric with a 30-day window) -->
