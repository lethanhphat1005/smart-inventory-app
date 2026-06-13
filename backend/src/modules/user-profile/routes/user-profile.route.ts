import { Router } from 'express';

import { asyncWrapper, validator } from '../../../common/middlewares/index.js';
import { authenticate } from '../../auth/index.js';
// Import middleware mới vừa tách
import { verifyAuthOnly } from '../../user-profile/middleware/optional-profile.middleware.js';
import { userProfileRouter } from '../index.js';
import { userProfileController } from '../user-profile.module.js';
import {
  paramsSchema,
  updateUserProfileBodySchema,
} from '../validator/user-profile.validator.js';

const router = Router();

router.post(
  '/me/profile',
  verifyAuthOnly,
  asyncWrapper(userProfileController.createMyProfile),
);

router.get(
  '/me',
  authenticate,
  asyncWrapper(userProfileController.getMyProfile),
);

/**
 * @api {PATCH} /api/auth/:userId Cập nhật thông tin người dùng
 * @description Cho phép người dùng cập nhật thông tin cá nhân của chính mình.
 * Hệ thống đã có bẫy lỗi 403 để chặn việc lấy
 * ID của người khác cập nhật trái phép.
 * * @headers
 * - Authorization: Bearer <access_token> (Bắt buộc: Token đăng nhập)
 * * @path_params
 * - userId: string (Bắt buộc: UUID của người dùng cần cập nhật thông tin)
 * * @body
 * - fullName: string (Không bắt buộc: Tên đầy đủ mới, tối đa 255 ký tự)
 * - address: string (Không bắt buộc: Địa chỉ mới, tối đa 255 ký tự)
 * - phone: string (Không bắt buộc: Số điện thoại mới, tối đa 20 ký tự)
 */
userProfileRouter.patch(
  '/:userId',
  authenticate,
  validator(paramsSchema, 'params'),
  validator(updateUserProfileBodySchema, 'body'),
  asyncWrapper(userProfileController.updateUserProfile),
);

export { router as userProfileRouter };
