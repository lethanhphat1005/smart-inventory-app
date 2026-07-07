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
  chatbotBurstLimit: vi.fn(
    (_req: Request, _res: Response, next: NextFunction): void => {
      next();
    },
  ),
  chatbotRateLimit: vi.fn(
    (_req: Request, _res: Response, next: NextFunction): void => {
      next();
    },
  ),
  processChat: vi.fn((_req: Request, res: Response): void => {
    res.status(200).json({ handler: 'processChat' });
  }),
  confirmAction: vi.fn((_req: Request, res: Response): void => {
    res.status(200).json({ handler: 'confirmAction' });
  }),
  clearHistory: vi.fn((_req: Request, res: Response): void => {
    res.status(200).json({ handler: 'clearHistory' });
  }),
}));

vi.mock('../../../../src/modules/auth/index.js', () => ({
  authenticate: routeMocks.authenticate,
}));

vi.mock('../../../../src/modules/store-member/index.js', () => ({
  requireStoreContext: routeMocks.requireStoreContext,
}));

vi.mock(
  '../../../../src/modules/chat-bot/chatbot-rate-limit.middleware.js',
  () => ({
    chatbotBurstLimit: routeMocks.chatbotBurstLimit,
    chatbotRateLimit: routeMocks.chatbotRateLimit,
  }),
);

vi.mock('../../../../src/modules/chat-bot/chatbot.module.js', () => ({
  chatController: {
    processChat: routeMocks.processChat,
    confirmAction: routeMocks.confirmAction,
    clearHistory: routeMocks.clearHistory,
  },
  chatbotController: {
    processChat: routeMocks.processChat,
    confirmAction: routeMocks.confirmAction,
    clearHistory: routeMocks.clearHistory,
  },
}));

describe('chatRouter', () => {
  let app: express.Express;

  beforeEach(async () => {
    vi.clearAllMocks();
    vi.resetModules();

    routeMocks.authenticate.mockImplementation(
      (_req: Request, _res: Response, next: NextFunction): void => {
        next();
      },
    );
    routeMocks.requireStoreContext.mockImplementation(
      (_req: Request, _res: Response, next: NextFunction): void => {
        next();
      },
    );
    routeMocks.chatbotBurstLimit.mockImplementation(
      (_req: Request, _res: Response, next: NextFunction): void => {
        next();
      },
    );
    routeMocks.chatbotRateLimit.mockImplementation(
      (_req: Request, _res: Response, next: NextFunction): void => {
        next();
      },
    );

    const [{ errorHandler }, routeModule] = await Promise.all([
      import('../../../../src/common/middlewares/index.js'),
      import('../../../../src/modules/chat-bot/chatbot.route.js'),
    ]);

    app = express();
    app.use(express.json());
    app.use('/chatbot', routeModule.chatRouter);
    app.use(errorHandler as ErrorRequestHandler);
  });

  it('routes POST / through auth, store context, rate limits, validation, and controller', async () => {
    const response = await request(app)
      .post('/chatbot')
      .send({ message: 'check low stock' });

    expect(response.status).toBe(200);
    expect(response.body).toEqual({ handler: 'processChat' });
    expect(routeMocks.authenticate).toHaveBeenCalledTimes(1);
    expect(routeMocks.requireStoreContext).toHaveBeenCalledTimes(1);
    expect(routeMocks.chatbotBurstLimit).toHaveBeenCalledTimes(1);
    expect(routeMocks.chatbotRateLimit).toHaveBeenCalledTimes(1);
    expect(routeMocks.processChat).toHaveBeenCalledTimes(1);
  });

  it('rejects invalid chat messages before rate-limited controller execution', async () => {
    const response = await request(app)
      .post('/chatbot')
      .send({ message: '   ' });

    expect(response.status).toBe(400);
    expect(response.body).toMatchObject({
      success: false,
      status: 400,
    });
    expect(routeMocks.processChat).not.toHaveBeenCalled();
  });

  it('routes POST /confirm through auth, store context, validation, and controller', async () => {
    const response = await request(app).post('/chatbot/confirm').send({
      draftActionId: 'draft-1',
      isConfirmed: true,
    });

    expect(response.status).toBe(200);
    expect(response.body).toEqual({ handler: 'confirmAction' });
    expect(routeMocks.confirmAction).toHaveBeenCalledTimes(1);
    expect(routeMocks.chatbotBurstLimit).not.toHaveBeenCalled();
    expect(routeMocks.chatbotRateLimit).not.toHaveBeenCalled();
  });

  it('rejects invalid confirmation bodies before controller execution', async () => {
    const response = await request(app).post('/chatbot/confirm').send({
      draftActionId: 'draft-1',
      isConfirmed: 'yes',
    });

    expect(response.status).toBe(400);
    expect(routeMocks.confirmAction).not.toHaveBeenCalled();
  });

  it('routes DELETE /history through auth, store context, and controller', async () => {
    const response = await request(app).delete('/chatbot/history');

    expect(response.status).toBe(200);
    expect(response.body).toEqual({ handler: 'clearHistory' });
    expect(routeMocks.clearHistory).toHaveBeenCalledTimes(1);
  });

  it('stops route execution when authentication rejects the request', async () => {
    routeMocks.authenticate.mockImplementation(
      (_req: Request, res: Response): void => {
        res.status(401).json({ success: false, message: 'Unauthorized' });
      },
    );

    const response = await request(app)
      .post('/chatbot')
      .send({ message: 'check low stock' });

    expect(response.status).toBe(401);
    expect(response.body).toEqual({
      success: false,
      message: 'Unauthorized',
    });
    expect(routeMocks.requireStoreContext).not.toHaveBeenCalled();
    expect(routeMocks.processChat).not.toHaveBeenCalled();
  });

  it('stops route execution when store context middleware rejects the request', async () => {
    routeMocks.requireStoreContext.mockImplementation(
      (_req: Request, res: Response): void => {
        res.status(400).json({ success: false, message: 'Missing store' });
      },
    );

    const response = await request(app)
      .post('/chatbot')
      .send({ message: 'check low stock' });

    expect(response.status).toBe(400);
    expect(response.body).toEqual({
      success: false,
      message: 'Missing store',
    });
    expect(routeMocks.processChat).not.toHaveBeenCalled();
  });

  it('forwards controller errors through asyncWrapper to the error handler', async () => {
    routeMocks.clearHistory.mockRejectedValue(new Error('clear failed'));

    const response = await request(app).delete('/chatbot/history');

    expect(response.status).toBe(500);
    expect(response.body).toMatchObject({
      success: false,
      status: 500,
      message: 'clear failed',
    });
  });
});
