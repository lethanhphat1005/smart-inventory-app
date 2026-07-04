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
    auditLogController: {
      getAuditLogs: vi.fn((_req: Request, res: Response): void => {
        res.status(200).json({ handler: 'getAuditLogs' });
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
    AUDIT_LOG_READ: 'AUDIT_LOG_READ',
  },
  requirePermission: routeMocks.requirePermission,
}));

vi.mock('../../../../src/modules/audit-log/audit-log.module.js', () => ({
  auditLogController: routeMocks.auditLogController,
}));

describe('auditLogRouter', () => {
  let app: express.Express;

  beforeEach(async () => {
    vi.clearAllMocks();
    vi.resetModules();

    const [{ errorHandler }, { auditLogRouter }] = await Promise.all([
      import('../../../../src/common/middlewares/index.js'),
      import('../../../../src/modules/audit-log/audit-log.route.js'),
    ]);

    app = express();
    app.use(express.json());
    app.use('/audit-logs', auditLogRouter);
    app.use(errorHandler as ErrorRequestHandler);
  });

  it('routes GET /audit-logs through auth, store context, audit-log read permission, and query validator', async () => {
    const response = await request(app).get(
      '/audit-logs?page=2&limit=25&sortOrder=asc&actionType=update',
    );

    expect(response.status).toBe(200);
    expect(response.body).toEqual({ handler: 'getAuditLogs' });
    expect(routeMocks.authenticate).toHaveBeenCalledTimes(1);
    expect(routeMocks.requireStoreContext).toHaveBeenCalledTimes(1);
    expect(routeMocks.requirePermission).toHaveBeenCalledWith(
      'AUDIT_LOG_READ',
    );
    expect(routeMocks.permissionMiddleware).toHaveBeenCalledTimes(1);
    expect(routeMocks.auditLogController.getAuditLogs).toHaveBeenCalledTimes(
      1,
    );
  });

  it('rejects invalid query before controller execution', async () => {
    const response = await request(app).get('/audit-logs?limit=101');

    expect(response.status).toBe(400);
    expect(response.body).toMatchObject({
      success: false,
      status: 400,
    });
    expect(routeMocks.auditLogController.getAuditLogs).not.toHaveBeenCalled();
  });
});
