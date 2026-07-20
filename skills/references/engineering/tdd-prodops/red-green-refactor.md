# Red / Green / Refactor Phases

---

## Red Phase

**Allowed:**
- Writing the integration test in `api/test/`
- Running the test and observing the failure reason
- Adjusting the test if the failure is due to a syntax/setup error, not behavior

**Prohibited:**
- Writing any production code (no `src/` changes)
- Changing the test assertion to make it pass trivially
- Moving forward without confirming the failure is behavioral

**Expected output:**
```
● POST /invoices › should create invoice and return 201

  expect(received).toBe(expected)
  Expected: 201
  Received: 404
```

**Invoice example — Red Bar test:**
```typescript
it('should create invoice and return 201 with invoiceId', async () => {
  const res = await request(app.getHttpServer())
    .post('/invoices')
    .set('x-tenant-id', 'tenant-abc')
    .send({ orderId: 'order-001', amount: 150.00, customer: { name: 'Ana', cpf: '000.000.000-00' } });

  expect(res.status).toBe(201);
  expect(res.body.invoiceId).toBeDefined();
  expect(res.body.status).toBe('PENDING');
});
```
Run this before `POST /invoices` exists. It must return 404. That is the Red Bar.

---

## Green Phase

**Allowed:**
- Minimum production code to pass the test (Fake It or Obvious Implementation)
- Hardcoded returns if the test passes — that is fine at this stage
- Adding route, controller method, service stub, repository call

**Prohibited:**
- Refactoring or cleaning up while making it green
- Adding features not covered by the current test
- Writing additional tests (finish the Green Bar first)

**Expected output:**
```
PASS api/test/criar-invoice.e2e-spec.ts
  ✓ should create invoice and return 201 with invoiceId (312ms)
```

**Invoice example — minimum Green Bar implementation:**
```typescript
// invoice.service.ts — minimum to pass
async create(dto: CreateInvoiceDto): Promise<{ invoiceId: string; status: string }> {
  const invoiceId = uuid();
  await this.repository.save({ invoiceId, tenantId: dto.tenantId, status: 'PENDING', ...dto });
  return { invoiceId, status: 'PENDING' };
}
```

---

## Refactor / Yellow Phase

**Allowed:**
- Extract method (e.g., `buildInvoiceEntity(dto)`)
- Rename variables to match domain language
- Remove duplication between service and DTO mapping
- Apply Yellow Bar patterns: Mock Object for logger/clock/UUID, Log String, Child Test

**Prohibited:**
- Adding new behavior not covered by a test
- Changing test assertions
- Introducing new branches without a corresponding Red Bar first

**Expected output:**
- All previously passing tests still pass
- Code reads closer to the domain: `InvoiceService.create` orchestrates, `InvoiceRepository.save` persists

**Invoice example — Refactor:**
```typescript
// Before: inline mapping in service
// After: extracted helper keeps service readable
private buildInvoiceEntity(dto: CreateInvoiceDto, invoiceId: string): Invoice {
  return { invoiceId, tenantId: dto.tenantId, orderId: dto.orderId, status: 'PENDING', createdAt: this.clock.now() };
}
```
Run tests after each extraction. Green must stay green throughout.
