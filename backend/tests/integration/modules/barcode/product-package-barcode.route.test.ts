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
    productPackageBarcodeController: {
      createPackageBarcode: vi.fn((_req: Request, res: Response): void => {
        res.status(201).json({ handler: 'createPackageBarcode' });
      }),
      deletePackageBarcode: vi.fn((_req: Request, res: Response): void => {
        res.status(200).json({ handler: 'deletePackageBarcode' });
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
    PRODUCT_WRITE: 'PRODUCT_WRITE',
  },
  requirePermission: routeMocks.requirePermission,
}));

vi.mock('../../../../src/modules/barcode/barcodes.module.js', () => ({
  productPackageBarcodeController:
    routeMocks.productPackageBarcodeController,
}));

describe('productPackageBarcodeRouter', () => {
  let app: express.Express;

  beforeEach(async () => {
    vi.clearAllMocks();
    vi.resetModules();

    const [{ errorHandler }, { productPackageBarcodeRouter }] =
      await Promise.all([
        import('../../../../src/common/middlewares/index.js'),
        import(
          '../../../../src/modules/barcode/routes/product-package-barcode.route.js'
        ),
      ]);

    app = express();
    app.use(express.json());
    app.use('/product-packages', productPackageBarcodeRouter);
    app.use(errorHandler as ErrorRequestHandler);
  });

  it('routes POST /product-packages/:productPackageId/barcodes through write permission and validators', async () => {
    const response = await request(app)
      .post(
        '/product-packages/550e8400-e29b-41d4-a716-446655440000/barcodes',
      )
      .send({
        barcode: '123456789012',
        type: 'ean',
      });

    expect(response.status).toBe(201);
    expect(response.body).toEqual({ handler: 'createPackageBarcode' });
    expect(routeMocks.authenticate).toHaveBeenCalledTimes(1);
    expect(routeMocks.requireStoreContext).toHaveBeenCalledTimes(1);
    expect(routeMocks.requirePermission).toHaveBeenCalledWith('PRODUCT_WRITE');
    expect(routeMocks.permissionMiddleware).toHaveBeenCalledTimes(1);
    expect(
      routeMocks.productPackageBarcodeController.createPackageBarcode,
    ).toHaveBeenCalledTimes(1);
  });

  it('rejects invalid create params and body before controller execution', async () => {
    const invalidParamsResponse = await request(app)
      .post('/product-packages/not-a-uuid/barcodes')
      .send({ barcode: '123456789012' });
    const invalidBodyResponse = await request(app)
      .post(
        '/product-packages/550e8400-e29b-41d4-a716-446655440000/barcodes',
      )
      .send({ barcode: '12345' });

    expect(invalidParamsResponse.status).toBe(400);
    expect(invalidBodyResponse.status).toBe(400);
    expect(
      routeMocks.productPackageBarcodeController.createPackageBarcode,
    ).not.toHaveBeenCalled();
  });

  it('routes DELETE /product-packages/:productPackageId/barcodes/:barcode through write permission and params validator', async () => {
    const response = await request(app).delete(
      '/product-packages/550e8400-e29b-41d4-a716-446655440000/barcodes/123456789012',
    );

    expect(response.status).toBe(200);
    expect(response.body).toEqual({ handler: 'deletePackageBarcode' });
    expect(routeMocks.requirePermission).toHaveBeenCalledWith('PRODUCT_WRITE');
    expect(
      routeMocks.productPackageBarcodeController.deletePackageBarcode,
    ).toHaveBeenCalledTimes(1);
  });

  it('rejects invalid delete params before controller execution', async () => {
    const response = await request(app).delete(
      '/product-packages/550e8400-e29b-41d4-a716-446655440000/barcodes/12345',
    );

    expect(response.status).toBe(400);
    expect(response.body).toMatchObject({
      success: false,
      status: 400,
      message: 'Barcode value is invalid',
    });
    expect(
      routeMocks.productPackageBarcodeController.deletePackageBarcode,
    ).not.toHaveBeenCalled();
  });
});
