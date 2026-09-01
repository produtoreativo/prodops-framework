# Operational Event Model Taxonomy
# ProdOps Framework

> **Domain:** Framework — applicable to all Journeys
> **Status:** Canonical
> **Version:** 1.0.0
> **Depends on:** [README.md](README.md) · [ontology.md](ontology.md)

---

## About this document

This document formalizes the **Operational Event Model (OEM) Taxonomy**: the classification
system that organizes, names, and governs all Operational Events in the ProdOps Framework.

The Taxonomy serves as a contract between the Framework and the Journeys. It ensures that
events from distinct Journeys are comparable, processable, and auditable in a consistent manner.

This document does not define schema, format, storage, or concrete Journey event catalogs.
Those documents depend on this Taxonomy for their elaboration.

→ [OEM Foundation](README.md) · [OEM Ontology](ontology.md) · [Framework Ontology](../ontology.md)

---

## 1. What an Event Taxonomy Is

### 1.1 Definition

> **Operational Event Taxonomy** is the canonical classification system that organizes
> all Operational Events of the ProdOps Framework into categories and types with precise
> semantics, standardized naming, and defined governance rules.

The Taxonomy is the contract that answers:

- To which class of occurrence does this event belong? → **Event Category**
- What is the precise name of this event within its Journey? → **Event Type**
- Who can define new types? Where are they documented? → **Governance**
- How do types evolve without breaking existing Timelines? → **Lifecycle**

### 1.2 Why the Taxonomy exists

Without a taxonomy, each Journey would invent its own names and categories. The result
would be:

- Two events with identical semantics receiving distinct names in different Journeys
- Two events with similar names having incompatible semantics
- Impossibility of cross-Journey analyses (metrics, Assessment, Diligence)
- Impossibility of auditing the Timeline without prior knowledge of each Journey

The Taxonomy eliminates these problems by defining:

1. **Fixed categories in the Framework** — common to all Journeys
2. **Journey-defined types** — specific, but following universal rules
3. **Shared types** — reusable across multiple Journeys
4. **Unique naming convention** — readable, predictable, unambiguous

### 1.3 Taxonomy's responsibility within the OEM

```
OEM
├── Foundation (README.md)    → What events are; principles
├── Ontology (ontology.md)    → Concepts, relationships, invariants
├── Taxonomy (taxonomy.md)    → Classification, naming, governance ← this document
├── Schema (schema.md)        → Technical structure of each event
└── Journey catalogs          → Concrete types defined by each Journey
```

The Taxonomy lives between the Ontology (which defines the concepts) and the Schema (which
defines the technical structure). It does not contain concrete types from any Journey —
only the rules that allow each Journey to define its own.

---

## 2. Event Category

### 2.1 Definition and purpose

> **Event Category** is a high-level classification that groups Event Types by
> operational nature. Categories are defined exclusively at the Framework level
> and are common to all Journeys.

The purpose of a Category is threefold:

1. **Classification:** indicates the nature of the occurrence without requiring reading the full name
2. **Filter:** allows Event Consumers (Diligence, metrics, Assessment) to filter by
   type of occurrence without knowing all types from all Journeys
3. **Behavior contract:** each Category carries expectations about `alters_state`,
   `requires_producer`, and emission patterns

### 2.2 Canonical Category catalog

| Category | Description | `alters_state` | Typical Producer | Frequency per cycle |
|---|---|---|---|---|
| **Phase Lifecycle** | Entry or exit of a Phase | Yes | Human, Agent | High — 2 per Phase (Start/End) |
| **Gate** | Result of quality criterion evaluation | Conditional | System, Agent | High — 1+ per Phase |
| **Human Decision** | Decision made by a human in the flow | Conditional | Human | Low — only in approvals |
| **Blocking** | Declaration or resolution of an impediment | Conditional | Human, Agent | Low — exception to normal flow |
| **Rework** | Return to a prior Phase | Yes | Human, Agent | Low — exception to normal flow |
| **System** | Event originated by infrastructure, pipeline, or tool | Rarely | System | Variable — depends on the pipeline |
| **Diligence** | Event emitted by Diligence when detecting an anomaly | Rarely | Agent (Diligence) | Low — exception to be remediated |
| **Correction** | Correction of an incorrectly recorded event | No | Human, Agent | Minimal — errors are exceptions |

