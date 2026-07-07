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
  requireStoreContext: vi.fn(
    (_req: Request, _res: Response, next: NextFunction): void => {
      next();
    },
  ),
  smartDecisionController: {
    getReorderSuggestions: vi.fn((_req: Request, res: Response): void => {
      res.status(200).json({ handler: 'getReorderSuggestions' });
    }),
  },
}));

vi.mock('../../../../src/modules/auth/index.js', () => ({
  authenticate: routeMocks.authenticate,
}));

vi.mock('../../../../src/modules/store-member/index.js', () => ({
  requireStoreContext: routeMocks.requireStoreContext,
}));

vi.mock('../../../../src/modules/alerts/smart-decision.module.js', () => ({
  smartDecisionController: routeMocks.smartDecisionController,
}));

describe('smartDecisionRouter', () => {
  let app: express.Express;

  beforeEach(async () => {
    vi.clearAllMocks();
    vi.resetModules();

    const [{ errorHandler }, { smartDecisionRouter }] = await Promise.all([
      import('../../../../src/common/middlewares/index.js'),
      import('../../../../src/modules/alerts/smart-decision.route.js'),
    ]);

    app = express();
    app.use(express.json());
    app.use('/smart-decisions', smartDecisionRouter);
    app.use(errorHandler as ErrorRequestHandler);
  });

  it('routes GET /smart-decisions/reorder-suggestions through auth and store context', async () => {
    const response = await request(app).get(
      '/smart-decisions/reorder-suggestions',
    );

    expect(response.status).toBe(200);
    expect(response.body).toEqual({ handler: 'getReorderSuggestions' });
    expect(routeMocks.authenticate).toHaveBeenCalledTimes(1);
    expect(routeMocks.requireStoreContext).toHaveBeenCalledTimes(1);
    expect(
      routeMocks.smartDecisionController.getReorderSuggestions,
    ).toHaveBeenCalledTimes(1);
  });

  it('forwards controller errors through async error handling', async () => {
    routeMocks.smartDecisionController.getReorderSuggestions.mockRejectedValue(
      new Error('service failed'),
    );

    const response = await request(app).get(
      '/smart-decisions/reorder-suggestions',
    );

    expect(response.status).toBe(500);
    expect(response.body).toMatchObject({
      success: false,
      status: 500,
    });
  });
});
