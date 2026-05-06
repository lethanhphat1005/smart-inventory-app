import rateLimit, { ipKeyGenerator } from 'express-rate-limit';

import { requireReqUser } from '../../common/utils/require-req.js';

import type { Request, Response } from 'express';
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
    message: 'You are working too fast. Please wait a moment! 📦✨',
  },
  keyGenerator: (req: Request, res: Response) => {
    try {
      const user = requireReqUser(req);

      return user.userId;
    } catch {
      type ERLReq = Parameters<typeof ipKeyGenerator>[0];
      type ERLRes = Parameters<typeof ipKeyGenerator>[1];

      return ipKeyGenerator(req as unknown as ERLReq, res as unknown as ERLRes);
    }
  },
});

export const chatbotBurstLimit = rateLimit({
  windowMs: 5 * 1000,
  max: 3,
  message: {
    success: false,
    message: 'Too fast! Please slow down 🐢',
  },
  keyGenerator: (req: Request, res: Response) => {
    try {
      const user = requireReqUser(req);

      return user.userId;
    } catch {
      type ERLReq = Parameters<typeof ipKeyGenerator>[0];
      type ERLRes = Parameters<typeof ipKeyGenerator>[1];

      return ipKeyGenerator(req as unknown as ERLReq, res as unknown as ERLRes);
    }
  },
});
