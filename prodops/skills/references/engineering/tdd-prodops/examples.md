# TDD Cycle Examples — Payments Domain

---

## Example 1: Create Invoice (Happy Path)

**Contract:** `POST /invoices` → 201 with `invoiceId` and `status: PENDING`

### Red Bar
```typescript
// api/test/criar-invoice.e2e-spec.ts
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
Run: fails with `Expected: 201, Received: 404`. Route does not exist yet. Red Bar confirmed.

### Green Bar
```typescript
// api/src/modules/invoices/invoice.controller.ts
@Post()
async create(@Body() dto: CreateInvoiceDto, @Headers('x-tenant-id') tenantId: string) {
  return this.invoiceService.create({ ...dto, tenantId });
}

// api/src/modules/invoices/services/invoice.service.ts
async create(dto: CreateInvoiceDto) {
  const invoiceId = this.uuidGenerator.generate();
  await this.repository.save({ invoiceId, tenantId: dto.tenantId, orderId: dto.orderId, status: 'PENDING' });
  return { invoiceId, status: 'PENDING' };
}
```
Run: passes with 201. Green Bar confirmed.

### Refactor
Extract `buildInvoiceEntity` to keep `create` readable:
```typescript
private buildInvoiceEntity(dto: CreateInvoiceDto, invoiceId: string): Invoice {
  return { invoiceId, tenantId: dto.tenantId, orderId: dto.orderId, status: 'PENDING', createdAt: this.clock.now() };
}
```
Run tests: still green. Commit Workflow executed.

---

## Example 2: Webhook Confirmation

**Contract:** `POST /webhooks/asaas` → 200; invoice status in DynamoDB transitions to `CONFIRMED`

### Red Bar
```typescript
// api/test/webhook-confirmation.acceptance.e2e-spec.ts
it('should confirm invoice when Asaas sends PAYMENT_CONFIRMED webhook', async () => {
  const { invoiceId } = await createInvoiceFixture(app, 'tenant-abc');

  const res = await request(app.getHttpServer())
    .post('/webhooks/asaas')
    .send({ event: 'PAYMENT_CONFIRMED', payment: { externalReference: invoiceId } });

  expect(res.status).toBe(200);

  const invoice = await getInvoiceFromDynamoDB(invoiceId);
  expect(invoice.status).toBe('CONFIRMED');
});
```
Run: fails with `Expected: "CONFIRMED", Received: "PENDING"`. Route exists but status not updated. Red Bar confirmed.

### Green Bar
```typescript
// api/src/modules/webhooks/webhook.handler.ts
async handleAsaas(payload: AsaasWebhookDto) {
  if (payload.event === 'PAYMENT_CONFIRMED') {
    await this.invoiceRepository.updateStatus(payload.payment.externalReference, 'CONFIRMED');
  }
  return { received: true };
}
```
Run: passes. Green Bar confirmed.

### Refactor
Extract event routing to `WebhookEventRouter` so the handler stays thin. Run tests: still green.

---

## Example 3: Provider Error (Unit Test)

**Scenario:** `AsaasService.createCharge` throws a network error; `InvoiceService` must rethrow
a mapped `ExternalProviderException`.

This belongs in a unit test — simulating a provider timeout in an acceptance spec requires
real network manipulation.

```typescript
// api/src/modules/invoices/services/invoice.service.spec.ts
describe('InvoiceService.create — provider error', () => {
  it('should throw ExternalProviderException when AsaasService fails', async () => {
    // Yellow Bar Mock Object: AsaasService is an external technical dep
    const asaasService = {
      createCharge: jest.fn().mockRejectedValue(new Error('ECONNREFUSED')),
    };
    const repository = { save: jest.fn() };
    const uuidGenerator = { generate: jest.fn().mockReturnValue('inv-001') };

    const service = new InvoiceService(asaasService as any, repository as any, uuidGenerator as any);

    await expect(
      service.create({ tenantId: 'tenant-abc', orderId: 'order-001', amount: 100 }),
    ).rejects.toThrow(ExternalProviderException);
  });
});
```

**Why Mock Object is acceptable here:** `AsaasService` is an external technical dependency (HTTP
client to Asaas API). Mocking it does not hide owned business logic — the unit test verifies that
`InvoiceService` handles provider failures correctly, which is the behavior under test.
