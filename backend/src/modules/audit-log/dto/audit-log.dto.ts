import { Prisma } from '../../../generated/prisma/client.js';

import type {
  ListPaginationQueryDto,
  PaginationResponseDto,
} from '../../../common/types/index.js';
import type { AuditActionType } from '../../../generated/prisma/enums.js';
import type { AuditLog } from '../audit-log.type.js';

export type AuditLogListItemDto = AuditLog;

export type ListAuditLogsQueryDto = ListPaginationQueryDto<'performedAt'> & {
  entityType?: string;
  actionType?: AuditActionType;
  userId?: string;
  startDate?: string;
  endDate?: string;
  search?: string;
};

export type ListAuditLogsResponseDto =
  PaginationResponseDto<AuditLogListItemDto>;

export type CreateAuditLogDto = {
  actionType: 'create' | 'update' | 'delete';
  entityType: string | null;
  entityId: string | null;
  userId: string;
  storeId: string;
  oldValue: Prisma.InputJsonValue | null;
  newValue: Prisma.InputJsonValue | null;
  note?: string | null;
};
