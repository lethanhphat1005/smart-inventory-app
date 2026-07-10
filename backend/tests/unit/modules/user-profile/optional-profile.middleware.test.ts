import { beforeEach, describe, expect, it, vi } from 'vitest';

import { verifyAuthOnly } from '../../../../src/modules/user-profile/middleware/optional-profile.middleware.js';
import { createRequest, createResponse } from '../../../helpers/index.js';

import type { MockRequest } from '../../../helpers/index.js';
import type { NextFunction, Request, Response } from 'express';

type TestRequest = Request & MockRequest;

const moduleMocks = vi.hoisted(() => ({
  authSessionService: {
    extractAccessToken: vi.fn(),
  },
  supabaseAuthProvider: {
    verifyAccessToken: vi.fn(),
  },
}));

vi.mock(
  '../../../../src/modules/auth/services/auth-session.service.js',
  () => ({
    authSessionService: moduleMocks.authSessionService,
  }),
);

vi.mock(
  '../../../../src/modules/auth/providers/supabase-auth.provider.js',
  () => ({
    supabaseAuthProvider: moduleMocks.supabaseAuthProvider,
  }),
);

describe('verifyAuthOnly', () => {
  let req: TestRequest;
  let res: Response;
  let next: NextFunction;

  beforeEach(() => {
    vi.clearAllMocks();
    req = createRequest({}) as TestRequest;
    res = createResponse();
    next = vi.fn();
  });

  it('sets minimal request user context from a valid access token', async () => {
    moduleMocks.authSessionService.extractAccessToken.mockReturnValue(
      'token-1',
    );
    moduleMocks.supabaseAuthProvider.verifyAccessToken.mockResolvedValue({
      user: {
        id: 'auth-user-1',
        email: 'user@example.com',
      },
    });

    await verifyAuthOnly(req, res, next);

    expect(
      moduleMocks.authSessionService.extractAccessToken,
    ).toHaveBeenCalledWith(req);
    expect(
      moduleMocks.supabaseAuthProvider.verifyAccessToken,
    ).toHaveBeenCalledWith('token-1');
    expect(req.user).toEqual({
      userId: '',
      authUserId: 'auth-user-1',
      email: 'user@example.com',
    });
    expect(next).toHaveBeenCalledWith();
  });

  it('passes token extraction failures to next', async () => {
    const error = new Error('missing token');

    moduleMocks.authSessionService.extractAccessToken.mockImplementation(() => {
      throw error;
    });

    await verifyAuthOnly(req, res, next);

    expect(next).toHaveBeenCalledWith(error);
    expect(
      moduleMocks.supabaseAuthProvider.verifyAccessToken,
    ).not.toHaveBeenCalled();
  });

  it('passes provider verification failures to next', async () => {
    const error = new Error('invalid token');

    moduleMocks.authSessionService.extractAccessToken.mockReturnValue(
      'token-1',
    );
    moduleMocks.supabaseAuthProvider.verifyAccessToken.mockRejectedValue(error);

    await verifyAuthOnly(req, res, next);

    expect(next).toHaveBeenCalledWith(error);
  });
});
