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
    transactionController: {
      getTransactions: vi.fn((_req: Request, res: Response): void => {
        res.status(200).json({ handler: 'getTransactions' });
      }),
      getTransactionById: vi.fn((_req: Request, res: Response): void => {
        res.status(200).json({ handler: 'getTransactionById' });
      }),
      createImportTransaction: vi.fn((_req: Request, res: Response): void => {
        res.status(201).json({ handler: 'createImportTransaction' });
      }),
      createExportTransaction: vi.fn((_req: Request, res: Response): void => {
        res.status(201).json({ handler: 'createExportTransaction' });
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
    TRANSACTION_READ: 'TRANSACTION_READ',
    TRANSACTION_WRITE: 'TRANSACTION_WRITE',
  },
  requirePermission: routeMocks.requirePermission,
}));

vi.mock('../../../../src/modules/transactions/transaction.module.js', () => ({
  transactionController: routeMocks.transactionController,
}));

const uuid = '550e8400-e29b-41d4-a716-446655440000';

describe('transactionRouter', () => {
  let app: express.Express;

  beforeEach(async () => {
    vi.clearAllMocks();
    vi.resetModules();

    const [{ errorHandler }, { transactionRouter }] = await Promise.all([
      import('../../../../src/common/middlewares/index.js'),
      import('../../../../src/modules/transactions/transaction.route.js'),
    ]);

    app = express();
    app.use(express.json());
    app.use('/transactions', transactionRouter);
    app.use(errorHandler as ErrorRequestHandler);
  });

  it('routes GET /transactions through auth, store context, read permission, and query validator', async () => {
    const response = await request(app).get(
      '/transactions?page=2&limit=25&sortBy=totalPrice&sortOrder=asc&type=import',
    );

    expect(response.status).toBe(200);
    expect(response.body).toEqual({ handler: 'getTransactions' });
    expect(routeMocks.authenticate).toHaveBeenCalledTimes(1);
    expect(routeMocks.requireStoreContext).toHaveBeenCalledTimes(1);
    expect(routeMocks.requirePermission).toHaveBeenCalledWith(
      'TRANSACTION_READ',
    );
    expect(routeMocks.permissionMiddleware).toHaveBeenCalledTimes(1);
    expect(
      routeMocks.transactionController.getTransactions,
    ).toHaveBeenCalledTimes(1);
  });

  it('rejects invalid list query before controller execution', async () => {
    const response = await request(app).get('/transactions?limit=101');

    expect(response.status).toBe(400);
    expect(response.body).toMatchObject({
      success: false,
      status: 400,
    });
    expect(
      routeMocks.transactionController.getTransactions,
    ).not.toHaveBeenCalled();
  });

  it('routes GET /transactions/:transactionId through read permission and params validator', async () => {
    const response = await request(app).get(`/transactions/${uuid}`);

    expect(response.status).toBe(200);
    expect(response.body).toEqual({ handler: 'getTransactionById' });
    expect(routeMocks.requirePermission).toHaveBeenCalledWith(
      'TRANSACTION_READ',
    );
    expect(
      routeMocks.transactionController.getTransactionById,
    ).toHaveBeenCalledTimes(1);
  });

  it('rejects invalid transactionId params before controller execution', async () => {
    const response = await request(app).get('/transactions/not-a-uuid');

    expect(response.status).toBe(400);
    expect(response.body).toMatchObject({
      success: false,
      status: 400,
      message: 'Invalid transactionId',
    });
    expect(
      routeMocks.transactionController.getTransactionById,
    ).not.toHaveBeenCalled();
  });

  it('routes POST /transactions/import through write permission and body validator', async () => {
    const response = await request(app)
      .post('/transactions/import')
      .send({
        note: 'Restock',
        items: [{ productPackageId: uuid, quantity: 2, unitPrice: 12000 }],
      });

    expect(response.status).toBe(201);
    expect(response.body).toEqual({ handler: 'createImportTransaction' });
    expect(routeMocks.requirePermission).toHaveBeenCalledWith(
      'TRANSACTION_WRITE',
    );
    expect(
      routeMocks.transactionController.createImportTransaction,
    ).toHaveBeenCalledTimes(1);
  });

  it('routes POST /transactions/export through write permission and body validator', async () => {
    const response = await request(app)
      .post('/transactions/export')
      .send({
        items: [{ productPackageId: uuid, quantity: 1, unitPrice: 15000 }],
      });

    expect(response.status).toBe(201);
    expect(response.body).toEqual({ handler: 'createExportTransaction' });
    expect(routeMocks.requirePermission).toHaveBeenCalledWith(
      'TRANSACTION_WRITE',
    );
    expect(
      routeMocks.transactionController.createExportTransaction,
    ).toHaveBeenCalledTimes(1);
  });

  it('rejects invalid create payload before import controller execution', async () => {
    const response = await request(app).post('/transactions/import').send({
      items: [],
    });

    expect(response.status).toBe(400);
    expect(response.body).toMatchObject({
      success: false,
      status: 400,
      message: 'Items cannot be empty',
    });
    expect(
      routeMocks.transactionController.createImportTransaction,
    ).not.toHaveBeenCalled();
  });

  it('rejects duplicate package ids before export controller execution', async () => {
    const response = await request(app)
      .post('/transactions/export')
      .send({
        items: [
          { productPackageId: uuid, quantity: 1, unitPrice: 1000 },
          { productPackageId: uuid, quantity: 2, unitPrice: 1000 },
        ],
      });

    expect(response.status).toBe(400);
    expect(response.body).toMatchObject({
      success: false,
      status: 400,
      message: 'Duplicate productPackageId in transaction items',
    });
    expect(
      routeMocks.transactionController.createExportTransaction,
    ).not.toHaveBeenCalled();
  });
});
