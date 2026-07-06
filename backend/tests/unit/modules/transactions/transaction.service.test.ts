import { StatusCodes } from 'http-status-codes';
import { beforeEach, describe, expect, it, vi } from 'vitest';

import { Prisma } from '../../../../src/generated/prisma/client.js';
import { TransactionService } from '../../../../src/modules/transactions/transaction.service.js';

const transactionMocks = vi.hoisted(() => {
  const transactionMock = vi.fn(
    async <T>(callback: (tx: unknown) => Promise<T>) => {
      return await callback({ tx: true });
    },
  );

  return {
    emit: vi.fn(),
    getSignedUrl: vi.fn(),
    transactionMock,
  };
});

vi.mock('../../../../src/db/prismaClient.js', () => ({
  prisma: {
    $transaction: transactionMocks.transactionMock,
  },
}));

vi.mock('../../../../src/common/events/event-bus.js', () => ({
  appEvents: {
    LARGE_ORDER_CREATED: 'large-order-created',
  },
  eventBus: {
    emit: transactionMocks.emit,
  },
}));

vi.mock('../../../../src/common/utils/index.js', async (importActual) => {
  const actual =
    await importActual<
      typeof import('../../../../src/common/utils/index.js')
    >();

  return {
    ...actual,
    StorageService: {
      getSignedUrl: transactionMocks.getSignedUrl,
    },
  };
});

type MockTransactionRepository = {
  findManyByStoreId: ReturnType<typeof vi.fn>;
  findOne: ReturnType<typeof vi.fn>;
  getFrequentlyBoughtTogether: ReturnType<typeof vi.fn>;
};

type MockProductPackageService = {
  getProductPackagesByIds: ReturnType<typeof vi.fn>;
};

type MockInventoryService = {
  adjustInventoriesForTransaction: ReturnType<typeof vi.fn>;
};

type MockTxRepository = {
  createOne: ReturnType<typeof vi.fn>;
};

type MockTransactionDetailRepository = {
  createMany: ReturnType<typeof vi.fn>;
};

const date = new Date('2026-01-02T00:00:00.000Z');

const createMockTransactionRepository = (): MockTransactionRepository => ({
  findManyByStoreId: vi.fn(),
  findOne: vi.fn(),
  getFrequentlyBoughtTogether: vi.fn(),
});

const createMockProductPackageService = (): MockProductPackageService => ({
  getProductPackagesByIds: vi.fn(),
});

const createMockInventoryService = (): MockInventoryService => ({
  adjustInventoriesForTransaction: vi.fn(),
});

const packageFixture = (overrides: Record<string, unknown> = {}) => ({
  productPackageId: '550e8400-e29b-41d4-a716-446655440000',
  displayName: 'Milk 1L',
  variant: '1L',
  importPrice: 10000,
  sellingPrice: 15000,
  unit: {
    unitId: 'unit-1',
    code: 'btl',
    name: 'Bottle',
  },
  product: {
    productId: 'product-1',
    name: 'Milk',
    imageUrl: 'products/milk.png',
    brand: 'Dairy Co',
    category: {
      categoryId: 'category-1',
      name: 'Dairy',
      description: null,
    },
  },
  ...overrides,
});

