import { StatusCodes } from 'http-status-codes';
import { beforeEach, describe, expect, it, vi } from 'vitest';

import { BarcodesController } from '../../../../src/modules/barcode/controllers/barcodes.controller.js';
import { ProductPackageBarcodeController } from '../../../../src/modules/barcode/controllers/product-package-barcode.controller.js';
import { createRequest, createResponse } from '../../../helpers/index.js';

const productPackage = {
  productPackageId: 'package-1',
  displayName: 'Cola 330ml',
  variant: '330ml',
  importPrice: 7000,
  sellingPrice: 10000,
  unitId: 'unit-1',
  productId: 'product-1',
};

describe('BarcodesController', () => {
  const service = {
    scanBarcode: vi.fn(),
    confirmBarcodeMapping: vi.fn(),
  };
  let controller: BarcodesController;

  beforeEach(() => {
    vi.clearAllMocks();
    controller = new BarcodesController(service as never);
  });

  it('scans a barcode for the current store and maps candidate DTOs', async () => {
    service.scanBarcode.mockResolvedValue({
      resolutionType: 'candidate_match',
      candidates: [
        {
          productPackageId: 'package-1',
          score: 100,
          scoreDetail: {},
          productPackage,
        },
      ],
      prefill: {
        name: 'Cola',
      },
    });
    const req = createRequest({
      storeContext: { storeId: 'store-1', role: 'owner' },
      body: {
        barcode: '123456789012',
        type: 'ean',
      },
    });
    const res = createResponse();

    await controller.scanBarcode(req, res);

    expect(service.scanBarcode).toHaveBeenCalledWith({
      storeId: 'store-1',
      barcode: '123456789012',
      type: 'ean',
    });
    expect(res.status).toHaveBeenCalledWith(StatusCodes.OK);
    expect(res.json).toHaveBeenCalledWith({
      success: true,
      data: {
        resolutionType: 'candidate_match',
        candidates: [productPackage],
        prefill: {
          name: 'Cola',
        },
      },
    });
  });

  it('maps exact and not-found scan results', async () => {
    const req = createRequest({
      storeContext: { storeId: 'store-1', role: 'owner' },
      body: {
        barcode: '123456789012',
      },
    });
    const res = createResponse();

    service.scanBarcode.mockResolvedValueOnce({
      resolutionType: 'exact_match',
      productPackage,
    });

    await controller.scanBarcode(req, res);

    expect(res.json).toHaveBeenLastCalledWith({
      success: true,
      data: {
        resolutionType: 'exact_match',
        productPackage,
      },
    });

    service.scanBarcode.mockResolvedValueOnce({
      resolutionType: 'not_found',
      prefill: {
        brand: 'Cola Co',
      },
    });

    await controller.scanBarcode(req, res);

    expect(res.json).toHaveBeenLastCalledWith({
      success: true,
      data: {
        resolutionType: 'not_found',
        prefill: {
          brand: 'Cola Co',
        },
      },
    });
  });

  it('omits optional prefill for candidate and not-found responses', async () => {
    const req = createRequest({
      storeContext: { storeId: 'store-1', role: 'owner' },
      body: {
        barcode: '123456789012',
      },
    });
    const res = createResponse();

    service.scanBarcode.mockResolvedValueOnce({
      resolutionType: 'candidate_match',
      candidates: [
        {
          productPackageId: 'package-1',
          score: 90,
          scoreDetail: {},
          productPackage,
        },
      ],
    });

    await controller.scanBarcode(req, res);

    expect(res.json).toHaveBeenLastCalledWith({
      success: true,
      data: {
        resolutionType: 'candidate_match',
        candidates: [productPackage],
      },
    });

    service.scanBarcode.mockResolvedValueOnce({
      resolutionType: 'not_found',
    });

    await controller.scanBarcode(req, res);

    expect(res.json).toHaveBeenLastCalledWith({
      success: true,
      data: {
        resolutionType: 'not_found',
      },
    });
  });

  it('confirms a barcode mapping and returns created status', async () => {
    const mapping = {
      barcode: '123456789012',
      type: 'ean',
      source: 'user_confirmed',
      confidence: 100,
      isVerified: true,
      productPackage,
    };
    service.confirmBarcodeMapping.mockResolvedValue(mapping);
    const req = createRequest({
      storeContext: { storeId: 'store-1', role: 'owner' },
      body: {
        barcode: '123456789012',
        productPackageId: 'package-1',
        type: 'ean',
      },
    });
    const res = createResponse();

    await controller.confirmBarcodeMapping(req, res);

    expect(service.confirmBarcodeMapping).toHaveBeenCalledWith({
      storeId: 'store-1',
      barcode: '123456789012',
      productPackageId: 'package-1',
      type: 'ean',
    });
    expect(res.status).toHaveBeenCalledWith(StatusCodes.CREATED);
    expect(res.json).toHaveBeenCalledWith({
      success: true,
      data: mapping,
    });
  });
});

describe('ProductPackageBarcodeController', () => {
  const service = {
    createPackageBarcodeMapping: vi.fn(),
    removePackageBarcodeMapping: vi.fn(),
  };
  let controller: ProductPackageBarcodeController;

  beforeEach(() => {
    vi.clearAllMocks();
    controller = new ProductPackageBarcodeController(service as never);
  });

  it('creates a package barcode mapping from params and body', async () => {
    const mapping = {
      barcode: '123456789012',
      type: null,
      source: 'barcode_flow_create',
      confidence: 100,
      isVerified: true,
      productPackage,
    };
    service.createPackageBarcodeMapping.mockResolvedValue(mapping);
    const req = createRequest({
      storeContext: { storeId: 'store-1', role: 'owner' },
      params: { productPackageId: 'package-1' },
      body: { barcode: '123456789012' },
    });
    const res = createResponse();

    await controller.createPackageBarcode(req, res);

    expect(service.createPackageBarcodeMapping).toHaveBeenCalledWith({
      storeId: 'store-1',
      productPackageId: 'package-1',
      barcode: '123456789012',
    });
    expect(res.status).toHaveBeenCalledWith(StatusCodes.CREATED);
    expect(res.json).toHaveBeenCalledWith({
      success: true,
      data: mapping,
    });
  });

  it('deletes a package barcode mapping from params', async () => {
    const req = createRequest({
      storeContext: { storeId: 'store-1', role: 'owner' },
      params: {
        productPackageId: 'package-1',
        barcode: '123456789012',
      },
    });
    const res = createResponse();

    await controller.deletePackageBarcode(req, res);

    expect(service.removePackageBarcodeMapping).toHaveBeenCalledWith({
      storeId: 'store-1',
      productPackageId: 'package-1',
      barcode: '123456789012',
    });
    expect(res.status).toHaveBeenCalledWith(StatusCodes.OK);
    expect(res.json).toHaveBeenCalledWith({
      success: true,
      data: null,
    });
  });
});
