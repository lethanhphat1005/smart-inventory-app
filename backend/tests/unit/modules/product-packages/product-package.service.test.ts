import { StatusCodes } from 'http-status-codes';
import { beforeEach, describe, expect, it, vi } from 'vitest';

import { ProductPackageService } from '../../../../src/modules/product-packages/services/product-package.service.js';

const serviceMocks = vi.hoisted(() => {
  const transactionClient = {
    productPackage: {
      createManyAndInventory: vi.fn(),
      updateOne: vi.fn(),
      softDeleteOne: vi.fn(),
    },
    inventory: {
      softDeleteOneByPackageId: vi.fn(),
    },
    auditLog: {
      create: vi.fn(),
    },
  };

  const transactionMock = vi.fn(
    async <T>(callback: (tx: typeof transactionClient) => Promise<T>) => {
      return await callback(transactionClient);
    },
  );

  return {
    getSignedUrl: vi.fn(),
    transactionClient,
    transactionMock,
  };
});

vi.mock('../../../../src/db/prismaClient.js', () => ({
  prisma: {
    $transaction: serviceMocks.transactionMock,
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
      getSignedUrl: serviceMocks.getSignedUrl,
    },
  };
});

vi.mock('../../../../src/modules/audit-log/index.js', () => ({
  AuditLogRepository: class MockAuditLogRepository {
    constructor(private readonly db: typeof serviceMocks.transactionClient) {}

    async createLog(data: unknown): Promise<void> {
      await this.db.auditLog.create({ data });
    }
  },
}));

vi.mock('../../../../src/modules/inventories/index.js', () => ({
  InventoryRepository: class MockInventoryRepository {
    constructor(private readonly db: typeof serviceMocks.transactionClient) {}

    async softDeleteOneByPackageId(productPackageId: string): Promise<unknown> {
      return await this.db.inventory.softDeleteOneByPackageId(productPackageId);
    }
  },
}));

vi.mock('../../../../src/modules/products/index.js', () => ({
  ProductRepository: class MockProductRepository {},
}));

vi.mock(
  '../../../../src/modules/product-packages/repositories/product-package.repository.js',
  () => ({
    ProductPackageRepository: class MockProductPackageRepository {
      constructor(private readonly db: typeof serviceMocks.transactionClient) {}

      async createManyAndInventory(data: unknown): Promise<unknown> {
        return await this.db.productPackage.createManyAndInventory(data);
      }

      async updateOne(
        productPackageId: string,
        data: unknown,
      ): Promise<unknown> {
        return await this.db.productPackage.updateOne(productPackageId, data);
      }

      async softDeleteOne(productPackageId: string): Promise<unknown> {
        return await this.db.productPackage.softDeleteOne(productPackageId);
      }
    },
  }),
);

type MockRepository = {
  findManyByStore: ReturnType<typeof vi.fn>;
  findManyByProductId: ReturnType<typeof vi.fn>;
  findDetailOne: ReturnType<typeof vi.fn>;
  findManyActiveByIds: ReturnType<typeof vi.fn>;
  findProductIdsHavingActivePackages: ReturnType<typeof vi.fn>;
  findOne: ReturnType<typeof vi.fn>;
  findOneExistedVariant: ReturnType<typeof vi.fn>;
};

type MockUnitRepository = {
  findManyByIds: ReturnType<typeof vi.fn>;
  findOneById: ReturnType<typeof vi.fn>;
};

type MockProductRepository = {
  findOne: ReturnType<typeof vi.fn>;
};

const date = new Date('2026-01-01T00:00:00.000Z');

const packageFixture = (overrides: Record<string, unknown> = {}) => ({
  productPackageId: 'package-1',
  displayName: 'Milk bottle',
  variant: 'bottle',
  importPrice: 1000,
  sellingPrice: 1500,
  unitId: 'unit-1',
  productId: 'product-1',
  ...overrides,
});

const detailPackageFixture = (overrides: Record<string, unknown> = {}) => ({
  ...packageFixture(),
  createdAt: date,
  unit: {
    unitId: 'unit-1',
    code: 'BTL',
    name: 'bottle',
  },
  category: {
    categoryId: 'category-1',
    name: 'Dairy',
  },
  product: {
    productId: 'product-1',
    imageUrl: 'products/milk.png',
  },
  inventory: {
    inventoryId: 'inventory-1',
    quantity: 5,
    reorderThreshold: 2,
  },
  productPackageBarcodes: [],
  ...overrides,
});

