import { Router } from 'express';

import { categoryController } from './category.module.js';
import {
  validateCreateCategory,
  validateUpdateCategory,
} from './category.validator.js';
import { asyncWrapper } from '../../common/middlewares/index.js';
import { PERMISSION, requirePermission } from '../access-control/index.js';
import { authenticate } from '../auth/index.js';
import { requireStoreContext } from '../stores/index.js';

const categoryRouter = Router();

categoryRouter.use(authenticate, requireStoreContext);

/**
 * API endpoint: GET /api/categories
 * Lấy danh sách category của cửa hàng hiện tại
 *
 * API endpoint: POST /api/categories
 * Tạo category mới
 *
 * Body:
 *  - name: string (required) - tên category
 *  - description?: string | null - mô tả category
 */
categoryRouter
  .route('/')
  .get(
    requirePermission(PERMISSION.CATEGORY_READ),
    asyncWrapper(categoryController.findAll),
  )
  .post(
    requirePermission(PERMISSION.CATEGORY_WRITE),
    validateCreateCategory,
    asyncWrapper(categoryController.createOne),
  );

/**
 * API endpoint: PATCH /api/categories/:categoryId
 * Cập nhật custom category
 *
 * Path params:
 *  - categoryId: string (UUID, required)
 *
 * Body:
 *  - name?: string - tên category
 *  - description?: string | null - mô tả category
 *
 * API endpoint: DELETE /api/categories/:categoryId
 * Xóa custom category
 *
 * Path params:
 *  - categoryId: string (UUID, required)
 *
 * Body:
 *  - canReassignToUncategorized?: boolean - nếu `true`,
 *    backend sẽ chuyển toàn bộ product sang `Uncategorized` trước khi xóa
 *
 * Quy trình gọi API 2 lần:
 *   Lần 1: Frontend gọi API với `canReassignToUncategorized = false`
 *     - Nếu category rỗng, backend xóa luôn
 *     - Nếu category đang được dùng, backend trả 409 CATEGORY_IN_USE
 *       - UI hiển thị popup hỏi người dùng có muốn chuyển
 *         các Product sang 'Uncategorized' không
 *       - User đồng ý
 *   Lần 2: Sau khi user đồng ý:
 *     - Frontend gọi lại cùng endpoint với `canReassignToUncategorized = true`
 *     - Backend chuyển product sang Uncategorized
 *       rồi xóa category trong transaction
 *
 * Lưu ý:
 *  - Nếu category vẫn đang được product sử dụng
 *    và chưa truyền `canReassignToUncategorized = true`,
 *    backend có thể trả về `409 CATEGORY_IN_USE`
 */
categoryRouter
  .route('/:categoryId')
  .patch(
    requirePermission(PERMISSION.CATEGORY_WRITE),
    validateUpdateCategory,
    asyncWrapper(categoryController.updateOne),
  )
  .delete(
    requirePermission(PERMISSION.CATEGORY_WRITE),
    asyncWrapper(categoryController.deleteCustomCategory),
  );

/**
 * API endpoint: POST /api/categories/:categoryId/hide
 * Ẩn một category mặc định khỏi cửa hàng hiện tại
 *
 * Path params:
 *  - categoryId: string (UUID, required)
 */
categoryRouter.post(
  '/:categoryId/hide',
  requirePermission(PERMISSION.CATEGORY_WRITE),
  asyncWrapper(categoryController.softDeleteDefaultOne),
);

/**
 * API endpoint: DELETE /api/categories/:categoryId/unhide
 * Bỏ ẩn một category mặc định khỏi cửa hàng hiện tại
 *
 * Path params:
 *  - categoryId: string (UUID, required)
 */
categoryRouter.delete(
  '/:categoryId/unhide',
  requirePermission(PERMISSION.CATEGORY_WRITE),
  asyncWrapper(categoryController.restoreDefaultOne),
);

export { categoryRouter };
