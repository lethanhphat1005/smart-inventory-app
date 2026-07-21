import rateLimit from 'express-rate-limit';
import { StatusCodes } from 'http-status-codes';

import { sendResponse } from '../utils/api-response.util.js';
import { logger } from '../utils/logger.util.js';

export const rateLimiter = ({
  windowMs = 15 * 60 * 1000,
  max = 100,
}: {
  windowMs?: number;
  max?: number;
}) => {
  return rateLimit({
    windowMs,
    max,
    standardHeaders: 'draft-7',
    legacyHeaders: false,
    handler: (req, res) => {
      // thêm log vì pinoLogger đã ignore >= 400 status code
      logger.warn(
        {
          req: {
            method: req.method,
            url: req.originalUrl,
            ip: req.ip,
          },
          res: {
            statusCode: StatusCodes.TOO_MANY_REQUESTS,
          },
        },
        'Rate limit exceeded',
      );

      sendResponse.error(
        res,
        StatusCodes.TOO_MANY_REQUESTS,
        'Too many requests. Please try again later!',
      );
    },
  });
};
