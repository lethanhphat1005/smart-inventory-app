import {
  getPaginationSkip,
  normalizePagination,
} from '../../../common/utils/index.js';
import { Prisma } from '../../../generated/prisma/client.js';

import type { DbClient } from '../../../common/types/index.js';
import type {
  CreateInventoryDto,
  InventoryDetailResponseDto,
  InventoryListItemDto,
  InventoryResponseDto,
  ListInventoriesQueryDto,
  UpdateInventoryDto,
  AdjustInventoryForTransactionDto,
} from '../dto/inventory.dto.js';
import type { InventoryStatus } from '../inventory.type.js';

const inventorySelect = {
  inventoryId: true,
  quantity: true,
  reorderThreshold: true,
  updatedAt: true,
  productPackage: {
    select: {
      productPackageId: true,
      displayName: true,
      importPrice: true,
      sellingPrice: true,
      unit: {
        select: {
          unitId: true,
          code: true,
          name: true,
        },
      },
      product: {
        select: {
          productId: true,
          name: true,
          imageUrl: true,
          brand: true,
          category: {
            select: {
              categoryId: true,
              name: true,
              description: true,
            },
          },
        },
      },
    },
  },
} satisfies Prisma.InventorySelect;

export class InventoryRepository {
  constructor(private readonly prisma: DbClient) {}

  private mapInventoryStatus(
    quantity: number,
    reorderThreshold: number | null,
  ): InventoryStatus {
    if (quantity <= 0) {
      return 'outOfStock';
    }

    if (reorderThreshold !== null && quantity <= reorderThreshold) {
      return 'lowStock';
    }

    return 'inStock';
  }

  private toInventoryListItem(
    item: Prisma.InventoryGetPayload<{ select: typeof inventorySelect }>,
  ): InventoryListItemDto {
    return {
      inventoryId: item.inventoryId,
      quantity: item.quantity,
      reorderThreshold: item.reorderThreshold,
      updatedAt: item.updatedAt,
      inventoryStatus: this.mapInventoryStatus(
        item.quantity,
        item.reorderThreshold,
      ),
      productPackage: {
        productPackageId: item.productPackage.productPackageId,
        displayName: item.productPackage.displayName,
        importPrice: item.productPackage.importPrice
          ? Number(item.productPackage.importPrice)
          : null,
        sellingPrice: item.productPackage.sellingPrice
          ? Number(item.productPackage.sellingPrice)
          : null,
        unit: item.productPackage.unit,
        product: item.productPackage.product,
      },
    };
  }

  private buildInventoryWhere(
    storeId: string,
    query?: Partial<ListInventoriesQueryDto>,
  ): Prisma.InventoryWhereInput {
    const keyword = query?.keyword?.trim();
    const categoryId = query?.categoryId;

    return {
      activeStatus: 'active',
      productPackage: {
        activeStatus: 'active',
        product: {
          storeId,
          activeStatus: 'active',
          ...(categoryId && {
            categoryId,
          }),
          ...(keyword && {
            OR: [
              { name: { contains: keyword, mode: 'insensitive' } },
              { brand: { contains: keyword, mode: 'insensitive' } },
              {
                productPackages: {
                  some: {
                    activeStatus: 'active',
                    OR: [
                      {
                        displayName: { contains: keyword, mode: 'insensitive' },
                      },
                    ],
                  },
                },
              },
            ],
          }),
        },
      },
    };
  }

  async findManyByStoreId(
    storeId: string,
    query: ListInventoriesQueryDto,
  ): Promise<{ items: InventoryListItemDto[]; totalItems: number }> {
    const { page, limit } = normalizePagination(query);
    const { sortBy = 'updatedAt', sortOrder = 'desc', inventoryStatus } = query;

    const where = this.buildInventoryWhere(storeId, query);

    const [rawItems, totalItems] = await this.prisma.$transaction([
      this.prisma.inventory.findMany({
        where,
        orderBy: { [sortBy]: sortOrder },
        skip: getPaginationSkip({ page, limit }),
        take: limit,
        select: inventorySelect,
      }),
      this.prisma.inventory.count({ where }),
    ]);

    let items = rawItems.map((item) => this.toInventoryListItem(item));

    if (inventoryStatus) {
      items = items.filter((item) => item.inventoryStatus === inventoryStatus);
    }

    return {
      items,
      totalItems: inventoryStatus ? items.length : totalItems,
    };
  }

