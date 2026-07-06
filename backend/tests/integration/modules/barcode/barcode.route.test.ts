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
    barcodesController: {
      scanBarcode: vi.fn((_req: Request, res: Response): void => {
        res.status(200).json({ handler: 'scanBarcode' });
      }),
      confirmBarcodeMapping: vi.fn((_req: Request, res: Response): void => {
        res.status(201).json({ handler: 'confirmBarcodeMapping' });
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

vi.mock('../../../../src/modules/barcode/barcodes.module.js', () => ({
  barcodesController: routeMocks.barcodesController,
}));

describe('barcodeRouter', () => {
  let app: express.Express;

  beforeEach(async () => {
    vi.clearAllMocks();
    vi.resetModules();

    const [{ errorHandler }, { barcodeRouter }] = await Promise.all([
      import('../../../../src/common/middlewares/index.js'),
      import('../../../../src/modules/barcode/routes/barcode.route.js'),
    ]);

    app = express();
    app.use(express.json());
    app.use('/barcodes', barcodeRouter);
    app.use(errorHandler as ErrorRequestHandler);
  });

  it('routes POST /barcodes/scan through auth, store context, read permission, and body validator', async () => {
    const response = await request(app).post('/barcodes/scan').send({
      barcode: '123456789012',
      type: 'ean',
    });

    expect(response.status).toBe(200);
    expect(response.body).toEqual({ handler: 'scanBarcode' });
    expect(routeMocks.authenticate).toHaveBeenCalledTimes(1);
    expect(routeMocks.requireStoreContext).toHaveBeenCalledTimes(1);
    expect(routeMocks.requirePermission).toHaveBeenCalledWith('PRODUCT_READ');
    expect(routeMocks.permissionMiddleware).toHaveBeenCalledTimes(1);
    expect(routeMocks.barcodesController.scanBarcode).toHaveBeenCalledTimes(1);
  });

  it('rejects invalid scan payload before controller execution', async () => {
    const response = await request(app).post('/barcodes/scan').send({
      barcode: '12345',
    });

    expect(response.status).toBe(400);
    expect(response.body).toMatchObject({
      success: false,
      status: 400,
      message: 'Barcode value is invalid',
    });
    expect(routeMocks.barcodesController.scanBarcode).not.toHaveBeenCalled();
  });

  it('routes POST /barcodes/confirm through write permission and body validator', async () => {
    const response = await request(app).post('/barcodes/confirm').send({
      barcode: '123456789012',
      productPackageId: '550e8400-e29b-41d4-a716-446655440000',
      type: 'upc',
    });

    expect(response.status).toBe(201);
    expect(response.body).toEqual({ handler: 'confirmBarcodeMapping' });
    expect(routeMocks.requirePermission).toHaveBeenCalledWith('PRODUCT_WRITE');
    expect(
      routeMocks.barcodesController.confirmBarcodeMapping,
    ).toHaveBeenCalledTimes(1);
  });

  it('rejects invalid confirm payload before controller execution', async () => {
    const response = await request(app).post('/barcodes/confirm').send({
      barcode: '123456789012',
      productPackageId: 'not-a-uuid',
    });

    expect(response.status).toBe(400);
    expect(response.body).toMatchObject({
      success: false,
      status: 400,
      message: 'Invalid productPackageId',
    });
    expect(
      routeMocks.barcodesController.confirmBarcodeMapping,
    ).not.toHaveBeenCalled();
  });
});
