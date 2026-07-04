import axios from 'axios';
import { beforeEach, describe, expect, it, vi } from 'vitest';

import { BarcodeProviderService } from '../../../../src/modules/barcode/services/barcode-provider.service.js';

vi.mock('axios', () => ({
  default: {
    get: vi.fn(),
  },
}));

const mockedAxios = vi.mocked(axios);

describe('BarcodeProviderService', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it('returns the first valid OpenFoodFacts result with normalized and extracted fields', async () => {
    mockedAxios.get.mockResolvedValueOnce({
      data: {
        status: 1,
        status_verbose: 'product found',
        product: {
          product_name_vi: 'Nuoc ngot Cola',
          product_name: 'Cola Drink',
          brands: 'Cola Co',
          quantity: '330 ml',
        },
      },
    });

    const service = new BarcodeProviderService();
    const result = await service.lookupBarcode({
      barcode: '123456789012',
      type: 'ean',
    });

    expect(mockedAxios.get).toHaveBeenCalledWith(
      expect.stringContaining('/123456789012.json'),
      { timeout: 5000 },
    );
    expect(result).toMatchObject({
      status: 'valid',
      provider: 'openfoodfacts',
      type: 'ean',
      normalizedName: 'cola drink',
      normalizedBrand: 'cola co',
      normalizedPackageText: '330 ml',
      extractedName: 'Nuoc ngot Cola',
      extractedBrand: 'Cola Co',
      extractedPackageText: '330 ml',
    });
  });

  it('falls through to UPCItemDB when OpenFoodFacts is not found', async () => {
    mockedAxios.get
      .mockResolvedValueOnce({
        data: {
          status: 0,
          status_verbose: 'product not found',
          product: {},
        },
      })
      .mockResolvedValueOnce({
        data: {
          total: 1,
          items: [
            {
              title: 'Cola Drink 330ml',
              brand: 'Cola Co (Imported)',
              size: '330ml',
              offers: [{ title: 'Cola Drink case of 24' }],
            },
          ],
        },
      });

    const service = new BarcodeProviderService();
    const result = await service.lookupBarcode({
      barcode: '123456789012',
    });

    expect(mockedAxios.get).toHaveBeenCalledTimes(2);
    expect(mockedAxios.get).toHaveBeenLastCalledWith(
      expect.stringContaining('upcitemdb'),
      {
        params: {
          upc: '123456789012',
        },
        timeout: 3000,
      },
    );
    expect(result).toMatchObject({
      status: 'valid',
      provider: 'upcitemdb',
      normalizedName: 'cola drink cola drink',
      normalizedBrand: 'cola co',
      normalizedPackageText: '330ml 330ml',
      extractedName: 'Cola Drink Cola Drink',
      extractedBrand: 'Cola Co',
      extractedPackageText: '330ml 330ml',
    });
  });

  it('returns not_found when providers fail or have no items', async () => {
    mockedAxios.get
      .mockRejectedValueOnce(new Error('openfoodfacts failed'))
      .mockResolvedValueOnce({
        data: {
          total: 0,
          items: [],
        },
      });

    const service = new BarcodeProviderService();
    const result = await service.lookupBarcode({
      barcode: '123456789012',
      type: 'upc',
    });

    expect(result).toEqual({
      rawPayload: null,
      status: 'not_found',
      type: 'upc',
    });
  });
});
