import type { CurrentUser } from '../../src/common/types/index.js';
import type { NextFunction, Request, Response } from 'express';

type RequestWithUser = Request & {
  user: CurrentUser;
};

export const mockAuthenticate = (
  req: Request,
  res: Response,
  next: NextFunction,
): void => {
  if (req.header('authorization') !== 'Bearer valid-token') {
    res.status(401).json({
      success: false,
      status: 401,
      message: 'Unauthorized',
    });

    return;
  }

  const authenticatedRequest = req as RequestWithUser;

  authenticatedRequest.user = {
    userId: 'user-1',
    authUserId: 'auth-user-1',
    email: null,
  };

  next();
};