### 2.3 Properties of a Category

| Property | Type | Required | Description |
|---|---|---|---|
| `name` | unique identifier | Yes | PascalCase, no spaces |
| `description` | text | Yes | Description of the operational nature |
| `alters_state` | enum: Yes/No/Conditional | Yes | Whether events of this category typically alter the Derived State |
| `requires_producer_subtypes` | list | No | Valid Producer subtypes (empty = all) |
| `governance_level` | Framework \| Journey | Yes | Who can define types in this Category |

### 2.4 Categories are fixed in the Framework

Categories **are not extensible by Journeys**. A Journey cannot create new
Categories — it can only create Event Types within existing Categories.

**Reason:** if Journeys could create Categories, two Journeys might create categories
with equivalent semantics but distinct names. This would break the cross-Journey analysis
capability of Event Consumers.

**What to do when no existing Category applies?**

An Event Type that does not fit in any Category is a signal that:

1. The type is being defined with wrong granularity or semantics (most likely), or
2. A new Framework Category may be needed — which requires a Taxonomy revision,
   not a unilateral Journey extension

The revision process is described in section 8 (Governance).

### 2.5 Category evolution

Categories evolve **slowly and in a controlled manner** — only by the Framework, not by
individual Journeys. The lifecycle of a Category:

| Phase | Trigger | Responsibility |
|---|---|---|
| **Proposed** | Multiple Journeys need a nature without an existing Category | Framework (formal proposal) |
| **Review** | Impact analysis on existing catalogs | Framework |
| **Active** | Category in use by at least one Journey | Framework |
| **Deprecated** | Category replaced by a more precise one | Framework — types migrated |
| **Removed** | No active Type references this Category | Framework — only after complete migration |

A deprecated Category remains valid for historical Event Types. Removal only occurs after
all catalogs have migrated their types to the replacement Category.

---

## 3. Event Type

### 3.1 Definition

> **Event Type** is the canonical name of a specific class of Operational Event,
> belonging to an Event Category and defined in a Journey's event catalog.

The Event Type is the identity of a class of occurrence. Each Operational Event
recorded in the Timeline is an instance of an Event Type.

### 3.2 Who creates an Event Type

| Who | Where | When |
|---|---|---|
| The Journey that needs to record a new type of occurrence | Journey catalog (`journeys/<journey>/events/catalog.md`) | When no existing type — own or shared — covers the occurrence |

No Operational Event can be recorded with an Event Type that is not cataloged.
Ad-hoc types (created at the time of emission) violate INV-07.

### 3.3 Who approves an Event Type

Approval is the responsibility of the **Journey governance** — the same authority that
approves structural changes to that Journey (see section 8). For types with cross-Journey
impact (shared types), approval requires Framework review.

### 3.4 Where an Event Type is documented

Every Event Type lives in **exactly one** of the following places:

| Type | Where it lives | Who defines it |
|---|---|---|
| **Shared type** | `events/shared-types.md` (future) | Framework |
| **Journey type** | `journeys/<journey>/events/catalog.md` | Journey |

A type cannot exist in more than one catalog. If two Journeys need the same occurrence,
the type is promoted to shared.

### 3.5 Can an Event Type exist outside a Journey?

Yes — **shared types**. These are types that represent generic reusable occurrences
by any Journey, such as `Phase.Started`, `Phase.Completed`, `Gate.Passed`,
`Gate.Failed`, `Impediment.Declared`, `Impediment.Resolved`, `Rework.Declared`, `Event.Corrected`.

Shared types are defined by the Framework, not by a specific Journey.

### 3.6 Can an Event Type be reused by more than one Journey?

**Shared types:** yes — they are reusable by definition.

**Journey types:** not directly. If two Journeys need the same occurrence with the same
semantics, the type must be promoted to shared. If the semantics are distinct, each Journey
defines its own type with an appropriate name.

**Critical rule:** never import a type from another Journey without promoting it to shared.
An informally imported type creates a hidden dependency between Journeys.

