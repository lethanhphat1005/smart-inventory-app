import { StatusCodes } from 'http-status-codes';
import { beforeEach, describe, expect, it, vi } from 'vitest';

import { TransactionType } from '../../../../src/generated/prisma/enums.js';
import { InventoryService } from '../../../../src/modules/inventories/service/inventory.service.js';

import type { InventoryDetailResponseDto } from '../../../../src/modules/inventories/dto/inventory.dto.js';

const inventoryMocks = vi.hoisted(() => {
  const transactionMock = vi.fn(
    async <T>(callback: (tx: unknown) => Promise<T>) => {
      return await callback({ tx: true });
    },
  );

  return {
    getSignedUrl: vi.fn(),
    transactionMock,
  };
});

vi.mock('../../../../src/db/prismaClient.js', () => ({
  prisma: {
    $transaction: inventoryMocks.transactionMock,
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
      getSignedUrl: inventoryMocks.getSignedUrl,
    },
  };
});

type MockInventoryRepository = {
  findManyByStoreId: ReturnType<typeof vi.fn>;
  findLowStockByStoreId: ReturnType<typeof vi.fn>;
  findOneByProductPackageId: ReturnType<typeof vi.fn>;
  findManyActiveByProductPackageIds: ReturnType<typeof vi.fn>;
  checkProductPackageBelongsToStore: ReturnType<typeof vi.fn>;
  getInventoryStatusByProductPackageId: ReturnType<typeof vi.fn>;
  createOne: ReturnType<typeof vi.fn>;
};

type MockTxRepository = {
  updateOne: ReturnType<typeof vi.fn>;
  adjustQuantity: ReturnType<typeof vi.fn>;
  restoreInventory: ReturnType<typeof vi.fn>;
  createOne: ReturnType<typeof vi.fn>;
  increaseManyForTransaction: ReturnType<typeof vi.fn>;
  decreaseManyForTransaction: ReturnType<typeof vi.fn>;
  delete: ReturnType<typeof vi.fn>;
};

const date = new Date('2026-01-01T00:00:00.000Z');

const inventoryFixture = (
  overrides: Partial<InventoryDetailResponseDto> = {},
): InventoryDetailResponseDto => ({
  inventoryId: 'inventory-1',
  quantity: 10,
  reorderThreshold: 5,
  updatedAt: date,
  inventoryStatus: 'inStock',
  productPackage: {
    productPackageId: 'package-1',
    displayName: 'Milk 1L',
    variant: '1L',
    importPrice: 12000,
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
  },
  ...overrides,
});

const createMockRepository = (): MockInventoryRepository => ({
  findManyByStoreId: vi.fn(),
  findLowStockByStoreId: vi.fn(),
  findOneByProductPackageId: vi.fn(),
  findManyActiveByProductPackageIds: vi.fn(),
  checkProductPackageBelongsToStore: vi.fn(),
  getInventoryStatusByProductPackageId: vi.fn(),
  createOne: vi.fn(),
});

const createMockTxRepository = (): MockTxRepository => ({
  updateOne: vi.fn(),
  adjustQuantity: vi.fn(),
  restoreInventory: vi.fn(),
  createOne: vi.fn(),
  increaseManyForTransaction: vi.fn(),
  decreaseManyForTransaction: vi.fn(),
  delete: vi.fn(),
});

const createMockAuditRepository = () => ({
  createLog: vi.fn(),
});

const createEventPublisher = () => ({
  emitInventoryDiscrepancy: vi.fn(),
  emitBatchInventoryChanged: vi.fn(),
});

