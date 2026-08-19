import type { DbClient } from '../../../common/types/db.type.js';
import type { TransactionType } from '../../../generated/prisma/client.js';

export class SmartDecisionRepository {
  constructor(private readonly db: DbClient) {}

  async findActiveInventoriesByStore(storeId: string) {
    return this.db.inventory.findMany({
      where: {
        activeStatus: 'active',
        productPackage: {
          product: {
            storeId,
          },
        },
      },
      include: {
        productPackage: {
          include: {
            product: {
              include: {
                category: true,
              },
            },
          },
        },
      },
    });
  }

  async getProductPackageSales(productPackageId: string, createdAt: Date) {
    return this.db.transactionDetail.aggregate({
      _sum: {
        quantity: true,
      },
      where: {
        productPackageId,
        transaction: {
          type: 'export' satisfies TransactionType,
          status: 'completed',
          createdAt: {
            gte: createdAt,
          },
        },
      },
    });
  }

  async findActiveStores() {
    return this.db.store.findMany({
      where: {
        activeStatus: 'active',
      },
      select: {
        storeId: true,
      },
    });
  }
}
