import express from 'express';
import request from 'supertest';
import { beforeEach, describe, expect, it, vi } from 'vitest';

import type { ErrorRequestHandler, Request, Response } from 'express';

const routeMocks = vi.hoisted(() => ({
  healthCheckController: {
    getLiveness: vi.fn((_req: Request, res: Response): void => {
      res.status(200).json({ handler: 'getLiveness' });
    }),
    getReadiness: vi.fn((_req: Request, res: Response): void => {
      res.status(200).json({ handler: 'getReadiness' });
    }),
  },
}));

vi.mock('../../../../src/modules/health-check/health-check.module.js', () => ({
  healthCheckController: routeMocks.healthCheckController,
}));

describe('healthRouter', () => {
  let app: express.Express;

  beforeEach(async () => {
    vi.clearAllMocks();
    vi.resetModules();

    const [{ errorHandler }, { healthRouter }] = await Promise.all([
      import('../../../../src/common/middlewares/index.js'),
      import('../../../../src/modules/health-check/health-check.route.js'),
    ]);

    app = express();
    app.use(express.json());
    app.use('/health', healthRouter);
    app.use(errorHandler as ErrorRequestHandler);
  });

  it('routes GET /health to the liveness handler without auth middleware', async () => {
    const response = await request(app).get('/health');

    expect(response.status).toBe(200);
    expect(response.body).toEqual({ handler: 'getLiveness' });
    expect(routeMocks.healthCheckController.getLiveness).toHaveBeenCalledTimes(
      1,
    );
    expect(routeMocks.healthCheckController.getReadiness).not.toHaveBeenCalled();
  });

  it('routes GET /health/ready to the readiness handler without auth middleware', async () => {
    const response = await request(app).get('/health/ready');

    expect(response.status).toBe(200);
    expect(response.body).toEqual({ handler: 'getReadiness' });
    expect(routeMocks.healthCheckController.getReadiness).toHaveBeenCalledTimes(
      1,
    );
    expect(routeMocks.healthCheckController.getLiveness).not.toHaveBeenCalled();
  });
});
