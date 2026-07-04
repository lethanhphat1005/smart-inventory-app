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
    categoryController: {
      findAll: vi.fn((_req: Request, res: Response): void => {
        res.status(200).json({ handler: 'findAll' });
      }),
      findAllHidden: vi.fn((_req: Request, res: Response): void => {
        res.status(200).json({ handler: 'findAllHidden' });
      }),
      createOne: vi.fn((_req: Request, res: Response): void => {
        res.status(201).json({ handler: 'createOne' });
      }),
      updateOne: vi.fn((_req: Request, res: Response): void => {
        res.status(200).json({ handler: 'updateOne' });
      }),
      hideDefaultCategory: vi.fn((_req: Request, res: Response): void => {
        res.status(200).json({ handler: 'hideDefaultCategory' });
      }),
      restoreDefaultOne: vi.fn((_req: Request, res: Response): void => {
        res.status(200).json({ handler: 'restoreDefaultOne' });
      }),
      deleteCustomCategory: vi.fn((_req: Request, res: Response): void => {
        res.status(200).json({ handler: 'deleteCustomCategory' });
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
    CATEGORY_READ: 'CATEGORY_READ',
    CATEGORY_WRITE: 'CATEGORY_WRITE',
  },
  requirePermission: routeMocks.requirePermission,
}));

vi.mock('../../../../src/modules/categories/category.module.js', () => ({
  categoryController: routeMocks.categoryController,
}));

const uuid = '550e8400-e29b-41d4-a716-446655440000';

describe('categoryRouter', () => {
  let app: express.Express;

  beforeEach(async () => {
    vi.clearAllMocks();
    vi.resetModules();

    const [{ errorHandler }, { categoryRouter }] = await Promise.all([
      import('../../../../src/common/middlewares/index.js'),
      import('../../../../src/modules/categories/category.route.js'),
    ]);

    app = express();
    app.use(express.json());
    app.use('/categories', categoryRouter);
    app.use(errorHandler as ErrorRequestHandler);
  });

  it('routes GET /categories through auth, store context, and read permission', async () => {
    const response = await request(app).get('/categories');

    expect(response.status).toBe(200);
    expect(response.body).toEqual({ handler: 'findAll' });
    expect(routeMocks.authenticate).toHaveBeenCalledTimes(1);
    expect(routeMocks.requireStoreContext).toHaveBeenCalledTimes(1);
    expect(routeMocks.requirePermission).toHaveBeenCalledWith('CATEGORY_READ');
    expect(routeMocks.permissionMiddleware).toHaveBeenCalledTimes(1);
    expect(routeMocks.categoryController.findAll).toHaveBeenCalledTimes(1);
  });

  it('routes POST /categories through write permission and body validator', async () => {
    const response = await request(app).post('/categories').send({
      name: 'Dairy',
      description: null,
    });

    expect(response.status).toBe(201);
    expect(response.body).toEqual({ handler: 'createOne' });
    expect(routeMocks.requirePermission).toHaveBeenCalledWith('CATEGORY_WRITE');
    expect(routeMocks.categoryController.createOne).toHaveBeenCalledTimes(1);
  });

  it('rejects invalid create payload before controller execution', async () => {
    const response = await request(app).post('/categories').send({
      name: '   ',
    });

    expect(response.status).toBe(400);
    expect(response.body).toMatchObject({
      success: false,
      status: 400,
      message: 'Category name is required.',
    });
    expect(routeMocks.categoryController.createOne).not.toHaveBeenCalled();
  });

  it('routes GET /categories/hide to hidden defaults before id routes', async () => {
    const response = await request(app).get('/categories/hide');

    expect(response.status).toBe(200);
    expect(response.body).toEqual({ handler: 'findAllHidden' });
    expect(routeMocks.requirePermission).toHaveBeenCalledWith('CATEGORY_READ');
    expect(routeMocks.categoryController.findAllHidden).toHaveBeenCalledTimes(1);
  });

  it('rejects invalid categoryId params before delete controller execution', async () => {
    const response = await request(app).delete('/categories/not-a-uuid');

    expect(response.status).toBe(400);
    expect(response.body).toMatchObject({
      success: false,
      status: 400,
      message: 'Invalid categoryId',
    });
    expect(
      routeMocks.categoryController.deleteCustomCategory,
    ).not.toHaveBeenCalled();
  });

  it('rejects empty update body before controller execution', async () => {
    const response = await request(app).patch(`/categories/${uuid}`).send({});

    expect(response.status).toBe(400);
    expect(response.body).toMatchObject({
      success: false,
      status: 400,
      message: 'Update request body cannot be empty',
    });
    expect(routeMocks.categoryController.updateOne).not.toHaveBeenCalled();
  });

  it('routes PATCH and DELETE /categories/:categoryId through write permission', async () => {
    const updateResponse = await request(app)
      .patch(`/categories/${uuid}`)
      .send({ name: 'Frozen' });
    const deleteResponse = await request(app).delete(`/categories/${uuid}`);

    expect(updateResponse.status).toBe(200);
    expect(updateResponse.body).toEqual({ handler: 'updateOne' });
    expect(deleteResponse.status).toBe(200);
    expect(deleteResponse.body).toEqual({ handler: 'deleteCustomCategory' });
    expect(routeMocks.requirePermission).toHaveBeenCalledWith('CATEGORY_WRITE');
    expect(routeMocks.categoryController.updateOne).toHaveBeenCalledTimes(1);
    expect(
      routeMocks.categoryController.deleteCustomCategory,
    ).toHaveBeenCalledTimes(1);
  });

  it('routes hide and unhide default category endpoints through write permission', async () => {
    const hideResponse = await request(app).post(`/categories/${uuid}/hide`);
    const unhideResponse = await request(app).delete(
      `/categories/${uuid}/unhide`,
    );

    expect(hideResponse.status).toBe(200);
    expect(hideResponse.body).toEqual({ handler: 'hideDefaultCategory' });
    expect(unhideResponse.status).toBe(200);
    expect(unhideResponse.body).toEqual({ handler: 'restoreDefaultOne' });
    expect(routeMocks.requirePermission).toHaveBeenCalledWith('CATEGORY_WRITE');
    expect(
      routeMocks.categoryController.hideDefaultCategory,
    ).toHaveBeenCalledTimes(1);
    expect(routeMocks.categoryController.restoreDefaultOne).toHaveBeenCalledTimes(
      1,
    );
  });
});
