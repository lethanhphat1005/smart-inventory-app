import { StatusCodes } from 'http-status-codes';
import { beforeEach, describe, expect, it, vi } from 'vitest';

import { authSessionService } from '../../../../src/modules/auth/services/auth-session.service.js';

import type { Request } from 'express';

const moduleMocks = vi.hoisted(() => ({
  supabaseAuthProvider: {
    verifyAccessToken: vi.fn(),
  },
  userFacade: {
    getActiveUserByAuthUserId: vi.fn(),
  },
}));

vi.mock(
  '../../../../src/modules/auth/providers/supabase-auth.provider.js',
  () => ({
    supabaseAuthProvider: moduleMocks.supabaseAuthProvider,
  }),
);

vi.mock('../../../../src/modules/user/user.module.js', () => ({
  userFacade: moduleMocks.userFacade,
}));

const createRequest = (authorizationHeader?: string): Request => {
  return {
    header: vi.fn((name: string) => {
      if (name === 'authorization') {
        return authorizationHeader;
      }

      return undefined;
    }),
  } as unknown as Request;
};

describe('authSessionService.extractAccessToken', () => {
  it('extracts a trimmed bearer access token', () => {
    const req = createRequest('Bearer   access-token   ');

    const result = authSessionService.extractAccessToken(req);

    expect(result).toBe('access-token');
    expect(req.header).toHaveBeenCalledWith('authorization');
  });

  it('throws unauthorized error when the authorization header is missing', () => {
    const req = createRequest();

    expect(() => authSessionService.extractAccessToken(req)).toThrow(
      expect.objectContaining({
        message: 'Missing Authorization header.',
        status: StatusCodes.UNAUTHORIZED,
      }),
    );
  });

  it('throws unauthorized error when the authorization header is not bearer', () => {
    const req = createRequest('Basic token');

    expect(() => authSessionService.extractAccessToken(req)).toThrow(
      expect.objectContaining({
        message: 'Authorization header must use Bearer token.',
        status: StatusCodes.UNAUTHORIZED,
      }),
    );
  });

  it('throws unauthorized error when the bearer token is empty', () => {
    const req = createRequest('Bearer    ');

    expect(() => authSessionService.extractAccessToken(req)).toThrow(
      expect.objectContaining({
        message: 'Access token is empty.',
        status: StatusCodes.UNAUTHORIZED,
      }),
    );
  });
});

describe('authSessionService.authenticateRequest', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it('returns the active local user mapped from a valid Supabase token', async () => {
    const req = createRequest('Bearer access-token');

    moduleMocks.supabaseAuthProvider.verifyAccessToken.mockResolvedValue({
      user: {
        id: 'auth-user-1',
        email: 'user@example.com',
      },
    });
    moduleMocks.userFacade.getActiveUserByAuthUserId.mockResolvedValue({
      userId: 'user-1',
      email: 'profile@example.com',
    });

    const result = await authSessionService.authenticateRequest(req);

    expect(result).toEqual({
      userId: 'user-1',
      authUserId: 'auth-user-1',
      email: 'profile@example.com',
    });
    expect(
      moduleMocks.supabaseAuthProvider.verifyAccessToken,
    ).toHaveBeenCalledWith('access-token');
    expect(
      moduleMocks.userFacade.getActiveUserByAuthUserId,
    ).toHaveBeenCalledWith('auth-user-1');
  });

  it('throws unauthorized error when the authenticated Supabase user has no email', async () => {
    const req = createRequest('Bearer access-token');

    moduleMocks.supabaseAuthProvider.verifyAccessToken.mockResolvedValue({
      user: {
        id: 'auth-user-1',
      },
    });

    await expect(authSessionService.authenticateRequest(req)).rejects.toThrow(
      expect.objectContaining({
        message: 'Authenticated user does not have email.',
        status: StatusCodes.UNAUTHORIZED,
      }),
    );
    expect(
      moduleMocks.userFacade.getActiveUserByAuthUserId,
    ).not.toHaveBeenCalled();
  });

  it('throws unauthorized error when the local user profile is missing or inactive', async () => {
    const req = createRequest('Bearer access-token');

    moduleMocks.supabaseAuthProvider.verifyAccessToken.mockResolvedValue({
      user: {
        id: 'auth-user-1',
        email: 'user@example.com',
      },
    });
    moduleMocks.userFacade.getActiveUserByAuthUserId.mockResolvedValue(null);

    await expect(authSessionService.authenticateRequest(req)).rejects.toThrow(
      expect.objectContaining({
        message: 'User profile not found or inactive.',
        status: StatusCodes.UNAUTHORIZED,
      }),
    );
  });

  it('propagates Supabase token verification failures', async () => {
    const req = createRequest('Bearer access-token');
    const error = new Error('invalid token');

    moduleMocks.supabaseAuthProvider.verifyAccessToken.mockRejectedValue(error);

    await expect(authSessionService.authenticateRequest(req)).rejects.toThrow(
      error,
    );
    expect(
      moduleMocks.userFacade.getActiveUserByAuthUserId,
    ).not.toHaveBeenCalled();
  });

  it('propagates local profile lookup failures', async () => {
    const req = createRequest('Bearer access-token');
    const error = new Error('database unavailable');

    moduleMocks.supabaseAuthProvider.verifyAccessToken.mockResolvedValue({
      user: {
        id: 'auth-user-1',
        email: 'user@example.com',
      },
    });
    moduleMocks.userFacade.getActiveUserByAuthUserId.mockRejectedValue(error);

    await expect(authSessionService.authenticateRequest(req)).rejects.toThrow(
      error,
    );
  });
});

describe('authSessionService.verifyOnlyToken', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it('returns Supabase identity without requiring a local user profile', async () => {
    const req = createRequest('Bearer access-token');

    moduleMocks.supabaseAuthProvider.verifyAccessToken.mockResolvedValue({
      user: {
        id: 'auth-user-1',
        email: 'user@example.com',
      },
    });

    const result = await authSessionService.verifyOnlyToken(req);

    expect(result).toEqual({
      authUserId: 'auth-user-1',
      email: 'user@example.com',
    });
    expect(
      moduleMocks.supabaseAuthProvider.verifyAccessToken,
    ).toHaveBeenCalledWith('access-token');
    expect(
      moduleMocks.userFacade.getActiveUserByAuthUserId,
    ).not.toHaveBeenCalled();
  });

  it('propagates Supabase token verification failures', async () => {
    const req = createRequest('Bearer access-token');
    const error = new Error('invalid token');

    moduleMocks.supabaseAuthProvider.verifyAccessToken.mockRejectedValue(error);

    await expect(authSessionService.verifyOnlyToken(req)).rejects.toThrow(
      error,
    );
  });
});
