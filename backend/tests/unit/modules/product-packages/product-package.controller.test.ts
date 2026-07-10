import { StatusCodes } from 'http-status-codes';
import { beforeEach, describe, expect, it, vi } from 'vitest';

import { ProductPackageController } from '../../../../src/modules/product-packages/controllers/product-package.controller.js';
import { UnitController } from '../../../../src/modules/product-packages/controllers/unit.controller.js';
import { createRequest, createResponse } from '../../../helpers/index.js';

vi.mock(
  '../../../../src/modules/product-packages/services/product-package.service.js',
  () => ({
    ProductPackageService: class MockProductPackageService {},
  }),
);

type MockProductPackageService = {
  getProductPackagesByStore: ReturnType<typeof vi.fn>;
  getProductPackagesByProductId: ReturnType<typeof vi.fn>;
  getProductPackageById: ReturnType<typeof vi.fn>;
  createProductPackageAndInventory: ReturnType<typeof vi.fn>;
  updateProductPackage: ReturnType<typeof vi.fn>;
  softDeleteProductPackage: ReturnType<typeof vi.fn>;
};

const packageFixture = () => ({
  productPackageId: 'package-1',
  displayName: 'Milk bottle',
  variant: 'bottle',
  importPrice: 1000,
  sellingPrice: 1500,
  unitId: 'unit-1',
  productId: 'product-1',
});

const createService = (): MockProductPackageService => ({
  getProductPackagesByStore: vi.fn(),
  getProductPackagesByProductId: vi.fn(),
  getProductPackageById: vi.fn(),
  createProductPackageAndInventory: vi.fn(),
  updateProductPackage: vi.fn(),
  softDeleteProductPackage: vi.fn(),
});

describe('ProductPackageController', () => {
  let service: MockProductPackageService;
  let controller: ProductPackageController;

  beforeEach(() => {
    service = createService();
    controller = new ProductPackageController(service as never);
  });

  it('returns store packages using the validated query from locals', async () => {
    const payload = {
      items: [packageFixture()],
      meta: {
        page: 1,
        limit: 50,
        totalItems: 1,
        totalPages: 1,
      },
    };
    const req = createRequest({
      storeContext: {
        storeId: 'store-1',
        role: 'owner',
      },
    });
    const res = createResponse({
      validatedQuery: {
        page: 1,
        limit: 50,
        sortBy: 'displayName',
        sortOrder: 'asc',
      },
    });

    service.getProductPackagesByStore.mockResolvedValue(payload);

    await controller.getProductPackagesByStore(req, res);

    expect(service.getProductPackagesByStore).toHaveBeenCalledWith('store-1', {
      page: 1,
      limit: 50,
      sortBy: 'displayName',
      sortOrder: 'asc',
    });
    expect(res.status).toHaveBeenCalledWith(StatusCodes.OK);
    expect(res.json).toHaveBeenCalledWith({
      success: true,
      data: payload,
    });
  });

  it('returns packages for a product path id', async () => {
    const req = createRequest({
      storeContext: {
        storeId: 'store-1',
        role: 'owner',
      },
      params: {
        productId: 'product-1',
      },
    });
    const res = createResponse();

    service.getProductPackagesByProductId.mockResolvedValue([packageFixture()]);

    await controller.getProductPackagesByProductId(req, res);

    expect(service.getProductPackagesByProductId).toHaveBeenCalledWith(
      'store-1',
      'product-1',
    );
    expect(res.status).toHaveBeenCalledWith(StatusCodes.OK);
  });

  it('returns package detail by path id', async () => {
    const req = createRequest({
      storeContext: {
        storeId: 'store-1',
        role: 'owner',
      },
      params: {
        productPackageId: 'package-1',
      },
    });
    const res = createResponse();

    service.getProductPackageById.mockResolvedValue(packageFixture());

    await controller.getProductPackageById(req, res);

    expect(service.getProductPackageById).toHaveBeenCalledWith(
      'store-1',
      'package-1',
    );
    expect(res.status).toHaveBeenCalledWith(StatusCodes.OK);
  });

  it('creates packages for the current store, user, and product', async () => {
    const body = [
      {
        package: { unitId: 'unit-1' },
        inventory: { quantity: 1 },
      },
    ];
    const req = createRequest({
      user: {
        userId: 'user-1',
        authUserId: 'auth-user-1',
        email: null,
      },
      storeContext: {
        storeId: 'store-1',
        role: 'owner',
      },
      params: {
        productId: 'product-1',
      },
      body,
    });
    const res = createResponse();

    service.createProductPackageAndInventory.mockResolvedValue([
      packageFixture(),
    ]);

    await controller.createProductPackage(req, res);

    expect(service.createProductPackageAndInventory).toHaveBeenCalledWith(
      'store-1',
      'user-1',
      'product-1',
      body,
    );
    expect(res.status).toHaveBeenCalledWith(StatusCodes.CREATED);
  });

  it('updates and soft deletes a package by path id', async () => {
    const updateReq = createRequest({
      user: {
        userId: 'user-1',
        authUserId: 'auth-user-1',
        email: null,
      },
      storeContext: {
        storeId: 'store-1',
        role: 'owner',
      },
      params: {
        productPackageId: 'package-1',
      },
      body: {
        sellingPrice: 1800,
      },
    });
    const deleteReq = createRequest({
      user: {
        userId: 'user-1',
        authUserId: 'auth-user-1',
        email: null,
      },
      storeContext: {
        storeId: 'store-1',
        role: 'owner',
      },
      params: {
        productPackageId: 'package-1',
      },
    });
    const updateRes = createResponse();
    const deleteRes = createResponse();

    service.updateProductPackage.mockResolvedValue(packageFixture());
    service.softDeleteProductPackage.mockResolvedValue(undefined);

    await controller.updateProductPackage(updateReq, updateRes);
    await controller.softDeleteProductPackage(deleteReq, deleteRes);

    expect(service.updateProductPackage).toHaveBeenCalledWith(
      'store-1',
      'user-1',
      'package-1',
      { sellingPrice: 1800 },
    );
    expect(service.softDeleteProductPackage).toHaveBeenCalledWith(
      'store-1',
      'user-1',
      'package-1',
    );
    expect(updateRes.status).toHaveBeenCalledWith(StatusCodes.OK);
    expect(deleteRes.json).toHaveBeenCalledWith({
      success: true,
      data: null,
    });
  });
});

describe('UnitController', () => {
  it('returns all units', async () => {
    const unitService = {
      getAllUnits: vi.fn().mockResolvedValue([
        {
          unitId: 'unit-1',
          code: 'PCS',
          name: 'piece',
        },
      ]),
    };
    const controller = new UnitController(unitService as never);
    const res = createResponse();

    await controller.getUnits(createRequest({}), res);

    expect(unitService.getAllUnits).toHaveBeenCalledTimes(1);
    expect(res.status).toHaveBeenCalledWith(StatusCodes.OK);
    expect(res.json).toHaveBeenCalledWith({
      success: true,
      data: [
        {
          unitId: 'unit-1',
          code: 'PCS',
          name: 'piece',
        },
      ],
    });
  });
});
