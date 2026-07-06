import { beforeEach, describe, expect, it, vi } from 'vitest';

import { SearchService } from '../../../../src/modules/search/search.service.js';

import type { SearchRepository } from '../../../../src/modules/search/search.repository.js';

const commonMocks = vi.hoisted(() => ({
  getSignedUrl: vi.fn(),
}));

vi.mock('../../../../src/common/utils/index.js', async (importOriginal) => {
  const actual =
    await importOriginal<
      typeof import('../../../../src/common/utils/index.js')
    >();

  return {
    ...actual,
    StorageService: {
      getSignedUrl: commonMocks.getSignedUrl,
    },
  };
});

type MockSearchRepository = {
  searchProductPackagesByKeyword: ReturnType<typeof vi.fn>;
  searchProductsByKeyword: ReturnType<typeof vi.fn>;
  searchProductsByPrefix: ReturnType<typeof vi.fn>;
};

const createMockSearchRepository = (): MockSearchRepository => ({
  searchProductPackagesByKeyword: vi.fn(),
  searchProductsByKeyword: vi.fn(),
  searchProductsByPrefix: vi.fn(),
});

describe('SearchService', () => {
  let searchRepository: MockSearchRepository;
  let searchService: SearchService;

  beforeEach(() => {
    vi.clearAllMocks();
    process.env.STORAGE_BUCKET = 'test-images';

    searchRepository = createMockSearchRepository();
    searchService = new SearchService(
      searchRepository as unknown as SearchRepository,
    );

    commonMocks.getSignedUrl.mockImplementation(
      (_bucket: string, path: string | null) =>
        path ? `signed:${path}` : null,
    );
  });

  it('searchProductPackagesByKeyword normalizes pagination and signs package images', async () => {
    searchRepository.searchProductPackagesByKeyword.mockResolvedValue({
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

    const result = await searchService.searchProductPackagesByKeyword(
      'store-1',
      {
        keyword: ' milk ',
        page: 2.8,
        limit: 200,
      },
    );

    expect(
      searchRepository.searchProductPackagesByKeyword,
    ).toHaveBeenCalledWith('store-1', {
      keyword: ' milk ',
      page: 2,
      limit: 100,
    });
    expect(commonMocks.getSignedUrl).toHaveBeenCalledWith(
      'test-images',
      'products/milk.png',
    );
    expect(result).toEqual({
      items: [
        expect.objectContaining({
          productId: 'product-1',
          imageUrl: 'signed:products/milk.png',
        }),
      ],
      meta: {
        page: 2,
        limit: 100,
        totalItems: 1,
        totalPages: 1,
      },
    });
  });

  it('searchProductsByKeyword returns paginated products with signed image URLs', async () => {
    searchRepository.searchProductsByKeyword.mockResolvedValue({
      items: [
        {
          productId: 'product-1',
          productName: 'Milk',
          imageUrl: 'products/milk.png',
          brand: null,
          categoryId: 'category-1',
          categoryName: 'Dairy',
        },
        {
          productId: 'product-2',
          productName: 'Yogurt',
          imageUrl: null,
          brand: 'Dairy Co',
          categoryId: 'category-1',
          categoryName: 'Dairy',
        },
      ],
      totalItems: 2,
    });

    const result = await searchService.searchProductsByKeyword('store-1', {
      keyword: 'milk',
      page: 1,
      limit: 10,
    });

    expect(searchRepository.searchProductsByKeyword).toHaveBeenCalledWith(
      'store-1',
      {
        keyword: 'milk',
        page: 1,
        limit: 10,
      },
    );
    expect(commonMocks.getSignedUrl).toHaveBeenCalledWith(
      'test-images',
      'products/milk.png',
    );
    expect(commonMocks.getSignedUrl).toHaveBeenCalledWith('test-images', null);
    expect(result.items).toEqual([
      expect.objectContaining({ imageUrl: 'signed:products/milk.png' }),
      expect.objectContaining({ imageUrl: null }),
    ]);
  });

  it('searchProductsByPrefix signs autocomplete product images without pagination metadata', async () => {
    searchRepository.searchProductsByPrefix.mockResolvedValue([
      {
        productId: 'product-1',
        name: 'Milk',
        brand: 'Dairy Co',
        imageUrl: 'products/milk.png',
      },
    ]);

    const result = await searchService.searchProductsByPrefix('store-1', {
      prefix: 'Mi',
      limit: 5,
    });

    expect(searchRepository.searchProductsByPrefix).toHaveBeenCalledWith(
      'store-1',
      {
        prefix: 'Mi',
        limit: 5,
      },
    );
    expect(result).toEqual([
      {
        productId: 'product-1',
        name: 'Milk',
        brand: 'Dairy Co',
        imageUrl: 'signed:products/milk.png',
      },
    ]);
  });

  it('uses the default image bucket when STORAGE_BUCKET is not configured', async () => {
    delete process.env.STORAGE_BUCKET;
    searchRepository.searchProductsByPrefix.mockResolvedValue([
      {
        productId: 'product-1',
        name: 'Milk',
        brand: null,
        imageUrl: 'products/milk.png',
      },
    ]);

    await searchService.searchProductsByPrefix('store-1', {
      prefix: 'Mi',
    });

    expect(commonMocks.getSignedUrl).toHaveBeenCalledWith(
      'images',
      'products/milk.png',
    );
  });

  it('propagates repository failures', async () => {
    const error = new Error('database unavailable');

    searchRepository.searchProductsByKeyword.mockRejectedValue(error);

    await expect(
      searchService.searchProductsByKeyword('store-1', {
        keyword: 'milk',
        page: 1,
        limit: 10,
      }),
    ).rejects.toThrow('database unavailable');
  });
});