describe('TransactionService', () => {
  let transactionRepository: MockTransactionRepository;
  let productPackageService: MockProductPackageService;
  let inventoryService: MockInventoryService;
  let txRepository: MockTxRepository;
  let transactionDetailRepository: MockTransactionDetailRepository;
  let auditLogRepository: { createLog: ReturnType<typeof vi.fn> };
  let service: TransactionService;

  beforeEach(() => {
    vi.clearAllMocks();

    transactionMocks.getSignedUrl.mockImplementation(
      (_bucket: string, path: string | null) =>
        path ? `signed:${path}` : null,
    );

    transactionRepository = createMockTransactionRepository();
    productPackageService = createMockProductPackageService();
    inventoryService = createMockInventoryService();
    txRepository = {
      createOne: vi.fn(),
    };
    transactionDetailRepository = {
      createMany: vi.fn(),
    };
    auditLogRepository = {
      createLog: vi.fn(),
    };

    service = new TransactionService(
      transactionRepository as never,
      productPackageService as never,
      inventoryService as never,
    );
    service.createTxRepository = vi.fn(() => ({
      transactionRepositoryTx: txRepository as never,
      transactionDetailRepositoryTx: transactionDetailRepository as never,
      auditLogRepositoryTx: auditLogRepository as never,
    }));
  });

  describe('getTransactionsByStoreId', () => {
    it('normalizes pagination and returns paginated transactions', async () => {
      transactionRepository.findManyByStoreId.mockResolvedValue({
        items: [
          {
            transactionId: 'transaction-1',
            type: 'import',
            note: null,
            status: 'completed',
            createdAt: date,
            totalPrice: 12000,
            itemCount: 1,
          },
        ],
        totalItems: 1,
      });

      const result = await service.getTransactionsByStoreId('store-1', {
        page: 2.8,
        limit: 200,
        sortBy: 'createdAt',
        sortOrder: 'desc',
      });

      expect(transactionRepository.findManyByStoreId).toHaveBeenCalledWith(
        'store-1',
        {
          page: 2,
          limit: 100,
          sortBy: 'createdAt',
          sortOrder: 'desc',
        },
      );
      expect(result.meta).toEqual({
        page: 2,
        limit: 100,
        totalItems: 1,
        totalPages: 1,
      });
    });
  });

  describe('getTransactionById', () => {
    it('returns a store-scoped transaction with signed image URLs', async () => {
      transactionRepository.findOne.mockResolvedValue({
        transactionId: 'transaction-1',
        type: 'export',
        note: null,
        status: 'completed',
        createdAt: date,
        totalPrice: 5000,
        items: [
          {
            productPackageId: 'package-1',
            displayName: 'Milk 1L',
            imageUrl: 'products/milk.png',
            quantity: 1,
            unitPrice: 5000,
          },
        ],
      });

      const result = await service.getTransactionById(
        'store-1',
        'transaction-1',
      );

      expect(transactionRepository.findOne).toHaveBeenCalledWith(
        'store-1',
        'transaction-1',
      );
      expect(transactionMocks.getSignedUrl).toHaveBeenCalledWith(
        'images',
        'products/milk.png',
      );
      expect(result.items[0]?.imageUrl).toBe('signed:products/milk.png');
    });

    it('throws not found when the transaction does not belong to the store', async () => {
      transactionRepository.findOne.mockResolvedValue(null);

      await expect(
        service.getTransactionById('store-1', 'transaction-1'),
      ).rejects.toMatchObject({
        message: 'Transaction not found',
        status: StatusCodes.NOT_FOUND,
      });
    });
  });

  describe('createImportTransaction', () => {
    it('creates transaction details, inventory adjustments, audit log, event, and price suggestions in one transaction', async () => {
      productPackageService.getProductPackagesByIds.mockResolvedValue([
        packageFixture({ importPrice: 10000 }),
      ]);
      txRepository.createOne.mockResolvedValue({
        transactionId: 'transaction-1',
        type: 'import',
        note: 'Restock',
        status: 'completed',
        createdAt: date,
        totalPrice: 24000,
      });

      const data = {
        note: 'Restock',
        items: [
          {
            productPackageId: '550e8400-e29b-41d4-a716-446655440000',
            quantity: 2,
            unitPrice: 12000,
          },
        ],
      };

      const result = await service.createImportTransaction(
        'store-1',
        'user-1',
        data,
      );

      expect(
        productPackageService.getProductPackagesByIds,
      ).toHaveBeenCalledWith('store-1', [
        '550e8400-e29b-41d4-a716-446655440000',
      ]);
      expect(transactionMocks.transactionMock).toHaveBeenCalledTimes(1);
      expect(txRepository.createOne).toHaveBeenCalledWith({
        type: 'import',
        note: 'Restock',
        totalPrice: 24000,
        userId: 'user-1',
        storeId: 'store-1',
      });
      expect(transactionDetailRepository.createMany).toHaveBeenCalledWith({
        transactionId: 'transaction-1',
        items: [
          {
            productPackageId: '550e8400-e29b-41d4-a716-446655440000',
            quantity: 2,
            unitPrice: expect.any(Prisma.Decimal),
          },
        ],
      });
      expect(
        inventoryService.adjustInventoriesForTransaction,
      ).toHaveBeenCalledWith(
        'transaction-1',
        'import',
        'user-1',
        'store-1',
        [
          {
            productPackageId: '550e8400-e29b-41d4-a716-446655440000',
            quantity: 2,
            unitPrice: 12000,
            transactionId: 'transaction-1',
          },
        ],
        { tx: true },
      );
      expect(auditLogRepository.createLog).toHaveBeenCalledWith(
        expect.objectContaining({
          actionType: 'create',
          entityType: 'Transaction',
          entityId: 'transaction-1',
          userId: 'user-1',
          storeId: 'store-1',
        }),
      );
      expect(transactionMocks.emit).toHaveBeenCalledWith(
        'large-order-created',
        expect.objectContaining({
          transactionId: 'transaction-1',
          type: 'import',
          totalPrice: 24000,
          itemCount: 1,
        }),
      );
      expect(result.priceUpdateSuggestions).toEqual([
        {
          productPackageId: '550e8400-e29b-41d4-a716-446655440000',
          currentImportPrice: 10000,
          latestImportUnitPrice: 12000,
        },
      ]);
    });

    it('does not suggest a price update when import price matches unit price', async () => {
      productPackageService.getProductPackagesByIds.mockResolvedValue([
        packageFixture({ importPrice: 12000 }),
      ]);
      txRepository.createOne.mockResolvedValue({
        transactionId: 'transaction-1',
        type: 'import',
        note: null,
        status: 'completed',
        createdAt: date,
        totalPrice: 12000,
      });

      const result = await service.createImportTransaction(
        'store-1',
        'user-1',
        {
          items: [
            {
              productPackageId: '550e8400-e29b-41d4-a716-446655440000',
              quantity: 1,
              unitPrice: 12000,
            },
          ],
        },
      );

      expect(result.priceUpdateSuggestions).toEqual([]);
    });

    it('throws when items are empty', async () => {
      await expect(
        service.createImportTransaction('store-1', 'user-1', { items: [] }),
      ).rejects.toMatchObject({
        message: 'Items cannot be empty',
        code: 'PACKAGE_ITEM_IS_EMPTY',
        status: StatusCodes.BAD_REQUEST,
      });
      expect(
        productPackageService.getProductPackagesByIds,
      ).not.toHaveBeenCalled();
    });

    it('throws when package ids are duplicated', async () => {
      await expect(
        service.createImportTransaction('store-1', 'user-1', {
          items: [
            {
              productPackageId: 'package-1',
              quantity: 1,
              unitPrice: 1000,
            },
            {
              productPackageId: 'package-1',
              quantity: 2,
              unitPrice: 1000,
            },
          ],
        }),
      ).rejects.toMatchObject({
        message: 'Duplicate productPackageId in transaction items',
        code: 'DUPLICATE_PRODUCT_PACKAGE',
        status: StatusCodes.BAD_REQUEST,
      });
    });

    it('throws when a package is not found in the store package lookup', async () => {
      productPackageService.getProductPackagesByIds.mockResolvedValue([]);

      await expect(
        service.createImportTransaction('store-1', 'user-1', {
          items: [
            {
              productPackageId: 'missing-package',
              quantity: 1,
              unitPrice: 1000,
            },
          ],
        }),
      ).rejects.toMatchObject({
        message: 'Product package not found',
        status: StatusCodes.NOT_FOUND,
      });
      expect(transactionMocks.transactionMock).not.toHaveBeenCalled();
    });

    it('throws when item values are invalid before creating a database transaction', async () => {
      productPackageService.getProductPackagesByIds.mockResolvedValue([
        packageFixture({ productPackageId: 'package-1' }),
      ]);

      await expect(
        service.createImportTransaction('store-1', 'user-1', {
          items: [
            {
              productPackageId: 'package-1',
              quantity: 1,
              unitPrice: 0,
            },
          ],
        }),
      ).rejects.toMatchObject({
        message: 'Invalid unitPrice',
        status: StatusCodes.BAD_REQUEST,
      });
      expect(transactionMocks.transactionMock).not.toHaveBeenCalled();
    });

    it('throws when quantity is not a positive integer before creating a database transaction', async () => {
      productPackageService.getProductPackagesByIds.mockResolvedValue([
        packageFixture({ productPackageId: 'package-1' }),
      ]);

      await expect(
        service.createImportTransaction('store-1', 'user-1', {
          items: [
            {
              productPackageId: 'package-1',
              quantity: 1.5,
              unitPrice: 1000,
            },
          ],
        }),
      ).rejects.toMatchObject({
        message: 'Invalid quantity',
        status: StatusCodes.BAD_REQUEST,
      });
      expect(transactionMocks.transactionMock).not.toHaveBeenCalled();
    });
  });

  describe('createExportTransaction', () => {
    it('throws when export items are empty', async () => {
      await expect(
        service.createExportTransaction('store-1', 'user-1', { items: [] }),
      ).rejects.toMatchObject({
        message: 'Items cannot be empty',
        code: 'PACKAGE_ITEM_IS_EMPTY',
        status: StatusCodes.BAD_REQUEST,
      });
      expect(
        productPackageService.getProductPackagesByIds,
      ).not.toHaveBeenCalled();
    });

    it('creates an export transaction and delegates inventory stock validation to inventory service', async () => {
      productPackageService.getProductPackagesByIds.mockResolvedValue([
        packageFixture({ productPackageId: 'package-1' }),
      ]);
      txRepository.createOne.mockResolvedValue({
        transactionId: 'transaction-2',
        type: 'export',
        note: null,
        status: 'completed',
        createdAt: date,
        totalPrice: 15000,
      });

      const result = await service.createExportTransaction(
        'store-1',
        'user-1',
        {
          items: [
            {
              productPackageId: 'package-1',
              quantity: 3,
              unitPrice: 5000,
            },
          ],
        },
      );

      expect(txRepository.createOne).toHaveBeenCalledWith({
        type: 'export',
        note: null,
        totalPrice: 15000,
        userId: 'user-1',
        storeId: 'store-1',
      });
      expect(
        inventoryService.adjustInventoriesForTransaction,
      ).toHaveBeenCalledWith(
        'transaction-2',
        'export',
        'user-1',
        'store-1',
        [
          {
            productPackageId: 'package-1',
            quantity: 3,
            unitPrice: 5000,
            transactionId: 'transaction-2',
          },
        ],
        { tx: true },
      );
      expect(result).toMatchObject({
        transactionId: 'transaction-2',
        type: 'export',
        items: [
          {
            productPackageId: 'package-1',
            quantity: 3,
            unitPrice: 5000,
          },
        ],
      });
    });

    it('propagates inventory adjustment failures so the database transaction rolls back', async () => {
      productPackageService.getProductPackagesByIds.mockResolvedValue([
        packageFixture({ productPackageId: 'package-1' }),
      ]);
      txRepository.createOne.mockResolvedValue({
        transactionId: 'transaction-2',
        type: 'export',
        note: null,
        status: 'completed',
        createdAt: date,
        totalPrice: 15000,
      });
      inventoryService.adjustInventoriesForTransaction.mockRejectedValue(
        new Error('Insufficient stock'),
      );

      await expect(
        service.createExportTransaction('store-1', 'user-1', {
          items: [
            {
              productPackageId: 'package-1',
              quantity: 3,
              unitPrice: 5000,
            },
          ],
        }),
      ).rejects.toThrow('Insufficient stock');
      expect(auditLogRepository.createLog).not.toHaveBeenCalled();
      expect(transactionMocks.emit).not.toHaveBeenCalled();
    });
  });

  it('getCrossSellSuggestions delegates to repository with the default limit', async () => {
    transactionRepository.getFrequentlyBoughtTogether.mockResolvedValue([
      { associatedPackageId: 'package-2', frequency: 3 },
    ]);

    const result = await service.getCrossSellSuggestions(
      'store-1',
      'package-1',
    );

    expect(
      transactionRepository.getFrequentlyBoughtTogether,
    ).toHaveBeenCalledWith('store-1', 'package-1', 3);
    expect(result).toEqual([
      { associatedPackageId: 'package-2', frequency: 3 },
    ]);
  });
});
