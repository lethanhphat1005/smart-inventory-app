import { StatusCodes } from 'http-status-codes';
import { beforeEach, describe, expect, it } from 'vitest';
import { vi } from 'vitest';

import { SearchController } from '../../../../src/modules/search/search.controller.js';
import { createRequest, createResponse } from '../../../helpers/index.js';

import type {
  ListProductByKeywordResponseDto,
  ListProductPackageByKeywordResponseDto,
  SearchProductPrefixResponseDto,
} from '../../../../src/modules/search/search.dto.js';

type MockSearchService = {
  searchProductPackagesByKeyword: ReturnType<typeof vi.fn>;
  searchProductsByKeyword: ReturnType<typeof vi.fn>;
  searchProductsByPrefix: ReturnType<typeof vi.fn>;
};

const createMockSearchService = (): MockSearchService => ({
  searchProductPackagesByKeyword: vi.fn(),
  searchProductsByKeyword: vi.fn(),
  searchProductsByPrefix: vi.fn(),
});

describe('SearchController', () => {
  let searchService: MockSearchService;
  let searchController: SearchController;

  beforeEach(() => {
    searchService = createMockSearchService();
    searchController = new SearchController(searchService as never);
  });

  it('returns product package keyword search results for the current store', async () => {
    const payload: ListProductPackageByKeywordResponseDto = {
      items: [],
      meta: {
        page: 1,
        limit: 50,
        totalItems: 0,
        totalPages: 0,
      },
    };
    const req = createRequest({
      storeContext: {
        storeId: 'store-1',
        role: 'owner',
      },
    });
    const res = createResponse<ListProductPackageByKeywordResponseDto>({
      validatedQuery: {
        keyword: 'milk',
        page: 1,
        limit: 50,
      },
    });

    searchService.searchProductPackagesByKeyword.mockResolvedValue(payload);

    await searchController.getProductPackagesbyKeyword(req, res);

    expect(searchService.searchProductPackagesByKeyword).toHaveBeenCalledWith(
      'store-1',
      {
        keyword: 'milk',
        page: 1,
        limit: 50,
      },
    );
    expect(res.status).toHaveBeenCalledWith(StatusCodes.OK);
    expect(res.json).toHaveBeenCalledWith({
      success: true,
      data: payload,
    });
  });

  it('returns product keyword search results for the current store', async () => {
    const payload: ListProductByKeywordResponseDto = {
      items: [],
      meta: {
        page: 1,
        limit: 50,
        totalItems: 0,
        totalPages: 0,
      },
    };
    const req = createRequest({
      storeContext: {
        storeId: 'store-1',
        role: 'owner',
      },
    });
    const res = createResponse<ListProductByKeywordResponseDto>({
      validatedQuery: {
        keyword: 'milk',
        page: 1,
        limit: 50,
      },
    });

    searchService.searchProductsByKeyword.mockResolvedValue(payload);

    await searchController.getProductsbyKeyword(req, res);

    expect(searchService.searchProductsByKeyword).toHaveBeenCalledWith(
      'store-1',
      {
        keyword: 'milk',
        page: 1,
        limit: 50,
      },
    );
    expect(res.status).toHaveBeenCalledWith(StatusCodes.OK);
  });

  it('returns product prefix search results for the current store', async () => {
    const payload: SearchProductPrefixResponseDto[] = [
      {
        productId: 'product-1',
        name: 'Milk',
        brand: 'Dairy Co',
        imageUrl: 'signed:products/milk.png',
      },
    ];
    const req = createRequest({
      storeContext: {
        storeId: 'store-1',
        role: 'owner',
      },
    });
    const res = createResponse<SearchProductPrefixResponseDto[]>({
      validatedQuery: {
        prefix: 'Mi',
        limit: 5,
      },
    });

    searchService.searchProductsByPrefix.mockResolvedValue(payload);

    await searchController.getProductsByPrefix(req, res);

    expect(searchService.searchProductsByPrefix).toHaveBeenCalledWith(
      'store-1',
      {
        prefix: 'Mi',
        limit: 5,
      },
    );
    expect(res.status).toHaveBeenCalledWith(StatusCodes.OK);
    expect(res.json).toHaveBeenCalledWith({
      success: true,
      data: payload,
    });
  });

  it('throws when store context is missing', async () => {
    const req = createRequest({});
    const res = createResponse<ListProductByKeywordResponseDto>({
      validatedQuery: {
        keyword: 'milk',
      },
    });

    await expect(
      searchController.getProductsbyKeyword(req, res),
    ).rejects.toThrow('Cannot get store ID');
    expect(searchService.searchProductsByKeyword).not.toHaveBeenCalled();
  });
});
