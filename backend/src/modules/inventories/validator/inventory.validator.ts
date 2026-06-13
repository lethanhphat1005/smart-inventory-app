/* Định nghĩa các schema kiểm tra dữ liệu đầu vào (validation)
bằng thư viện Zod cho module Inventory.
Các middleware trong file này sẽ được gắn vào
Route để chặn các request không hợp lệ
trước khi chúng đi vào xử lý tại Controller. */

import { z } from 'zod';

import { validateSchema } from '../../../common/utils/index.js';

import type { Request, Response, NextFunction } from 'express';

export const paramsSchema = z.object({
  productPackageId: z.uuid('Invalid productPackageId'),
});

// Tự động ép kiểu (coerce) và gán giá trị mặc định
// (default) cho các tham số phân trang, sắp xếp
export const listInventoriesQuerySchema = z.object({
  page: z.coerce.number().int().min(1).optional().default(1),
  limit: z.coerce.number().int().min(1).max(100).optional().default(10),
  sortBy: z
    .enum(['updatedAt', 'quantity', 'reorderThreshold'])
    .optional()
    .default('updatedAt'),
  sortOrder: z.enum(['asc', 'desc']).optional().default('desc'),
  keyword: z.string().trim().min(1).max(255).optional(),
  categoryId: z.string().optional(),
  inventoryStatus: z.enum(['inStock', 'lowStock', 'outOfStock']).optional(),
});

export const updateInventoryBodySchema = z
  .object({
    reorderThreshold: z.number().int().min(0).nullable().optional(),
  })
  // NOTE: Sử dụng hàm refine để đảm bảo người dùng gửi lên ít nhất 1 trường
  //  cần cập nhật, tránh payload rỗng
  .refine(
    (data) => Object.keys(data).length > 0,
    'Request body cannot be empty',
  );

export const createInventoryBodySchema = z.object({
  productPackageId: z.string(),
  quantity: z.number().int().min(0).default(0),
  reorderThreshold: z.number().int().min(0).nullable().optional(),
});

export const batchAdjustInventoryBodySchema = z.object({
  items: z
    .array(
      z.object({
        productPackageId: z.string().uuid('ID sản phẩm phải là định dạng UUID'),
        type: z.enum(['set', 'increase', 'decrease']),
        quantity: z.number().min(0, 'Số lượng không được nhỏ hơn 0'),
        reason: z.string().nullish(),
        note: z.string().nullish(),
      }),
    )
    .min(1, 'Danh sách điều chỉnh phải có ít nhất 1 sản phẩm'),
});

// Middleware lưu trữ kết quả query đã validate
// an toàn vào res.locals để Controller truy xuất
export const validateGetInventories = (
  req: Request,
  res: Response,
  next: NextFunction,
): void => {
  res.locals.validatedQuery = validateSchema(
    listInventoriesQuerySchema,
    req.query,
  );

  next();
};
