import { Router } from 'express';

import { asyncWrapper } from '../../common/middlewares/index.js';
import { PERMISSION, requirePermission } from '../access-control/index.js';
import { auditLogController } from '../audit-log/audit-log.module.js';
import { validateGetAuditLogs } from '../audit-log/validator/audit-log.validator.js';
import { authenticate } from '../auth/index.js';
import { requireStoreContext } from '../store-member/index.js';

const auditLogRouter = Router();

// NOTE: Áp dụng middleware xác thực và bắt buộc có ngữ cảnh cửa hàng
// (storeId) cho toàn bộ API để đảm bảo tính cô lập dữ liệu
auditLogRouter.use(authenticate, requireStoreContext);

auditLogRouter.get(
  '/',
  requirePermission(PERMISSION.AUDIT_LOG_READ),
  validateGetAuditLogs,
  asyncWrapper(auditLogController.getAuditLogs),
);

export { auditLogRouter };
