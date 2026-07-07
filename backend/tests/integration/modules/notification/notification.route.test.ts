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
  registerToken: vi.fn((_req: Request, res: Response): void => {
    res.status(200).json({ handler: 'registerToken' });
  }),
  removeToken: vi.fn((_req: Request, res: Response): void => {
    res.status(200).json({ handler: 'removeToken' });
  }),
  testSend: vi.fn((_req: Request, res: Response): void => {
    res.status(200).json({ handler: 'testSend' });
  }),
  getNotifications: vi.fn((_req: Request, res: Response): void => {
    res.status(200).json({ handler: 'getNotifications' });
  }),
  markAsRead: vi.fn((_req: Request, res: Response): void => {
    res.status(200).json({ handler: 'markAsRead' });
  }),
  deleteNotification: vi.fn((_req: Request, res: Response): void => {
    res.status(200).json({ handler: 'deleteNotification' });
  }),
  markAllAsRead: vi.fn((_req: Request, res: Response): void => {
    res.status(200).json({ handler: 'markAllAsRead' });
  }),
}));

vi.mock('../../../../src/modules/auth/index.js', () => ({
  authenticate: routeMocks.authenticate,
}));

vi.mock(
  '../../../../src/modules/notification/controllers/notification.controller.js',
  () => ({
    NotificationController: vi.fn(() => {
      return {
        registerToken: routeMocks.registerToken,
        removeToken: routeMocks.removeToken,
        testSend: routeMocks.testSend,
        getNotifications: routeMocks.getNotifications,
        markAsRead: routeMocks.markAsRead,
        deleteNotification: routeMocks.deleteNotification,
        markAllAsRead: routeMocks.markAllAsRead,
      };
    }),
  }),
);

vi.mock(
  '../../../../src/modules/notification/repositories/notification.repository.js',
  () => ({
    NotificationRepository: vi.fn(() => {
      return {};
    }),
  }),
);

vi.mock(
  '../../../../src/modules/notification/services/notification.service.js',
  () => ({
    NotificationService: vi.fn(() => {
      return {};
    }),
  }),
);

describe('notificationRouter', () => {
  let app: express.Express;

  beforeEach(async () => {
    vi.clearAllMocks();
    vi.resetModules();

    routeMocks.authenticate.mockImplementation(
      (_req: Request, _res: Response, next: NextFunction): void => {
        next();
      },
    );

    const [{ errorHandler }, notificationRouteModule] = await Promise.all([
      import('../../../../src/common/middlewares/index.js'),
      import('../../../../src/modules/notification/notification.route.js'),
    ]);

    app = express();
    app.use(express.json());
    app.use('/notifications', notificationRouteModule.default);
    app.use(errorHandler as ErrorRequestHandler);
  });

  it('routes POST /register-token through auth, body validation, and controller', async () => {
    const response = await request(app)
      .post('/notifications/register-token')
      .send({ token: 'token-1' });

    expect(response.status).toBe(200);
    expect(response.body).toEqual({ handler: 'registerToken' });
    expect(routeMocks.authenticate).toHaveBeenCalledTimes(1);
    expect(routeMocks.registerToken).toHaveBeenCalledTimes(1);
  });

  it('rejects invalid register-token bodies before controller execution', async () => {
    const response = await request(app)
      .post('/notifications/register-token')
      .send({ token: '   ' });

    expect(response.status).toBe(400);
    expect(response.body).toMatchObject({
      success: false,
      status: 400,
    });
    expect(routeMocks.registerToken).not.toHaveBeenCalled();
  });

  it('routes POST /remove-token through auth, body validation, and controller', async () => {
    const response = await request(app)
      .post('/notifications/remove-token')
      .send({ token: 'token-1' });

    expect(response.status).toBe(200);
    expect(response.body).toEqual({ handler: 'removeToken' });
    expect(routeMocks.authenticate).toHaveBeenCalledTimes(1);
    expect(routeMocks.removeToken).toHaveBeenCalledTimes(1);
  });

  it('routes POST /test-send through auth and controller', async () => {
    const response = await request(app).post('/notifications/test-send').send({
      title: 'Title',
      body: 'Body',
      type: 'GENERAL',
    });

    expect(response.status).toBe(200);
    expect(response.body).toEqual({ handler: 'testSend' });
    expect(routeMocks.testSend).toHaveBeenCalledTimes(1);
  });

  it('routes GET /notifications through auth and controller', async () => {
    const response = await request(app).get('/notifications');

    expect(response.status).toBe(200);
    expect(response.body).toEqual({ handler: 'getNotifications' });
    expect(routeMocks.getNotifications).toHaveBeenCalledTimes(1);
  });

  it('routes PATCH /:notificationId/read through auth and controller', async () => {
    const response = await request(app).patch(
      '/notifications/notification-1/read',
    );

    expect(response.status).toBe(200);
    expect(response.body).toEqual({ handler: 'markAsRead' });
    expect(routeMocks.markAsRead).toHaveBeenCalledTimes(1);
  });

  it('routes DELETE /:notificationId through auth and controller', async () => {
    const response = await request(app).delete('/notifications/notification-1');

    expect(response.status).toBe(200);
    expect(response.body).toEqual({ handler: 'deleteNotification' });
    expect(routeMocks.deleteNotification).toHaveBeenCalledTimes(1);
  });

  it('routes PATCH /read-all through auth and controller', async () => {
    const response = await request(app).patch('/notifications/read-all');

    expect(response.status).toBe(200);
    expect(response.body).toEqual({ handler: 'markAllAsRead' });
    expect(routeMocks.markAllAsRead).toHaveBeenCalledTimes(1);
    expect(routeMocks.markAsRead).not.toHaveBeenCalled();
  });

  it('does not call controllers when authentication rejects the request', async () => {
    routeMocks.authenticate.mockImplementation(
      (_req: Request, res: Response): void => {
        res.status(401).json({
          success: false,
          message: 'Unauthorized',
        });
      },
    );

    const response = await request(app)
      .post('/notifications/register-token')
      .send({ token: 'token-1' });

    expect(response.status).toBe(401);
    expect(response.body).toEqual({
      success: false,
      message: 'Unauthorized',
    });
    expect(routeMocks.registerToken).not.toHaveBeenCalled();
  });

  it('forwards controller errors through asyncWrapper to the error handler', async () => {
    routeMocks.getNotifications.mockRejectedValue(
      new Error('notification lookup failed'),
    );

    const response = await request(app).get('/notifications');

    expect(response.status).toBe(500);
    expect(response.body).toMatchObject({
      success: false,
      status: 500,
      message: 'notification lookup failed',
    });
  });
});
