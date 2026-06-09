import { Router } from 'express';

import { storeController } from './store.module.js';
import {
  validateCreateStore,
  validateGetStoreById,
  validateDeleteStore,
  validateUpdateStore,
  validateJoinStore,
} from './store.validator.js';
import { asyncWrapper } from '../../common/middlewares/index.js';
import { requirePermission, PERMISSION } from '../access-control/index.js';
import { authenticate } from '../auth/index.js';
import { requireStoreContext } from '../store-member/index.js';

const storeRouter = Router();

storeRouter.use(authenticate);

/**
 * API endpoint: GET /api/stores
 * Lấy danh sách cửa hàng mà user hiện tại đang tham gia
 *
 * API endpoint: POST /api/stores
 * Tạo cửa hàng mới
 *
 * Body:
 *  - name: string (required) - tên cửa hàng
 *  - address?: string | null - địa chỉ cửa hàng
 *  - timezone?: string | null - múi giờ của cửa hàng
 *  - currencyCode: string (required) - tiền tệ của cửa hàng
 *
 * API endpoint: PATCH /api/stores/
 * Cập nhật thông tin cửa hàng
 *
 * Body:
 *  - name?: string - tên cửa hàng
 *  - address?: string | null - địa chỉ cửa hàng
 *  - timezone?: string | null - múi giờ của cửa hàng
 *  - currencyCode?: string - tiền tệ của cửa hàng
 */
storeRouter
  .route('/')
  .get(asyncWrapper(storeController.getStores))
  .post(validateCreateStore, asyncWrapper(storeController.createStore))
  .patch(
    requireStoreContext,
    requirePermission(PERMISSION.STORE_WRITE),
    validateUpdateStore,
    asyncWrapper(storeController.updateStore),
  );

/**
 * API endpoint: GET /api/stores/:storeId
 * Lấy chi tiết một cửa hàng theo id
 *
 * Path params:
 *  - storeId: string (UUID, required)
 *
 * API endpoint: DELETE /api/stores/:storeId
 * Xóa mềm cửa hàng theo id
 *
 * Path params:
 *  - storeId: string (UUID, required)
 */
storeRouter
  .route('/:storeId')
  .get(
    requireStoreContext,
    requirePermission(PERMISSION.STORE_READ),
    validateGetStoreById,
    asyncWrapper(storeController.getStoreById),
  )

  .delete(
    requireStoreContext,
    requirePermission(PERMISSION.STORE_WRITE),
    validateDeleteStore,
    asyncWrapper(storeController.softDeleteStore),
  );

/**
 * API endpoint: POST /api/stores/refresh-invite-code
 * Tạo mới (refresh) mã mời cho cửa hàng
 *
 * Path params:
 * - storeId: string (UUID, required)
 */
storeRouter.post(
  '/refresh-invite-code',
  requireStoreContext,
  requirePermission(PERMISSION.STORE_WRITE),
  asyncWrapper(storeController.refreshInviteCode),
);

/**
 * API endpoint: POST /api/stores/join
 * Tham gia vào cửa hàng bằng mã mời
 * * Body:
 * - inviteCode: string (required)
 */
storeRouter.post(
  '/join',
  validateJoinStore,
  asyncWrapper(storeController.joinStore),
);
export { storeRouter };
