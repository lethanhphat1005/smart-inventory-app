import { beforeEach, describe, expect, it, vi } from 'vitest';

import { AuditLogService } from '../../../../src/modules/audit-log/service/audit-log.service.js';

import type { AuditLogRepository } from '../../../../src/modules/audit-log/repository/audit-log.repository.js';

type MockAuditLogRepository = {
  findManyByStoreId: ReturnType<typeof vi.fn>;
};

const createMockAuditLogRepository = (): MockAuditLogRepository => ({
  findManyByStoreId: vi.fn(),
});

describe('AuditLogService', () => {
  let auditLogRepository: MockAuditLogRepository;
  let auditLogService: AuditLogService;

  beforeEach(() => {
    auditLogRepository = createMockAuditLogRepository();
    auditLogService = new AuditLogService(
      auditLogRepository as unknown as AuditLogRepository,
    );
  });

  it('normalizes pagination, preserves filters, and returns paginated audit logs', async () => {
    const performedAt = new Date('2026-01-02T03:04:05.000Z');

    auditLogRepository.findManyByStoreId.mockResolvedValue({
      items: [
        {
          eventId: 'event-1',
          actionType: 'update',
          entityType: 'product',
          entityId: 'product-1',
          oldValue: { name: 'Old milk' },
          newValue: { name: 'Milk' },
          performedAt,
          userId: 'user-1',
          storeId: 'store-1',
          note: 'Changed product name',
        },
      ],
      totalItems: 21,
    });

    const result = await auditLogService.getAuditLogs('store-1', {
      page: 2.8,
      limit: 200,
      sortBy: 'performedAt',
      sortOrder: 'asc',
      entityType: 'product',
      actionType: 'update',
      userId: 'user-1',
      startDate: '2026-01-01T00:00:00.000Z',
      endDate: '2026-01-31T23:59:59.999Z',
      search: 'milk',
    });

    expect(auditLogRepository.findManyByStoreId).toHaveBeenCalledWith(
      'store-1',
      {
        page: 2,
        limit: 100,
        sortBy: 'performedAt',
        sortOrder: 'asc',
        entityType: 'product',
        actionType: 'update',
        userId: 'user-1',
        startDate: '2026-01-01T00:00:00.000Z',
        endDate: '2026-01-31T23:59:59.999Z',
        search: 'milk',
      },
    );
    expect(result).toEqual({
      items: [
        expect.objectContaining({
          eventId: 'event-1',
          storeId: 'store-1',
        }),
      ],
      meta: {
        page: 2,
        limit: 100,
        totalItems: 21,
        totalPages: 1,
      },
    });
  });

  it('applies default pagination when query omits page and limit', async () => {
    auditLogRepository.findManyByStoreId.mockResolvedValue({
      items: [],
      totalItems: 0,
    });

    const result = await auditLogService.getAuditLogs('store-1', {});

    expect(auditLogRepository.findManyByStoreId).toHaveBeenCalledWith(
      'store-1',
      {
        page: 1,
        limit: 10,
      },
    );
    expect(result.meta).toEqual({
      page: 1,
      limit: 10,
      totalItems: 0,
      totalPages: 0,
    });
  });

  it('propagates repository failures', async () => {
    auditLogRepository.findManyByStoreId.mockRejectedValue(
      new Error('database unavailable'),
    );

    await expect(
      auditLogService.getAuditLogs('store-1', {
        page: 1,
        limit: 10,
      }),
    ).rejects.toThrow('database unavailable');
  });
});
