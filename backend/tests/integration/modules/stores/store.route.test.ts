import express from 'express';
import request from 'supertest';
import { beforeEach, describe, expect, it, vi } from 'vitest';

import { errorHandler } from '../../../../src/common/middlewares/index.js';

import type { NextFunction, Request, Response } from 'express';

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
    storeController: {
      getStores: vi.fn((_req: Request, res: Response): void => {
        res.status(200).json({ handler: 'getStores' });
      }),
      getStoreById: vi.fn((_req: Request, res: Response): void => {
        res.status(200).json({ handler: 'getStoreById' });
      }),
      createStore: vi.fn((_req: Request, res: Response): void => {
        res.status(201).json({ handler: 'createStore' });
      }),
      updateStore: vi.fn((_req: Request, res: Response): void => {
        res.status(200).json({ handler: 'updateStore' });
      }),
      softDeleteStore: vi.fn((_req: Request, res: Response): void => {
        res.status(200).json({ handler: 'softDeleteStore' });
      }),
      refreshInviteCode: vi.fn((_req: Request, res: Response): void => {
        res.status(200).json({ handler: 'refreshInviteCode' });
      }),
      joinStore: vi.fn((_req: Request, res: Response): void => {
        res.status(200).json({ handler: 'joinStore' });
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
    STORE_READ: 'STORE_READ',
    STORE_WRITE: 'STORE_WRITE',
  },
  requirePermission: routeMocks.requirePermission,
}));

vi.mock('../../../../src/modules/stores/store.module.js', () => ({
  storeController: routeMocks.storeController,
}));

describe('storeRouter', () => {
  let app: express.Express;

  beforeEach(async () => {
    vi.clearAllMocks();

    const { storeRouter } =
      await import('../../../../src/modules/stores/store.route.js');

    app = express();
    app.use(express.json());
    app.use('/stores', storeRouter);
    app.use(errorHandler);
  });

  it('routes GET /stores through authentication to list stores', async () => {
    const response = await request(app).get('/stores');

    expect(response.status).toBe(200);
    expect(response.body).toEqual({ handler: 'getStores' });
    expect(routeMocks.authenticate).toHaveBeenCalledTimes(1);
    expect(routeMocks.storeController.getStores).toHaveBeenCalledTimes(1);
  });

  it('rejects invalid create payload before controller execution', async () => {
    const response = await request(app).post('/stores').send({
      currencyCode: 'VND',
    });

    expect(response.status).toBe(400);
    expect(response.body).toMatchObject({
      success: false,
      status: 400,
      message: 'Invalid input: expected string, received undefined',
    });
    expect(routeMocks.storeController.createStore).not.toHaveBeenCalled();
  });

  it('routes GET /stores/:storeId through context and read permission', async () => {
    const response = await request(app).get(
      '/stores/550e8400-e29b-41d4-a716-446655440000',
    );

    expect(response.status).toBe(200);
    expect(response.body).toEqual({ handler: 'getStoreById' });
    expect(routeMocks.requireStoreContext).toHaveBeenCalledTimes(1);
    expect(routeMocks.permissionMiddleware).toHaveBeenCalledTimes(1);
    expect(routeMocks.storeController.getStoreById).toHaveBeenCalledTimes(1);
  });

  it('rejects invalid storeId params before delete controller execution', async () => {
    const response = await request(app).delete('/stores/not-a-uuid');

    expect(response.status).toBe(400);
    expect(response.body).toMatchObject({
      success: false,
      status: 400,
      message: 'Invalid storeId',
    });
    expect(routeMocks.storeController.softDeleteStore).not.toHaveBeenCalled();
  });

  it('routes refresh invite code through store write permission', async () => {
    const response = await request(app).post('/stores/refresh-invite-code');

    expect(response.status).toBe(200);
    expect(response.body).toEqual({ handler: 'refreshInviteCode' });
    expect(routeMocks.requireStoreContext).toHaveBeenCalledTimes(1);
    expect(routeMocks.permissionMiddleware).toHaveBeenCalledTimes(1);
  });

  it('rejects empty invite code before join controller execution', async () => {
    const response = await request(app).post('/stores/join').send({
      inviteCode: '   ',
    });

    expect(response.status).toBe(400);
    expect(response.body).toMatchObject({
      success: false,
      status: 400,
      message: 'Invite code is required',
    });
    expect(routeMocks.storeController.joinStore).not.toHaveBeenCalled();
  });
});
