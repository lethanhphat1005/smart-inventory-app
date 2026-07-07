import { StatusCodes } from 'http-status-codes';
import { beforeEach, describe, expect, it, vi } from 'vitest';

import { requirePermission } from '../../../../src/modules/access-control/require-permission.middleware.js';
import { PERMISSION } from '../../../../src/modules/access-control/role-permission.constant.js';

import type { MockRequest } from '../../../helpers/index.js';
import type { NextFunction, Request, Response } from 'express';

type TestRequest = Request & MockRequest;

describe('requirePermission', () => {
  let next: NextFunction;
  const res = {} as Response;

  beforeEach(() => {
    next = vi.fn();
  });

  it('calls next without an error when the store role has the permission', () => {
    const req = {
      storeContext: {
        storeId: 'store-1',
        role: 'staff',
      },
    } as TestRequest;

    requirePermission(PERMISSION.TRANSACTION_WRITE)(req, res, next);

    expect(next).toHaveBeenCalledWith();
  });

  it('normalizes lower-case roles before checking permissions', () => {
    const req = {
      storeContext: {
        storeId: 'store-1',
        role: 'owner',
      },
    } as TestRequest;

    requirePermission(PERMISSION.STORE_WRITE)(req, res, next);

    expect(next).toHaveBeenCalledWith();
  });

  it('passes forbidden error when the store role does not have the permission', () => {
    const req = {
      storeContext: {
        storeId: 'store-1',
        role: 'staff',
      },
    } as TestRequest;

    requirePermission(PERMISSION.PRODUCT_WRITE)(req, res, next);

    expect(next).toHaveBeenCalledWith(
      expect.objectContaining({
        message: 'You do not have permission to perform this action',
        status: StatusCodes.FORBIDDEN,
      }),
    );
  });

  it('passes bad request error when store context is missing', () => {
    const req = {} as TestRequest;

    requirePermission(PERMISSION.PRODUCT_READ)(req, res, next);

    expect(next).toHaveBeenCalledWith(
      expect.objectContaining({
        message: 'Cannot get store ID',
        status: StatusCodes.BAD_REQUEST,
      }),
    );
  });
});
