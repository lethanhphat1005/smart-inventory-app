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
    searchController: {
      getProductPackagesbyKeyword: vi.fn(
        (_req: Request, res: Response): void => {
          res.status(200).json({ handler: 'getProductPackagesbyKeyword' });
        },
      ),
      getProductsbyKeyword: vi.fn((_req: Request, res: Response): void => {
        res.status(200).json({ handler: 'getProductsbyKeyword' });
      }),
      getProductsByPrefix: vi.fn((_req: Request, res: Response): void => {
        res.status(200).json({ handler: 'getProductsByPrefix' });
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
  },
  requirePermission: routeMocks.requirePermission,
}));

vi.mock('../../../../src/modules/search/search.module.js', () => ({
  searchController: routeMocks.searchController,
}));

describe('searchRouter', () => {
  let app: express.Express;

  beforeEach(async () => {
    vi.clearAllMocks();
    vi.resetModules();

    const [{ errorHandler }, { searchRouter }] = await Promise.all([
      import('../../../../src/common/middlewares/index.js'),
      import('../../../../src/modules/search/search.route.js'),
    ]);

    app = express();
    app.use(express.json());
    app.use('/search', searchRouter);
    app.use(errorHandler as ErrorRequestHandler);
  });

  it('routes GET /search/products through auth, store context, read permission, and keyword validator', async () => {
    const response = await request(app).get(
      '/search/products?keyword=milk&page=2&limit=25',
    );

    expect(response.status).toBe(200);
    expect(response.body).toEqual({ handler: 'getProductsbyKeyword' });
    expect(routeMocks.authenticate).toHaveBeenCalledTimes(1);
    expect(routeMocks.requireStoreContext).toHaveBeenCalledTimes(1);
    expect(routeMocks.requirePermission).toHaveBeenCalledWith('PRODUCT_READ');
    expect(routeMocks.permissionMiddleware).toHaveBeenCalledTimes(1);
    expect(routeMocks.searchController.getProductsbyKeyword).toHaveBeenCalledTimes(
      1,
    );
  });

  it('rejects invalid product keyword query before controller execution', async () => {
    const response = await request(app).get('/search/products?keyword=   ');

    expect(response.status).toBe(400);
    expect(response.body).toMatchObject({
      success: false,
      status: 400,
      message: 'Keyword is required',
    });
    expect(routeMocks.searchController.getProductsbyKeyword).not.toHaveBeenCalled();
  });

  it('routes GET /search/products/prefix through prefix validator', async () => {
    const response = await request(app).get(
      '/search/products/prefix?prefix=Mi&limit=5',
    );

    expect(response.status).toBe(200);
    expect(response.body).toEqual({ handler: 'getProductsByPrefix' });
    expect(routeMocks.requirePermission).toHaveBeenCalledWith('PRODUCT_READ');
    expect(routeMocks.searchController.getProductsByPrefix).toHaveBeenCalledTimes(
      1,
    );
  });

  it('rejects invalid prefix query before controller execution', async () => {
    const response = await request(app).get(
      '/search/products/prefix?prefix=Mi&limit=21',
    );

    expect(response.status).toBe(400);
    expect(response.body).toMatchObject({
      success: false,
      status: 400,
    });
    expect(routeMocks.searchController.getProductsByPrefix).not.toHaveBeenCalled();
  });

  it('routes GET /search/product-packages using the current prefix query validator', async () => {
    const response = await request(app).get(
      '/search/product-packages?prefix=Mi&limit=5',
    );

    expect(response.status).toBe(200);
    expect(response.body).toEqual({ handler: 'getProductPackagesbyKeyword' });
    expect(routeMocks.requirePermission).toHaveBeenCalledWith('PRODUCT_READ');
    expect(
      routeMocks.searchController.getProductPackagesbyKeyword,
    ).toHaveBeenCalledTimes(1);
  });

  it('rejects keyword-shaped product package search because the route currently requires prefix', async () => {
    const response = await request(app).get(
      '/search/product-packages?keyword=milk&page=1&limit=10',
    );

    expect(response.status).toBe(400);
    expect(response.body).toMatchObject({
      success: false,
      status: 400,
    });
    expect(
      routeMocks.searchController.getProductPackagesbyKeyword,
    ).not.toHaveBeenCalled();
  });
});
