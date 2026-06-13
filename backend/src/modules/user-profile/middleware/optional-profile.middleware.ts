import { supabaseAuthProvider } from '../../auth/providers/supabase-auth.provider.js';
import { authSessionService } from '../../auth/services/auth-session.service.js';

import type { Request, Response, NextFunction } from 'express';

/**
 * Middleware xác thực token nhưng không yêu cầu user phải có profile trong DB.
 * Phù hợp cho các route khởi tạo profile.
 */
export const verifyAuthOnly = async (
  req: Request,
  res: Response,
  next: NextFunction,
) => {
  try {
    const accessToken = authSessionService.extractAccessToken(req);
    const { user } = await supabaseAuthProvider.verifyAccessToken(accessToken);

    // Gán thông tin tối thiểu vào req.user để Controller sử dụng
    req.user = {
      userId: '', // Sẽ được tạo sau khi create profile
      authUserId: user.id!,
      email: user.email!,
    };

    next();
  } catch (error) {
    next(error);
  }
};
