import { beforeEach, describe, expect, it, vi } from 'vitest';

import { Prisma } from '../../../../src/generated/prisma/client.js';
import { AuditLogRepository } from '../../../../src/modules/audit-log/repository/audit-log.repository.js';

const createMockDb = () => ({
  $transaction: vi.fn(),
  auditLog: {
    findMany: vi.fn(),
    count: vi.fn(),
    create: vi.fn(),
  },
});

describe('AuditLogRepository', () => {
  let db: ReturnType<typeof createMockDb>;
  let auditLogRepository: AuditLogRepository;

  beforeEach(() => {
    db = createMockDb();
    auditLogRepository = new AuditLogRepository(db as never);
  });

  it('findManyByStoreId queries store-scoped audit logs with defaults', async () => {
    const rows = [
      {
        eventId: 'event-1',
        actionType: 'create',
        entityType: 'product',
        entityId: 'product-1',
        oldValue: null,
        newValue: { name: 'Milk' },
        performedAt: new Date('2026-01-02T03:04:05.000Z'),
        userId: 'user-1',
        storeId: 'store-1',
        note: null,
        user: {
          fullName: 'Ada Lovelace',
        },
      },
    ];

    db.$transaction.mockResolvedValue([rows, 1]);

    const result = await auditLogRepository.findManyByStoreId('store-1', {});

    expect(db.$transaction).toHaveBeenCalledWith([
      db.auditLog.findMany({
        where: {
          storeId: 'store-1',
        },
        orderBy: {
          performedAt: 'desc',
        },
        skip: 0,
        take: 10,
        include: {
          user: {
            select: { fullName: true },
          },
        },
      }),
      db.auditLog.count({
        where: {
          storeId: 'store-1',
        },
      }),
    ]);
    expect(result).toEqual({
      items: rows,
      totalItems: 1,
    });
  });

  it('findManyByStoreId applies filters, date range, search, sorting, and pagination', async () => {
    db.$transaction.mockResolvedValue([[], 0]);

    await auditLogRepository.findManyByStoreId('store-1', {
      page: 3,
      limit: 20,
      sortBy: 'performedAt',
      sortOrder: 'asc',
      entityType: 'product',
      actionType: 'update',
      userId: 'user-1',
      startDate: '2026-01-01T00:00:00.000Z',
      endDate: '2026-01-31T23:59:59.999Z',
      search: 'milk',
    });

    const expectedWhere = {
      storeId: 'store-1',
      entityType: 'product',
      actionType: 'update',
      userId: 'user-1',
      performedAt: {
        gte: new Date('2026-01-01T00:00:00.000Z'),
        lte: new Date('2026-01-31T23:59:59.999Z'),
      },
      OR: [
        {
          note: {
            contains: 'milk',
            mode: 'insensitive',
          },
        },
        { newValue: { string_contains: 'milk' } },
      ],
    };

    expect(db.auditLog.findMany).toHaveBeenCalledWith({
      where: expectedWhere,
      orderBy: {
        performedAt: 'asc',
      },
      skip: 40,
      take: 20,
      include: {
        user: {
          select: { fullName: true },
        },
      },
    });
    expect(db.auditLog.count).toHaveBeenCalledWith({
      where: expectedWhere,
    });
  });

  it('findManyByStoreId supports one-sided date ranges', async () => {
    db.$transaction.mockResolvedValue([[], 0]);

    await auditLogRepository.findManyByStoreId('store-1', {
      startDate: '2026-01-01T00:00:00.000Z',
    });

    expect(db.auditLog.findMany).toHaveBeenCalledWith(
      expect.objectContaining({
        where: {
          storeId: 'store-1',
          performedAt: {
            gte: new Date('2026-01-01T00:00:00.000Z'),
          },
        },
      }),
    );
  });

  it('propagates transaction failures', async () => {
    db.$transaction.mockRejectedValue(new Error('transaction failed'));

    await expect(
      auditLogRepository.findManyByStoreId('store-1', {
        page: 1,
        limit: 10,
      }),
    ).rejects.toThrow('transaction failed');
  });

  it('createLog persists audit log data and converts null JSON values to DbNull', async () => {
    await auditLogRepository.createLog({
      actionType: 'delete',
      entityType: 'product',
      entityId: 'product-1',
      userId: 'user-1',
      storeId: 'store-1',
      oldValue: { name: 'Milk' },
      newValue: null,
      note: undefined,
    });

    expect(db.auditLog.create).toHaveBeenCalledWith({
      data: {
        actionType: 'delete',
        entityType: 'product',
        entityId: 'product-1',
        userId: 'user-1',
        storeId: 'store-1',
        oldValue: { name: 'Milk' },
        newValue: Prisma.DbNull,
        note: null,
      },
    });
  });

  it('createLog preserves provided JSON values and notes', async () => {
    await auditLogRepository.createLog({
      actionType: 'create',
      entityType: null,
      entityId: null,
      userId: 'user-1',
      storeId: 'store-1',
      oldValue: null,
      newValue: { name: 'Milk' },
      note: 'Created product',
    });

    expect(db.auditLog.create).toHaveBeenCalledWith({
      data: {
        actionType: 'create',
        entityType: null,
        entityId: null,
        userId: 'user-1',
        storeId: 'store-1',
        oldValue: Prisma.DbNull,
        newValue: { name: 'Milk' },
        note: 'Created product',
      },
    });
  });
});
