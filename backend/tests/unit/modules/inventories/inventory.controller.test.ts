import { StatusCodes } from 'http-status-codes';
import { beforeEach, describe, expect, it, vi } from 'vitest';

import { InventoryController } from '../../../../src/modules/inventories/controller/inventory.controller.js';
import {
  createRequest,
  createResponse,
} from '../../../helpers/create-request-response.util.js';

const date = new Date('2026-01-01T00:00:00.000Z');

const inventory = {
  inventoryId: 'inventory-1',
  quantity: 10,
  reorderThreshold: 5,
  updatedAt: date,
  inventoryStatus: 'inStock',
  productPackage: {
    productPackageId: 'package-1',
    displayName: 'Milk 1L',
    variant: '1L',
    importPrice: 12000,
    sellingPrice: 15000,
    unit: { unitId: 'unit-1', code: 'btl', name: 'Bottle' },
    product: {
      productId: 'product-1',
      name: 'Milk',
      imageUrl: 'products/milk.png',
      brand: 'Dairy Co',
      category: {
        categoryId: 'category-1',
        name: 'Dairy',
        description: null,
      },
    },
  },
};

const createService = () => ({
  getInventoriesByStoreId: vi.fn(),
  getLowStockInventoriesByStoreId: vi.fn(),
  getInventoryByProductPackageId: vi.fn(),
  updateInventory: vi.fn(),
  adjustInventories: vi.fn(),
  createInventory: vi.fn(),
  deleteInventory: vi.fn(),
});

describe('InventoryController', () => {
  let service: ReturnType<typeof createService>;
  let controller: InventoryController;

  beforeEach(() => {
    vi.clearAllMocks();
    service = createService();
    controller = new InventoryController(service as never);
  });

  it('gets inventories using store context and validated query', async () => {
    service.getInventoriesByStoreId.mockResolvedValue({
      items: [inventory],
      meta: { page: 1, limit: 10, totalItems: 1, totalPages: 1 },
    });
    const req = createRequest({
      storeContext: { storeId: 'store-1' },
    } as never);
    const res = createResponse({
      validatedQuery: { page: 1, limit: 10 },
    });

    await controller.getInventories(req, res as never);

    expect(service.getInventoriesByStoreId).toHaveBeenCalledWith('store-1', {
      page: 1,
      limit: 10,
    });
    expect(res.status).toHaveBeenCalledWith(StatusCodes.OK);
  });

  it('gets low stock inventories from validated query', async () => {
    service.getLowStockInventoriesByStoreId.mockResolvedValue({
      items: [inventory],
      meta: { page: 1, limit: 10, totalItems: 1, totalPages: 1 },
    });
    const req = createRequest({
      storeContext: { storeId: 'store-1' },
    } as never);
    const res = createResponse({
      validatedQuery: { inventoryStatus: 'lowStock' },
    });

    await controller.getLowStockInventories(req, res as never);

    expect(service.getLowStockInventoriesByStoreId).toHaveBeenCalledWith(
      'store-1',
      { inventoryStatus: 'lowStock' },
    );
    expect(res.status).toHaveBeenCalledWith(StatusCodes.OK);
  });

  it('gets one inventory by product package id', async () => {
    service.getInventoryByProductPackageId.mockResolvedValue(inventory);
    const req = createRequest({
      storeContext: { storeId: 'store-1' },
      params: { productPackageId: 'package-1' },
    } as never);
    const res = createResponse();

    await controller.getInventoryByProductPackageId(req, res as never);

    expect(service.getInventoryByProductPackageId).toHaveBeenCalledWith(
      'store-1',
      'package-1',
    );
    expect(res.status).toHaveBeenCalledWith(StatusCodes.OK);
  });

  it('updates inventory using store, user, params, and body', async () => {
    service.updateInventory.mockResolvedValue(inventory);
    const req = createRequest({
      storeContext: { storeId: 'store-1' },
      user: { userId: 'user-1' },
      params: { productPackageId: 'package-1' },
      body: { reorderThreshold: 3 },
    } as never);
    const res = createResponse();

    await controller.updateInventory(req, res as never);

    expect(service.updateInventory).toHaveBeenCalledWith(
      'store-1',
      'package-1',
      { reorderThreshold: 3 },
      'user-1',
    );
    expect(res.status).toHaveBeenCalledWith(StatusCodes.OK);
  });

  it('adjusts inventories using store, user, and body', async () => {
    const adjusted = [
      {
        productPackageId: 'package-1',
        previousQuantity: 10,
        currentQuantity: 8,
        changedQuantity: -2,
        adjustmentType: 'decrease',
        reason: 'damaged',
        note: null,
        updatedAt: date,
      },
    ];

    service.adjustInventories.mockResolvedValue(adjusted);
    const req = createRequest({
      storeContext: { storeId: 'store-1' },
      user: { userId: 'user-1' },
      body: { items: [{ productPackageId: 'package-1', quantity: 2 }] },
    } as never);
    const res = createResponse();

    await controller.adjustInventories(req, res as never);

    expect(service.adjustInventories).toHaveBeenCalledWith(
      'store-1',
      'user-1',
      req.body,
    );
    expect(res.status).toHaveBeenCalledWith(StatusCodes.OK);
  });

  it('creates inventory and returns created status', async () => {
    service.createInventory.mockResolvedValue(inventory);
    const req = createRequest({
      storeContext: { storeId: 'store-1' },
      user: { userId: 'user-1' },
      body: { productPackageId: 'package-1', quantity: 0 },
    } as never);
    const res = createResponse();

    await controller.createInventory(req, res as never);

    expect(service.createInventory).toHaveBeenCalledWith(
      'store-1',
      req.body,
      'user-1',
    );
    expect(res.status).toHaveBeenCalledWith(StatusCodes.CREATED);
  });

  it('deletes inventory and returns a success message', async () => {
    service.deleteInventory.mockResolvedValue(undefined);
    const req = createRequest({
      storeContext: { storeId: 'store-1' },
      user: { userId: 'user-1' },
      params: { productPackageId: 'package-1' },
    } as never);
    const res = createResponse();

    await controller.deleteInventory(req, res as never);

    expect(service.deleteInventory).toHaveBeenCalledWith(
      'store-1',
      'package-1',
      'user-1',
    );
    expect(res.status).toHaveBeenCalledWith(StatusCodes.OK);
    expect(res.json).toHaveBeenCalledWith(
      expect.objectContaining({
        message: 'Inventory deleted successfully',
        data: null,
      }),
    );
  });
});