### 3.7 Properties of an Event Type

| Property | Type | Required | Description |
|---|---|---|---|
| `name` | identifier | Yes | Canonical name (see naming convention section 5) |
| `category` | Event Category | Yes | The Category to which this type belongs |
| `journey` | Journey \| `shared` | Yes | Owner Journey, or `shared` |
| `phase` | Phase \| null | Conditional | Phase during which it typically occurs |
| `alters_state` | boolean | Yes | Whether instances alter the Derived State |
| `new_state` | value \| null | Conditional | The resulting Derived State (when `alters_state = true`) |
| `producer_subtypes` | list | Yes | Valid subtypes: Human, System, Agent |
| `preconditions` | list of text | Yes | Conditions that must be true before emission |
| `postconditions` | list of text | Yes | Conditions that become true after emission |
| `status` | enum | Yes | Draft \| Active \| Deprecated \| Removed |
| `introduced_in` | version | Yes | Catalog version in which the type was created |
| `deprecated_in` | version \| null | No | Version in which the type was deprecated |

---

## 4. Relationship between Category and Type

### 4.1 Cardinalities

| Relationship | Cardinality | Invariant |
|---|---|---|
| Category → Event Types | 1 : N | A Category may have zero or more Types |
| Event Type → Category | N : 1 | A Type belongs to exactly one Category |
| Event Type → Operational Events | 1 : N | A Type may be instantiated zero or more times |
| Operational Event → Event Type | N : 1 | Every event has exactly one Type |

### 4.2 Constraints

**Can a Type change Category?**

No. The Category of an Event Type is immutable. If the categorization proves wrong, the
type is deprecated and a new type is created with the correct Category. Historical types
retain their original Category to preserve the integrity of existing Timelines.

**Can a Category disappear?**

Only after all its Types have been deprecated and migrated, and after all historical
Timelines have been addressed. In practice, Categories never disappear — they are
deprecated with a clear status and left as historical references.

**Can a Journey create a new Category?**

No. Categories are the Framework's exclusive domain. A Journey that needs a new Category
must propose its creation to the Framework — not create it unilaterally.

### 4.3 Invariants specific to the Category × Type relationship

**INV-TAX-01 — Category immutability per Type**
The Category of an Event Type never changes. If the Category is wrong, the type is deprecated
and a new type with the correct Category is created.

**INV-TAX-02 — Framework monopoly on Category definition**
No Journey can create, modify, or deprecate an Event Category without explicit Framework approval.

**INV-TAX-03 — No Type without Category**
There is no Event Type without a Category. An uncategorized event is not an Operational Event
— it is a log.

**INV-TAX-04 — Consistency between Type and Category regarding `alters_state`**
An Event Type with `alters_state = true` must belong to a Category whose `alters_state`
field is `Yes` or `Conditional`. A Type that alters state but belongs to a Category with
`alters_state = No` is a taxonomy inconsistency.

---

## 5. Naming Convention

### 5.1 The adopted convention

```
[Namespace.]Subject.Action
```

| Component | Requirement | Description |
|---|---|---|
| `Namespace` | Optional — omitted within the Journey's own catalog | Journey identifier (`Delivery`, `Diligence`, `Assessment`, `Discovery`, `Operation`) or `Shared` |
| `Subject` | Required | What was affected — a Phase, an entity, a process |
| `Action` | Required | What happened — verb in the past or state noun |

**Examples:**

```
Phase Lifecycle:    Bootstrap.Started       Bootstrap.Completed
Gate:               Gate.Passed             Gate.Failed
Human Decision:     Promote.Approved        Promote.Rejected
Blocking:           Impediment.Declared     Impediment.Resolved
Rework:             Rework.Declared         Rework.Resolved
System:             Pipeline.Failed         Deploy.Completed
Diligence:          Stale.Detected          Drift.Detected
Correction:         Event.Corrected

With Namespace (cross-Journey reference):
                    Delivery.Bootstrap.Started
                    Diligence.Scan.DriftDetected
                    Shared.Gate.Passed
```

### 5.2 Naming rules

**Rule 1 — PascalCase in all components**
```
✓ Bootstrap.Started
✓ Validate.GateFailed
✗ bootstrap.started
✗ BOOTSTRAP_STARTED
✗ bootstrap-started
```

