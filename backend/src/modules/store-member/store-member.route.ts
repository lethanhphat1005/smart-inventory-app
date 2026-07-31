import { Router } from 'express';

import { requireStoreContext } from './middlewares/require-store-context.middleware.js'; // tránh circular dependencies
import { storeMemberController } from './store-member.module.js';
import {
  paramsSchema,
  updateStoreMemberRoleBodySchema,
} from './store-member.validator.js';
import { asyncWrapper, validator } from '../../common/middlewares/index.js';
import { requirePermission } from '../access-control/require-permission.middleware.js';
import { PERMISSION } from '../access-control/role-permission.constant.js';
import { authenticate } from '../auth/index.js';

const storeMemberRouter = Router();

storeMemberRouter.use(authenticate, requireStoreContext);

/**
 * @api {GET} /api/store-members
 * Lấy danh sách thành viên cửa hàng
 * @description Trả về danh sách thông tin cá nhân (profile) và vai trò (role)
 * của các thành viên đang hoạt động (active) trong một cửa hàng cụ thể.
 * Yêu cầu người gọi request phải có quyền truy cập vào cửa hàng này.
 * * @headers
 * - Authorization: Bearer <access_token> (Bắt buộc: Token đăng nhập)
 * - x-store-id: <store_uuid> (Bắt buộc:
 * ID của cửa hàng đang thao tác để verify storeContext)
 * * @path_params
 * - storeId: string (Bắt buộc: UUID của cửa hàng cần lấy danh sách thành viên)
 * * @body
 * (Không yêu cầu Body)
 */
storeMemberRouter.get('/', asyncWrapper(storeMemberController.getStoreMembers));

/**
 * @api {DELETE} /api/store-members/:userId Xóa thành viên khỏi cửa hàng
 * @description Thực hiện xóa mềm (soft-delete) một người dùng
 * khỏi cửa hàng bằng cách chuyển `activeStatus` thành `inactive`.
 * * @headers
 * - Authorization: Bearer <access_token> (Bắt buộc: Token đăng nhập)
 * - x-store-id: <store_uuid> (Bắt buộc: ID của cửa hàng đang thao tác)
 * * @path_params
 * - userId: string (Bắt buộc: UUID của người bị xóa)
 */

storeMemberRouter.delete(
  '/:userId',
  requirePermission(PERMISSION.STORE_MEMBER_DELETE),
  validator(paramsSchema, 'params'),
  asyncWrapper(storeMemberController.removeUser),
);

/**
 * @api {PATCH} /api/store-members/:userId/role Thay đổi vai trò thành viên
 * @description Chỉ Owner mới có quyền thay đổi vai trò
 * (role) của thành viên trong cửa hàng.
 * * @headers
 * - Authorization: Bearer <access_token> (Bắt buộc: Token đăng nhập)
 * - x-store-id: <store_uuid> (Bắt buộc: ID của cửa hàng đang thao tác)
 * * @path_params
 * - userId: string (Bắt buộc: UUID của người cần đổi role)
 * * @body
 * - role: "manager" | "staff"
 */
storeMemberRouter.patch(
  '/:userId/role',
  requirePermission(PERMISSION.STORE_MEMBER_WRITE),
  validator(paramsSchema, 'params'),
  validator(updateStoreMemberRoleBodySchema, 'body'),
  asyncWrapper(storeMemberController.updateRole),
);

export { storeMemberRouter };
