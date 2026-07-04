import { beforeEach, describe, expect, it, vi } from 'vitest';

import { ProductRepository } from '../../../../src/modules/products/product.repository.js';

const createMockDb = () => ({
  $transaction: vi.fn(async (operations: Promise<unknown>[]) => {
    return await Promise.all(operations);
  }),
  product: {
    findMany: vi.fn(),
    count: vi.fn(),
    findUnique: vi.fn(),
    create: vi.fn(),
    update: vi.fn(),
    updateMany: vi.fn(),
  },
});

const decimal = (value: number) => ({
  toNumber: vi.fn(() => value),
});

describe('ProductRepository', () => {
  let db: ReturnType<typeof createMockDb>;
  let productRepository: ProductRepository;

  beforeEach(() => {
    db = createMockDb();
    productRepository = new ProductRepository(db as never);
  });

  it('findManyByStoreId scopes active products by store and filters', async () => {
    db.product.findMany.mockResolvedValue([]);
    db.product.count.mockResolvedValue(0);

    await productRepository.findManyByStoreId('store-1', {
      page: 2,
      limit: 10,
      sortBy: 'createdAt',
      sortOrder: 'asc',
      categoryId: 'category-1',
      brand: 'Dairy Co',
    });

    expect(db.product.findMany).toHaveBeenCalledWith(
      expect.objectContaining({
        where: {
          storeId: 'store-1',
          activeStatus: 'active',
          categoryId: 'category-1',
          brand: {
            equals: 'Dairy Co',
            mode: 'insensitive',
          },
        },
        orderBy: {
          createdAt: 'asc',
        },
        skip: 10,
        take: 10,
      }),
    );
    expect(db.product.count).toHaveBeenCalledWith({
      where: expect.objectContaining({
        storeId: 'store-1',
        activeStatus: 'active',
      }),
    });
  });

  it('findOne enforces store scope and active status', async () => {
    db.product.findUnique.mockResolvedValue(null);

    await productRepository.findOne('store-1', 'product-1');

    expect(db.product.findUnique).toHaveBeenCalledWith(
      expect.objectContaining({
        where: {
          productId: 'product-1',
          storeId: 'store-1',
          activeStatus: 'active',
        },
      }),
    );
  });

  it('findDetailOne converts package prices to numbers', async () => {
    db.product.findUnique.mockResolvedValue({
      productId: 'product-1',
      productPackages: [
        {
          productPackageId: 'package-1',
          importPrice: decimal(1000),
          sellingPrice: decimal(1500),
        },
        {
          productPackageId: 'package-2',
          importPrice: null,
          sellingPrice: null,
        },
      ],
    });

    const result = await productRepository.findDetailOne('store-1', 'product-1');

    expect(db.product.findUnique).toHaveBeenCalledWith(
      expect.objectContaining({
        where: {
          productId: 'product-1',
          storeId: 'store-1',
          activeStatus: 'active',
        },
      }),
    );
    expect(result?.productPackages).toEqual([
      {
        productPackageId: 'package-1',
        importPrice: 1000,
        sellingPrice: 1500,
      },
      {
        productPackageId: 'package-2',
        importPrice: null,
        sellingPrice: null,
      },
    ]);
  });

  it('findManyActiveByIds returns early for empty input', async () => {
    const result = await productRepository.findManyActiveByIds('store-1', []);

    expect(result).toEqual([]);
    expect(db.product.findMany).not.toHaveBeenCalled();
  });

  it('findManyActiveByIds scopes ids by store and active status', async () => {
    db.product.findMany.mockResolvedValue([]);

    await productRepository.findManyActiveByIds('store-1', [
      'product-1',
      'product-2',
    ]);

    expect(db.product.findMany).toHaveBeenCalledWith(
      expect.objectContaining({
        where: {
          productId: {
            in: ['product-1', 'product-2'],
          },
          storeId: 'store-1',
          activeStatus: 'active',
        },
      }),
    );
  });

  it('createOne writes the product payload', async () => {
    db.product.create.mockResolvedValue({ productId: 'product-1' });

    await productRepository.createOne({
      storeId: 'store-1',
      name: 'Milk',
      imageUrl: null,
      brand: 'Dairy Co',
      categoryId: 'category-1',
    });

    expect(db.product.create).toHaveBeenCalledWith(
      expect.objectContaining({
        data: {
          storeId: 'store-1',
          name: 'Milk',
          imageUrl: null,
          brand: 'Dairy Co',
          categoryId: 'category-1',
        },
      }),
    );
  });

  it('updateOne updates by productId', async () => {
    db.product.update.mockResolvedValue({ productId: 'product-1' });

    await productRepository.updateOne('product-1', { name: 'Updated Milk' });

    expect(db.product.update).toHaveBeenCalledWith(
      expect.objectContaining({
        where: { productId: 'product-1' },
        data: { name: 'Updated Milk' },
      }),
    );
  });

  it('findManyByCategoryId returns active products and count for a category', async () => {
    db.product.findMany.mockResolvedValue([
      {
        productId: 'product-1',
        name: 'Milk',
        imageUrl: 'products/milk.png',
        brand: 'Dairy Co',
      },
      {
        productId: 'product-2',
        name: 'Yogurt',
        imageUrl: null,
        brand: null,
      },
    ]);

    const result = await productRepository.findManyByCategoryId('category-1');

    expect(db.product.findMany).toHaveBeenCalledWith({
      where: { categoryId: 'category-1', activeStatus: 'active' },
      select: {
        productId: true,
        name: true,
        imageUrl: true,
        brand: true,
      },
    });
    expect(result).toEqual({
      count: 2,
      products: [
        {
          productId: 'product-1',
          name: 'Milk',
          imageUrl: 'products/milk.png',
          brand: 'Dairy Co',
        },
        {
          productId: 'product-2',
          name: 'Yogurt',
          imageUrl: null,
          brand: null,
        },
      ],
    });
  });

  it('uncategorizeMany moves products in a store to the fallback category', async () => {
    db.product.updateMany.mockResolvedValue({ count: 3 });

    const result = await productRepository.uncategorizeMany(
      'store-1',
      'old-category',
      'uncategorized',
    );

    expect(result).toBe(3);
    expect(db.product.updateMany).toHaveBeenCalledWith({
      where: {
        categoryId: 'old-category',
        storeId: 'store-1',
      },
      data: {
        categoryId: 'uncategorized',
      },
    });
  });

  it('softDeleteOne marks a product inactive', async () => {
    db.product.update.mockResolvedValue({ productId: 'product-1' });

    await productRepository.softDeleteOne('product-1');

    expect(db.product.update).toHaveBeenCalledWith({
      where: {
        productId: 'product-1',
      },
      data: {
        activeStatus: 'inactive',
      },
      select: {
        productId: true,
      },
    });
  });
});
