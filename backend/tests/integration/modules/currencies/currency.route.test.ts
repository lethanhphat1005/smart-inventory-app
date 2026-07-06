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
  currencyController: {
    getCurrencies: vi.fn((_req: Request, res: Response): void => {
      res.status(200).json({ handler: 'getCurrencies' });
    }),
  },
}));

vi.mock('../../../../src/modules/auth/index.js', () => ({
  authenticate: routeMocks.authenticate,
}));

vi.mock('../../../../src/modules/currencies/currency.module.js', () => ({
  currencyController: routeMocks.currencyController,
}));

describe('currencyRouter', () => {
  let app: express.Express;

  beforeEach(async () => {
    vi.clearAllMocks();
    vi.resetModules();

    routeMocks.authenticate.mockImplementation(
      (_req: Request, _res: Response, next: NextFunction): void => {
        next();
      },
    );
    routeMocks.currencyController.getCurrencies.mockImplementation(
      (_req: Request, res: Response): void => {
        res.status(200).json({ handler: 'getCurrencies' });
      },
    );

    const [{ errorHandler }, { currencyRouter }] = await Promise.all([
      import('../../../../src/common/middlewares/index.js'),
      import('../../../../src/modules/currencies/currency.route.js'),
    ]);

    app = express();
    app.use(express.json());
    app.use('/currencies', currencyRouter);
    app.use(errorHandler as ErrorRequestHandler);
  });

  it('routes GET /currencies through authentication', async () => {
    const response = await request(app).get('/currencies');

    expect(response.status).toBe(200);
    expect(response.body).toEqual({ handler: 'getCurrencies' });
    expect(routeMocks.authenticate).toHaveBeenCalledTimes(1);
    expect(routeMocks.currencyController.getCurrencies).toHaveBeenCalledTimes(
      1,
    );
  });

  it('does not call the controller when authentication rejects the request', async () => {
    routeMocks.authenticate.mockImplementation(
      (_req: Request, res: Response): void => {
        res.status(401).json({
          success: false,
          message: 'Unauthorized',
        });
      },
    );

    const response = await request(app).get('/currencies');

    expect(response.status).toBe(401);
    expect(response.body).toEqual({
      success: false,
      message: 'Unauthorized',
    });
    expect(routeMocks.currencyController.getCurrencies).not.toHaveBeenCalled();
  });

  it('forwards controller errors through asyncWrapper to the error handler', async () => {
    routeMocks.currencyController.getCurrencies.mockRejectedValue(
      new Error('currency lookup failed'),
    );

    const response = await request(app).get('/currencies');

    expect(response.status).toBe(500);
    expect(response.body).toMatchObject({
      success: false,
      status: 500,
      message: 'currency lookup failed',
    });
  });
});
