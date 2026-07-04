import { beforeEach, describe, expect, it, vi } from 'vitest';

import { SearchRepository } from '../../../../src/modules/search/search.repository.js';

const createMockDb = () => ({
  $queryRaw: vi.fn(),
  product: {
    findMany: vi.fn(),
  },
});

const decimal = (value: number) => ({
  toNumber: vi.fn(() => value),
});

describe('SearchRepository', () => {
  let db: ReturnType<typeof createMockDb>;
  let searchRepository: SearchRepository;

  beforeEach(() => {
    db = createMockDb();
    searchRepository = new SearchRepository(db as never);
  });

  it('searchProductPackagesByKeyword returns early when keyword is empty', async () => {
    const result = await searchRepository.searchProductPackagesByKeyword(
      'store-1',
      {
        keyword: '',
        page: 1,
        limit: 10,
      },
    );

    expect(result).toEqual({ items: [], totalItems: 0 });
    expect(db.$queryRaw).not.toHaveBeenCalled();
  });

  it('searchProductPackagesByKeyword queries store-scoped active packages and maps decimal prices', async () => {
    db.$queryRaw
      .mockResolvedValueOnce([{ total: 1n }])
      .mockResolvedValueOnce([
        {
          productId: 'product-1',
          productName: 'Milk',
          imageUrl: 'products/milk.png',
          brand: 'Dairy Co',
          categoryId: 'category-1',
          categoryName: 'Dairy',
          productPackageId: 'package-1',
          displayName: 'Milk Box',
          importPrice: decimal(1000),
          sellingPrice: decimal(1500),
          quantity: 10,
          reorderThreshold: 2,
          unitId: 'unit-1',
          unitCode: 'BOX',
          unitName: 'Box',
        },
      ]);

    const result = await searchRepository.searchProductPackagesByKeyword(
      'store-1',
      {
        keyword: 'milk box',
        page: 2,
        limit: 5,
      },
    );

    expect(db.$queryRaw).toHaveBeenCalledTimes(2);
    expect(db.$queryRaw.mock.calls[0]?.[0].values).toContain('store-1');
    expect(db.$queryRaw.mock.calls[0]?.[0].values).toContain(
      'milk:* | box:*',
    );
    expect(db.$queryRaw.mock.calls[1]?.[0].values).toEqual(
      expect.arrayContaining(['store-1', 'milk:* & box:*', 'milk:* | box:*', 5, 5]),
    );
    expect(result).toEqual({
      items: [
        {
          productId: 'product-1',
          productName: 'Milk',
          imageUrl: 'products/milk.png',
          brand: 'Dairy Co',
          categoryId: 'category-1',
          categoryName: 'Dairy',
          productPackageId: 'package-1',
          displayName: 'Milk Box',
          importPrice: 1000,
          sellingPrice: 1500,
          quantity: 10,
          reorderThreshold: 2,
          unitId: 'unit-1',
          unitCode: 'BOX',
          unitName: 'Box',
        },
      ],
      totalItems: 1,
    });
  });

  it('searchProductPackagesByKeyword returns early when escaped tokens are empty', async () => {
    const result = await searchRepository.searchProductPackagesByKeyword(
      'store-1',
      {
        keyword: '& | ! ( ) : *',
        page: 1,
        limit: 10,
      },
    );

    expect(result).toEqual({ items: [], totalItems: 0 });
    expect(db.$queryRaw).not.toHaveBeenCalled();
  });

  it('searchProductPackagesByKeyword maps null decimal prices and missing count rows', async () => {
    db.$queryRaw.mockResolvedValueOnce([]).mockResolvedValueOnce([
      {
        productId: 'product-1',
        productName: 'Milk',
        imageUrl: null,
        brand: null,
        categoryId: 'category-1',
        categoryName: 'Dairy',
        productPackageId: 'package-1',
        displayName: null,
        importPrice: null,
        sellingPrice: null,
        quantity: null,
        reorderThreshold: null,
        unitId: 'unit-1',
        unitCode: 'BOX',
        unitName: 'Box',
      },
    ]);

    const result = await searchRepository.searchProductPackagesByKeyword(
      'store-1',
      {
        keyword: 'milk',
        page: 1,
        limit: 10,
      },
    );

    expect(result).toEqual({
      items: [
        expect.objectContaining({
          importPrice: null,
          sellingPrice: null,
          quantity: null,
          reorderThreshold: null,
        }),
      ],
      totalItems: 0,
    });
  });

  it('searchProductsByKeyword escapes tsquery operators and maps product rows', async () => {
    db.$queryRaw
      .mockResolvedValueOnce([{ total: 1n }])
      .mockResolvedValueOnce([
        {
          productId: 'product-1',
          productName: 'Milk',
          imageUrl: null,
          brand: null,
          categoryId: 'category-1',
          categoryName: 'Dairy',
        },
      ]);

    const result = await searchRepository.searchProductsByKeyword('store-1', {
      keyword: 'milk & box',
      page: 1,
      limit: 10,
    });

    expect(db.$queryRaw).toHaveBeenCalledTimes(2);
    expect(db.$queryRaw.mock.calls[0]?.[0].values).toContain(
      'milk:* | box:*',
    );
    expect(db.$queryRaw.mock.calls[1]?.[0].values).toEqual(
      expect.arrayContaining(['store-1', 'milk:* & box:*', 'milk:* | box:*', 10, 0]),
    );
    expect(result).toEqual({
      items: [
        {
          productId: 'product-1',
          productName: 'Milk',
          imageUrl: null,
          brand: null,
          categoryId: 'category-1',
          categoryName: 'Dairy',
        },
      ],
      totalItems: 1,
    });
  });

  it('searchProductsByKeyword returns early when keyword is empty', async () => {
    const result = await searchRepository.searchProductsByKeyword('store-1', {
      keyword: '',
      page: 1,
      limit: 10,
    });

    expect(result).toEqual({ items: [], totalItems: 0 });
    expect(db.$queryRaw).not.toHaveBeenCalled();
  });

  it('searchProductsByKeyword returns early when escaped tokens are empty', async () => {
    const result = await searchRepository.searchProductsByKeyword('store-1', {
      keyword: '& | ! ( ) : *',
      page: 1,
      limit: 10,
    });

    expect(result).toEqual({ items: [], totalItems: 0 });
    expect(db.$queryRaw).not.toHaveBeenCalled();
  });

  it('searchProductsByKeyword defaults missing count rows to zero total items', async () => {
    db.$queryRaw.mockResolvedValueOnce([]).mockResolvedValueOnce([]);

    const result = await searchRepository.searchProductsByKeyword('store-1', {
      keyword: 'milk',
      page: 1,
      limit: 10,
    });

    expect(result).toEqual({
      items: [],
      totalItems: 0,
    });
  });

  it('searchProductsByPrefix returns early for blank prefix', async () => {
    const result = await searchRepository.searchProductsByPrefix('store-1', {
      prefix: '   ',
      limit: 5,
    });

    expect(result).toEqual([]);
    expect(db.product.findMany).not.toHaveBeenCalled();
  });

  it('searchProductsByPrefix scopes active products by store and clamps limit', async () => {
    db.product.findMany.mockResolvedValue([
      {
        productId: 'product-1',
        name: 'Milk',
        brand: 'Dairy Co',
        imageUrl: 'products/milk.png',
      },
    ]);

    const result = await searchRepository.searchProductsByPrefix('store-1', {
      prefix: ' Mi ',
      limit: 25,
    });

    expect(db.product.findMany).toHaveBeenCalledWith({
      where: {
        storeId: 'store-1',
        activeStatus: 'active',
        name: {
          startsWith: 'Mi',
          mode: 'insensitive',
        },
      },
      select: {
        productId: true,
        name: true,
        brand: true,
        imageUrl: true,
      },
      orderBy: [
        {
          name: 'asc',
        },
      ],
      take: 20,
    });
    expect(result).toEqual([
      {
        productId: 'product-1',
        name: 'Milk',
        brand: 'Dairy Co',
        imageUrl: 'products/milk.png',
      },
    ]);
  });

  it('searchProductsByPrefix uses default limit for invalid values', async () => {
    db.product.findMany.mockResolvedValue([]);

    await searchRepository.searchProductsByPrefix('store-1', {
      prefix: 'Mi',
      limit: 0,
    });

    expect(db.product.findMany).toHaveBeenCalledWith(
      expect.objectContaining({
        take: 10,
      }),
    );
  });
});
