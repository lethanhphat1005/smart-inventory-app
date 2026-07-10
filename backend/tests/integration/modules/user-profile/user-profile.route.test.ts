import express from 'express';
import request from 'supertest';
import { beforeEach, describe, expect, it, vi } from 'vitest';

import type {
  ErrorRequestHandler,
  NextFunction,
  Request,
  Response,
} from 'express';

const routeMocks = vi.hoisted(() => ({
  authenticate: vi.fn(
    (_req: Request, _res: Response, next: NextFunction): void => {
      next();
    },
  ),
  verifyAuthOnly: vi.fn(
    (_req: Request, _res: Response, next: NextFunction): void => {
      next();
    },
  ),
  userProfileController: {
    createMyProfile: vi.fn((_req: Request, res: Response): void => {
      res.status(201).json({ handler: 'createMyProfile' });
    }),
    getMyProfile: vi.fn((_req: Request, res: Response): void => {
      res.status(200).json({ handler: 'getMyProfile' });
    }),
    updateUserProfile: vi.fn((_req: Request, res: Response): void => {
      res.status(200).json({ handler: 'updateUserProfile' });
    }),
  },
}));

vi.mock('../../../../src/modules/auth/index.js', () => ({
  authenticate: routeMocks.authenticate,
}));

vi.mock(
  '../../../../src/modules/user-profile/middleware/optional-profile.middleware.js',
  () => ({
    verifyAuthOnly: routeMocks.verifyAuthOnly,
  }),
);

vi.mock('../../../../src/modules/user-profile/user-profile.module.js', () => ({
  userProfileController: routeMocks.userProfileController,
}));

const uuid = '550e8400-e29b-41d4-a716-446655440000';

describe('userProfileRouter', () => {
  let app: express.Express;

  beforeEach(async () => {
    vi.clearAllMocks();
    vi.resetModules();

    const [{ errorHandler }, { userProfileRouter }] = await Promise.all([
      import('../../../../src/common/middlewares/index.js'),
      import('../../../../src/modules/user-profile/routes/user-profile.route.js'),
    ]);

    app = express();
    app.use(express.json());
    app.use('/profiles', userProfileRouter);
    app.use(errorHandler as ErrorRequestHandler);
  });

  it('routes POST /profiles/me/profile through token-only auth', async () => {
    const response = await request(app).post('/profiles/me/profile').send({
      fullName: 'Test User',
    });

    expect(response.status).toBe(201);
    expect(response.body).toEqual({ handler: 'createMyProfile' });
    expect(routeMocks.verifyAuthOnly).toHaveBeenCalledTimes(1);
    expect(routeMocks.authenticate).not.toHaveBeenCalled();
    expect(routeMocks.userProfileController.createMyProfile).toHaveBeenCalledTimes(
      1,
    );
  });

  it('routes GET /profiles/me through full authentication', async () => {
    const response = await request(app).get('/profiles/me');

    expect(response.status).toBe(200);
    expect(response.body).toEqual({ handler: 'getMyProfile' });
    expect(routeMocks.authenticate).toHaveBeenCalledTimes(1);
    expect(routeMocks.userProfileController.getMyProfile).toHaveBeenCalledTimes(
      1,
    );
  });

  it('routes PATCH /profiles/:userId through authentication and validators', async () => {
    const response = await request(app).patch(`/profiles/${uuid}`).send({
      fullName: 'Updated User',
      address: '123 Main Street',
      phone: '1234567890',
    });

    expect(response.status).toBe(200);
    expect(response.body).toEqual({ handler: 'updateUserProfile' });
    expect(routeMocks.authenticate).toHaveBeenCalledTimes(1);
    expect(
      routeMocks.userProfileController.updateUserProfile,
    ).toHaveBeenCalledTimes(1);
  });

  it('rejects invalid userId params before update controller execution', async () => {
    const response = await request(app).patch('/profiles/not-a-uuid').send({
      fullName: 'Updated User',
    });

    expect(response.status).toBe(400);
    expect(response.body).toMatchObject({
      success: false,
      status: 400,
    });
    expect(
      routeMocks.userProfileController.updateUserProfile,
    ).not.toHaveBeenCalled();
  });

  it('rejects invalid update body before update controller execution', async () => {
    const response = await request(app).patch(`/profiles/${uuid}`).send({
      phone: '1'.repeat(21),
    });

    expect(response.status).toBe(400);
    expect(response.body).toMatchObject({
      success: false,
      status: 400,
    });
    expect(
      routeMocks.userProfileController.updateUserProfile,
    ).not.toHaveBeenCalled();
  });
});