**Rule 2 — Subject is the most specific relevant context**
```
✓ Bootstrap.Started     → Phase is the subject
✓ OBC.StateChanged      → Affected entity is the subject
✗ Delivery.Started      → Too ambiguous — what in Delivery started?
✗ Something.Happened    → Too generic
```

**Rule 3 — Action describes the occurrence, not the intention**
```
✓ Gate.Failed           → past fact
✓ Promote.Approved      → past fact
✗ Gate.Failing          → ongoing state
✗ Gate.WillFail         → future intention
✗ Gate.ShouldBe         → expectation
```

**Rule 4 — Complementary pair for transition events**
Events representing the start and end of an action must use complementary Actions:
```
✓ Phase.Started / Phase.Completed
✓ Impediment.Declared / Impediment.Resolved
✓ Rework.Declared / Rework.Resolved
✗ Phase.Begin / Phase.Done         → inconsistent
✗ Block.On / Block.Off             → not descriptive
```

**Rule 5 — Names without technology references**
```
✓ Pipeline.Failed       → process, not tool
✓ Deploy.Completed      → action, not tool
✗ GitHubActions.Failed  → technology reference
✗ PRMerged              → technology reference (PR = GitHub)
✗ JiraTicketClosed      → technology reference
```

**Rule 6 — Semantic uniqueness across the combined set of catalogs**
Two types with the same Subject.Action in different Journeys must have *different* semantics.
If the semantics are the same, the type must be shared.

```
Acceptable:
  Delivery.Promote.Completed  ≠  Diligence.Promote.Completed
  (Promote has different meaning in each Journey)

Not acceptable (promote to shared):
  Delivery.Gate.Failed  ≈  Diligence.Gate.Failed
  (Gate.Failed has the same semantics — must be Shared.Gate.Failed)
```

### 5.3 Advantages of this convention

| Advantage | Description |
|---|---|
| **Direct readability** | `Bootstrap.Started` is self-descriptive without consulting the catalog |
| **Optional Namespace** | Within the catalog, the Namespace is implicit — less verbosity |
| **Unambiguous cross-Journey** | With Namespace, `Delivery.Promote.Completed` is unambiguous |
| **Natural complementary pair** | `Phase.Started` / `Phase.Completed` form an obvious pair |
| **Technology-free** | Tool refactoring does not require renaming events |
| **Natural alphabetical ordering** | `Bootstrap.*` groups all Bootstrap events |

### 5.4 Known limitations

| Limitation | Mitigation |
|---|---|
| **Subject collision between Journeys** | Namespace resolves; Shared promotes |
| **Ambiguous Subject for cross-Phase events** | Use Category as alternative Subject |
| **Verbosity with Namespace** | Namespace is only required outside the Journey's catalog |
| **Phase name evolution** | Renaming a Phase requires deprecating types and creating new ones — high cost |

---

## 6. Taxonomy Evolution

### 6.1 Event Type lifecycle

```
Need                 Proposal              Review            Approval
identified      →    drafted in       →    by                by
by Journey           catalog               consumers          Framework
                     (status: Draft)       (Diligence,        (status: Active)
                                           Metrics,
                                           Assessment)
                                               ↓
                                    (in use in Timelines)
                                               ↓
                     Need for               ↓
                     change      →    Deprecation          New type created
                                     (status: Deprecated)  (substitutes)
                                               ↓
                     No new                   ↓
                     emission      →    Removal from catalog (status: Removed)
                     expected           (historical Timelines preserved)
```

### 6.2 How a new Event Type is born

1. **Identification:** the Journey identifies an occurrence that should be recorded and for
   which no existing type (own or shared) has adequate semantics.
2. **Duplicate check:** before proposing, the Journey verifies the catalogs of all Journeys
   and the shared types catalog to confirm the type does not exist.
3. **Draft:** the type is documented with all required properties, including Category,
   preconditions, postconditions, and whether it alters the Derived State.
4. **Review:** the proposal is reviewed by the main Event Consumers (Diligence, whoever
   maintains metrics, whoever maintains Assessment) to verify impact.
