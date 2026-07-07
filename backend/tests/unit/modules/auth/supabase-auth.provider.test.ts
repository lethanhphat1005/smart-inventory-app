import { StatusCodes } from 'http-status-codes';
import { beforeEach, describe, expect, it, vi } from 'vitest';

import { supabaseAuthProvider } from '../../../../src/modules/auth/providers/supabase-auth.provider.js';

const moduleMocks = vi.hoisted(() => ({
  client: {
    auth: {
      getUser: vi.fn(),
    },
  },
  SupabaseProvider: {
    getClient: vi.fn(),
  },
}));

vi.mock('../../../../src/db/supabaseClient.js', () => {
  moduleMocks.SupabaseProvider.getClient.mockReturnValue(moduleMocks.client);

  return {
    SupabaseProvider: moduleMocks.SupabaseProvider,
  };
});

describe('supabaseAuthProvider.verifyAccessToken', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it('returns the Supabase user for a valid token', async () => {
    const supabaseUser = {
      id: 'auth-user-1',
      email: 'user@example.com',
    };

    moduleMocks.client.auth.getUser.mockResolvedValue({
      data: {
        user: supabaseUser,
      },
      error: null,
    });

    const result = await supabaseAuthProvider.verifyAccessToken('access-token');

    expect(result).toEqual({
      user: supabaseUser,
    });
    expect(moduleMocks.client.auth.getUser).toHaveBeenCalledWith(
      'access-token',
    );
  });

  it('throws forbidden error when Supabase returns an auth error', async () => {
    moduleMocks.client.auth.getUser.mockResolvedValue({
      data: {
        user: null,
      },
      error: new Error('expired token'),
    });

    await expect(
      supabaseAuthProvider.verifyAccessToken('access-token'),
    ).rejects.toThrow(
      expect.objectContaining({
        message: 'Invalid or expired access token',
        status: StatusCodes.FORBIDDEN,
      }),
    );
  });

  it('throws forbidden error when Supabase returns no user', async () => {
    moduleMocks.client.auth.getUser.mockResolvedValue({
      data: {
        user: null,
      },
      error: null,
    });

    await expect(
      supabaseAuthProvider.verifyAccessToken('access-token'),
    ).rejects.toThrow(
      expect.objectContaining({
        message: 'Invalid or expired access token',
        status: StatusCodes.FORBIDDEN,
      }),
    );
  });
});
