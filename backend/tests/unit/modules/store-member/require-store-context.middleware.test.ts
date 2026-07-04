import { StatusCodes } from 'http-status-codes';
import { beforeEach, describe, expect, it, vi } from 'vitest';

import { requireStoreContext } from '../../../../src/modules/store-member/middlewares/require-store-context.middleware.js';

import type { MockRequest } from '../../../helpers/index.js';
import type { NextFunction, Request, Response } from 'express';

type TestRequest = Request & MockRequest;

const moduleMocks = vi.hoisted(() => ({
  storeMemberService: {
    getMembershipByUserIdAndStoreId: vi.fn(),
  },
}));

vi.mock('../../../../src/modules/store-member/store-member.module.js', () => ({
  storeMemberService: moduleMocks.storeMemberService,
}));

const createRequest = (
  overrides: MockRequest & { headers?: { storeId?: string } },
): TestRequest => {
  return {
    ...overrides,
    header: vi.fn((name: string) => {
      if (name === 'x-store-id') {
        return overrides.headers?.storeId;
      }

      return undefined;
    }),
  } as unknown as TestRequest;
};

describe('requireStoreContext', () => {
  let next: NextFunction;
  const res = {} as Response;

  beforeEach(() => {
    vi.clearAllMocks();
    next = vi.fn();
  });

  it('stores active membership context on the request', async () => {
    const req = createRequest({
      headers: { storeId: 'store-1' },
      user: {
        userId: 'user-1',
        authUserId: 'auth-user-1',
        email: null,
      },
    });

    moduleMocks.storeMemberService.getMembershipByUserIdAndStoreId.mockResolvedValue(
      {
        userId: 'user-1',
        storeId: 'store-1',
        role: 'manager',
      },
    );

    await requireStoreContext(req, res, next);

    expect(
      moduleMocks.storeMemberService.getMembershipByUserIdAndStoreId,
    ).toHaveBeenCalledWith('user-1', 'store-1');
    expect(req.storeContext).toEqual({
      storeId: 'store-1',
      role: 'manager',
    });
    expect(next).toHaveBeenCalledWith();
  });

  it('passes bad request error when x-store-id header is missing', async () => {
    const req = createRequest({
      user: {
        userId: 'user-1',
        authUserId: 'auth-user-1',
        email: null,
      },
    });

    await requireStoreContext(req, res, next);

    expect(next).toHaveBeenCalledWith(
      expect.objectContaining({
        message: 'Store ID is required in the x-store-id header',
        status: StatusCodes.BAD_REQUEST,
      }),
    );
  });

  it('passes unauthorized error when request user is missing', async () => {
    const req = createRequest({
      headers: { storeId: 'store-1' },
    });

    await requireStoreContext(req, res, next);

    expect(next).toHaveBeenCalledWith(
      expect.objectContaining({
        message: 'User is not authenticated',
        status: StatusCodes.UNAUTHORIZED,
      }),
    );
  });

  it('passes forbidden error when user has no store membership', async () => {
    const req = createRequest({
      headers: { storeId: 'store-1' },
      user: {
        userId: 'user-1',
        authUserId: 'auth-user-1',
        email: null,
      },
    });

    moduleMocks.storeMemberService.getMembershipByUserIdAndStoreId.mockResolvedValue(
      null,
    );

    await requireStoreContext(req, res, next);

    expect(next).toHaveBeenCalledWith(
      expect.objectContaining({
        message: 'User does not have access to the specified store',
        status: StatusCodes.FORBIDDEN,
      }),
    );
  });
});
