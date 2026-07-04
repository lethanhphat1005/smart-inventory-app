import { StatusCodes } from 'http-status-codes';
import { beforeEach, describe, expect, it, vi } from 'vitest';

import { BarcodesService } from '../../../../src/modules/barcode/services/barcodes.service.js';

const productPackage = {
  productPackageId: 'package-1',
  displayName: 'Coca Cola 330ml',
  variant: '330ml',
  importPrice: 7000,
  sellingPrice: 10000,
  unitId: 'unit-1',
  productId: 'product-1',
};

const candidateRecord = {
  productName: 'Coca Cola',
  brand: 'Coca Cola',
  productPackage,
};

const cacheRecord = (overrides: Record<string, unknown> = {}) => ({
  barcodeCacheId: 'cache-1',
  barcode: '123456789012',
  payload: { rawPayload: null },
  status: 'valid',
  provider: 'provider',
  type: 'ean',
  normalizedName: 'coca cola',
  normalizedBrand: 'coca cola',
  normalizedPackageText: '330ml',
  extractedName: 'Coca Cola',
  extractedBrand: 'Coca Cola',
  extractedPackageText: '330ml',
  fetchedAt: new Date(),
  lastUsedAt: null,
  hitCount: 0,
  createdAt: new Date(),
  updatedAt: new Date(),
  ...overrides,
});

const createRepositories = () => ({
  packageBarcodeRepository: {
    findByBarcode: vi.fn(),
    checkOneExistedInStore: vi.fn(),
    createMapping: vi.fn(),
  },
  barcodeApiCacheRepository: {
    findOneByBarcode: vi.fn(),
    markAsUsed: vi.fn(),
    createOne: vi.fn(),
    updateOne: vi.fn(),
  },
  productPackageRepository: {
    findBarcodeCandidates: vi.fn(),
    findOne: vi.fn(),
  },
  barcodeProviderService: {
    lookupBarcode: vi.fn(),
  },
});

