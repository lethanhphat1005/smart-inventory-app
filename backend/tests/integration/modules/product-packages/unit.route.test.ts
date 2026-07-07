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
  unitController: {
    getUnits: vi.fn((_req: Request, res: Response): void => {
      res.status(200).json({ handler: 'getUnits' });
    }),
  },
}));

vi.mock('../../../../src/modules/auth/index.js', () => ({
  authenticate: routeMocks.authenticate,
}));

vi.mock(
  '../../../../src/modules/product-packages/modules/unit.module.js',
  () => ({
    unitController: routeMocks.unitController,
  }),
);

describe('unitRouter', () => {
  let app: express.Express;

  beforeEach(async () => {
    vi.clearAllMocks();
    vi.resetModules();

    const [{ errorHandler }, { unitRouter }] = await Promise.all([
      import('../../../../src/common/middlewares/index.js'),
      import('../../../../src/modules/product-packages/routes/unit.route.js'),
    ]);

    app = express();
    app.use(express.json());
    app.use('/units', unitRouter);
    app.use(errorHandler as ErrorRequestHandler);
  });

  it('routes GET /units through authentication to the unit controller', async () => {
    const response = await request(app).get('/units');

    expect(response.status).toBe(200);
    expect(response.body).toEqual({ handler: 'getUnits' });
    expect(routeMocks.authenticate).toHaveBeenCalledTimes(1);
    expect(routeMocks.unitController.getUnits).toHaveBeenCalledTimes(1);
  });
});
