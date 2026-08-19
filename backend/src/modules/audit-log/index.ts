/* Điểm public entry-point của toàn bộ module Audit Log.
Chỉ đóng vai trò re-export router
và các thành phần public để các module khác gọi tới,
tuyệt đối không chứa logic xử lý tại đây. */
export { auditLogRouter } from './audit-log.route.js';
export { auditLogService } from './audit-log.module.js';
export { AuditLogRepository } from './repository/audit-log.repository.js';
