import { beforeEach, describe, expect, it, vi } from 'vitest';

import { ProductPackageRepository } from '../../../../src/modules/product-packages/repositories/product-package.repository.js';

const createMockDb = () => ({
  $transaction: vi.fn(async (operations: Promise<unknown>[]) => {
    return await Promise.all(operations);
  }),
  productPackage: {
    findMany: vi.fn(),
    count: vi.fn(),
    findFirst: vi.fn(),
    create: vi.fn(),
    update: vi.fn(),
    updateMany: vi.fn(),
  },
});

const decimal = (value: number) => ({
  toNumber: vi.fn(() => value),
});

const record = (overrides: Record<string, unknown> = {}) => ({
  productPackageId: 'package-1',
  displayName: 'Milk bottle',
  variant: 'bottle',
  importPrice: decimal(1000),
  sellingPrice: decimal(1500),
  unitId: 'unit-1',
  productId: 'product-1',
  createdAt: new Date('2026-01-01T00:00:00.000Z'),
  unit: {
    unitId: 'unit-1',
    code: 'BTL',
    name: 'bottle',
  },
  product: {
    productId: 'product-1',
    imageUrl: 'products/milk.png',
    name: 'Milk',
    brand: 'Dairy Co',
    category: {
      categoryId: 'category-1',
      name: 'Dairy',
    },
  },
  inventory: {
    inventoryId: 'inventory-1',
    quantity: 5,
    reorderThreshold: 2,
  },
  productPackageBarcodes: [],
  ...overrides,
});

