import {
  getPaginationSkip,
  normalizePagination,
} from '../../../common/utils/index.js';
import { Prisma } from '../../../generated/prisma/client.js';

import type { DbClient } from '../../../common/types/index.js';
import type {
  AuditLogListItemDto,
  ListAuditLogsQueryDto,
  CreateAuditLogDto,
} from '../dto/audit-log.dto.js';

export class AuditLogRepository {
  constructor(private readonly db: DbClient) {}

  async findManyByStoreId(
    storeId: string,
    // Bổ sung thêm type { search?: string } để TypeScript không báo lỗi
    // trong trường hợp DTO của bạn chưa định nghĩa trường search
    query: ListAuditLogsQueryDto & { search?: string },
  ): Promise<{ items: AuditLogListItemDto[]; totalItems: number }> {
    const { page, limit } = normalizePagination(query);
    const {
      sortBy = 'performedAt',
      sortOrder = 'desc',
      entityType,
      actionType,
      userId,
      startDate,
      endDate,
      search,
    } = query;

    const where: Prisma.AuditLogWhereInput = {
      storeId,
      ...(entityType && { entityType }),
      ...(actionType && { actionType }),
      ...(userId && { userId }),
      ...((startDate || endDate) && {
        performedAt: {
          ...(startDate && { gte: new Date(startDate) }),
          ...(endDate && { lte: new Date(endDate) }),
        },
      }),
    };

    if (search) {
      where.OR = [
        {
          note: {
            contains: search,
            mode: 'insensitive',
          },
        },
      ];
    }
    const [items, totalItems] = await this.db.$transaction([
      this.db.auditLog.findMany({
        where,
        orderBy: {
          [sortBy]: sortOrder,
        },
        skip: getPaginationSkip({ page, limit }),
        take: limit,
      }),
      this.db.auditLog.count({
        where,
      }),
    ]);

    return {
      items,
      totalItems,
    };
  }

  async createLog(data: CreateAuditLogDto): Promise<void> {
    await this.db.auditLog.create({
      data: {
        actionType: data.actionType,
        entityType: data.entityType,
        entityId: data.entityId,
        userId: data.userId,
        storeId: data.storeId,
        oldValue: data.oldValue ?? Prisma.DbNull,
        newValue: data.newValue ?? Prisma.DbNull,
        note: data.note ?? null,
      },
    });
  }
}
