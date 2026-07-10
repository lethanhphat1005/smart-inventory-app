import { beforeEach, describe, expect, it, vi } from 'vitest';

import { ProductSearchHelper } from '../../../../src/modules/chat-bot/services/helpers/product-search.helper.js';

type MockInventoryService = {
  getInventoriesByStoreId: ReturnType<typeof vi.fn>;
};

describe('ProductSearchHelper', () => {
  let inventoryService: MockInventoryService;

  beforeEach(() => {
    inventoryService = {
      getInventoriesByStoreId: vi.fn(),
    };
  });

  it('cleans package words and slang before searching inventory', async () => {
    inventoryService.getInventoriesByStoreId.mockResolvedValue({
      items: [{ inventoryId: 'inv-1' }],
    });

    const result = await ProductSearchHelper.searchInventory(
      inventoryService as never,
      'store-1',
      'thung bo huc',
    );

    expect(result).toEqual([{ inventoryId: 'inv-1' }]);
    expect(inventoryService.getInventoriesByStoreId).toHaveBeenCalledWith(
      'store-1',
      expect.objectContaining({
        keyword: 'thung bo huc',
        limit: 5,
        page: 1,
      }),
    );
  });

  it('falls back to parenthesis-stripped and normalized keywords', async () => {
    const searchedKeywords: unknown[] = [];

    inventoryService.getInventoriesByStoreId.mockImplementation(
      (_storeId: string, query: { keyword?: string }) => {
        searchedKeywords.push(query.keyword);

        return {
          items:
            searchedKeywords.length === 3 ? [{ inventoryId: 'inv-2' }] : [],
        };
      },
    );

    const result = await ProductSearchHelper.searchInventory(
      inventoryService as never,
      'store-1',
      'Milk (Box)',
    );

    expect(result).toEqual([{ inventoryId: 'inv-2' }]);
    expect(searchedKeywords).toEqual(['milk ()', 'Milk', 'milkbox']);
  });
});
