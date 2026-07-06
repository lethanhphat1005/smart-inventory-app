import { StatusCodes } from 'http-status-codes';
import { beforeEach, describe, expect, it, vi } from 'vitest';

import { AuditLogController } from '../../../../src/modules/audit-log/controller/audit-log.controller.js';
import { createRequest, createResponse } from '../../../helpers/index.js';

import type { ListAuditLogsResponseDto } from '../../../../src/modules/audit-log/dto/audit-log.dto.js';

type MockAuditLogService = {
  getAuditLogs: ReturnType<typeof vi.fn>;
};

const createMockAuditLogService = (): MockAuditLogService => ({
  getAuditLogs: vi.fn(),
});

describe('AuditLogController', () => {
  let auditLogService: MockAuditLogService;
  let auditLogController: AuditLogController;

  beforeEach(() => {
    auditLogService = createMockAuditLogService();
    auditLogController = new AuditLogController(auditLogService as never);
  });

  it('returns audit logs for the current store using the validated query', async () => {
    const payload: ListAuditLogsResponseDto = {
      items: [],
      meta: {
        page: 1,
        limit: 10,
        totalItems: 0,
        totalPages: 0,
      },
    };
    const req = createRequest({
      storeContext: {
        storeId: 'store-1',
        role: 'owner',
      },
    });
    const res = createResponse<ListAuditLogsResponseDto>({
      validatedQuery: {
        page: 1,
        limit: 10,
        actionType: 'delete',
      },
    });

    auditLogService.getAuditLogs.mockResolvedValue(payload);

    await auditLogController.getAuditLogs(req, res);

    expect(auditLogService.getAuditLogs).toHaveBeenCalledWith('store-1', {
      page: 1,
      limit: 10,
      actionType: 'delete',
    });
    expect(res.status).toHaveBeenCalledWith(StatusCodes.OK);
    expect(res.json).toHaveBeenCalledWith({
      success: true,
      data: payload,
    });
  });

  it('throws when store context is missing', async () => {
    const req = createRequest({});
    const res = createResponse<ListAuditLogsResponseDto>({
      validatedQuery: {
        page: 1,
        limit: 10,
      },
    });

    await expect(auditLogController.getAuditLogs(req, res)).rejects.toThrow(
      'Cannot get store ID',
    );
    expect(auditLogService.getAuditLogs).not.toHaveBeenCalled();
  });

  it('propagates service failures to async error handling', async () => {
    const req = createRequest({
      storeContext: {
        storeId: 'store-1',
        role: 'owner',
      },
    });
    const res = createResponse<ListAuditLogsResponseDto>({
      validatedQuery: {
        page: 1,
        limit: 10,
      },
    });

    auditLogService.getAuditLogs.mockRejectedValue(new Error('service failed'));

    await expect(auditLogController.getAuditLogs(req, res)).rejects.toThrow(
      'service failed',
    );
  });
});
