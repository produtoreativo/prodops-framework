# Observability Validation

The observability step in the TDD cycle confirms that the system is observable in production,
not just correct in tests. Run this after Green Bar, before Commit Workflow.

---

## Structured Logs

Every operation that mutates state must emit a structured log entry. Requirements:

- `invoiceId` present in all log entries for that operation
- `tenantId` present in all log entries (multi-tenant traceability)
- `correlationId` propagated from the HTTP request header through all log entries
- **No PII:** no customer name, CPF, card number, or email in log output
- **No secrets:** no API keys, tokens, or credentials
- Error logs include a meaningful `message` field — not just a stack trace

**Example of a compliant log entry:**
```json
{ "level": "info", "message": "invoice.created", "invoiceId": "inv-001", "tenantId": "tenant-abc", "correlationId": "req-xyz", "status": "PENDING" }
```

**Non-compliant (PII leak):**
```json
{ "message": "invoice created for Ana Silva, CPF 000.000.000-00" }
```

---

## Traceability

| Field | Where it originates | Where it must appear |
|-------|--------------------|--------------------|
| `correlationId` | `x-correlation-id` request header | All log entries for the request |
| `tenantId` | `x-tenant-id` request header | All log entries, all downstream calls |
| `externalReference` | Asaas charge response | Invoice record in DynamoDB, relevant log entries |

If `correlationId` is missing from a downstream call to `AsaasService`, a production incident
becomes untraceable. Validate this before committing.

---

## Log String Pattern (Yellow Bar)

To assert that observability behavior is correct in tests, capture the logger output using the
Log String technique:

```typescript
const logMessages: string[] = [];
const logger = { log: (msg: string) => logMessages.push(msg), error: jest.fn(), warn: jest.fn() };

// ... run operation ...

expect(logMessages).toContain(expect.stringContaining('invoice.created'));
expect(logMessages).toContain(expect.stringContaining('inv-001'));
```

Use Log String in unit tests for log-sensitive paths. Do not use it to replace integration tests.

---

## Observability Checklist

Before marking the observability step done:

- [ ] `invoiceId` logged on create, confirm, and cancel operations
- [ ] `tenantId` logged on all operations
- [ ] `correlationId` present in all log entries for a request
- [ ] No customer name, CPF, or payment card data in any log entry
- [ ] No API keys or tokens in any log entry
- [ ] Error paths log a human-readable `message`, not only `stack`
- [ ] `externalReference` stored in DynamoDB and logged on Asaas integration
