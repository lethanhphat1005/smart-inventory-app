import { StatusCodes } from 'http-status-codes';

import { CustomError } from '../../../common/errors/index.js';
import { requireReqUser } from '../../../common/utils/index.js';
import { storeMemberService } from '../store-member.module.js';

import type { Request, Response, NextFunction } from 'express';

export const requireStoreContext = async (
  req: Request,
  _res: Response,
  next: NextFunction,
): Promise<void> => {
  try {
    const storeId = req.header('x-store-id');

    if (!storeId) {
      throw new CustomError({
        message: 'Store ID is required in the x-store-id header',
        status: StatusCodes.BAD_REQUEST,
      });
    }

    const currentUser = requireReqUser(req);

    const membership = await storeMemberService.getMembershipByUserIdAndStoreId(
      currentUser.userId,
      storeId,
    );

    if (!membership) {
      throw new CustomError({
        message: 'User does not have access to the specified store',
        status: StatusCodes.FORBIDDEN,
      });
    }

    req.storeContext = {
      storeId,
      role: membership.role,
    };

    next();
  } catch (error) {
    next(error);
  }
};
