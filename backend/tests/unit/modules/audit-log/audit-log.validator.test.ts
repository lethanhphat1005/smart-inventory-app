import { describe, expect, it } from 'vitest';

import { listAuditLogsQuerySchema } from '../../../../src/modules/audit-log/validator/audit-log.validator.js';

describe('listAuditLogsQuerySchema', () => {
  it('accepts valid query filters and coerces pagination', () => {
    const result = listAuditLogsQuerySchema.parse({
      page: '2',
      limit: '25',
      sortBy: 'performedAt',
      sortOrder: 'asc',
      entityType: ' product ',
      actionType: 'update',
      userId: 'user-1',
      startDate: '2026-01-01T00:00:00.000Z',
      endDate: '2026-01-31T23:59:59.999Z',
      search: 'milk',
    });

    expect(result).toEqual({
      page: 2,
      limit: 25,
      sortBy: 'performedAt',
      sortOrder: 'asc',
      entityType: 'product',
      actionType: 'update',
      userId: 'user-1',
      startDate: '2026-01-01T00:00:00.000Z',
      endDate: '2026-01-31T23:59:59.999Z',
      search: 'milk',
    });
  });

  it('applies default pagination and sorting values', () => {
    expect(listAuditLogsQuerySchema.parse({})).toEqual({
      page: 1,
      limit: 10,
      sortBy: 'performedAt',
      sortOrder: 'desc',
    });
  });

  it('rejects pagination outside allowed boundaries', () => {
    expect(() => listAuditLogsQuerySchema.parse({ page: '0' })).toThrow();
    expect(() => listAuditLogsQuerySchema.parse({ limit: '0' })).toThrow();
    expect(() => listAuditLogsQuerySchema.parse({ limit: '101' })).toThrow();
  });

  it('rejects unsupported sort and action values', () => {
    expect(() =>
      listAuditLogsQuerySchema.parse({ sortBy: 'entityType' }),
    ).toThrow();
    expect(() =>
      listAuditLogsQuerySchema.parse({ sortOrder: 'newest' }),
    ).toThrow();
    expect(() =>
      listAuditLogsQuerySchema.parse({ actionType: 'restore' }),
    ).toThrow();
  });

  it('preserves blank optional string filters according to current schema behavior', () => {
    const result = listAuditLogsQuerySchema.parse({
      entityType: '   ',
      userId: '',
      search: '',
      startDate: 'not-a-date',
    });

    expect(result).toMatchObject({
      entityType: '',
      userId: '',
      search: '',
      startDate: 'not-a-date',
    });
  });
});
