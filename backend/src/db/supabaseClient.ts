import { createClient, type SupabaseClient } from '@supabase/supabase-js';
import { StatusCodes } from 'http-status-codes';

import { CustomError } from '../common/errors/index.js';

/* Sử dụng Singleton Class cho supabase client
giúp đồng nhất instance trên toàn hệ thống */
export class SupabaseProvider {
  private static supabase: SupabaseClient | null = null;

  static getClient = (): SupabaseClient => {
    if (this.supabase) {
      return this.supabase;
    }

    // NOTE: SUPABASE_ANON_KEY cho backend end-user client
    // NOTE: SUPABASE_SERVICE_ROLE_KEY cho backend admin client
    const supabaseUrl = process.env.SUPABASE_URL;
    // const supabaseServiceKey = process.env.SUPABASE_ANON_KEY;
    const supabaseServiceKey = process.env.SUPABASE_SERVICE_ROLE_KEY;

    if (!supabaseUrl || !supabaseServiceKey) {
      throw new CustomError({
        message:
          'Missing SUPABASE_URL or SUPABASE_ANON_KEY environment variables.',
        status: StatusCodes.INTERNAL_SERVER_ERROR,
      });
    }

    this.supabase = createClient(supabaseUrl, supabaseServiceKey, {
      auth: {
        persistSession: false, // Tắt lưu session vào localStorage

        // Tắt tự động refresh token
        // vì backend thường không cần refresh token như frontend
        autoRefreshToken: false,

        detectSessionInUrl: false, // Tắt phát hiện session từ URL
      },
    });

    return this.supabase;
  };
}