describe('InventoryService', () => {
  let repository: MockInventoryRepository;
  let txRepository: MockTxRepository;
  let auditRepository: ReturnType<typeof createMockAuditRepository>;
  let eventPublisher: ReturnType<typeof createEventPublisher>;
  let service: InventoryService;

  beforeEach(() => {
    vi.clearAllMocks();

    inventoryMocks.getSignedUrl.mockImplementation(
      (_bucket: string, path: string | null) =>
        path ? `signed:${path}` : null,
    );

    repository = createMockRepository();
    txRepository = createMockTxRepository();
    auditRepository = createMockAuditRepository();
    eventPublisher = createEventPublisher();
    service = new InventoryService(repository as never, eventPublisher);
    service.createTxRepositories = vi.fn(() => ({
      inventoryRepositoryTx: txRepository as never,
      auditLogRepositoryTx: auditRepository as never,
    }));
  });

  describe('getInventoriesByStoreId', () => {
    it('normalizes pagination, signs product images, and returns paginated inventories', async () => {
      repository.findManyByStoreId.mockResolvedValue({
        items: [inventoryFixture()],
        totalItems: 1,
      });

      const result = await service.getInventoriesByStoreId('store-1', {
        page: 1,
        limit: 10,
        sortBy: 'updatedAt',
        sortOrder: 'desc',
      });

      expect(repository.findManyByStoreId).toHaveBeenCalledWith('store-1', {
        page: 1,
        limit: 10,
        sortBy: 'updatedAt',
        sortOrder: 'desc',
      });
      expect(inventoryMocks.getSignedUrl).toHaveBeenCalledWith(
        'images',
        'products/milk.png',
      );
      expect(result.items[0]?.productPackage.product.imageUrl).toBe(
        'signed:products/milk.png',
      );
      expect(result.meta.totalItems).toBe(1);
    });

    it('uses low-stock repository for low-stock listing', async () => {
      repository.findLowStockByStoreId.mockResolvedValue({
        items: [inventoryFixture({ inventoryStatus: 'lowStock' })],
        totalItems: 1,
      });

      const result = await service.getLowStockInventoriesByStoreId('store-1', {
        page: 1,
        limit: 10,
        sortBy: 'updatedAt',
        sortOrder: 'desc',
      });

      expect(repository.findLowStockByStoreId).toHaveBeenCalledWith(
        'store-1',
        expect.objectContaining({ page: 1, limit: 10 }),
      );
      expect(result.items[0]?.inventoryStatus).toBe('lowStock');
    });
  });

  describe('getInventoryByProductPackageId', () => {
    it('returns an existing inventory scoped by store and package', async () => {
      repository.findOneByProductPackageId.mockResolvedValue(
        inventoryFixture(),
      );

      await expect(
        service.getInventoryByProductPackageId('store-1', 'package-1'),
      ).resolves.toMatchObject({ inventoryId: 'inventory-1' });
    });

    it('throws not found when inventory is missing', async () => {
      repository.findOneByProductPackageId.mockResolvedValue(null);

      await expect(
        service.getInventoryByProductPackageId('store-1', 'package-1'),
      ).rejects.toMatchObject({
        message: 'Inventory not found',
        status: StatusCodes.NOT_FOUND,
      });
    });
  });

  describe('updateInventory', () => {
    it('updates reorder threshold and writes an audit log inside a transaction', async () => {
      repository.findOneByProductPackageId.mockResolvedValue(
        inventoryFixture({ reorderThreshold: 5 }),
      );
      txRepository.updateOne.mockResolvedValue(
        inventoryFixture({ reorderThreshold: 8 }),
      );

      const result = await service.updateInventory(
        'store-1',
        'package-1',
        { reorderThreshold: 8 },
        'user-1',
      );

      expect(inventoryMocks.transactionMock).toHaveBeenCalledTimes(1);
      expect(txRepository.updateOne).toHaveBeenCalledWith('inventory-1', {
        reorderThreshold: 8,
      });
      expect(auditRepository.createLog).toHaveBeenCalledWith(
        expect.objectContaining({
          actionType: 'update',
          entityType: 'Inventory',
          entityId: 'inventory-1',
          userId: 'user-1',
          storeId: 'store-1',
          oldValue: { reorderThreshold: 5 },
          newValue: expect.objectContaining({
            reorderThreshold: 8,
            productPackageId: 'package-1',
          }),
        }),
      );
      expect(result.reorderThreshold).toBe(8);
    });
  });

  describe('adjustInventories', () => {
    it('adjusts a valid batch, logs each item, emits discrepancy and batch change events, and strips inventoryId from response', async () => {
      repository.findManyActiveByProductPackageIds.mockResolvedValue([
        {
          inventoryId: 'inventory-1',
          productPackageId: 'package-1',
          quantity: 10,
          productPackage: { displayName: 'Milk 1L' },
        },
      ]);
      txRepository.adjustQuantity.mockResolvedValue(
        inventoryFixture({ quantity: 3 }),
      );

      const result = await service.adjustInventories('store-1', 'user-1', {
        items: [
          {
            productPackageId: 'package-1',
            type: 'set',
            quantity: 3,
            reason: 'cycle_count',
            note: 'counted shelf',
          },
        ],
      });

      expect(repository.findManyActiveByProductPackageIds).toHaveBeenCalledWith(
        'store-1',
        ['package-1'],
      );
      expect(txRepository.adjustQuantity).toHaveBeenCalledWith(
        'inventory-1',
        'set',
        3,
      );
      expect(auditRepository.createLog).toHaveBeenCalledWith(
        expect.objectContaining({
          note: expect.stringMatching(/^\[Lô-[A-F0-9]{6}\] counted shelf$/),
          oldValue: { quantity: 10 },
          newValue: expect.objectContaining({
            quantity: 3,
            changedQuantity: -7,
            adjustmentType: 'set',
            reason: 'cycle_count',
          }),
        }),
      );
      expect(eventPublisher.emitInventoryDiscrepancy).toHaveBeenCalledWith(
        expect.objectContaining({
          storeId: 'store-1',
          adjustmentId: expect.stringMatching(/^[A-F0-9]{6}$/),
          items: [
            {
              productName: 'Milk 1L',
              systemQuantity: 10,
              actualQuantity: 3,
            },
          ],
        }),
      );
      expect(eventPublisher.emitBatchInventoryChanged).toHaveBeenCalledWith({
        storeId: 'store-1',
        items: [
          {
            inventoryId: 'inventory-1',
            oldQuantity: 10,
            newQuantity: 3,
          },
        ],
      });
      expect(result).toEqual([
        expect.not.objectContaining({ inventoryId: expect.anything() }),
      ]);
    });

    it('rejects missing or inactive inventory before opening a transaction', async () => {
      repository.findManyActiveByProductPackageIds.mockResolvedValue([]);

      await expect(
        service.adjustInventories('store-1', 'user-1', {
          items: [
            { productPackageId: 'package-1', type: 'increase', quantity: 1 },
          ],
        }),
      ).rejects.toMatchObject({ status: StatusCodes.BAD_REQUEST });
      expect(inventoryMocks.transactionMock).not.toHaveBeenCalled();
    });

    it('prevents decrease adjustments that exceed current stock', async () => {
      repository.findManyActiveByProductPackageIds.mockResolvedValue([
        {
          inventoryId: 'inventory-1',
          productPackageId: 'package-1',
          quantity: 1,
          productPackage: { displayName: null },
        },
      ]);

      await expect(
        service.adjustInventories('store-1', 'user-1', {
          items: [
            { productPackageId: 'package-1', type: 'decrease', quantity: 2 },
          ],
        }),
      ).rejects.toMatchObject({
        status: StatusCodes.BAD_REQUEST,
        message: expect.stringContaining('Số lượng giảm'),
      });
      expect(inventoryMocks.transactionMock).not.toHaveBeenCalled();
    });
  });

  describe('createInventory', () => {
    it('rejects product packages outside the store', async () => {
      repository.checkProductPackageBelongsToStore.mockResolvedValue(false);

      await expect(
        service.createInventory(
          'store-1',
          { productPackageId: 'package-1', quantity: 0 },
          'user-1',
        ),
      ).rejects.toMatchObject({
        status: StatusCodes.NOT_FOUND,
        message: 'Product Package not found or does not belong to this store',
      });
      expect(inventoryMocks.transactionMock).not.toHaveBeenCalled();
    });

    it('rejects duplicate active inventory inside the transaction', async () => {
      repository.checkProductPackageBelongsToStore.mockResolvedValue(true);
      repository.getInventoryStatusByProductPackageId.mockResolvedValue({
        inventoryId: 'inventory-1',
        activeStatus: 'active',
        quantity: 5,
      });

      await expect(
        service.createInventory(
          'store-1',
          { productPackageId: 'package-1', quantity: 0 },
          'user-1',
        ),
      ).rejects.toMatchObject({ status: StatusCodes.CONFLICT });
    });

    it('restores inactive inventory and writes a create audit log', async () => {
      repository.checkProductPackageBelongsToStore.mockResolvedValue(true);
      repository.getInventoryStatusByProductPackageId.mockResolvedValue({
        inventoryId: 'inventory-1',
        activeStatus: 'inactive',
        quantity: 0,
      });
      txRepository.restoreInventory.mockResolvedValue(
        inventoryFixture({ quantity: 6, reorderThreshold: 2 }),
      );

      const result = await service.createInventory(
        'store-1',
        { productPackageId: 'package-1', quantity: 6, reorderThreshold: 2 },
        'user-1',
      );

      expect(txRepository.restoreInventory).toHaveBeenCalledWith(
        'inventory-1',
        { productPackageId: 'package-1', quantity: 6, reorderThreshold: 2 },
      );
      expect(auditRepository.createLog).toHaveBeenCalledWith(
        expect.objectContaining({
          actionType: 'create',
          oldValue: { activeStatus: 'inactive' },
          newValue: expect.objectContaining({ activeStatus: 'active' }),
        }),
      );
      expect(result.quantity).toBe(6);
    });

    it('creates new inventory and writes an audit log', async () => {
      repository.checkProductPackageBelongsToStore.mockResolvedValue(true);
      repository.getInventoryStatusByProductPackageId.mockResolvedValue(null);
      repository.createOne.mockResolvedValue(
        inventoryFixture({ inventoryId: 'inventory-created', quantity: 4 }),
      );

      const result = await service.createInventory(
        'store-1',
        { productPackageId: 'package-1', quantity: 4, reorderThreshold: null },
        'user-1',
      );

      expect(repository.createOne).toHaveBeenCalledWith({
        productPackageId: 'package-1',
        quantity: 4,
        reorderThreshold: null,
      });
      expect(auditRepository.createLog).toHaveBeenCalledWith(
        expect.objectContaining({
          actionType: 'create',
          entityId: 'inventory-created',
          oldValue: null,
        }),
      );
      expect(result.inventoryId).toBe('inventory-created');
    });
  });

  describe('adjustInventoriesForTransaction', () => {
    it('imports transaction quantities, writes audit logs, and emits batch inventory change', async () => {
      const db = {
        inventory: {
          findMany: vi.fn().mockResolvedValue([
            {
              inventoryId: 'inventory-1',
              productPackageId: 'package-1',
              quantity: 5,
              productPackage: { displayName: 'Milk 1L' },
            },
          ]),
        },
      };

      await service.adjustInventoriesForTransaction(
        'transaction-1',
        TransactionType.import,
        'user-1',
        'store-1',
        [
          {
            productPackageId: 'package-1',
            quantity: 3,
            unitPrice: 15000,
            transactionId: 'transaction-1',
          },
        ],
        db as never,
      );

      expect(txRepository.increaseManyForTransaction).toHaveBeenCalledWith([
        expect.objectContaining({
          inventoryId: 'inventory-1',
          quantity: 5,
          transactionQuantity: 3,
        }),
      ]);
      expect(auditRepository.createLog).toHaveBeenCalledWith(
        expect.objectContaining({
          newValue: expect.objectContaining({
            quantity: 8,
            changedQuantity: 3,
            adjustmentType: 'import',
            transactionId: 'transaction-1',
          }),
        }),
      );
      expect(eventPublisher.emitBatchInventoryChanged).toHaveBeenCalledWith({
        storeId: 'store-1',
        items: [{ inventoryId: 'inventory-1', oldQuantity: 5, newQuantity: 8 }],
      });
    });

    it('rejects export transactions when requested quantity exceeds available stock', async () => {
      const db = {
        inventory: {
          findMany: vi.fn().mockResolvedValue([
            {
              inventoryId: 'inventory-1',
              productPackageId: 'package-1',
              quantity: 1,
              productPackage: { displayName: 'Milk 1L' },
            },
          ]),
        },
      };

      await expect(
        service.adjustInventoriesForTransaction(
          'transaction-1',
          TransactionType.export,
          'user-1',
          'store-1',
          [
            {
              productPackageId: 'package-1',
              quantity: 2,
              unitPrice: 15000,
              transactionId: 'transaction-1',
            },
          ],
          db as never,
        ),
      ).rejects.toMatchObject({
        status: StatusCodes.BAD_REQUEST,
        code: 'INSUFFICIENT_INVENTORY',
      });
      expect(inventoryMocks.transactionMock).not.toHaveBeenCalled();
    });

    it('surfaces database-level export quantity conflicts with failed package ids', async () => {
      const db = {
        inventory: {
          findMany: vi.fn().mockResolvedValue([
            {
              inventoryId: 'inventory-1',
              productPackageId: 'package-1',
              quantity: 5,
              productPackage: { displayName: 'Milk 1L' },
            },
          ]),
        },
      };

      txRepository.decreaseManyForTransaction.mockResolvedValue(
        new Set(['package-1']),
      );

      await expect(
        service.adjustInventoriesForTransaction(
          'transaction-1',
          TransactionType.export,
          'user-1',
          'store-1',
          [
            {
              productPackageId: 'package-1',
              quantity: 2,
              unitPrice: 15000,
              transactionId: 'transaction-1',
            },
          ],
          db as never,
        ),
      ).rejects.toMatchObject({
        status: StatusCodes.BAD_REQUEST,
        code: 'INSUFFICIENT_INVENTORY',
        details: { productPackageIds: new Set(['package-1']) },
      });
      expect(eventPublisher.emitBatchInventoryChanged).not.toHaveBeenCalled();
    });

    it('exports transaction quantities, writes audit logs, and emits decreased inventory changes', async () => {
      const db = {
        inventory: {
          findMany: vi.fn().mockResolvedValue([
            {
              inventoryId: 'inventory-1',
              productPackageId: 'package-1',
              quantity: 5,
              productPackage: { displayName: 'Milk 1L' },
            },
          ]),
        },
      };

      txRepository.decreaseManyForTransaction.mockResolvedValue(new Set());

      await service.adjustInventoriesForTransaction(
        'transaction-1',
        TransactionType.export,
        'user-1',
        'store-1',
        [
          {
            productPackageId: 'package-1',
            quantity: 2,
            unitPrice: 15000,
            transactionId: 'transaction-1',
          },
        ],
        db as never,
      );

      expect(txRepository.decreaseManyForTransaction).toHaveBeenCalledWith([
        expect.objectContaining({
          inventoryId: 'inventory-1',
          quantity: 5,
          transactionQuantity: 2,
        }),
      ]);
      expect(auditRepository.createLog).toHaveBeenCalledWith(
        expect.objectContaining({
          note: 'export transaction',
          newValue: expect.objectContaining({
            quantity: 3,
            changedQuantity: 2,
            adjustmentType: 'export',
            reason: null,
          }),
        }),
      );
      expect(eventPublisher.emitBatchInventoryChanged).toHaveBeenCalledWith({
        storeId: 'store-1',
        items: [{ inventoryId: 'inventory-1', oldQuantity: 5, newQuantity: 3 }],
      });
    });
  });

  describe('deleteInventory', () => {
    it('soft deletes existing inventory and records a delete audit log', async () => {
      repository.findOneByProductPackageId.mockResolvedValue(
        inventoryFixture(),
      );

      await service.deleteInventory('store-1', 'package-1', 'user-1');

      expect(txRepository.delete).toHaveBeenCalledWith('inventory-1');
      expect(auditRepository.createLog).toHaveBeenCalledWith(
        expect.objectContaining({
          actionType: 'delete',
          entityType: 'Inventory',
          entityId: 'inventory-1',
          oldValue: { activeStatus: 'active' },
          newValue: {
            activeStatus: 'inactive',
            productPackageId: 'package-1',
          },
        }),
      );
    });
  });
});
