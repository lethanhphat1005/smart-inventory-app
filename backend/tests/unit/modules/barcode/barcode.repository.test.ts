import { beforeEach, describe, expect, it, vi } from 'vitest';

import { BarcodeApiCacheRepository } from '../../../../src/modules/barcode/repositories/barcode-api-cache.repository.js';
import { PackageBarcodeRepository } from '../../../../src/modules/barcode/repositories/product-package-barcode.repository.js';

const decimal = (value: number) => ({
  toNumber: () => value,
});

const createMockDb = () => ({
  productPackageBarcode: {
    findFirst: vi.fn(),
    create: vi.fn(),
    count: vi.fn(),
    deleteMany: vi.fn(),
  },
  barcodeApiCache: {
    findFirst: vi.fn(),
    create: vi.fn(),
    update: vi.fn(),
  },
});

const productPackageRecord = {
  productPackageId: 'package-1',
  displayName: 'Cola 330ml',
  variant: '330ml',
  importPrice: decimal(7000),
  sellingPrice: decimal(10000),
  unitId: 'unit-1',
  productId: 'product-1',
};

describe('PackageBarcodeRepository', () => {
  let db: ReturnType<typeof createMockDb>;
  let repository: PackageBarcodeRepository;

  beforeEach(() => {
    db = createMockDb();
    repository = new PackageBarcodeRepository(db as never);
  });

  it('findByBarcode scopes lookup to active package and active product in store', async () => {
    db.productPackageBarcode.findFirst.mockResolvedValue({
      barcode: '123456789012',
      type: 'ean',
      source: 'user_confirmed',
      isVerified: true,
      confidence: decimal(100),
      productPackage: productPackageRecord,
    });

    const result = await repository.findByBarcode('store-1', '123456789012');

    expect(db.productPackageBarcode.findFirst).toHaveBeenCalledWith(
      expect.objectContaining({
        where: {
          barcode: '123456789012',
          productPackage: {
            activeStatus: 'active',
            product: {
              storeId: 'store-1',
              activeStatus: 'active',
            },
          },
        },
      }),
    );
    expect(result).toEqual({
      barcode: '123456789012',
      type: 'ean',
      source: 'user_confirmed',
      isVerified: true,
      confidence: 100,
      productPackage: {
        productPackageId: 'package-1',
        displayName: 'Cola 330ml',
        variant: '330ml',
        importPrice: 7000,
        sellingPrice: 10000,
        unitId: 'unit-1',
        productId: 'product-1',
      },
    });
  });

  it('checkOneExistedInStore maps confidence and returns null when not found', async () => {
    db.productPackageBarcode.findFirst.mockResolvedValueOnce({
      barcode: '123456789012',
      type: null,
      source: 'seed',
      isVerified: false,
      confidence: null,
      productPackageId: 'package-1',
    });

    await expect(
      repository.checkOneExistedInStore('store-1', '123456789012'),
    ).resolves.toMatchObject({
      barcode: '123456789012',
      confidence: null,
      productPackageId: 'package-1',
    });

    db.productPackageBarcode.findFirst.mockResolvedValueOnce(null);

    await expect(
      repository.checkOneExistedInStore('store-1', 'missing'),
    ).resolves.toBeNull();
  });

  it('creates mappings and includes optional confidence and type only when provided', async () => {
    db.productPackageBarcode.create.mockResolvedValue({
      barcode: '123456789012',
      type: 'ean',
      source: 'user_confirmed',
      isVerified: true,
      confidence: decimal(100),
      productPackage: productPackageRecord,
    });

    const result = await repository.createMapping({
      barcode: '123456789012',
      productPackageId: 'package-1',
      source: 'user_confirmed',
      isVerified: true,
      confidence: 100,
      type: 'ean',
    });

    expect(db.productPackageBarcode.create).toHaveBeenCalledWith(
      expect.objectContaining({
        data: {
          barcode: '123456789012',
          productPackageId: 'package-1',
          source: 'user_confirmed',
          isVerified: true,
          confidence: 100,
          type: 'ean',
        },
      }),
    );
    expect(result.confidence).toBe(100);
  });

  it('checks barcode existence and deletes by barcode plus package id', async () => {
    db.productPackageBarcode.count.mockResolvedValue(1);
    db.productPackageBarcode.deleteMany.mockResolvedValue({ count: 2 });

    await expect(repository.existsByBarcode('123456')).resolves.toBe(true);
    await expect(
      repository.deleteByBarcodeAndProductPackageId('123456', 'package-1'),
    ).resolves.toBe(2);

    expect(db.productPackageBarcode.count).toHaveBeenCalledWith({
      where: { barcode: '123456' },
    });
    expect(db.productPackageBarcode.deleteMany).toHaveBeenCalledWith({
      where: {
        barcode: '123456',
        productPackageId: 'package-1',
      },
    });
  });

  it('finds one barcode by active product package id', async () => {
    db.productPackageBarcode.findFirst.mockResolvedValue({
      barcode: '123456789012',
      type: 'ean',
    });

    const result = await repository.findByProductPackageId('package-1');

    expect(result).toEqual({
      barcode: '123456789012',
      type: 'ean',
    });
    expect(db.productPackageBarcode.findFirst).toHaveBeenCalledWith({
      where: {
        productPackageId: 'package-1',
        productPackage: { activeStatus: 'active' },
      },
      select: {
        barcode: true,
        type: true,
      },
    });
  });
});

describe('BarcodeApiCacheRepository', () => {
  let db: ReturnType<typeof createMockDb>;
  let repository: BarcodeApiCacheRepository;

  beforeEach(() => {
    db = createMockDb();
    repository = new BarcodeApiCacheRepository(db as never);
  });

  it('finds the newest cache row by barcode', async () => {
    await repository.findOneByBarcode('123456789012');

    expect(db.barcodeApiCache.findFirst).toHaveBeenCalledWith({
      where: {
        barcode: '123456789012',
      },
      orderBy: {
        fetchedAt: 'desc',
      },
    });
  });

  it('creates and updates cache rows with normalized and extracted fields', async () => {
    const data = {
      barcode: '123456789012',
      payload: { rawPayload: null },
      status: 'valid' as const,
      provider: 'provider',
      type: 'ean' as const,
      normalizedName: 'cola',
      normalizedBrand: 'cola',
      normalizedPackageText: '330ml',
      extractedName: 'Cola',
      extractedBrand: 'Cola',
      extractedPackageText: '330ml',
    };

    await repository.createOne(data);
    await repository.updateOne('cache-1', data);

    expect(db.barcodeApiCache.create).toHaveBeenCalledWith({
      data,
    });
    expect(db.barcodeApiCache.update).toHaveBeenCalledWith(
      expect.objectContaining({
        where: { barcodeCacheId: 'cache-1' },
        data: expect.objectContaining({
          payload: data.payload,
          status: 'valid',
          fetchedAt: expect.any(Date),
          normalizedName: 'cola',
        }),
      }),
    );
  });

  it('marks a cache row as used', async () => {
    await repository.markAsUsed('cache-1');

    expect(db.barcodeApiCache.update).toHaveBeenCalledWith({
      where: { barcodeCacheId: 'cache-1' },
      data: {
        lastUsedAt: expect.any(Date),
        hitCount: {
          increment: 1,
        },
      },
    });
  });
});