5. **Approval:** the type enters `Active` status and can be emitted by Skills.

### 6.3 How an Event Type evolves

Event Types **do not evolve** — they are immutable after approval. An active type cannot
have its properties changed (Category, `alters_state`, `new_state`).

**What can change without deprecating:**
- Clarification of the `description` (editorial)
- Addition of examples in documentation
- Addition of clarification notes on preconditions/postconditions

**What requires deprecating and creating a new type:**
- Category change
- `alters_state` change
- `new_state` change
- Renaming the type
- Changing the semantics of the represented occurrence

### 6.4 How an Event Type is deprecated

1. The type receives `Deprecated` status in the catalog.
2. A `deprecation_note` is added explaining the reason and the substitute type.
3. Skills that emitted the deprecated type are updated to emit the substitute type.
4. **Historical Timelines containing events of the deprecated type remain valid.** The deprecated
   type continues to be recognized by Event Consumers for historical reading.

### 6.5 How an Event Type is removed

A type only enters `Removed` status when:

- It has been in `Deprecated` status for at least one complete Journey cycle (to ensure
  no active Timeline is still actively using it)
- No new emission has occurred since the deprecation
- Event Consumers have confirmed the type can be excluded from active processing

**Important:** removing a type from the catalog does not erase historical events that use it.
Timelines are immutable — events with removed types remain in the Timeline with the original
type recorded. The catalog keeps removed types as read-only historical references.

### 6.6 Cross-version compatibility

A Journey's catalog is versioned. Compatibility rules:

| Change | Compatible? | Action |
|---|---|---|
| Add new type (status: Active) | Yes | Backward-compatible — consumers ignore unknown types |
| Deprecate existing type | Yes | Compatible — type is still recognized |
| Remove type (status: Removed) | Caution | Consumers must handle historical events with removed types |
| Rename type | No | Requires deprecating the original and creating a new one — never rename directly |
| Change `alters_state` of an active type | No | Requires deprecating and creating a new one |

---

## 7. Rules for Journeys

### 7.1 The contract

Every Journey that defines Event Types must sign the following contract:

**REG-01 — Verify before creating**
Before creating a new Event Type, the Journey MUST verify whether an equivalent type exists
in the shared types or in another Journey's catalog. Duplicating semantics violates INV-07
and fragments the analytical capacity of Event Consumers.

**REG-02 — Use shared types when available**
If a shared type covers the occurrence with adequate precision, the Journey MUST use it —
not create its own variation. Shared types are superior because they are processed by all
Event Consumers without Journey-specific mapping.

**REG-03 — Promote equivalent types between Journeys**
If two Journeys need the same occurrence with the same semantics, the type MUST be promoted
to shared. Duplication is never the correct solution.

**REG-04 — Follow the naming convention**
All Event Types MUST follow the `Subject.Action` convention with PascalCase. Names that
violate the convention cannot enter Active status.

**REG-05 — Document all required properties**
An Event Type without Category, without `alters_state` defined, without preconditions, or
without postconditions is an incomplete type. Incomplete types cannot enter Active status.

**REG-06 — Do not reference technology in names**
Event Types MUST NOT reference tools, platforms, systems, or implementations in their names.
The name must survive the replacement of any tool.

**REG-07 — Document impact on Derived State**
Every Event Type MUST explicitly declare whether it alters the Derived State and, if so,
to what value. Ambiguity about `alters_state` invalidates the type as a reliable source
of state projection.

**REG-08 — Document the expected Event Producer**
Every Event Type MUST declare which Producer subtypes are valid for its emission.
An event emitted by an undeclared Producer is a taxonomy violation.

**REG-09 — Complementary pair for transitions**
Events representing the start and end of a transition MUST exist as a pair. One cannot
define only `Phase.Started` without `Phase.Completed`.

**REG-10 — Maintain Timeline compatibility**
No change in Event Types can invalidate existing Timelines. The Timeline is immutable —
the evolution rules (section 6) must be followed to ensure historical events remain readable.

---

## 8. Governance

### 8.1 Governance structure

The Taxonomy has two governance levels, corresponding to the two types of element:

