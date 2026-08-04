# Pull Request Checklist

- [ ] The change went through the Hack Flow.
- [ ] A test exists before or alongside the implementation (Red Bar confirmed).
- [ ] Integration/acceptance tests were prioritized.
- [ ] No improper mocks of business logic were created.
- [ ] Contracts (OpenAPI, BDD Feature, AsyncAPI) were updated when necessary.
- [ ] Relevant logs and error messages were validated.
- [ ] Lint executed (`npm run lint` exited 0).
- [ ] Tests executed (unit + acceptance when applicable).
- [ ] Build executed.
- [ ] Architecture and Event Storming updated if the change was structural.
- [ ] Evidence recorded in the Release Trail or upstream-trail.
- [ ] Definition of Done satisfied. See [definition-of-done.md](../engineering/definition-of-done.md).