const createRepository = (): MockRepository => ({
  findManyByStore: vi.fn(),
  findManyByProductId: vi.fn(),
  findDetailOne: vi.fn(),
  findManyActiveByIds: vi.fn(),
  findProductIdsHavingActivePackages: vi.fn(),
  findOne: vi.fn(),
  findOneExistedVariant: vi.fn(),
});

describe('ProductPackageService', () => {
  let productPackageRepository: MockRepository;
  let unitRepository: MockUnitRepository;
  let productRepository: MockProductRepository;
  let service: ProductPackageService;

  beforeEach(() => {
    vi.clearAllMocks();

    serviceMocks.getSignedUrl.mockImplementation(
      (_bucket: string, path: string | null) =>
        path ? `signed:${path}` : null,
    );

    productPackageRepository = createRepository();
    unitRepository = {
      findManyByIds: vi.fn(),
      findOneById: vi.fn(),
    };
    productRepository = {
      findOne: vi.fn(),
    };
    service = new ProductPackageService(
      productPackageRepository as never,
      unitRepository as never,
      productRepository as never,
    );
  });

  it('returns paginated store packages with signed product image URLs', async () => {
    productPackageRepository.findManyByStore.mockResolvedValue({
      items: [detailPackageFixture()],
      totalItems: 1,
    });

    const result = await service.getProductPackagesByStore('store-1', {
      page: 1,
      limit: 50,
      sortBy: 'displayName',
      sortOrder: 'asc',
    });

    expect(productPackageRepository.findManyByStore).toHaveBeenCalledWith(
      'store-1',
      {
        page: 1,
        limit: 50,
        sortBy: 'displayName',
        sortOrder: 'asc',
      },
    );
    expect(result.items[0]?.product.imageUrl).toBe('signed:products/milk.png');
    expect(result.meta).toEqual({
      page: 1,
      limit: 50,
      totalItems: 1,
      totalPages: 1,
    });
  });

  it('requires the product before listing packages by product id', async () => {
    productRepository.findOne.mockResolvedValue({ productId: 'product-1' });
    productPackageRepository.findManyByProductId.mockResolvedValue([
      detailPackageFixture(),
    ]);

    const result = await service.getProductPackagesByProductId(
      'store-1',
      'product-1',
    );

    expect(productRepository.findOne).toHaveBeenCalledWith(
      'store-1',
      'product-1',
    );
    expect(result[0]?.product.imageUrl).toBe('signed:products/milk.png');
  });

  it('throws not found when the product is missing before package lookup', async () => {
    productRepository.findOne.mockResolvedValue(null);

    await expect(
      service.getProductPackagesByProductId('store-1', 'missing-product'),
    ).rejects.toMatchObject({
      message: 'Product not found',
      status: StatusCodes.NOT_FOUND,
    });
    expect(productPackageRepository.findManyByProductId).not.toHaveBeenCalled();
  });

  it('returns package detail with a signed product image URL', async () => {
    productPackageRepository.findDetailOne.mockResolvedValue(
      detailPackageFixture(),
    );

    const result = await service.getProductPackageById('store-1', 'package-1');

    expect(productPackageRepository.findDetailOne).toHaveBeenCalledWith(
      'store-1',
      'package-1',
    );
    expect(result.product.imageUrl).toBe('signed:products/milk.png');
  });

  it('throws not found when package detail is missing', async () => {
    productPackageRepository.findDetailOne.mockResolvedValue(null);

    await expect(
      service.getProductPackageById('store-1', 'missing-package'),
    ).rejects.toMatchObject({
      message: 'Product package not found',
      status: StatusCodes.NOT_FOUND,
    });
  });

  it('delegates active package and product-id helper lookups', async () => {
    productPackageRepository.findManyActiveByIds.mockResolvedValue([
      packageFixture(),
    ]);
    productPackageRepository.findProductIdsHavingActivePackages.mockResolvedValue(
      ['product-1'],
    );

    await expect(
      service.getProductPackagesByIds('store-1', ['package-1']),
    ).resolves.toEqual([packageFixture()]);
    await expect(
      service.getProductIdsHavingPackages('store-1', ['product-1']),
    ).resolves.toEqual(['product-1']);
  });

  it('creates packages, inventories, and audit logs in one transaction', async () => {
    productRepository.findOne.mockResolvedValue({
      productId: 'product-1',
      name: 'Milk',
    });
    unitRepository.findManyByIds.mockResolvedValue([
      { unitId: 'unit-1', code: 'BTL', name: 'bottle' },
    ]);
    productPackageRepository.findOneExistedVariant.mockResolvedValue(null);
    serviceMocks.transactionClient.productPackage.createManyAndInventory.mockResolvedValue(
      [
        {
          ...packageFixture(),
          createdAt: date,
          inventory: {
            inventoryId: 'inventory-1',
            quantity: 3,
            reorderThreshold: 1,
          },
          productPackageBarcodes: [],
        },
      ],
    );

    const result = await service.createProductPackageAndInventory(
      'store-1',
      'user-1',
      'product-1',
      [
        {
          package: {
            unitId: 'unit-1',
            variant: 'bottle',
            importPrice: 1000,
            sellingPrice: 1500,
          },
          inventory: {
            productPackageId: 'package-1',
            quantity: 3,
            reorderThreshold: 1,
          },
        },
      ],
    );

    expect(
      serviceMocks.transactionClient.productPackage.createManyAndInventory,
    ).toHaveBeenCalledWith([
      {
        package: {
          unitId: 'unit-1',
          variant: 'bottle',
          importPrice: 1000,
          sellingPrice: 1500,
          productId: 'product-1',
          displayName: 'Milk bottle',
        },
        inventory: {
          productPackageId: 'package-1',
          quantity: 3,
          reorderThreshold: 1,
        },
      },
    ]);
    expect(serviceMocks.transactionClient.auditLog.create).toHaveBeenCalledTimes(
      2,
    );
    expect(result[0]?.displayName).toBe('Milk bottle');
  });

  it('rejects duplicate unit and variant combinations in the request', async () => {
    productRepository.findOne.mockResolvedValue({
      productId: 'product-1',
      name: 'Milk',
    });
    unitRepository.findManyByIds.mockResolvedValue([
      { unitId: 'unit-1', code: 'BTL', name: 'bottle' },
    ]);

    await expect(
      service.createProductPackageAndInventory(
        'store-1',
        'user-1',
        'product-1',
        [
          {
            package: { unitId: 'unit-1', variant: 'bottle' },
            inventory: { productPackageId: 'package-1', quantity: 1 },
          },
          {
            package: { unitId: 'unit-1', variant: 'bottle' },
            inventory: { productPackageId: 'package-2', quantity: 2 },
          },
        ],
      ),
    ).rejects.toMatchObject({
      message: 'Duplicate package: unitId=unit-1, variant=bottle',
      status: StatusCodes.BAD_REQUEST,
    });
    expect(serviceMocks.transactionMock).not.toHaveBeenCalled();
  });

  it('rejects missing units and existing variants before creating', async () => {
    productRepository.findOne.mockResolvedValue({
      productId: 'product-1',
      name: 'Milk',
    });
    unitRepository.findManyByIds.mockResolvedValue(null);

    await expect(
      service.createProductPackageAndInventory(
        'store-1',
        'user-1',
        'product-1',
        [
          {
            package: { unitId: 'unit-1' },
            inventory: { productPackageId: 'package-1', quantity: 1 },
          },
        ],
      ),
    ).rejects.toMatchObject({
      message: 'Unit not found',
      status: StatusCodes.NOT_FOUND,
    });

    unitRepository.findManyByIds.mockResolvedValue([]);

    await expect(
      service.createProductPackageAndInventory(
        'store-1',
        'user-1',
        'product-1',
        [
          {
            package: { unitId: 'unit-1' },
            inventory: { productPackageId: 'package-1', quantity: 1 },
          },
        ],
      ),
    ).rejects.toMatchObject({
      message: 'One or more units not found',
      status: StatusCodes.NOT_FOUND,
    });

    unitRepository.findManyByIds.mockResolvedValue([
      { unitId: 'unit-1', code: 'BTL', name: 'bottle' },
    ]);
    productPackageRepository.findOneExistedVariant.mockResolvedValue({
      productPackageId: 'package-1',
    });

    await expect(
      service.createProductPackageAndInventory(
        'store-1',
        'user-1',
        'product-1',
        [
          {
            package: { unitId: 'unit-1' },
            inventory: { productPackageId: 'package-1', quantity: 1 },
          },
        ],
      ),
    ).rejects.toMatchObject({
      message: 'Product package variant already exists',
      status: StatusCodes.CONFLICT,
    });
  });

  it('updates unit-dependent display name and writes an audit log for changes', async () => {
    productPackageRepository.findOne.mockResolvedValue(packageFixture());
    productRepository.findOne.mockResolvedValue({
      productId: 'product-1',
      name: 'Milk',
    });
    unitRepository.findOneById.mockResolvedValue({
      unitId: 'unit-2',
      code: 'BOX',
      name: 'box',
    });
    serviceMocks.transactionClient.productPackage.updateOne.mockResolvedValue(
      packageFixture({
        unitId: 'unit-2',
        displayName: 'Milk box',
      }),
    );

    const result = await service.updateProductPackage(
      'store-1',
      'user-1',
      'package-1',
      {
        unitId: 'unit-2',
        sellingPrice: 1800,
      },
    );

    expect(serviceMocks.transactionClient.productPackage.updateOne).toHaveBeenCalledWith(
      'package-1',
      {
        unitId: 'unit-2',
        displayName: 'Milk box',
        sellingPrice: 1800,
      },
    );
    expect(serviceMocks.transactionClient.auditLog.create).toHaveBeenCalledWith({
      data: expect.objectContaining({
        actionType: 'update',
        entityType: 'ProductPackage',
        oldValue: expect.objectContaining({
          unitId: 'unit-1',
          sellingPrice: 1500,
        }),
        newValue: expect.objectContaining({
          unitId: 'unit-2',
          displayName: 'Milk box',
          sellingPrice: 1800,
        }),
      }),
    });
    expect(result.displayName).toBe('Milk box');
  });

  it('updates variant and import price without changing unit display name', async () => {
    productPackageRepository.findOne.mockResolvedValue(packageFixture());
    serviceMocks.transactionClient.productPackage.updateOne.mockResolvedValue(
      packageFixture({
        variant: 'box',
        importPrice: 1200,
      }),
    );

    await service.updateProductPackage('store-1', 'user-1', 'package-1', {
      variant: 'box',
      importPrice: 1200,
    });

    expect(productRepository.findOne).not.toHaveBeenCalled();
    expect(unitRepository.findOneById).not.toHaveBeenCalled();
    expect(serviceMocks.transactionClient.productPackage.updateOne).toHaveBeenCalledWith(
      'package-1',
      {
        variant: 'box',
        importPrice: 1200,
      },
    );
    expect(serviceMocks.transactionClient.auditLog.create).toHaveBeenCalledWith({
      data: expect.objectContaining({
        oldValue: {
          variant: 'bottle',
          importPrice: 1000,
        },
        newValue: {
          variant: 'box',
          importPrice: 1200,
        },
      }),
    });
  });

  it('does not write an update audit log when submitted values do not change', async () => {
    productPackageRepository.findOne.mockResolvedValue(packageFixture());
    serviceMocks.transactionClient.productPackage.updateOne.mockResolvedValue(
      packageFixture(),
    );

    await service.updateProductPackage('store-1', 'user-1', 'package-1', {
      sellingPrice: 1500,
    });

    expect(serviceMocks.transactionClient.auditLog.create).not.toHaveBeenCalled();
  });

  it('throws before updating when the package or replacement unit is missing', async () => {
    productPackageRepository.findOne.mockResolvedValue(null);

    await expect(
      service.updateProductPackage('store-1', 'user-1', 'missing-package', {
        sellingPrice: 1800,
      }),
    ).rejects.toMatchObject({
      message: 'Product package not found',
      status: StatusCodes.NOT_FOUND,
    });

    productPackageRepository.findOne.mockResolvedValue(packageFixture());
    productRepository.findOne.mockResolvedValue({
      productId: 'product-1',
      name: 'Milk',
    });
    unitRepository.findOneById.mockResolvedValue(null);

    await expect(
      service.updateProductPackage('store-1', 'user-1', 'package-1', {
        unitId: 'missing-unit',
      }),
    ).rejects.toMatchObject({
      message: 'Unit not found',
      status: StatusCodes.NOT_FOUND,
    });
  });

  it('soft deletes a package and its inventory in one transaction', async () => {
    productPackageRepository.findOne.mockResolvedValue(packageFixture());
    serviceMocks.transactionClient.productPackage.softDeleteOne.mockResolvedValue(
      { productPackageId: 'package-1' },
    );
    serviceMocks.transactionClient.inventory.softDeleteOneByPackageId.mockResolvedValue(
      { inventoryId: 'inventory-1' },
    );

    await service.softDeleteProductPackage('store-1', 'user-1', 'package-1');

    expect(
      serviceMocks.transactionClient.productPackage.softDeleteOne,
    ).toHaveBeenCalledWith('package-1');
    expect(
      serviceMocks.transactionClient.inventory.softDeleteOneByPackageId,
    ).toHaveBeenCalledWith('package-1');
    expect(serviceMocks.transactionClient.auditLog.create).toHaveBeenCalledWith({
      data: expect.objectContaining({
        actionType: 'delete',
        entityType: 'ProductPackage',
        entityId: 'package-1',
        newValue: {
          activeStatus: 'inactive',
          affectedInventory: {
            inventoryId: 'inventory-1',
            activeStatus: 'inactive',
          },
        },
      }),
    });
  });
});