  async findLowStockByStoreId(
    storeId: string,
    query: ListInventoriesQueryDto,
  ): Promise<{ items: InventoryListItemDto[]; totalItems: number }> {
    const { page, limit } = normalizePagination(query);
    const skip = getPaginationSkip({ page, limit });
    const { keyword, categoryId } = query;

    let keywordCondition = Prisma.empty;

    if (keyword) {
      const search = `%${keyword}%`;

      keywordCondition = Prisma.sql`AND (p.name ILIKE ${search} OR pp.display_name ILIKE ${search})`;
    }

    let categoryCondition = Prisma.empty;

    if (categoryId) {
      categoryCondition = Prisma.sql`AND CAST(p.category_id AS uuid) = CAST(${categoryId} AS uuid)`;
    }

    const commonJoinsAndWhere = Prisma.sql`
      FROM "Inventory" i
      INNER JOIN "ProductPackage" pp ON i.product_package_id = pp.product_package_id
      INNER JOIN "Product" p ON pp.product_id = p.product_id
      WHERE CAST(p.store_id AS uuid) = CAST(${storeId} AS uuid)
        AND i.active_status = 'active'::"ActiveStatus"
        AND p.active_status = 'active'::"ActiveStatus"
        AND pp.active_status = 'active'::"ActiveStatus"
        AND i.reorder_threshold IS NOT NULL
        AND i.quantity <= i.reorder_threshold
        ${keywordCondition}
        ${categoryCondition}
    `;

    const totalRaw = await this.prisma.$queryRaw<{ count: bigint }[]>`
      SELECT COUNT(i.inventory_id) as count
      ${commonJoinsAndWhere}
    `;
    const totalItems = Number(totalRaw[0]?.count || 0);

    if (totalItems === 0) {
      return { items: [], totalItems: 0 };
    }

    const idsRaw = await this.prisma.$queryRaw<{ inventory_id: string }[]>`
      SELECT i.inventory_id
      ${commonJoinsAndWhere}
      ORDER BY i.updated_at DESC
      LIMIT ${limit} OFFSET ${skip}
    `;

    const inventoryIds = idsRaw.map((row) => row.inventory_id);

    const rawItems = await this.prisma.inventory.findMany({
      where: {
        inventoryId: { in: inventoryIds },
      },
      select: inventorySelect,
      orderBy: { updatedAt: 'desc' },
    });

    const items = rawItems.map((item) => this.toInventoryListItem(item));

    return { items, totalItems };
  }

  async findOneByProductPackageId(
    storeId: string,
    productPackageId: string,
  ): Promise<InventoryDetailResponseDto | null> {
    const inventory = await this.prisma.inventory.findFirst({
      where: {
        productPackageId,
        activeStatus: 'active',
        productPackage: {
          activeStatus: 'active',
          product: { storeId, activeStatus: 'active' },
        },
      },
      select: inventorySelect,
    });

    if (!inventory) {
      return null;
    }

    return this.toInventoryListItem(inventory);
  }

  async findManyActiveByProductPackageIds(
    storeId: string,
    productPackageIds: string[],
  ): Promise<
    Array<
      Pick<
        InventoryResponseDto,
        'inventoryId' | 'quantity' | 'productPackageId'
      > & {
        productPackage: { displayName: string | null };
      }
    >
  > {
    if (productPackageIds.length === 0) {
      return [];
    }

    return await this.prisma.inventory.findMany({
      where: {
        productPackageId: {
          in: productPackageIds,
        },
        activeStatus: 'active',
        productPackage: {
          activeStatus: 'active',
          product: {
            storeId,
            activeStatus: 'active',
          },
        },
      },
      select: {
        inventoryId: true,
        productPackageId: true,
        quantity: true,
        productPackage: {
          select: {
            displayName: true,
          },
        },
      },
    });
  }