| Element | Governed by | Process |
|---|---|---|
| **Event Category** | Framework | Formal proposal, impact analysis on all Journeys, centralized approval |
| **Shared Event Type** | Framework | Journey proposal, review by all consumers, centralized approval |
| **Journey Event Type** | Journey | Internal proposal, review by Journey consumers (Diligence), Journey approval |

### 8.2 Framework governance responsibilities

The Framework is responsible for:

- **Maintaining the Event Category catalog** — adding, deprecating, removing
- **Maintaining the shared types catalog** — `events/shared-types.md` (future)
- **Arbitrating naming conflicts** — when two Journeys propose similar types
- **Auditing cross-Journey consistency** — ensuring REG-01 to REG-10 are followed
- **Reviewing proposals for new Categories** — evaluating whether they truly don't fit existing ones
- **Defining and versioning the Taxonomy** — this document

The Framework is **not** responsible for:

- Defining the specific Event Types of each Journey — that is the Journey's responsibility
- Validating whether event emission is occurring correctly — that is Diligence's responsibility

### 8.3 Journey governance responsibilities

Each Journey is responsible for:

- **Maintaining its Event Type catalog** — creating, approving, deprecating its types
- **Ensuring conformance with REG-01 to REG-10** — every type proposal must comply
- **Notifying the Framework** when proposing types that may be shared
- **Ensuring Skills emit the correct types** — the catalog and Skills must be aligned
- **Maintaining catalog versioning** — each change increments the version

### 8.4 Who can approve new Categories?

Only the **Framework** can approve new Event Categories. The process:

1. A Journey identifies that no existing Category covers the occurrence's nature
2. The Journey proposes the new Category with: name, description, `alters_state`, `requires_producer`
3. The Framework evaluates whether the Category is truly not covered by existing ones
4. If approved, the Category is added to the Taxonomy with versioning

### 8.5 Who can deprecate events?

| What | Who can deprecate |
|---|---|
| Event Category | Framework only |
| Shared Event Type | Framework only |
| Journey Event Type | The Journey that owns the type |

---

## 9. Relationship with Future Documents

This Taxonomy is the basis for the following documents — all depend on the categories,
conventions, and rules defined here:

### 9.1 OEM domain documents

| Document | How it uses the Taxonomy |
|---|---|
| `events/schema.md` | Defines the technical structure of each Event Type attribute; uses Category for consistency validations |
| `events/shared-types.md` | Shared types catalog — all follow the naming and rules of this Taxonomy |
| `events/timeline.md` | Defines Timeline behavior; uses Categories for ordering rules and state derivation |
| `events/event-store.md` | Defines storage; uses Categories for indexing and retention strategies |

### 9.2 Journey documents

| Document | How it uses the Taxonomy |
|---|---|
| `journeys/*/events/catalog.md` | Defines the Journey's Event Types; each type MUST follow the naming convention, belong to a Category of this Taxonomy, and satisfy REG-01 to REG-10 |

### 9.3 Consumption documents

| Consumer | How it uses the Taxonomy |
|---|---|
| **Diligence** | Checks filter by Category (e.g., "was there a Gate.Failed event in the last N days?"); detects absences by expected Category per Phase |
| **Assessment** | Pattern analysis uses Categories to aggregate — e.g., "proportion of Gate.Failed in Gate.Passed across 3 releases" |
| **Metrics** | Time metrics use `Phase Lifecycle` as anchors; quality metrics use `Gate`; rework metrics use `Rework` |
| **Agents** | Filter the Timeline by Category to make contextual decisions without processing all events |

---

## 10. Anti-patterns

### ANT-01 — Semantic duplication between Journeys

**The problem:** Journey A creates `Validate.Completed` and Journey B creates `Review.Done`,
both representing the successful completion of a validation phase.

**Consequence:** cross-Journey metrics are impossible without manual mapping. Assessment
cannot compare Journeys.

**Solution:** promote to shared type `Phase.Completed` with specific properties.

---

### ANT-02 — Different names for the same semantics in the same Journey

**The problem:** `Bootstrap.Started` and `Bootstrap.Begin` coexist in the same catalog with
the same semantics.

**Consequence:** ambiguity in the Timeline; consumers must handle both.

