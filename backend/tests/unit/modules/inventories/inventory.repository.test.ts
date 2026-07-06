import { describe, expect, it, vi } from 'vitest';

import { InventoryRepository } from '../../../../src/modules/inventories/repository/inventory.repository.js';

const decimal = (value: number) => ({
  toNumber: () => value,
});

const date = new Date('2026-01-01T00:00:00.000Z');

const rawInventory = (overrides: Record<string, unknown> = {}) => ({
  inventoryId: 'inventory-1',
  quantity: 4,
  reorderThreshold: 5,
  updatedAt: date,
  productPackage: {
    productPackageId: 'package-1',
    displayName: 'Milk 1L',
    variant: '1L',
    importPrice: decimal(12000),
    sellingPrice: decimal(15000),
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

const createMockDb = () => ({
  $transaction: vi.fn(),
  $queryRaw: vi.fn(),
  inventory: {
    findMany: vi.fn(),
    count: vi.fn(),
    findFirst: vi.fn(),
    findUnique: vi.fn(),
    update: vi.fn(),
    updateMany: vi.fn(),
    create: vi.fn(),
  },
  productPackage: {
    count: vi.fn(),
  },
});

describe('InventoryRepository', () => {
  it('findManyByStoreId scopes to active store inventory and maps inventory status', async () => {
    const db = createMockDb();

    db.$transaction.mockResolvedValue([
      [
        rawInventory({ quantity: 0, reorderThreshold: 5 }),
        rawInventory({
          inventoryId: 'inventory-2',
          quantity: 10,
          reorderThreshold: 5,
        }),
      ],
      2,
    ]);
    const repository = new InventoryRepository(db as never);

    const result = await repository.findManyByStoreId('store-1', {
      page: 2,
      limit: 10,
      sortBy: 'quantity',
      sortOrder: 'asc',
      keyword: ' milk ',
      categoryId: 'category-1',
    });

    expect(db.inventory.findMany).toHaveBeenCalledWith(
      expect.objectContaining({
        where: expect.objectContaining({
          activeStatus: 'active',
          productPackage: expect.objectContaining({
            activeStatus: 'active',
            product: expect.objectContaining({
              storeId: 'store-1',
              activeStatus: 'active',
              categoryId: 'category-1',
              OR: expect.any(Array),
            }),
          }),
        }),
        orderBy: { quantity: 'asc' },
        skip: 10,
        take: 10,
      }),
    );
    expect(db.inventory.count).toHaveBeenCalledWith({
      where: expect.objectContaining({
        activeStatus: 'active',
        productPackage: expect.objectContaining({
          product: expect.objectContaining({ storeId: 'store-1' }),
        }),
      }),
    });
    expect(result.items.map((item) => item.inventoryStatus)).toEqual([
      'outOfStock',
      'inStock',
    ]);
    expect(result.totalItems).toBe(2);
  });

  it('findManyByStoreId filters derived inventoryStatus after mapping', async () => {
    const db = createMockDb();

    db.$transaction.mockResolvedValue([
      [
        rawInventory({ quantity: 0, reorderThreshold: 5 }),
        rawInventory({
          inventoryId: 'inventory-2',
          quantity: 4,
          reorderThreshold: 5,
        }),
        rawInventory({
          inventoryId: 'inventory-3',
          quantity: 9,
          reorderThreshold: 5,
        }),
      ],
      3,
    ]);
    const repository = new InventoryRepository(db as never);

    const result = await repository.findManyByStoreId('store-1', {
      page: 1,
      limit: 10,
      sortBy: 'updatedAt',
      sortOrder: 'desc',
      inventoryStatus: 'lowStock',
    });

    expect(result.items).toHaveLength(1);
    expect(result.items[0]?.inventoryStatus).toBe('lowStock');
    expect(result.totalItems).toBe(1);
  });

  it('findLowStockByStoreId returns early when count is zero', async () => {
    const db = createMockDb();

    db.$queryRaw.mockResolvedValueOnce([{ count: 0n }]);
    const repository = new InventoryRepository(db as never);

    const result = await repository.findLowStockByStoreId('store-1', {
      page: 1,
      limit: 10,
      sortBy: 'updatedAt',
      sortOrder: 'desc',
    });

    expect(result).toEqual({ items: [], totalItems: 0 });
    expect(db.inventory.findMany).not.toHaveBeenCalled();
  });

  it('findLowStockByStoreId fetches low stock ids then maps selected inventories', async () => {
    const db = createMockDb();

    db.$queryRaw
      .mockResolvedValueOnce([{ count: 1n }])
      .mockResolvedValueOnce([{ inventory_id: 'inventory-1' }]);
    db.inventory.findMany.mockResolvedValue([rawInventory()]);
    const repository = new InventoryRepository(db as never);

    const result = await repository.findLowStockByStoreId('store-1', {
      page: 1,
      limit: 10,
      sortBy: 'updatedAt',
      sortOrder: 'desc',
      keyword: 'milk',
      categoryId: 'category-1',
    });

    expect(db.inventory.findMany).toHaveBeenCalledWith(
      expect.objectContaining({
        where: { inventoryId: { in: ['inventory-1'] } },
        orderBy: { updatedAt: 'desc' },
      }),
    );
    expect(result.items[0]?.inventoryStatus).toBe('lowStock');
    expect(result.totalItems).toBe(1);
  });

  it('findManyActiveByProductPackageIds returns empty input immediately or active store-scoped records', async () => {
    const db = createMockDb();

    db.inventory.findMany.mockResolvedValue([
      {
        inventoryId: 'inventory-1',
        productPackageId: 'package-1',
        quantity: 3,
        productPackage: { displayName: 'Milk 1L' },
      },
    ]);
    const repository = new InventoryRepository(db as never);

    await expect(
      repository.findManyActiveByProductPackageIds('store-1', []),
    ).resolves.toEqual([]);
    await expect(
      repository.findManyActiveByProductPackageIds('store-1', ['package-1']),
    ).resolves.toEqual([
      {
        inventoryId: 'inventory-1',
        productPackageId: 'package-1',
        quantity: 3,
        productPackage: { displayName: 'Milk 1L' },
      },
    ]);

    expect(db.inventory.findMany).toHaveBeenCalledTimes(1);
    expect(db.inventory.findMany).toHaveBeenCalledWith({
      where: {
        productPackageId: { in: ['package-1'] },
        activeStatus: 'active',
        productPackage: {
          activeStatus: 'active',
          product: {
            storeId: 'store-1',
            activeStatus: 'active',
          },
        },
      },
      select: {
        inventoryId: true,
        productPackageId: true,
        quantity: true,
        productPackage: {
          select: {
            displayName: true,
          },
        },
      },
    });
  });

  it('findOneByProductPackageId returns null or active store-scoped inventory details', async () => {
    const db = createMockDb();

    db.inventory.findFirst.mockResolvedValueOnce(null).mockResolvedValueOnce(
      rawInventory({
        reorderThreshold: null,
        productPackage: {
          ...rawInventory().productPackage,
          importPrice: null,
          sellingPrice: null,
        },
      }),
    );
    const repository = new InventoryRepository(db as never);

    await expect(
      repository.findOneByProductPackageId('store-1', 'package-1'),
    ).resolves.toBeNull();
    const result = await repository.findOneByProductPackageId(
      'store-1',
      'package-1',
    );

    expect(db.inventory.findFirst).toHaveBeenCalledWith(
      expect.objectContaining({
        where: {
          productPackageId: 'package-1',
          activeStatus: 'active',
          productPackage: {
            activeStatus: 'active',
            product: { storeId: 'store-1', activeStatus: 'active' },
          },
        },
      }),
    );
    expect(result?.inventoryStatus).toBe('inStock');
    expect(result?.productPackage.importPrice).toBeNull();
  });

  it('adjusts quantity using set, increment, and decrement update shapes', async () => {
    const db = createMockDb();

    db.inventory.update.mockResolvedValue(rawInventory());
    const repository = new InventoryRepository(db as never);

    await repository.adjustQuantity('inventory-1', 'set', 7);
    await repository.adjustQuantity('inventory-1', 'increase', 2);
    await repository.adjustQuantity('inventory-1', 'decrease', 1);

    expect(db.inventory.update).toHaveBeenNthCalledWith(
      1,
      expect.objectContaining({ data: { quantity: 7 } }),
    );
    expect(db.inventory.update).toHaveBeenNthCalledWith(
      2,
      expect.objectContaining({ data: { quantity: { increment: 2 } } }),
    );
    expect(db.inventory.update).toHaveBeenNthCalledWith(
      3,
      expect.objectContaining({ data: { quantity: { decrement: 1 } } }),
    );
  });

  it('updates reorder threshold and soft deletes by product package id', async () => {
    const db = createMockDb();

    db.inventory.update
      .mockResolvedValueOnce(rawInventory({ reorderThreshold: 9 }))
      .mockResolvedValueOnce({ inventoryId: 'inventory-1' });
    const repository = new InventoryRepository(db as never);

    await expect(
      repository.updateOne('inventory-1', { reorderThreshold: 9 }),
    ).resolves.toMatchObject({ reorderThreshold: 9 });
    await expect(
      repository.softDeleteOneByPackageId('package-1'),
    ).resolves.toEqual({ inventoryId: 'inventory-1' });

    expect(db.inventory.update).toHaveBeenNthCalledWith(
      1,
      expect.objectContaining({
        where: { inventoryId: 'inventory-1' },
        data: { reorderThreshold: 9 },
      }),
    );
    expect(db.inventory.update).toHaveBeenNthCalledWith(2, {
      where: { productPackageId: 'package-1' },
      data: { activeStatus: 'inactive' },
      select: { inventoryId: true },
    });
  });

  it('checks ownership, creates, restores, and soft deletes inventory records', async () => {
    const db = createMockDb();

    db.productPackage.count.mockResolvedValue(1);
    db.inventory.findUnique.mockResolvedValue({
      inventoryId: 'inventory-1',
      activeStatus: 'inactive',
      quantity: 2,
    });
    db.inventory.create.mockResolvedValue(rawInventory({ quantity: 2 }));
    db.inventory.update.mockResolvedValue(rawInventory({ quantity: 3 }));
    const repository = new InventoryRepository(db as never);

    await expect(
      repository.checkProductPackageBelongsToStore('store-1', 'package-1'),
    ).resolves.toBe(true);
    await expect(
      repository.getInventoryStatusByProductPackageId('package-1'),
    ).resolves.toMatchObject({ activeStatus: 'inactive' });
    await repository.createOne({ productPackageId: 'package-1', quantity: 2 });
    await repository.restoreInventory('inventory-1', {
      productPackageId: 'package-1',
      quantity: 3,
      reorderThreshold: undefined,
    });
    await repository.delete('inventory-1');

    expect(db.productPackage.count).toHaveBeenCalledWith({
      where: { productPackageId: 'package-1', product: { storeId: 'store-1' } },
    });
    expect(db.inventory.create).toHaveBeenCalledWith(
      expect.objectContaining({
        data: {
          productPackageId: 'package-1',
          quantity: 2,
          reorderThreshold: null,
        },
      }),
    );
    expect(db.inventory.update).toHaveBeenLastCalledWith({
      where: { inventoryId: 'inventory-1' },
      data: { activeStatus: 'inactive' },
    });
  });

  it('decreaseManyForTransaction records packages that fail the database quantity guard', async () => {
    const db = createMockDb();

    db.inventory.updateMany
      .mockResolvedValueOnce({ count: 1 })
      .mockResolvedValueOnce({ count: 0 });
    const repository = new InventoryRepository(db as never);

    const failed = await repository.decreaseManyForTransaction([
      {
        inventoryId: 'inventory-1',
        productPackageId: 'package-1',
        quantity: 10,
        transactionQuantity: 2,
        unitPrice: 15000,
        transactionId: 'transaction-1',
      },
      {
        inventoryId: 'inventory-2',
        productPackageId: 'package-2',
        quantity: 1,
        transactionQuantity: 2,
        unitPrice: 15000,
        transactionId: 'transaction-1',
      },
    ]);

    expect(db.inventory.updateMany).toHaveBeenCalledWith(
      expect.objectContaining({
        where: {
          inventoryId: 'inventory-1',
          quantity: { gte: 2 },
        },
        data: { quantity: { decrement: 2 } },
      }),
    );
    expect(failed).toEqual(new Set(['package-2']));
  });

  it('increaseManyForTransaction increments each inventory atomically', async () => {
    const db = createMockDb();

    db.inventory.update.mockResolvedValue(rawInventory());
    const repository = new InventoryRepository(db as never);

    await repository.increaseManyForTransaction([
      {
        inventoryId: 'inventory-1',
        productPackageId: 'package-1',
        quantity: 5,
        transactionQuantity: 2,
        unitPrice: 15000,
        transactionId: 'transaction-1',
      },
    ]);

    expect(db.inventory.update).toHaveBeenCalledWith({
      where: { inventoryId: 'inventory-1' },
      data: { quantity: { increment: 2 } },
    });
  });
});
