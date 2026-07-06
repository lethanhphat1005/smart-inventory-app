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
    productController: {
      getProducts: vi.fn((_req: Request, res: Response): void => {
        res.status(200).json({ handler: 'getProducts' });
      }),
      getProductById: vi.fn((_req: Request, res: Response): void => {
        res.status(200).json({ handler: 'getProductById' });
      }),
      createProduct: vi.fn((_req: Request, res: Response): void => {
        res.status(201).json({ handler: 'createProduct' });
      }),
      updateProduct: vi.fn((_req: Request, res: Response): void => {
        res.status(200).json({ handler: 'updateProduct' });
      }),
      softDeleteProduct: vi.fn((_req: Request, res: Response): void => {
        res.status(200).json({ handler: 'softDeleteProduct' });
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

vi.mock('../../../../src/modules/products/product.module.js', () => ({
  productController: routeMocks.productController,
}));

describe('productRouter', () => {
  let app: express.Express;

  beforeEach(async () => {
    vi.clearAllMocks();
    vi.resetModules();

    const [{ errorHandler }, { productRouter }] = await Promise.all([
      import('../../../../src/common/middlewares/index.js'),
      import('../../../../src/modules/products/product.route.js'),
    ]);

    app = express();
    app.use(express.json());
    app.use('/products', productRouter);
    app.use(errorHandler as ErrorRequestHandler);
  });

  it('routes GET /products through auth, store context, read permission, and query validator', async () => {
    const response = await request(app).get(
      '/products?page=2&limit=25&sortBy=createdAt&sortOrder=asc',
    );

    expect(response.status).toBe(200);
    expect(response.body).toEqual({ handler: 'getProducts' });
    expect(routeMocks.authenticate).toHaveBeenCalledTimes(1);
    expect(routeMocks.requireStoreContext).toHaveBeenCalledTimes(1);
    expect(routeMocks.requirePermission).toHaveBeenCalledWith('PRODUCT_READ');
    expect(routeMocks.permissionMiddleware).toHaveBeenCalledTimes(1);
    expect(routeMocks.productController.getProducts).toHaveBeenCalledTimes(1);
  });

  it('rejects invalid list query before controller execution', async () => {
    const response = await request(app).get('/products?limit=101');

    expect(response.status).toBe(400);
    expect(response.body).toMatchObject({
      success: false,
      status: 400,
    });
    expect(routeMocks.productController.getProducts).not.toHaveBeenCalled();
  });

  it('routes POST /products through write permission and body validator', async () => {
    const response = await request(app).post('/products').send({
      name: 'Milk',
      imageUrl: null,
      brand: 'Dairy Co',
      categoryId: '660e8400-e29b-41d4-a716-446655440000',
    });

    expect(response.status).toBe(201);
    expect(response.body).toEqual({ handler: 'createProduct' });
    expect(routeMocks.requirePermission).toHaveBeenCalledWith('PRODUCT_WRITE');
    expect(routeMocks.productController.createProduct).toHaveBeenCalledTimes(1);
  });

  it('rejects invalid create payload before controller execution', async () => {
    const response = await request(app).post('/products').send({
      categoryId: '660e8400-e29b-41d4-a716-446655440000',
    });

    expect(response.status).toBe(400);
    expect(response.body).toMatchObject({
      success: false,
      status: 400,
      message: 'Invalid input: expected string, received undefined',
    });
    expect(routeMocks.productController.createProduct).not.toHaveBeenCalled();
  });

  it('routes GET /products/:productId through read permission and params validator', async () => {
    const response = await request(app).get(
      '/products/550e8400-e29b-41d4-a716-446655440000',
    );

    expect(response.status).toBe(200);
    expect(response.body).toEqual({ handler: 'getProductById' });
    expect(routeMocks.requirePermission).toHaveBeenCalledWith('PRODUCT_READ');
    expect(routeMocks.productController.getProductById).toHaveBeenCalledTimes(
      1,
    );
  });

  it('rejects invalid productId params before delete controller execution', async () => {
    const response = await request(app).delete('/products/not-a-uuid');

    expect(response.status).toBe(400);
    expect(response.body).toMatchObject({
      success: false,
      status: 400,
      message: 'Invalid productId',
    });
    expect(
      routeMocks.productController.softDeleteProduct,
    ).not.toHaveBeenCalled();
  });

  it('rejects empty update body before controller execution', async () => {
    const response = await request(app)
      .patch('/products/550e8400-e29b-41d4-a716-446655440000')
      .send({});

    expect(response.status).toBe(400);
    expect(response.body).toMatchObject({
      success: false,
      status: 400,
      message: 'Request body cannot be empty',
    });
    expect(routeMocks.productController.updateProduct).not.toHaveBeenCalled();
  });

  it('routes PATCH and DELETE /products/:productId through write permission', async () => {
    const updateResponse = await request(app)
      .patch('/products/550e8400-e29b-41d4-a716-446655440000')
      .send({ name: 'Oat Milk' });
    const deleteResponse = await request(app).delete(
      '/products/550e8400-e29b-41d4-a716-446655440000',
    );

    expect(updateResponse.status).toBe(200);
    expect(updateResponse.body).toEqual({ handler: 'updateProduct' });
    expect(deleteResponse.status).toBe(200);
    expect(deleteResponse.body).toEqual({ handler: 'softDeleteProduct' });
    expect(routeMocks.requirePermission).toHaveBeenCalledWith('PRODUCT_WRITE');
    expect(routeMocks.productController.updateProduct).toHaveBeenCalledTimes(1);
    expect(
      routeMocks.productController.softDeleteProduct,
    ).toHaveBeenCalledTimes(1);
  });
});