  async updateOne(
    inventoryId: string,
    data: UpdateInventoryDto,
  ): Promise<InventoryDetailResponseDto> {
    const inventory = await this.prisma.inventory.update({
      where: { inventoryId },
      data,
      select: inventorySelect,
    });

    return this.toInventoryListItem(inventory);
  }

  async adjustQuantity(
    inventoryId: string,
    type: 'set' | 'increase' | 'decrease',
    quantityValue: number,
  ): Promise<InventoryDetailResponseDto> {
    let updateData: Prisma.InventoryUpdateInput = {};

    if (type === 'set') {
      updateData = { quantity: quantityValue };
    } else if (type === 'increase') {
      updateData = { quantity: { increment: quantityValue } };
    } else if (type === 'decrease') {
      updateData = { quantity: { decrement: quantityValue } };
    }

    const inventory = await this.prisma.inventory.update({
      where: { inventoryId },
      data: updateData,
      select: inventorySelect,
    });

    return this.toInventoryListItem(inventory);
  }

  async checkProductPackageBelongsToStore(
    storeId: string,
    productPackageId: string,
  ): Promise<boolean> {
    const count = await this.prisma.productPackage.count({
      where: { productPackageId, product: { storeId } },
    });

    return count > 0;
  }

  async getInventoryStatusByProductPackageId(productPackageId: string) {
    return await this.prisma.inventory.findUnique({
      where: { productPackageId },
      select: {
        inventoryId: true,
        activeStatus: true,
        quantity: true,
      },
    });
  }

  async restoreInventory(
    inventoryId: string,
    data: CreateInventoryDto,
  ): Promise<InventoryDetailResponseDto> {
    const inventory = await this.prisma.inventory.update({
      where: { inventoryId },
      data: {
        quantity: data.quantity,
        reorderThreshold: data.reorderThreshold ?? null,
        activeStatus: 'active',
      },
      select: inventorySelect,
    });

    return this.toInventoryListItem(inventory);
  }

  async createOne(
    data: CreateInventoryDto,
  ): Promise<InventoryDetailResponseDto> {
    const inventory = await this.prisma.inventory.create({
      data: {
        productPackageId: data.productPackageId,
        quantity: data.quantity,
        reorderThreshold: data.reorderThreshold ?? null,
      },
      select: inventorySelect,
    });

    return this.toInventoryListItem(inventory);
  }

  async softDeleteOneByPackageId(
    productPackageId: string,
  ): Promise<{ inventoryId: string }> {
    return await this.prisma.inventory.update({
      where: { productPackageId },
      data: { activeStatus: 'inactive' },
      select: {
        inventoryId: true,
      },
    });
  }

  async increaseManyForTransaction(
    items: AdjustInventoryForTransactionDto[],
  ): Promise<void> {
    await Promise.all(
      items.map((item) =>
        this.prisma.inventory.update({
          where: {
            inventoryId: item.inventoryId,
          },
          data: {
            // Dùng atomic increment để cộng tồn trực tiếp ở DB
            quantity: {
              increment: item.transactionQuantity,
            },
          },
        }),
      ),
    );
  }

  async decreaseManyForTransaction(
    items: AdjustInventoryForTransactionDto[],
  ): Promise<Set<string>> {
    const failedProductPackageIds = new Set<string>();

    for (const item of items) {
      const result = await this.prisma.inventory.updateMany({
        where: {
          inventoryId: item.inventoryId,

          // DB-level check: chỉ update khi quantity hiện tại vẫn đủ để xuất
          quantity: {
            gte: item.transactionQuantity,
          },
        },
        data: {
          quantity: {
            decrement: item.transactionQuantity,
          },
        },
      });

      // count = 0 nghĩa là update không xảy ra:
      // - hoặc inventory không tồn tại
      // - hoặc quantity không đủ tại thời điểm update
      if (result.count === 0) {
        failedProductPackageIds.add(item.productPackageId);
      }
    }

    return failedProductPackageIds;
  }

  async delete(inventoryId: string): Promise<void> {
    await this.prisma.inventory.update({
      where: { inventoryId },
      data: { activeStatus: 'inactive' },
    });
  }
}
