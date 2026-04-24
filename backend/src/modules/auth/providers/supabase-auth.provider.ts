import { StatusCodes } from 'http-status-codes';

import { CustomError } from '../../../common/errors/index.js';
import { SupabaseProvider } from '../../../db/supabaseClient.js';

import type { User, SupabaseClient } from '@supabase/supabase-js';

type VerifyAccessTokenResult = {
  user: User;
};

class SupabaseAuthProvider {
  private readonly client: SupabaseClient;

  public constructor() {
    this.client = SupabaseProvider.getClient();
  }

  public async verifyAccessToken(
    accessToken: string,
  ): Promise<VerifyAccessTokenResult> {
    const { data, error } = await this.client.auth.getUser(accessToken);

    if (error || !data.user) {
      throw new CustomError({
        message: 'Invalid or expired access token',
        status: StatusCodes.FORBIDDEN,
      });
    }

    return {
      user: data.user,
    };
  }
}

export const supabaseAuthProvider = new SupabaseAuthProvider();
