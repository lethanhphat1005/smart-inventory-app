import { beforeEach, describe, expect, it, vi } from 'vitest';

import { authenticate } from '../../../../src/modules/auth/middlewares/authenticate.middleware.js';
import { createRequest, createResponse } from '../../../helpers/index.js';

import type { MockRequest } from '../../../helpers/index.js';
import type { NextFunction, Request } from 'express';

type TestRequest = Request & MockRequest;

const moduleMocks = vi.hoisted(() => ({
  authSessionService: {
    authenticateRequest: vi.fn(),
  },
}));

vi.mock(
  '../../../../src/modules/auth/services/auth-session.service.js',
  () => ({
    authSessionService: moduleMocks.authSessionService,
  }),
);

describe('authenticate', () => {
  let next: NextFunction;
  const res = createResponse();

  beforeEach(() => {
    vi.clearAllMocks();
    next = vi.fn();
  });

  it('attaches the authenticated user to the request and continues', async () => {
    const req = createRequest({}) as TestRequest;
    const currentUser = {
      userId: 'user-1',
      authUserId: 'auth-user-1',
      email: 'user@example.com',
    };

    moduleMocks.authSessionService.authenticateRequest.mockResolvedValue(
      currentUser,
    );

    await authenticate(req, res, next);

    expect(
      moduleMocks.authSessionService.authenticateRequest,
    ).toHaveBeenCalledWith(req);
    expect(req.user).toEqual(currentUser);
    expect(next).toHaveBeenCalledWith();
  });

  it('forwards authentication errors', async () => {
    const req = createRequest({}) as TestRequest;
    const error = new Error('authentication failed');

    moduleMocks.authSessionService.authenticateRequest.mockRejectedValue(error);

    await authenticate(req, res, next);

    expect(next).toHaveBeenCalledWith(error);
    expect(req.user).toBeUndefined();
  });
});
