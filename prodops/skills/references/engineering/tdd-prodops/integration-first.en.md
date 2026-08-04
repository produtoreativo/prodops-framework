# Integration Tests First

---

## Why Integration Before Unit

Integration tests in `api/test/` verify *observable behavior* at the HTTP boundary. They exercise
the whole stack: routing → controller → service → repository → DynamoDB (LocalStack). A unit test
for `InvoiceService.create` can pass while the route is missing, the DTO validation rejects the
payload, or the DynamoDB table name is wrong.

Concrete bugs unit tests cannot catch:
- Route not registered in the module
- DTO missing `@IsString()` causing 400 instead of 201
- DynamoDB attribute name mismatch (saved as `invoice_id`, queried as `invoiceId`)
- SQS event not emitted after status transition
- `tenantId` not propagated to the repository call

**Test pyramid for this repository:**
```
acceptance/E2E (api/test/)      ← primary driver of TDD Red Bar
    integration                 ← service + repository in isolation when needed
        unit                    ← error paths, pure business logic, Learning Tests
```

---

## When Unit Tests Make Sense

- **Error paths requiring external system failure:** AsaasService times out, returns 5xx, or returns
  malformed payload. Simulating these in an acceptance spec requires network manipulation; a unit
  test with a Yellow Bar Mock Object on the HTTP client is the right tool.
- **Complex pure business logic without HTTP surface:** fee calculation, instalment splitting, date
  arithmetic with edge cases.
- **Learning Tests:** verify behavior of a third-party library (e.g., DynamoDB DocumentClient
  `put` vs `update` semantics) before using it in production code.

---

## Tools and Setup

| Tool | Purpose |
|------|---------|
| `supertest` | HTTP assertions against real NestJS app |
| `LocalStack` | DynamoDB and SQS running locally via Docker |
| `./scripts/test-acceptance.sh` | Bootstraps LocalStack, runs `jest --config jest-e2e.json` |
| `ASAAS_MOCK=true` | Activates deterministic branch inside real `AsaasService` |

---

## App Lifecycle Per Spec File

```typescript
let app: INestApplication;

beforeAll(async () => {
  const moduleRef = await Test.createTestingModule({ imports: [AppModule] }).compile();
  app = moduleRef.createNestApplication();
  await app.init();
});

afterAll(async () => {
  await app.close();
});

beforeEach(async () => {
  await truncateTables(['invoices', 'tenants']); // reset state, never share between tests
});
```

One app instance per file. Never create the app inside `beforeEach` — startup cost is too high
and connection pools leak.
