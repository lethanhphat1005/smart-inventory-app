import { beforeEach, describe, expect, it, vi } from 'vitest';

import { TransactionDetailRepository } from '../../../../src/modules/transactions/repositories/transaction-detail.repository.js';
import { TransactionRepository } from '../../../../src/modules/transactions/repositories/transaction.repository.js';

const decimal = (value: number) => ({
  toNumber: vi.fn(() => value),
});

const createMockDb = () => ({
  $transaction: vi.fn(async (operations: Promise<unknown>[]) => {
    return await Promise.all(operations);
  }),
  $queryRaw: vi.fn(),
  transaction: {
    findMany: vi.fn(),
    count: vi.fn(),
    findFirst: vi.fn(),
    create: vi.fn(),
  },
  transactionDetail: {
    findMany: vi.fn(),
    createMany: vi.fn(),
  },
});

describe('TransactionRepository', () => {
  let db: ReturnType<typeof createMockDb>;
  let transactionRepository: TransactionRepository;

  beforeEach(() => {
    db = createMockDb();
    transactionRepository = new TransactionRepository(db as never);
  });

  it('findManyByStoreId scopes transactions by store and filters', async () => {
    db.transaction.findMany.mockResolvedValue([
      {
        transactionId: 'transaction-1',
        type: 'import',
        note: 'Restock',
        status: 'completed',
        createdAt: new Date('2026-01-02T00:00:00.000Z'),
        totalPrice: decimal(30000),
        _count: { transactionDetails: 2 },
      },
    ]);
    db.transaction.count.mockResolvedValue(1);

    const result = await transactionRepository.findManyByStoreId('store-1', {
      page: 2,
      limit: 10,
      sortBy: 'totalPrice',
      sortOrder: 'asc',
      type: 'import',
      userId: 'user-1',
      startDate: '2026-01-01',
      endDate: '2026-01-31',
    });

    expect(db.transaction.findMany).toHaveBeenCalledWith(
      expect.objectContaining({
        where: {
          storeId: 'store-1',
          type: 'import',
          userId: 'user-1',
          createdAt: {
            gte: expect.any(Date),
            lte: expect.any(Date),
          },
        },
        orderBy: { totalPrice: 'asc' },
        skip: 10,
        take: 10,
      }),
    );
    expect(result).toEqual({
      items: [
        expect.objectContaining({
          transactionId: 'transaction-1',
          totalPrice: 30000,
          itemCount: 2,
        }),
      ],
      totalItems: 1,
    });
  });

  it('findOne returns null when the transaction is missing in the store', async () => {
    db.transaction.findFirst.mockResolvedValue(null);

    const result = await transactionRepository.findOne(
      'store-1',
      'transaction-1',
    );

    expect(result).toBeNull();
    expect(db.transaction.findFirst).toHaveBeenCalledWith(
      expect.objectContaining({
        where: {
          transactionId: 'transaction-1',
          storeId: 'store-1',
        },
      }),
    );
  });

  it('findOne maps transaction details and decimal values', async () => {
    db.transaction.findFirst.mockResolvedValue({
      transactionId: 'transaction-1',
      type: 'export',
      note: null,
      status: 'completed',
      createdAt: new Date('2026-01-02T00:00:00.000Z'),
      totalPrice: decimal(5000),
      transactionDetails: [
        {
          quantity: 2,
          unitPrice: decimal(2500),
          productPackage: {
            productPackageId: 'package-1',
            displayName: 'Milk 1L',
            product: {
              imageUrl: 'products/milk.png',
            },
          },
        },
      ],
    });

    const result = await transactionRepository.findOne(
      'store-1',
      'transaction-1',
    );

    expect(result).toEqual({
      transactionId: 'transaction-1',
      type: 'export',
      note: null,
      status: 'completed',
      createdAt: new Date('2026-01-02T00:00:00.000Z'),
      totalPrice: 5000,
      items: [
        {
          productPackageId: 'package-1',
          displayName: 'Milk 1L',
          imageUrl: 'products/milk.png',
          quantity: 2,
          unitPrice: 2500,
        },
      ],
    });
  });

  it('createOne writes a completed transaction and converts totalPrice', async () => {
    db.transaction.create.mockResolvedValue({
      transactionId: 'transaction-1',
      type: 'import',
      note: null,
      status: 'completed',
      createdAt: new Date('2026-01-02T00:00:00.000Z'),
      totalPrice: decimal(12000),
    });

    const result = await transactionRepository.createOne({
      type: 'import',
      note: undefined,
      totalPrice: 12000,
      userId: 'user-1',
      storeId: 'store-1',
    });

    expect(db.transaction.create).toHaveBeenCalledWith(
      expect.objectContaining({
        data: {
          type: 'import',
          status: 'completed',
          note: null,
          totalPrice: 12000,
          userId: 'user-1',
          storeId: 'store-1',
        },
      }),
    );
    expect(result.totalPrice).toBe(12000);
  });

  it('getFrequentlyBoughtTogether maps bigint frequencies to numbers', async () => {
    db.$queryRaw.mockResolvedValue([
      {
        associatedPackageId: 'package-2',
        frequency: 3n,
        productName: 'Bread',
      },
    ]);

    const result = await transactionRepository.getFrequentlyBoughtTogether(
      'store-1',
      'package-1',
      5,
    );

    expect(db.$queryRaw).toHaveBeenCalledTimes(1);
    expect(result).toEqual([
      {
        associatedPackageId: 'package-2',
        frequency: 3,
        productName: 'Bread',
      },
    ]);
  });
});

describe('TransactionDetailRepository', () => {
  let db: ReturnType<typeof createMockDb>;
  let transactionDetailRepository: TransactionDetailRepository;

  beforeEach(() => {
    db = createMockDb();
    transactionDetailRepository = new TransactionDetailRepository(db as never);
  });

  it('findMany queries by transaction and package ids and maps prices', async () => {
    db.transactionDetail.findMany.mockResolvedValue([
      {
        transactionId: 'transaction-1',
        productPackageId: 'package-1',
        quantity: 2,
        unitPrice: decimal(2500),
      },
    ]);

    const result = await transactionDetailRepository.findMany({
      transactionId: 'transaction-1',
      items: [
        {
          productPackageId: 'package-1',
          quantity: 2,
          unitPrice: decimal(2500) as never,
        },
      ],
    });

    expect(db.transactionDetail.findMany).toHaveBeenCalledWith({
      where: {
        transactionId: 'transaction-1',
        productPackageId: {
          in: ['package-1'],
        },
      },
      select: {
        transactionId: true,
        productPackageId: true,
        quantity: true,
        unitPrice: true,
      },
    });
    expect(result).toEqual([
      {
        transactionId: 'transaction-1',
        productPackageId: 'package-1',
        quantity: 2,
        unitPrice: 2500,
      },
    ]);
  });

  it('createMany persists all transaction detail rows', async () => {
    const unitPrice = decimal(2500) as never;

    await transactionDetailRepository.createMany({
      transactionId: 'transaction-1',
      items: [
        {
          productPackageId: 'package-1',
          quantity: 2,
          unitPrice,
        },
      ],
    });

    expect(db.transactionDetail.createMany).toHaveBeenCalledWith({
      data: [
        {
          transactionId: 'transaction-1',
          productPackageId: 'package-1',
          quantity: 2,
          unitPrice,
        },
      ],
    });
  });
});
