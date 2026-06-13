import { StatusCodes } from 'http-status-codes';

import { sendResponse } from '../utils/index.js';

import type { Request, Response } from 'express';

export const notFoundHandler = (req: Request, res: Response) => {
  return sendResponse.error(
    res,
    StatusCodes.NOT_FOUND,
    `Route not found: ${req.method} ${req.originalUrl}`,
  );
};
