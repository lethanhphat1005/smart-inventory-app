import {
  getPaginationSkip,
  buildDateRangeFilter,
} from '../../../common/utils/index.js';
import { Prisma } from '../../../generated/prisma/client.js';

import type {
  DbClient,
  ListPaginationResponseDto,
} from '../../../common/types/index.js';
import type {
  TransactionResponseDto,
  CreateTransactionData,
  ListTransactionsQueryDto,
  TransactionListItemDto,
  DetailTransactionResponseDto,
} from '../transaction.dto.js';

export class TransactionRepository {
  constructor(private readonly db: DbClient) {}

  async findManyByStoreId(
    storeId: string,
    query: ListTransactionsQueryDto,
  ): Promise<ListPaginationResponseDto<TransactionListItemDto>> {
    const { page, limit, sortBy, sortOrder, type, userId, startDate, endDate } =
      query;

    const dateRange = buildDateRangeFilter(startDate, endDate);

    const where: Prisma.TransactionWhereInput = {
      storeId,
      ...(type && { type }),
      ...(userId && { userId }),
      ...(dateRange && {
        createdAt: dateRange,
      }),
    };

    const [items, totalItems] = await this.db.$transaction([
      this.db.transaction.findMany({
        where,
        orderBy: {
          [sortBy]: sortOrder,
        },
        skip: getPaginationSkip({ page, limit }),
        take: limit,
        select: {
          transactionId: true,
          type: true,
          note: true,
          status: true,
          createdAt: true,
          totalPrice: true,
          _count: {
            select: {
              transactionDetails: true,
            },
          },
        },
      }),
      this.db.transaction.count({
        where,
      }),
    ]);

    return {
      items: items.map((item) => ({
        transactionId: item.transactionId,
        type: item.type,
        note: item.note,
        status: item.status,
        createdAt: item.createdAt,
        totalPrice: item.totalPrice.toNumber(),
        itemCount: item._count.transactionDetails,
      })),
      totalItems,
    };
  }

  async findOne(
    storeId: string,
    transactionId: string,
  ): Promise<DetailTransactionResponseDto | null> {
    const transaction = await this.db.transaction.findFirst({
      where: {
        transactionId,
        storeId,
      },
      select: {
        transactionId: true,
        type: true,
        note: true,
        status: true,
        createdAt: true,
        totalPrice: true,
        transactionDetails: {
          orderBy: {
            productPackageId: 'asc',
          },
          select: {
            quantity: true,
            unitPrice: true,
            productPackage: {
              select: {
                productPackageId: true,
                displayName: true,
                product: {
                  select: {
                    imageUrl: true,
                  },
                },
              },
            },
          },
        },
      },
    });

    if (!transaction) {
      return null;
    }

    return {
      transactionId: transaction.transactionId,
      type: transaction.type,
      note: transaction.note,
      status: transaction.status,
      createdAt: transaction.createdAt,
      totalPrice: transaction.totalPrice.toNumber(),
      items: transaction.transactionDetails.map((item) => ({
        productPackageId: item.productPackage.productPackageId,
        displayName: item.productPackage.displayName,
        imageUrl: item.productPackage.product.imageUrl,
        quantity: item.quantity,
        unitPrice: item.unitPrice.toNumber(),
      })),
    };
  }

  async createOne(
    data: CreateTransactionData,
  ): Promise<TransactionResponseDto> {
    const transaction = await this.db.transaction.create({
      data: {
        type: data.type,
        status: 'completed',
        note: data.note ?? null,
        totalPrice: data.totalPrice,
        userId: data.userId,
        storeId: data.storeId,
      },
      select: {
        transactionId: true,
        type: true,
        note: true,
        status: true,
        createdAt: true,
        totalPrice: true,
      },
    });

    return {
      ...transaction,
      totalPrice: transaction.totalPrice.toNumber(),
    };
  }
}
