import express from 'express';
import request from 'supertest';
import { beforeEach, describe, expect, it, vi } from 'vitest';

import type {
  ErrorRequestHandler,
  NextFunction,
  Request,
  Response,
} from 'express';

const uuid = '550e8400-e29b-41d4-a716-446655440000';

const routeMocks = vi.hoisted(() => {
  const permissionMiddleware = vi.fn(
    (_req: Request, _res: Response, next: NextFunction): void => {
      next();
    },
  );

  return {
    authenticate: vi.fn(
      (_req: Request, _res: Response, next: NextFunction): void => {
        next();
      },
    ),
    requireStoreContext: vi.fn(
      (_req: Request, _res: Response, next: NextFunction): void => {
        next();
      },
    ),
    requirePermission: vi.fn(() => permissionMiddleware),
    permissionMiddleware,
    inventoryController: {
      getInventories: vi.fn((_req: Request, res: Response): void => {
        res.status(200).json({ handler: 'getInventories' });
      }),
      getLowStockInventories: vi.fn((_req: Request, res: Response): void => {
        res.status(200).json({ handler: 'getLowStockInventories' });
      }),
      getInventoryByProductPackageId: vi.fn(
        (_req: Request, res: Response): void => {
          res.status(200).json({ handler: 'getInventoryByProductPackageId' });
        },
      ),
      updateInventory: vi.fn((_req: Request, res: Response): void => {
        res.status(200).json({ handler: 'updateInventory' });
      }),
      createInventory: vi.fn((_req: Request, res: Response): void => {
        res.status(201).json({ handler: 'createInventory' });
      }),
      adjustInventories: vi.fn((_req: Request, res: Response): void => {
        res.status(200).json({ handler: 'adjustInventories' });
      }),
      deleteInventory: vi.fn((_req: Request, res: Response): void => {
        res.status(200).json({ handler: 'deleteInventory' });
      }),
    },
  };
});

vi.mock('../../../../src/modules/auth/index.js', () => ({
  authenticate: routeMocks.authenticate,
}));

vi.mock('../../../../src/modules/store-member/index.js', () => ({
  requireStoreContext: routeMocks.requireStoreContext,
}));

vi.mock('../../../../src/modules/access-control/index.js', () => ({
  PERMISSION: {
    INVENTORY_READ: 'INVENTORY_READ',
    INVENTORY_WRITE: 'INVENTORY_WRITE',
  },
  requirePermission: routeMocks.requirePermission,
}));

vi.mock('../../../../src/modules/inventories/inventory.module.js', () => ({
  inventoryController: routeMocks.inventoryController,
}));

