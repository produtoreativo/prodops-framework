# Learnings

Record reusable learnings from experiments, spikes, prototypes and exploratory validation here.

Do not convert learnings into delivery commitments until they are accepted into Downstream.

## Credit Card Asaas Lifecycle

Credit card support is feasible with the current Payments gateway shape, but it should not advance to Downstream as a simple extension of `billingType: CREDIT_CARD`.

Key learnings:

- The Asaas hosted checkout and the transparent checkout are distinct product and security contracts.
- Direct card capture requires fields and decisions not present in the current DTO: `creditCard`, `creditCardHolderInfo`, `creditCardToken`, `authorizeOnly`, installments and `remoteIp`.
- Immediate card processing can refuse authorization before persisting a charge, so the invoice state model and idempotency behavior must be explicit.
- Asaas card events — such as risk analysis, authorization, capture refusal, confirmation, receipt, deletion and refund — need explicit BDD mapping and observability.
- Deleting an unpaid charge is not the same as refunding an already-paid card charge.

Candidate for Downstream only after the next experiment defines the capture model and produces OBC, BDD, DTO, observability and Reliability Plan updates.

## Hosted vs Tokenized Credit Card

The focused comparison favors the Asaas hosted checkout as the first Downstream slice.

Validated learning:

- The hosted checkout can reuse the current `POST /invoices` shape, since Asaas can create a `CREDIT_CARD` payment without card fields and return an `invoiceUrl` for completion by the payer.
- Tokenized card payment is viable, but it is not just a UI option. It requires `creditCardToken`, `remoteIp`, explicit timeout, refusal mapping, risk-analysis mapping and storage/security rules for token ownership.
- Direct raw card data capture should remain outside the first Downstream slice unless Magazine Siará explicitly accepts the PCI/security and antifraud obligations.
- The Validation Workbench now exposes the proposed tokenized payload shape and card-specific webhook events for functional exploration.
- The capability is nearly ready for Downstream as hosted checkout, but tokenized payment still needs product and security approval before delivery.

## Saved Cards and Tokenization Boundary

Saved-card support is a Payments-owned contract, not just a Checkout UI choice.

Reusable learning:

- Cart/Checkout should list and select cards through `cardId` values owned by Payments. It must not receive or store the provider's `creditCardToken`.
- Payments can persist safe display metadata for the card — brand, last 4 digits, expiry, holder, provider and status — but must not persist the full card number, CVV or raw `creditCard` payload.
- The provider card token must be treated as sensitive material and suppressed from logs, traces, analytics, error payloads and dead-letter messages.
- New card registration expands the PCI/security scope even when raw card data is only transient, because `creditCard` and `creditCardHolderInfo` cross the Payments API boundary.
- `remoteIp` belongs to the payer context and must be provided by Cart/Checkout; using the Payments server IP weakens the antifraud evidence.
- The hosted checkout can still advance first, but saved-card reuse and new-card registration need Security, Architecture and Product decisions before Downstream.

## Checkout Gateway Feature Flag Readiness

The highest-priority uncertainty in the current product context is not a Payments API endpoint. It is knowing whether Checkout can safely enable the new gateway through a Feature Flag with rollout, auditability and rollback evidence.

Reusable learning:

- A release can have a functional Payments API and still fail to deliver value if the Checkout routing flag cannot be activated safely.
- Feature Flag readiness is a cross-system contract between Checkout, Payments and operations.
- Rollback must define what happens to orders already started in Payments; simply cutting off new traffic is not sufficient.
- The repository can prove Payments-side idempotency, correlation and webhook behavior, but cannot prove Checkout targeting or rollback without external evidence.

## Datadog Native AWS Instrumentation

The Payments API can maintain Datadog instrumentation without depending on the Serverless Framework.

Reusable learning:

