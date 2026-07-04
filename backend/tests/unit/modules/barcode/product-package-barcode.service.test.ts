import { StatusCodes } from 'http-status-codes';
import { beforeEach, describe, expect, it, vi } from 'vitest';

import { ProductPackageBarcodeService } from '../../../../src/modules/barcode/services/product-package-barcode.service.js';

const productPackage = {
  productPackageId: 'package-1',
  displayName: 'Cola 330ml',
  variant: '330ml',
  importPrice: 7000,
  sellingPrice: 10000,
  unitId: 'unit-1',
  productId: 'product-1',
};

const createRepositories = () => ({
  packageBarcodeRepository: {
    checkOneExistedInStore: vi.fn(),
    createMapping: vi.fn(),
    deleteByBarcodeAndProductPackageId: vi.fn(),
  },
  productPackageRepository: {
    findOne: vi.fn(),
  },
});

describe('ProductPackageBarcodeService', () => {
  let repositories: ReturnType<typeof createRepositories>;
  let service: ProductPackageBarcodeService;

  beforeEach(() => {
    repositories = createRepositories();
    repositories.productPackageRepository.findOne.mockResolvedValue(
      productPackage,
    );
    service = new ProductPackageBarcodeService(
      repositories.packageBarcodeRepository as never,
      repositories.productPackageRepository as never,
    );
  });

  it('creates a verified mapping for an active package', async () => {
    repositories.packageBarcodeRepository.checkOneExistedInStore.mockResolvedValue(
      null,
    );
    repositories.packageBarcodeRepository.createMapping.mockResolvedValue({
      barcode: '123456789012',
      type: 'ean',
      source: 'barcode_flow_create',
      confidence: 100,
      isVerified: true,
      productPackage,
    });

    const result = await service.createPackageBarcodeMapping({
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
      source: 'barcode_flow_create',
      confidence: 100,
      isVerified: true,
      type: 'ean',
    });
    expect(result.productPackage).toEqual(productPackage);
  });

  it('returns the existing mapping when creation is idempotent', async () => {
    repositories.packageBarcodeRepository.checkOneExistedInStore.mockResolvedValue({
      barcode: '123456789012',
      productPackageId: 'package-1',
      type: null,
      source: 'user_confirmed',
      confidence: 100,
      isVerified: true,
    });

    const result = await service.createPackageBarcodeMapping({
      storeId: 'store-1',
      productPackageId: 'package-1',
      barcode: '123456789012',
    });

    expect(repositories.packageBarcodeRepository.createMapping).not.toHaveBeenCalled();
    expect(result).toEqual({
      barcode: '123456789012',
      type: null,
      source: 'user_confirmed',
      confidence: 100,
      isVerified: true,
      productPackage,
    });
  });

  it('rejects missing packages and cross-package duplicate mappings', async () => {
    repositories.productPackageRepository.findOne.mockResolvedValueOnce(null);

    await expect(
      service.createPackageBarcodeMapping({
        storeId: 'store-1',
        productPackageId: 'missing',
        barcode: '123456789012',
      }),
    ).rejects.toMatchObject({
      status: StatusCodes.NOT_FOUND,
      message: 'Product package not found',
    });

    repositories.productPackageRepository.findOne.mockResolvedValueOnce(
      productPackage,
    );
    repositories.packageBarcodeRepository.checkOneExistedInStore.mockResolvedValueOnce({
      barcode: '123456789012',
      productPackageId: 'other-package',
    });

    await expect(
      service.createPackageBarcodeMapping({
        storeId: 'store-1',
        productPackageId: 'package-1',
        barcode: '123456789012',
      }),
    ).rejects.toMatchObject({
      status: StatusCodes.CONFLICT,
      message: 'Barcode mapping already exists in the store',
    });
  });

  it('removes an owned mapping', async () => {
    repositories.packageBarcodeRepository.checkOneExistedInStore.mockResolvedValue({
      barcode: '123456789012',
      productPackageId: 'package-1',
    });

    await service.removePackageBarcodeMapping({
      storeId: 'store-1',
      productPackageId: 'package-1',
      barcode: ' 123456789012 ',
    });

    expect(
      repositories.packageBarcodeRepository.deleteByBarcodeAndProductPackageId,
    ).toHaveBeenCalledWith('123456789012', 'package-1');
  });

  it('rejects remove when mapping is missing or belongs to another package', async () => {
    repositories.packageBarcodeRepository.checkOneExistedInStore.mockResolvedValueOnce(
      null,
    );

    await expect(
      service.removePackageBarcodeMapping({
        storeId: 'store-1',
        productPackageId: 'package-1',
        barcode: '123456789012',
      }),
    ).rejects.toMatchObject({
      status: StatusCodes.NOT_FOUND,
      message: 'Barcode mapping not found',
    });

    repositories.packageBarcodeRepository.checkOneExistedInStore.mockResolvedValueOnce({
      barcode: '123456789012',
      productPackageId: 'other-package',
    });

    await expect(
      service.removePackageBarcodeMapping({
        storeId: 'store-1',
        productPackageId: 'package-1',
        barcode: '123456789012',
      }),
    ).rejects.toMatchObject({
      status: StatusCodes.CONFLICT,
      message: 'Barcode does not belong to this product package',
    });
  });
});