describe('inventoryRouter', () => {
  let app: express.Express;

  beforeEach(async () => {
    vi.clearAllMocks();
    vi.resetModules();

    const [{ errorHandler }, { inventoryRouter }] = await Promise.all([
      import('../../../../src/common/middlewares/index.js'),
      import('../../../../src/modules/inventories/inventory.route.js'),
    ]);

    app = express();
    app.use(express.json());
    app.use('/inventories', inventoryRouter);
    app.use(errorHandler as ErrorRequestHandler);
  });

  it('routes GET /inventories through auth, store context, read permission, and query validator', async () => {
    const response = await request(app)
      .get('/inventories')
      .query({ page: '2', limit: '10', inventoryStatus: 'lowStock' });

    expect(response.status).toBe(200);
    expect(response.body).toEqual({ handler: 'getInventories' });
    expect(routeMocks.authenticate).toHaveBeenCalledTimes(1);
    expect(routeMocks.requireStoreContext).toHaveBeenCalledTimes(1);
    expect(routeMocks.requirePermission).toHaveBeenCalledWith('INVENTORY_READ');
    expect(routeMocks.permissionMiddleware).toHaveBeenCalledTimes(1);
    expect(routeMocks.inventoryController.getInventories).toHaveBeenCalledTimes(
      1,
    );
  });

  it('rejects invalid list query before controller execution', async () => {
    const response = await request(app).get('/inventories').query({
      limit: '101',
    });

    expect(response.status).toBe(400);
    expect(
      routeMocks.inventoryController.getInventories,
    ).not.toHaveBeenCalled();
  });

  it('routes POST /inventories through write permission and body validator', async () => {
    const response = await request(app).post('/inventories').send({
      productPackageId: uuid,
      quantity: 2,
      reorderThreshold: 1,
    });

    expect(response.status).toBe(201);
    expect(response.body).toEqual({ handler: 'createInventory' });
    expect(routeMocks.requirePermission).toHaveBeenCalledWith(
      'INVENTORY_WRITE',
    );
    expect(
      routeMocks.inventoryController.createInventory,
    ).toHaveBeenCalledTimes(1);
  });

  it('rejects invalid create body before controller execution', async () => {
    const response = await request(app).post('/inventories').send({
      productPackageId: uuid,
      quantity: -1,
    });

    expect(response.status).toBe(400);
    expect(
      routeMocks.inventoryController.createInventory,
    ).not.toHaveBeenCalled();
  });

  it('routes GET /inventories/low-stock through read permission and query validator', async () => {
    const response = await request(app)
      .get('/inventories/low-stock')
      .query({ keyword: 'milk' });

    expect(response.status).toBe(200);
    expect(response.body).toEqual({ handler: 'getLowStockInventories' });
    expect(routeMocks.requirePermission).toHaveBeenCalledWith('INVENTORY_READ');
    expect(
      routeMocks.inventoryController.getLowStockInventories,
    ).toHaveBeenCalledTimes(1);
  });

  it('routes product package detail, update, and delete through expected permissions and validators', async () => {
    const getResponse = await request(app).get(
      `/inventories/product-packages/${uuid}`,
    );
    const patchResponse = await request(app)
      .patch(`/inventories/product-packages/${uuid}`)
      .send({ reorderThreshold: 4 });
    const deleteResponse = await request(app).delete(
      `/inventories/product-packages/${uuid}`,
    );

    expect(getResponse.status).toBe(200);
    expect(patchResponse.status).toBe(200);
    expect(deleteResponse.status).toBe(200);
    expect(routeMocks.requirePermission).toHaveBeenCalledWith('INVENTORY_READ');
    expect(routeMocks.requirePermission).toHaveBeenCalledWith(
      'INVENTORY_WRITE',
    );
    expect(
      routeMocks.inventoryController.getInventoryByProductPackageId,
    ).toHaveBeenCalledTimes(1);
    expect(
      routeMocks.inventoryController.updateInventory,
    ).toHaveBeenCalledTimes(1);
    expect(
      routeMocks.inventoryController.deleteInventory,
    ).toHaveBeenCalledTimes(1);
  });

  it('rejects invalid product package params and empty update bodies before controller execution', async () => {
    const invalidParamsResponse = await request(app).get(
      '/inventories/product-packages/not-a-uuid',
    );
    const emptyPatchResponse = await request(app)
      .patch(`/inventories/product-packages/${uuid}`)
      .send({});

    expect(invalidParamsResponse.status).toBe(400);
    expect(emptyPatchResponse.status).toBe(400);
    expect(
      routeMocks.inventoryController.getInventoryByProductPackageId,
    ).not.toHaveBeenCalled();
    expect(
      routeMocks.inventoryController.updateInventory,
    ).not.toHaveBeenCalled();
  });

  it('routes POST /inventories/adjustments through write permission and body validator', async () => {
    const response = await request(app)
      .post('/inventories/adjustments')
      .send({
        items: [
          {
            productPackageId: uuid,
            type: 'decrease',
            quantity: 1,
            reason: 'damaged',
          },
        ],
      });

    expect(response.status).toBe(200);
    expect(response.body).toEqual({ handler: 'adjustInventories' });
    expect(routeMocks.requirePermission).toHaveBeenCalledWith(
      'INVENTORY_WRITE',
    );
    expect(
      routeMocks.inventoryController.adjustInventories,
    ).toHaveBeenCalledTimes(1);
  });

  it('rejects invalid adjustment body before controller execution', async () => {
    const response = await request(app).post('/inventories/adjustments').send({
      items: [],
    });

    expect(response.status).toBe(400);
    expect(
      routeMocks.inventoryController.adjustInventories,
    ).not.toHaveBeenCalled();
  });
});
