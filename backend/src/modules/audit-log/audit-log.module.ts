/* Xử lý Dependency Injection (DI) cho module Audit Log.
Khởi tạo và liên kết (wiring) các instance của Repository,
Service và Controller với nhau.
Đóng vai trò là Composition Root cấp module. */
import { prisma } from '../../db/prismaClient.js';
import { AuditLogController } from '../audit-log/controller/audit-log.controller.js';
import { AuditLogRepository } from '../audit-log/repository/audit-log.repository.js';
import { AuditLogService } from '../audit-log/service/audit-log.service.js';

export const auditLogRepository = new AuditLogRepository(prisma);
export const auditLogService = new AuditLogService(auditLogRepository);

export const auditLogController = new AuditLogController(auditLogService);