- `dd-trace` and the existing observability module are application concerns; they do not require `serverless-plugin-datadog`.
- The AWS deploy should attach the Datadog Lambda Extension through SAM parameters, with the API key injected by the deploy pipeline.
- Local functional validation should use the NestJS sandbox with mocks and in-memory storage; Lambda/LocalStack validation is a separate infrastructure path, not the standard development loop.
- The remaining deploy decision is external to the repository: the pipeline owners must provide the correct Datadog Extension Layer ARN/version per AWS region.
- Lambda Function URL is sufficient for this lab API and avoids API Gateway cost.
- DynamoDB provisioned capacity mode can keep the current table/index model within the classic Free Tier envelope of 25 RCU / 25 WCU, assigning 1 RCU and 1 WCU to each table and GSI.
- Removing CloudWatch Logs permissions avoids log ingestion/storage charges, at the cost of losing application logs on the AWS side for troubleshooting.

## ProdOps Add-on Model — Open/Closed Principle (EXP-017)

The ProdOps Framework can be extended with external methods without modifying its core ontology.

Key learnings:

- **Extension Points as stable interfaces:** declaring EP-001 to EP-005 (discovery.methods, inception.pre-icebox, backlog.prioritization, artifacts.obc.sections, bdd.story-generation) allows any external method to plug into the Framework with an explicit contract — without touching existing Journey, Cycle, Phase, Capability, Skill or Step.
- **addon.yaml as a declarative contract:** each Add-on declares what it consumes (ProdOps artifacts), what it produces (new artifacts), which Extension Points it acts on, and which entry/exit gates it satisfies. This contract is sufficient for an agent to invoke the Add-on at the right point in the lifecycle.
- **PBB maps cleanly to ProdOps:** Personas → OBC stakeholders, Features → OBC capabilities, Steps Map (ARO) → BDD Feature steps, COORG → Iteration Backlog prioritization. No PBB concept conflicts with the existing ontology.
- **The natural PBB hook point is EP-002 (inception.pre-icebox):** the PBB session occurs after the OBC Draft enters the Product Backlog and before refinement in the Icebox. It enriches the OBC with Personas and Features and produces the initial BDD Features.
- **PBB Enablers → Upstream ProdOps:** a PBB exploratory Enabler is exactly an Upstream Spike; a technical Enabler is a non-functional PBI or Reliability Plan item. No new concept is needed.
- **Add-on is an implementation layer, not a structural one:** like Skill and Step, Add-on is an implementation convention — it does not alter the Journey → Cycle → Phase axis. The ontology.md receives only a minimal descriptive section.
- **Implementation belongs in prodops-portfolio:** the payments-api repository is a future consumer of the PBB Add-on, not the implementation location. Distribution happens via the prodops-framework mechanism (POPS-ICE-001).

Ready for Downstream in prodops-portfolio immediately — no blockers.

### 6 Industry Invariants — Mature Extension Systems (EXP-017 research)

Comparative research of 10 systems (VS Code, Eclipse, Backstage, Babel, ESLint, Terraform, GitHub Actions, Gradle, Jenkins, Webpack) identified 6 invariants present in all successful systems:

1. **Separation between Contract and Implementation:** the Framework declares only the interface (Extension Point); the Add-on provides the implementation. Never mix — an Extension Point without coupled implementation is the correct pattern.

2. **Declarative Registration + Lazy Activation:** Add-ons register metadata at discovery time (addon.yaml parsing); code only executes when the hook point is reached in the lifecycle. Two problems solved: slow startup and initialization coupling.

3. **Inversion of Control:** the Framework always calls the Add-on; the Add-on never calls the Framework directly nor modifies core artifacts. The Add-on receives what it declared in `artifacts.consumes` and writes only to `artifacts.produces`.

4. **Unique Identity with Hierarchical Namespace:** Extension Point IDs use hierarchical dot notation (`prodops.inception.pre-icebox`), not simple IDs (`EP-002`). Avoids collisions between Add-ons and makes the origin readable without consulting additional documentation.

5. **Isolation by API Surface:** the Add-on does not access the Framework's file system beyond what it declared. For the ProdOps context (LLM agents + Markdown files), isolation by API surface is sufficient — process-level isolation (Terraform/Backstage) is only necessary for Add-ons that execute external side effects.

6. **Versioning as a First-Class Contract:** compatibility uses range constraints (`">=1.14.0"`), not exact versions. An exact version is an anti-pattern: it automatically breaks on every Framework patch. A range constraint allows the Add-on to keep working across minor/patch versions without changes.
