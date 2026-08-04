# ProdOps TDD Reference

**Definition:** Write verifiable contract → integration test → red → green → refactor → observability → evidence.
TDD here is classical (Detroit school): verify observable state — HTTP responses and DynamoDB state.

## Relation to Hack Flow

TDD drives the Hack phase: Red Bar = entering Hack, Green Bar = Hack in progress, Yellow Bar (refactor) = closing Hack before Commit Workflow.

## Files

| File | Description |
|------|-------------|
| [workflow.md](workflow.md) | Complete ProdOps TDD cycle step by step, with "done" criteria for each step |
| [red-green-refactor.md](red-green-refactor.md) | What is allowed and prohibited in each of the three phases |
| [integration-first.md](integration-first.md) | Why integration tests precede unit tests; tools and app lifecycle |
| [mocking-policy.md](mocking-policy.md) | No Mocks Rule: what is prohibited, what is permitted, and enforcement |
| [observability.md](observability.md) | What to validate in the observability step; Log String pattern |
| [quality-gates.md](quality-gates.md) | Delivery gates and test quality gates that block merge |
| [examples.md](examples.md) | Three complete TDD cycle examples in the Payments domain |
