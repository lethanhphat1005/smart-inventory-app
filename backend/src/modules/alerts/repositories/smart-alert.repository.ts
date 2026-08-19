import type { DbClient } from '../../../common/types/db.type.js';
import type { TransactionType } from '../../../generated/prisma/client.js';

export class SmartAlertRepository {
  constructor(private readonly db: DbClient) {}

  async findInventoryById(inventoryId: string) {
    return this.db.inventory.findUnique({
      where: {
        inventoryId,
      },
      include: {
        productPackage: {
          include: {
            product: true,
          },
        },
      },
    });
  }

  async findLowStockInventories() {
    return this.db.inventory.findMany({
      where: {
        reorderThreshold: {
          not: null,
        },
        quantity: {
          lte: this.db.inventory.fields.reorderThreshold,
        },
        activeStatus: 'active',
      },
      include: {
        productPackage: {
          include: {
            product: true,
          },
        },
      },
    });
  }

  async findInventoriesByIds(inventoryIds: string[]) {
    return this.db.inventory.findMany({
      where: {
        inventoryId: {
          in: inventoryIds,
        },
      },
      include: {
        productPackage: {
          include: {
            product: true,
          },
        },
      },
    });
  }

  async findTargetMembers(storeId: string) {
    return this.db.storeMember.findMany({
      where: {
        storeId,
        role: {
          in: ['owner', 'manager'],
        },
        activeStatus: 'active',
      },
      select: {
        userId: true,
      },
    });
  }

  async getTransactionStats(
    storeId: string,
    type: TransactionType,
    createdAt: Date,
  ) {
    return this.db.transaction.aggregate({
      where: {
        storeId,
        type,
        status: 'completed',
        createdAt: {
          gte: createdAt,
        },
      },
      _avg: {
        totalPrice: true,
      },
      _count: {
        transactionId: true,
      },
    });
  }
}
