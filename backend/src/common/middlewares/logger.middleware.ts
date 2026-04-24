import { pinoHttp } from 'pino-http';

import { logger } from '../utils/index.js';

import type { Request, Response, RequestHandler } from 'express';

export const pinoLogger: RequestHandler = pinoHttp({
  logger,

  customLogLevel: (_req, res, err) => {
    // bỏ log các error response cho errorHandler
    if (err || res.statusCode >= 500) {
      return 'silent';
    }
    if (res.statusCode >= 400) {
      return 'silent';
    }

    return 'info';
  },

  autoLogging: {
    ignore: (req) => req.url === '/api/health',
  },

  serializers: {
    req: (req: Request) => ({
      method: req.method,
      url: req.url,
    }),
    res: (res: Response) => ({
      statusCode: res.statusCode,
    }),
  },
});
