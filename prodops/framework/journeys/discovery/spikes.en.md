# Spike Solutions

## What is a Spike Solution

A Spike Solution is a **time-boxed technical investigation** whose only output is a decision — not a product, not an increment, not deliverable code.

The objective is to answer one specific technical question that blocks or conditions progress.

**Central characteristic:** there is never a customer involved. If there is a customer, it is a PoC.

---

## Spike Solution vs PoC

| Dimension | PoC | Spike Solution |
|---|---|---|
| Customer involved | Always | Never |
| Objective | Validate feasibility with real feedback | Answer a specific technical question |
| Produces | Validated learning with customer | Internal technical decision |
| Code | Can be demonstrable | Always disposable |
| When to use | Hypothesis Validation phase | Any stage, any phase |

---

## When to use

A Spike Solution is appropriate when:

- there is a specific technical uncertainty that blocks a design or architecture decision;
- the question cannot be answered without exploratory implementation;
- the scope is small and well-bounded (one question = one spike);
- the risk of implementing without investigating outweighs the cost of the spike.

A Spike Solution is **not** appropriate when:

- the objective is to validate with a user or customer — use a PoC;
- the investigation has no defined question — use an Upstream experiment;
- the result will be incorporated directly into the product without review — in that case, it is not a spike.

---

## When it can occur

A Spike Solution can occur at any point in the product lifecycle:

- **Inside an Upstream experiment** — to answer a technical question before advancing
- **Inside a PoC** — to validate a technical component before customer demonstration
- **In the Icebox** — to resolve technical uncertainty that blocks the Minimum OBC
- **During Downstream** — to investigate unexpected behavior without altering the delivery flow

---

## How to record

Record the spike directly in this file using the structure below.

If the spike is part of an active Upstream experiment, record it in that experiment's `upstream-trail.md`, not here.

---

## Spike record structure

```
## Spike — [Title]

**Date:** YYYY-MM-DD
**Product stage:** PoC | MVP | IPR | MVR | MVT | MLP
**Question:** [One specific, closed-ended question]
**Timebox:** [E.g.: 2 hours, 1 day]

**What was investigated:**

**Evidence found:**

**Decision:**
- [ ] Advance with the investigated approach
- [ ] Discard the approach — reason:
- [ ] Requires another spike — question:
- [ ] Escalate to Upstream experiment

**Artifacts produced:** (links to disposable code, scripts, notes)
```

---

## Recorded spikes

<!-- Add entries below as they occur -->