**Solution:** one single type per semantics; deprecate the duplicate immediately.

---

### ANT-03 — Overlapping Event Categories

**The problem:** creating a Category `Transition` that encompasses both Phase Lifecycle and
Human Decision.

**Consequence:** Category filters lose precision; Diligence cannot distinguish automatic
transition from human decision.

**Solution:** Categories must be orthogonal — no Event Type should be ambiguous between
two Categories.

---

### ANT-04 — Event Type too generic

**The problem:** creating `Thing.Happened` or `Event.Occurred` as a generic fallback type.

**Consequence:** the Timeline loses meaning; metrics derived from these types are useless.

**Solution:** every type must have precise semantics. If the occurrence cannot be named
precisely, it should not be recorded as an Operational Event.

---

### ANT-05 — Technological Event Type

**The problem:** creating `PullRequest.Merged` (GitHub reference), `JiraTicket.Closed`,
or `CircleCI.PipelinePassed`.

**Consequence:** changing tools invalidates the entire historical Timeline; consumers
become coupled to the infrastructure.

**Solution:** name the occurrence by the process, not the tool: `CodeReview.Approved`,
`Pipeline.Completed`, `WorkItem.Closed`.

---

### ANT-06 — Event Type representing intention, not fact

**The problem:** creating `Deploy.Planned`, `Gate.Expected`, `Phase.Scheduled`.

**Consequence:** violates P-01 (events represent facts); the Timeline mixes facts with
planning, making it untrustworthy as a source of truth.

**Solution:** only past occurrences are Operational Events. Planning lives in Knowledge
Space artifacts.

---

### ANT-07 — Journey creating Event Category unilaterally

**The problem:** Discovery decides it needs a `Signal` Category and creates it in its
own catalog.

**Consequence:** the `Signal` Category is not recognized by Framework Event Consumers;
breaks standardization; fragments cross-Journey analyses.

**Solution:** formal proposal to the Framework; while not approved, the type uses the
closest existing Category.

---

### ANT-08 — Changing `alters_state` of an active type

**The problem:** an active type has `alters_state = false` and the Journey decides to change
it to `true` without deprecating the type.

**Consequence:** historical Timelines calculate Derived State incorrectly for events prior
to the change; undetectable retrospective inconsistency.

**Solution:** deprecate the type and create a new one with the correct `alters_state`.
Type immutability is INV-TAX-01.

---

### ANT-09 — Importing types from another Journey without promoting to shared

**The problem:** Delivery decides to use `Diligence.Scan.Completed` in its Timeline because
"it's the same occurrence".

**Consequence:** hidden dependency between Journeys; if Diligence deprecates the type,
Delivery breaks; the type appears in the wrong context in analyses.

**Solution:** promote to shared type `Scan.Completed` or create `Delivery.Scan.Completed`
with its own semantics.

---

### ANT-10 — Creating types for non-operational occurrences

**The problem:** creating `BusinessDecision.Made` (strategic product decision) or
`StakeholderMeeting.Held` as Operational Events.

**Consequence:** pollutes the Timeline with occurrences outside ProdOps' scope; Event
Consumers don't know what to do with them.

**Solution:** Operational Events represent facts of the *Framework execution process*
— not facts from the external world, business, or strategy.

---

### ANT-11 — Using correction types to hide errors

**The problem:** instead of investigating why an incorrect event was emitted, the Journey
routinely emits `Event.Corrected` as a workaround.

**Consequence:** the Timeline becomes noise; the root cause of emission errors is never
addressed; consumers lose confidence in the Timeline.

**Solution:** `Event.Corrected` is for exceptional human or system recording errors.
Frequent correction emissions indicate a failure in the emission process — which must be
fixed in the Skills, not in the Timeline.

---

## References

- [OEM Foundation](README.md)
- [OEM Ontology](ontology.md)
- [Framework Ontology](../ontology.md)
- Delivery event analysis
- OEM foundation refinement
- OEM ontology report

---

*This Taxonomy is the canonical source of OEM classification and naming. Every Journey event
catalog, every schema document, and every implementation document must reference this document
as the origin of conventions and governance rules.*