describe('BarcodesService', () => {
  let repositories: ReturnType<typeof createRepositories>;
  let service: BarcodesService;

  beforeEach(() => {
    vi.clearAllMocks();
    repositories = createRepositories();
    repositories.packageBarcodeRepository.findByBarcode.mockResolvedValue(null);
    repositories.barcodeApiCacheRepository.findOneByBarcode.mockResolvedValue(
      null,
    );
    repositories.productPackageRepository.findBarcodeCandidates.mockResolvedValue(
      [],
    );
    repositories.productPackageRepository.findOne.mockResolvedValue(
      productPackage,
    );
    repositories.barcodeProviderService.lookupBarcode.mockResolvedValue({
      rawPayload: { product: true },
      status: 'valid',
      provider: 'provider',
      type: 'ean',
      normalizedName: 'coca cola',
      normalizedBrand: 'coca cola',
      normalizedPackageText: '330ml',
      extractedName: 'Coca Cola',
      extractedBrand: 'Coca Cola',
      extractedPackageText: '330ml',
    });

    service = new BarcodesService(
      repositories.packageBarcodeRepository as never,
      repositories.barcodeApiCacheRepository as never,
      repositories.productPackageRepository as never,
      repositories.barcodeProviderService as never,
    );
  });

  it('uses verified exact mapping before cache or provider lookup', async () => {
    repositories.packageBarcodeRepository.findByBarcode.mockResolvedValue({
      barcode: '123456789012',
      isVerified: true,
      productPackage,
    });

    const result = await service.scanBarcode({
      storeId: 'store-1',
      barcode: ' 123456789012 ',
    });

    expect(result).toEqual({
      resolutionType: 'exact_match',
      productPackage,
    });
    expect(repositories.barcodeApiCacheRepository.findOneByBarcode).not.toHaveBeenCalled();
  });

  it('returns scored candidates and prefill from fresh cache', async () => {
    repositories.barcodeApiCacheRepository.findOneByBarcode.mockResolvedValue(
      cacheRecord(),
    );
    repositories.productPackageRepository.findBarcodeCandidates.mockResolvedValue([
      candidateRecord,
    ]);

    const result = await service.scanBarcode({
      storeId: 'store-1',
      barcode: '123456789012',
      type: 'ean',
    });

    expect(repositories.barcodeApiCacheRepository.markAsUsed).toHaveBeenCalledWith(
      'cache-1',
    );
    expect(repositories.barcodeProviderService.lookupBarcode).not.toHaveBeenCalled();
    expect(result).toMatchObject({
      resolutionType: 'candidate_match',
      prefill: {
        name: 'Coca Cola',
        brand: 'Coca Cola',
        packageText: '330ml',
      },
    });
    expect(
      result.resolutionType === 'candidate_match' && result.candidates[0],
    ).toMatchObject({
      productPackageId: 'package-1',
      productPackage,
    });
  });

  it('creates cache from provider result and returns not found with prefill when no candidate scores', async () => {
    const result = await service.scanBarcode({
      storeId: 'store-1',
      barcode: '123456789012',
      type: 'ean',
    });

    expect(repositories.barcodeApiCacheRepository.createOne).toHaveBeenCalledWith(
      expect.objectContaining({
        barcode: '123456789012',
        status: 'valid',
        provider: 'provider',
        type: 'ean',
        normalizedName: 'coca cola',
      }),
    );
    expect(result).toEqual({
      resolutionType: 'not_found',
      prefill: {
        name: 'Coca Cola',
        brand: 'Coca Cola',
        packageText: '330ml',
      },
    });
  });

  it('updates expired cache and falls back to stale cache when provider fails', async () => {
    const oldCache = cacheRecord({
      barcodeCacheId: 'cache-old',
      fetchedAt: new Date(Date.now() - 1000 * 60 * 60 * 24 * 60),
    });

    repositories.barcodeApiCacheRepository.findOneByBarcode.mockResolvedValueOnce(
      oldCache,
    );
    repositories.barcodeProviderService.lookupBarcode.mockResolvedValueOnce({
      rawPayload: null,
      status: 'not_found',
    });

    await service.scanBarcode({
      storeId: 'store-1',
      barcode: '123456789012',
    });

    expect(repositories.barcodeApiCacheRepository.updateOne).toHaveBeenCalledWith(
      'cache-old',
      expect.objectContaining({
        barcode: '123456789012',
        status: 'not_found',
      }),
    );

    repositories.barcodeApiCacheRepository.findOneByBarcode.mockResolvedValueOnce(
      oldCache,
    );
    repositories.barcodeProviderService.lookupBarcode.mockRejectedValueOnce(
      new Error('network failed'),
    );

    const result = await service.scanBarcode({
      storeId: 'store-1',
      barcode: '123456789012',
    });

    expect(result).toMatchObject({
      resolutionType: 'not_found',
      prefill: {
        name: 'Coca Cola',
      },
    });
  });

  it('throws a bad gateway error when provider lookup fails without cache', async () => {
    repositories.barcodeProviderService.lookupBarcode.mockRejectedValueOnce(
      new Error('network failed'),
    );

    await expect(
      service.scanBarcode({
        storeId: 'store-1',
        barcode: '123456789012',
      }),
    ).rejects.toMatchObject({
      status: StatusCodes.BAD_GATEWAY,
      message: 'Failed to lookup barcode from provider',
    });
  });

  it('scores candidates using name, brand, and package signals', () => {
    const result = service.scoreCandidate({
      normalizedData: {
        normalizedName: 'coca cola',
        normalizedBrand: 'coca cola',
        normalizedPackageText: '330ml',
      },
      candidate: candidateRecord as never,
    });

    expect(result).toMatchObject({
      productPackageId: 'package-1',
      score: 100,
      scoreDetail: {
        isBrandMatch: true,
        isNameMatch: true,
        isPackageTextMatch: true,
      },
    });
  });

  it('scores candidates with name-only and single auxiliary signal thresholds', () => {
    const nameOnlyResult = service.scoreCandidate({
      normalizedData: {
        normalizedName: 'coca cola',
      },
      candidate: {
        ...candidateRecord,
        brand: null,
        productPackage: {
          ...productPackage,
          variant: null,
        },
      } as never,
    });
    const packageSignalResult = service.scoreCandidate({
      normalizedData: {
        normalizedName: 'coca cola',
        normalizedPackageText: '330ml',
      },
      candidate: {
        ...candidateRecord,
        brand: null,
      } as never,
    });

    expect(nameOnlyResult).toMatchObject({
      scoreDetail: {
        threshold: 35,
        availableSignalCount: 1,
      },
    });
    expect(packageSignalResult).toMatchObject({
      scoreDetail: {
        threshold: 50,
        availableSignalCount: 2,
      },
    });
  });

  it('sorts multiple candidate matches by score', async () => {
    repositories.barcodeApiCacheRepository.findOneByBarcode.mockResolvedValue(
      cacheRecord({
        normalizedName: 'coca cola classic',
        normalizedBrand: null,
        normalizedPackageText: null,
        extractedBrand: null,
        extractedPackageText: null,
      }),
    );
    repositories.productPackageRepository.findBarcodeCandidates.mockResolvedValue([
      {
        productName: 'Coca',
        brand: null,
        productPackage: {
          ...productPackage,
          productPackageId: 'package-low',
          displayName: 'Coca Cola',
          variant: null,
        },
      },
      {
        productName: 'Coca Cola Classic',
        brand: null,
        productPackage: {
          ...productPackage,
          productPackageId: 'package-high',
          displayName: 'Coca Cola Classic',
          variant: null,
        },
      },
    ]);

    const result = await service.scanBarcode({
      storeId: 'store-1',
      barcode: '123456789012',
    });

    expect(result).toMatchObject({
      resolutionType: 'candidate_match',
      candidates: [
        { productPackageId: 'package-high' },
        { productPackageId: 'package-low' },
      ],
    });
  });

  it('rejects low scoring candidates', () => {
    const result = service.scoreCandidate({
      normalizedData: {
        normalizedName: 'orange juice',
        normalizedBrand: 'fresh brand',
        normalizedPackageText: '1l',
      },
      candidate: candidateRecord as never,
    });

    expect(result).toBeNull();
  });

  it('uses cache TTL by status', () => {
    expect(
      service.shouldUseCache(
        cacheRecord({
          status: 'not_found',
          fetchedAt: new Date(Date.now() - 1000 * 60 * 60 * 24 * 8),
        }) as never,
      ),
    ).toBe(false);
    expect(
      service.shouldUseCache(
        cacheRecord({
          status: 'invalid',
          fetchedAt: new Date(),
        }) as never,
      ),
    ).toBe(true);
  });

  it('confirms a new verified mapping for an active product package', async () => {
    repositories.packageBarcodeRepository.checkOneExistedInStore.mockResolvedValue(
      null,
    );
    repositories.packageBarcodeRepository.createMapping.mockResolvedValue({
      barcode: '123456789012',
      type: 'ean',
      source: 'user_confirmed',
      confidence: 100,
      isVerified: true,
      productPackage,
    });

    const result = await service.confirmBarcodeMapping({
      storeId: 'store-1',
      productPackageId: 'package-1',
      barcode: ' 123456789012 ',
      type: 'ean',
    });

    expect(repositories.productPackageRepository.findOne).toHaveBeenCalledWith(
      'store-1',
      'package-1',
    );
    expect(repositories.packageBarcodeRepository.createMapping).toHaveBeenCalledWith({
      barcode: '123456789012',
      productPackageId: 'package-1',
      source: 'user_confirmed',
      confidence: 100,
      isVerified: true,
      type: 'ean',
    });
    expect(result.productPackage).toEqual(productPackage);
  });

  it('keeps confirm idempotent for the same package and rejects conflicts', async () => {
    repositories.packageBarcodeRepository.checkOneExistedInStore.mockResolvedValueOnce({
      barcode: '123456789012',
      productPackageId: 'package-1',
      type: null,
      source: 'user_confirmed',
      confidence: 100,
      isVerified: true,
    });

    await expect(
      service.confirmBarcodeMapping({
        storeId: 'store-1',
        productPackageId: 'package-1',
        barcode: '123456789012',
      }),
    ).resolves.toMatchObject({
      barcode: '123456789012',
      productPackage,
    });

    repositories.packageBarcodeRepository.checkOneExistedInStore.mockResolvedValueOnce({
      barcode: '123456789012',
      productPackageId: 'other-package',
    });

    await expect(
      service.confirmBarcodeMapping({
        storeId: 'store-1',
        productPackageId: 'package-1',
        barcode: '123456789012',
      }),
    ).rejects.toMatchObject({
      status: StatusCodes.CONFLICT,
      message: 'Barcode mapping already exists in the store',
    });
  });

  it('rejects confirm when product package is not active in the store', async () => {
    repositories.productPackageRepository.findOne.mockResolvedValue(null);

    await expect(
      service.confirmBarcodeMapping({
        storeId: 'store-1',
        productPackageId: 'missing',
        barcode: '123456789012',
      }),
    ).rejects.toMatchObject({
      status: StatusCodes.NOT_FOUND,
      message: 'Product package not found',
    });
  });
});
