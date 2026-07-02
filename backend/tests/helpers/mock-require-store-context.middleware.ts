import type { StoreContext } from '../../src/common/types/index.js';
import type { StoreRole } from '../../src/generated/prisma/enums.js';
import type { NextFunction, Request, Response } from 'express';

type RequestWithStoreContext = Request & {
  storeContext: StoreContext;
};

const isStoreRole = (value: string | undefined): value is StoreRole => {
  return value === 'owner' || value === 'manager' || value === 'staff';
};

export const mockRequireStoreContext = (
  req: Request,
  res: Response,
  next: NextFunction,
): void => {
  const storeId = req.header('x-store-id');

  if (!storeId) {
    res.status(400).json({
      success: false,
      status: 400,
      message: 'Store ID is required in the x-store-id header',
    });

    return;
  }

  const storeRoleHeader = req.header('x-store-role');
  const storeRole = isStoreRole(storeRoleHeader) ? storeRoleHeader : 'owner';
  const requestWithStoreContext = req as RequestWithStoreContext;

  requestWithStoreContext.storeContext = {
    storeId,
    role: storeRole,
  };

  next();
};
