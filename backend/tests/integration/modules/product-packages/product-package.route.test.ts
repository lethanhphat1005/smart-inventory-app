import express from 'express';
import request from 'supertest';
import { beforeEach, describe, expect, it, vi } from 'vitest';

import type {
  ErrorRequestHandler,
  NextFunction,
  Request,
  Response,
} from 'express';

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
    productPackageController: {
      getProductPackagesByStore: vi.fn(
        (_req: Request, res: Response): void => {
          res.status(200).json({ handler: 'getProductPackagesByStore' });
        },
      ),
      getProductPackagesByProductId: vi.fn(
        (_req: Request, res: Response): void => {
          res.status(200).json({ handler: 'getProductPackagesByProductId' });
        },
      ),
      getProductPackageById: vi.fn((_req: Request, res: Response): void => {
        res.status(200).json({ handler: 'getProductPackageById' });
      }),
      createProductPackage: vi.fn((_req: Request, res: Response): void => {
        res.status(201).json({ handler: 'createProductPackage' });
      }),
      updateProductPackage: vi.fn((_req: Request, res: Response): void => {
        res.status(200).json({ handler: 'updateProductPackage' });
      }),
      softDeleteProductPackage: vi.fn((_req: Request, res: Response): void => {
        res.status(200).json({ handler: 'softDeleteProductPackage' });
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
    PRODUCT_READ: 'PRODUCT_READ',
    PRODUCT_WRITE: 'PRODUCT_WRITE',
  },
  requirePermission: routeMocks.requirePermission,
}));

vi.mock(
  '../../../../src/modules/product-packages/modules/product-package.module.js',
  () => ({
    productPackageController: routeMocks.productPackageController,
  }),
);

const uuid = '550e8400-e29b-41d4-a716-446655440000';

describe('product package routers', () => {
  let app: express.Express;

  beforeEach(async () => {
    vi.clearAllMocks();
    vi.resetModules();

    const [{ errorHandler }, routes] = await Promise.all([
      import('../../../../src/common/middlewares/index.js'),
      import(
        '../../../../src/modules/product-packages/routes/product-package.route.js'
      ),
    ]);

    app = express();
    app.use(express.json());
    app.use('/product-packages', routes.productPackageRouter);
    app.use('/products', routes.productPackageProductRouter);
    app.use(errorHandler as ErrorRequestHandler);
  });

  it('routes GET /product-packages through auth, store context, read permission, and query validator', async () => {
    const response = await request(app).get(
      `/product-packages?page=2&limit=25&sortBy=updatedAt&sortOrder=desc&categoryId=${uuid}`,
    );

    expect(response.status).toBe(200);
    expect(response.body).toEqual({ handler: 'getProductPackagesByStore' });
    expect(routeMocks.authenticate).toHaveBeenCalledTimes(1);
    expect(routeMocks.requireStoreContext).toHaveBeenCalledTimes(1);
    expect(routeMocks.requirePermission).toHaveBeenCalledWith('PRODUCT_READ');
    expect(
      routeMocks.productPackageController.getProductPackagesByStore,
    ).toHaveBeenCalledTimes(1);
  });

  it('rejects invalid package list query before controller execution', async () => {
    const response = await request(app).get('/product-packages?limit=101');

    expect(response.status).toBe(400);
    expect(response.body).toMatchObject({
      success: false,
      status: 400,
    });
    expect(
      routeMocks.productPackageController.getProductPackagesByStore,
    ).not.toHaveBeenCalled();
  });

  it('routes product package list and create nested under products', async () => {
    const listResponse = await request(app).get(`/products/${uuid}/packages`);
    const createResponse = await request(app)
      .post(`/products/${uuid}/packages`)
      .send([
        {
          package: {
            unitId: uuid,
            importPrice: 1000,
            sellingPrice: 1500,
            variant: 'bottle',
          },
          inventory: {
            quantity: 3,
            reorderThreshold: 1,
          },
        },
      ]);

    expect(listResponse.status).toBe(200);
    expect(listResponse.body).toEqual({
      handler: 'getProductPackagesByProductId',
    });
    expect(createResponse.status).toBe(201);
    expect(createResponse.body).toEqual({ handler: 'createProductPackage' });
    expect(routeMocks.requirePermission).toHaveBeenCalledWith('PRODUCT_READ');
    expect(routeMocks.requirePermission).toHaveBeenCalledWith('PRODUCT_WRITE');
  });

  it('rejects invalid product id and invalid create body before controller execution', async () => {
    const invalidParamResponse = await request(app).get(
      '/products/not-a-uuid/packages',
    );
    const invalidBodyResponse = await request(app)
      .post(`/products/${uuid}/packages`)
      .send([]);

    expect(invalidParamResponse.status).toBe(400);
    expect(invalidParamResponse.body).toMatchObject({
      success: false,
      message: 'Invalid productId',
    });
    expect(invalidBodyResponse.status).toBe(400);
    expect(invalidBodyResponse.body).toMatchObject({
      success: false,
      message: 'At least one package is required',
    });
    expect(
      routeMocks.productPackageController.getProductPackagesByProductId,
    ).not.toHaveBeenCalled();
    expect(
      routeMocks.productPackageController.createProductPackage,
    ).not.toHaveBeenCalled();
  });

  it('routes package detail, update, and delete through validators and permissions', async () => {
    const detailResponse = await request(app).get(`/product-packages/${uuid}`);
    const updateResponse = await request(app)
      .patch(`/product-packages/${uuid}`)
      .send({ unitId: uuid, sellingPrice: 1800 });
    const deleteResponse = await request(app).delete(
      `/product-packages/${uuid}`,
    );

    expect(detailResponse.status).toBe(200);
    expect(updateResponse.status).toBe(200);
    expect(deleteResponse.status).toBe(200);
    expect(routeMocks.requirePermission).toHaveBeenCalledWith('PRODUCT_READ');
    expect(routeMocks.requirePermission).toHaveBeenCalledWith('PRODUCT_WRITE');
    expect(
      routeMocks.productPackageController.getProductPackageById,
    ).toHaveBeenCalledTimes(1);
    expect(
      routeMocks.productPackageController.updateProductPackage,
    ).toHaveBeenCalledTimes(1);
    expect(
      routeMocks.productPackageController.softDeleteProductPackage,
    ).toHaveBeenCalledTimes(1);
  });

  it('rejects invalid package id and empty update body before controller execution', async () => {
    const invalidParamResponse = await request(app).delete(
      '/product-packages/not-a-uuid',
    );
    const emptyBodyResponse = await request(app)
      .patch(`/product-packages/${uuid}`)
      .send({});

    expect(invalidParamResponse.status).toBe(400);
    expect(invalidParamResponse.body).toMatchObject({
      success: false,
      message: 'Invalid productPackageId',
    });
    expect(emptyBodyResponse.status).toBe(400);
    expect(emptyBodyResponse.body).toMatchObject({
      success: false,
      message: 'Invalid unitId',
    });
    expect(
      routeMocks.productPackageController.softDeleteProductPackage,
    ).not.toHaveBeenCalled();
    expect(
      routeMocks.productPackageController.updateProductPackage,
    ).not.toHaveBeenCalled();
  });
});
