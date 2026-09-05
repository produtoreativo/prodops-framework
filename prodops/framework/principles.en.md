# ProdOps Principles

## 1. Business intent drives technology
Every technical action must have a traceable business intent. Technology without intent has no direction; intent without technology has no outcome. The OBC is the contract that makes this relationship verifiable — it is not a technical requirement, it is the agreement between business and technology with observable criteria in production. No implementation work begins without the business intent being identified, understood, and formalized. See [Origin Streams](origin-streams.en.md) for the four possible origins of a Business Intent.

## 2. Flow over friction
Delivery acceleration is a consequence of eliminating friction, not of increasing pressure. Friction arises from missing context, undefined contracts, unrecorded decisions, and deferred automation. When the intent is clear, the contract is defined, and engineering practices are in place, flow is natural. Delivery speed is a health indicator of the process — not a goal in itself.

## 3. Engineering before implementation
Observability, deploy strategy, and tests are defined **before** writing production code — in that order of priority. They are not practices added at the end of delivery; they are design preconditions. Observability comes first: without it, it is impossible to know whether the implemented behavior is correct in production. Deploy comes second: without a progressive delivery strategy, code does not reach the user with control and safety. Tests come third: TDD is the practice, but tests without observability and without a deploy strategy are incomplete local verification. A system that cannot be observed, cannot be delivered progressively, or cannot be tested independently is not ready to be implemented.

## 4. Product context first
No code change begins without context compatible with its execution mode. Upstream is permissive, experimental and carries no delivery commitment. Downstream is complete: before Delivery execution, it requires every readiness artifact and gate defined by the Framework. Agents must not invent missing business context.

## 5. Upstream before commitment
Upstream is not a journey: it is the no-delivery-commitment mode, where any journey may operate with experimental rigor and variable maturity. Code is disposable until promoted to Downstream. Downstream may also execute any journey, but applies every current quality gate. See `AGENTS.md` in your repository (Upstream Path).

## 6. Contracts before implementation
Identify or create a verifiable contract (OpenAPI, AsyncAPI, BDD Feature, schema) before writing production code. The contract is the shared language between test and implementation.

## 7. Observability as a deliverable
Logs, errors, metrics, and traceability are part of the implementation, not add-ons added afterward. A feature is not done if its behavior cannot be observed in production.

Observability serves distinct roles in each execution mode:

- **In Downstream:** observability *verifies the commitment* — SLOs, DORA metrics, and the Release Trail answer "is the commitment being honored?"
- **In Upstream:** observability *makes uncertainty explicit* — the Evidence Package, Upstream Trail, and Decision Package answer "what do we know, what don't we know, and with what degree of confidence?"

In Downstream, the absence of observability is a commitment violation. In Upstream, the absence of observability is the absence of evidence — the experiment cannot produce verifiable learning.

## 8. Evidence-based decisions
Every delivery decision — promote, revert, accept risk — must be backed by recorded evidence. See [release-trail](../artifacts/trails/release-trail.md) and [operation/](journeys/operation/).

## 9. Reliability is a first-class concern
Reliability objectives are defined before implementation, tracked via OBCs and SLOs, and validated before promotion. See [reliability-plans](../artifacts/plans/reliability/).

## 10. No shortcuts in production code
Production code must not contain test-only branches, environment-specific hacks, or hidden overrides that alter behavior in tests. Designed behavior modes (e.g., external provider mock) are valid exceptions when explicitly declared as an intentional product feature — not as a test shortcut.

## 11. Automation First
An agent must always attempt to execute an action itself before instructing a human to do it. Manual intervention is a last resort (a documented **Manual Exception**), never the default path. Canonical order of attempts: API → MCP → CLI → SDK → Browser Automation → Manual Exception only when all else fails. Phrases like "do it manually", "access the UI", or "configure manually" are prohibited unless all automation options have been demonstrably exhausted and recorded in a tracking Issue. See [automation-first.md](automation-first.en.md) for the full decision tree.


---

→ **Next:** [Operating Model](operating-model.en.md)