describe('ProductPackageRepository', () => {
  let db: ReturnType<typeof createMockDb>;
  let repository: ProductPackageRepository;

  beforeEach(() => {
    db = createMockDb();
    repository = new ProductPackageRepository(db as never);
  });

  it('findManyByStore scopes active packages by store and category', async () => {
    db.productPackage.findMany.mockResolvedValue([record()]);
    db.productPackage.count.mockResolvedValue(1);

    const result = await repository.findManyByStore('store-1', {
      page: 2,
      limit: 10,
      sortBy: 'createdAt',
      sortOrder: 'desc',
      categoryId: 'category-1',
    });

    expect(db.productPackage.findMany).toHaveBeenCalledWith(
      expect.objectContaining({
        where: {
          activeStatus: 'active',
          product: {
            storeId: 'store-1',
            activeStatus: 'active',
            categoryId: 'category-1',
          },
        },
        orderBy: {
          createdAt: 'desc',
        },
        skip: 10,
        take: 10,
      }),
    );
    expect(result).toMatchObject({
      items: [
        {
          productPackageId: 'package-1',
          importPrice: 1000,
          sellingPrice: 1500,
        },
      ],
      totalItems: 1,
    });
  });

  it('findManyByProductId and findDetailOne convert decimal prices', async () => {
    db.productPackage.findMany.mockResolvedValue([record()]);
    db.productPackage.findFirst.mockResolvedValue(record());

    const many = await repository.findManyByProductId('store-1', 'product-1');
    const one = await repository.findDetailOne('store-1', 'package-1');

    expect(db.productPackage.findMany).toHaveBeenCalledWith(
      expect.objectContaining({
        where: {
          productId: 'product-1',
          activeStatus: 'active',
          product: {
            storeId: 'store-1',
            activeStatus: 'active',
          },
        },
      }),
    );
    expect(many[0]?.importPrice).toBe(1000);
    expect(one?.sellingPrice).toBe(1500);
  });

  it('findManyByProductIdForNameSync returns simple active packages for a product', async () => {
    db.productPackage.findMany.mockResolvedValue([
      {
        productPackageId: 'package-1',
        displayName: 'Milk bottle',
        variant: 'bottle',
      },
    ]);

    const result = await repository.findManyByProductIdForNameSync(
      'store-1',
      'product-1',
    );

    expect(db.productPackage.findMany).toHaveBeenCalledWith({
      where: {
        productId: 'product-1',
        activeStatus: 'active',
        product: {
          storeId: 'store-1',
          activeStatus: 'active',
        },
      },
      orderBy: {
        createdAt: 'desc',
      },
      select: {
        productPackageId: true,
        displayName: true,
        variant: true,
      },
    });
    expect(result).toEqual([
      {
        productPackageId: 'package-1',
        displayName: 'Milk bottle',
        variant: 'bottle',
      },
    ]);
  });

  it('findOne enforces store scope and active status', async () => {
    db.productPackage.findFirst.mockResolvedValue(record());

    const result = await repository.findOne('store-1', 'package-1');

    expect(db.productPackage.findFirst).toHaveBeenCalledWith(
      expect.objectContaining({
        where: {
          productPackageId: 'package-1',
          activeStatus: 'active',
          product: {
            storeId: 'store-1',
            activeStatus: 'active',
          },
        },
      }),
    );
    expect(result?.importPrice).toBe(1000);
  });

  it('returns early for empty active package and product-id lookups', async () => {
    await expect(repository.findManyActiveByIds('store-1', [])).resolves.toEqual(
      [],
    );
    await expect(
      repository.findProductIdsHavingActivePackages('store-1', []),
    ).resolves.toEqual([]);
    expect(db.productPackage.findMany).not.toHaveBeenCalled();
  });

  it('findManyActiveByIds and findProductIdsHavingActivePackages scope by store', async () => {
    db.productPackage.findMany
      .mockResolvedValueOnce([record()])
      .mockResolvedValueOnce([{ productId: 'product-1' }]);

    await repository.findManyActiveByIds('store-1', ['package-1']);
    const productIds = await repository.findProductIdsHavingActivePackages(
      'store-1',
      ['product-1'],
    );

    expect(db.productPackage.findMany).toHaveBeenNthCalledWith(
      1,
      expect.objectContaining({
        where: {
          productPackageId: {
            in: ['package-1'],
          },
          activeStatus: 'active',
          product: {
            storeId: 'store-1',
            activeStatus: 'active',
          },
        },
      }),
    );
    expect(db.productPackage.findMany).toHaveBeenNthCalledWith(
      2,
      expect.objectContaining({
        distinct: ['productId'],
        where: {
          productId: {
            in: ['product-1'],
          },
          activeStatus: 'active',
          product: {
            storeId: 'store-1',
            activeStatus: 'active',
          },
        },
      }),
    );
    expect(productIds).toEqual(['product-1']);
  });

  it('findOneExistedVariant queries active duplicate unit and variant pairs', async () => {
    db.productPackage.findFirst.mockResolvedValue({ productPackageId: 'p1' });

    await repository.findOneExistedVariant('product-1', [
      { unitId: 'unit-1', variant: null },
      { unitId: 'unit-2', variant: 'box' },
    ]);

    expect(db.productPackage.findFirst).toHaveBeenCalledWith({
      where: {
        productId: 'product-1',
        activeStatus: 'active',
        OR: [
          { unitId: 'unit-1', variant: null },
          { unitId: 'unit-2', variant: 'box' },
        ],
      },
      select: {
        productPackageId: true,
      },
    });
  });

  it('findBarcodeCandidates returns early without tokens and searches token groups', async () => {
    await expect(
      repository.findBarcodeCandidates({ storeId: 'store-1' }),
    ).resolves.toEqual([]);

    db.productPackage.findMany.mockResolvedValue([record()]);

    const result = await repository.findBarcodeCandidates({
      storeId: 'store-1',
      nameTokens: ['milk'],
      brandTokens: ['dairy'],
      packageTokens: ['bottle'],
    });

    expect(db.productPackage.findMany).toHaveBeenCalledWith(
      expect.objectContaining({
        where: expect.objectContaining({
          activeStatus: 'active',
          product: {
            storeId: 'store-1',
            activeStatus: 'active',
          },
          OR: expect.arrayContaining([
            { displayName: { contains: 'milk', mode: 'insensitive' } },
            { variant: { contains: 'bottle', mode: 'insensitive' } },
          ]),
        }),
        take: 30,
      }),
    );
    expect(result[0]).toMatchObject({
      productName: 'Milk',
      brand: 'Dairy Co',
      productPackage: {
        importPrice: 1000,
        sellingPrice: 1500,
      },
    });
  });

  it('creates packages with nested inventory and converts returned prices', async () => {
    db.productPackage.create.mockResolvedValue(record());

    const result = await repository.createManyAndInventory([
      {
        package: {
          productId: 'product-1',
          unitId: 'unit-1',
          displayName: 'Milk bottle',
        },
        inventory: {
          quantity: 5,
          reorderThreshold: 2,
        },
      },
    ]);

    expect(db.productPackage.create).toHaveBeenCalledWith(
      expect.objectContaining({
        data: {
          productId: 'product-1',
          unitId: 'unit-1',
          displayName: 'Milk bottle',
          inventory: {
            create: {
              quantity: 5,
              reorderThreshold: 2,
            },
          },
        },
      }),
    );
    expect(result[0]?.importPrice).toBe(1000);
  });

  it('updates only provided fields and soft deletes by id', async () => {
    db.productPackage.update
      .mockResolvedValueOnce(record({ variant: null, importPrice: null }))
      .mockResolvedValueOnce({ productPackageId: 'package-1' });

    const updated = await repository.updateOne('package-1', {
      variant: null,
      importPrice: null,
    });
    const deleted = await repository.softDeleteOne('package-1');

    expect(db.productPackage.update).toHaveBeenNthCalledWith(
      1,
      expect.objectContaining({
        where: { productPackageId: 'package-1' },
        data: {
          variant: null,
          importPrice: null,
        },
      }),
    );
    expect(db.productPackage.update).toHaveBeenNthCalledWith(2, {
      where: { productPackageId: 'package-1' },
      data: {
        activeStatus: 'inactive',
      },
      select: {
        productPackageId: true,
      },
    });
    expect(updated.importPrice).toBeNull();
    expect(deleted).toEqual({ productPackageId: 'package-1' });
  });

  it('updates display names and soft deletes many packages by product id', async () => {
    db.productPackage.update.mockResolvedValue({
      productPackageId: 'package-1',
      displayName: 'Oat Milk bottle',
      variant: 'bottle',
    });
    db.productPackage.updateMany.mockResolvedValue({ count: 2 });

    await repository.updateDisplayNameWithProduct(
      'package-1',
      'Oat Milk bottle',
    );
    await expect(repository.softDeleteManyByProductId('product-1')).resolves.toBe(
      2,
    );

    expect(db.productPackage.updateMany).toHaveBeenCalledWith({
      where: { productId: 'product-1' },
      data: {
        activeStatus: 'inactive',
      },
    });
  });
});
