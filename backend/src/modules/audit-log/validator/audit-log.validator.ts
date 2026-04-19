import { z } from 'zod';

import { validateSchema } from '../../../common/utils/index.js';

import type { Request, Response, NextFunction } from 'express';

const listAuditLogsQuerySchema = z.object({
  page: z.coerce.number().int().min(1).optional().default(1),
  limit: z.coerce.number().int().min(1).max(100).optional().default(10),
  sortBy: z.enum(['performedAt']).optional().default('performedAt'),
  sortOrder: z.enum(['asc', 'desc']).optional().default('desc'),
  entityType: z.string().trim().optional(),
  actionType: z.enum(['create', 'update', 'delete']).optional(),
  userId: z.string().optional(),

  // NOTE: Bắt buộc định dạng thời gian truyền lên phải tuân thủ
  // nghiêm ngặt chuẩn ISO 8601 để parse đúng múi giờ
  startDate: z.string().optional(),
  endDate: z.string().optional(),
  search: z.string().optional(),
});

// Middleware lưu trữ kết quả query đã validate an toàn
// vào res.locals để Controller truy xuất
export const validateGetAuditLogs = (
  req: Request,
  res: Response,
  next: NextFunction,
): void => {
  res.locals.validatedQuery = validateSchema(
    listAuditLogsQuerySchema,
    req.query,
  );

  next();
};
