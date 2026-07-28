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
    storeMemberController: {
      getStoreMembers: vi.fn((_req: Request, res: Response): void => {
        res.status(200).json({ handler: 'getStoreMembers' });
      }),
      removeUser: vi.fn((_req: Request, res: Response): void => {
        res.status(200).json({ handler: 'removeUser' });
      }),
      updateRole: vi.fn((_req: Request, res: Response): void => {
        res.status(200).json({ handler: 'updateRole' });
      }),
    },
  };
});

vi.mock('../../../../src/modules/auth/index.js', () => ({
  authenticate: routeMocks.authenticate,
}));

vi.mock(
  '../../../../src/modules/store-member/middlewares/require-store-context.middleware.js',
  () => ({
    requireStoreContext: routeMocks.requireStoreContext,
  }),
);

vi.mock(
  '../../../../src/modules/access-control/require-permission.middleware.js',
  () => ({
    requirePermission: routeMocks.requirePermission,
  }),
);

vi.mock('../../../../src/modules/store-member/store-member.module.js', () => ({
  storeMemberController: routeMocks.storeMemberController,
}));

describe('storeMemberRouter', () => {
  let app: express.Express;

  beforeEach(async () => {
    vi.clearAllMocks();

    const { storeMemberRouter } =
      await import('../../../../src/modules/store-member/store-member.route.js');

    app = express();
    app.use(express.json());
    app.use((req, _res, next) => {
      Object.defineProperty(req, 'query', {
        value: req.query,
        writable: true,
        configurable: true,
      });
      next();
    });
    app.use('/store-members', storeMemberRouter);
    app.use(errorHandler);
  });

  it('routes GET /store-members through auth and store context', async () => {
    const response = await request(app).get('/store-members');

    expect(response.status).toBe(200);
    expect(response.body).toEqual({ handler: 'getStoreMembers' });
    expect(routeMocks.authenticate).toHaveBeenCalledTimes(1);
    expect(routeMocks.requireStoreContext).toHaveBeenCalledTimes(1);
    expect(routeMocks.storeMemberController.getStoreMembers).toHaveBeenCalled();
  });

  it('routes DELETE /store-members/:userId through delete permission', async () => {
    const response = await request(app).delete(
      '/store-members/550e8400-e29b-41d4-a716-446655440000',
    );

    expect(response.status).toBe(200);
    expect(response.body).toEqual({ handler: 'removeUser' });
    expect(routeMocks.permissionMiddleware).toHaveBeenCalledTimes(1);
    expect(routeMocks.storeMemberController.removeUser).toHaveBeenCalledTimes(
      1,
    );
  });

  it('rejects invalid delete userId before controller execution', async () => {
    const response = await request(app).delete('/store-members/not-a-uuid');

    expect(response.status).toBe(400);
    expect(response.body).toMatchObject({
      success: false,
      status: 400,
    });
    expect(routeMocks.storeMemberController.removeUser).not.toHaveBeenCalled();
  });

  it('routes PATCH /store-members/:userId/role through write permission', async () => {
    const response = await request(app)
      .patch('/store-members/550e8400-e29b-41d4-a716-446655440000/role')
      .send({ role: 'manager' });

    expect(response.status).toBe(200);
    expect(response.body).toEqual({ handler: 'updateRole' });
    expect(routeMocks.permissionMiddleware).toHaveBeenCalledTimes(1);
    expect(routeMocks.storeMemberController.updateRole).toHaveBeenCalledTimes(
      1,
    );
  });

  it('rejects invalid role payload before controller execution', async () => {
    const response = await request(app)
      .patch('/store-members/550e8400-e29b-41d4-a716-446655440000/role')
      .send({ role: 'owner' });

    expect(response.status).toBe(400);
    expect(response.body).toMatchObject({
      success: false,
      status: 400,
    });
    expect(routeMocks.storeMemberController.updateRole).not.toHaveBeenCalled();
  });
});
