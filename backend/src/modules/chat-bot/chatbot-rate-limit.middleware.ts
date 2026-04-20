import rateLimit from 'express-rate-limit';

import { requireReqUser } from '../../common/utils/require-req.js';

import type { Request } from 'express';

/**
 * Middleware giới hạn số lượng tin nhắn từ người dùng
 * windowMs: 1 phút
 * max: 15 request (Mỗi nhân viên chỉ được chat 15 câu/phút)
 */
export const chatbotRateLimit = rateLimit({
  windowMs: 1 * 60 * 1000,
  max: 15,
  standardHeaders: true,
  legacyHeaders: false,
  message: {
    success: false,
    message:
      'Bạn đang nhắn tin quá nhanh. Vui lòng đợi một chút để em xử lý xong các yêu cầu trước nhé! 📦✨',
  },
  keyGenerator: (req: Request) => {
    try {
      const user = requireReqUser(req);

      return user.userId;
    } catch {
      return req.ip || 'unknown-ip';
    }
  },
});
