import { getPaginationSkip } from '../../common/utils/index.js';

import type {
  CreateProductData,
  UpdateProductDto,
  ProductResponseDto,
  DetailProductResponseDto,
  ListProductsQueryDto,
  ProductListItemDto,
  ProductsByCategoryDto,
  ProductSimpleResponseDto,
} from './product.dto.js';
import type { Prisma } from '../../../src/generated/prisma/client.js';
import type {
  DbClient,
  ListPaginationResponseDto,
} from '../../common/types/index.js';

export class ProductRepository {
  constructor(private readonly db: DbClient) {}

  async findManyByStoreId(
    storeId: string,
    query: ListProductsQueryDto,
  ): Promise<ListPaginationResponseDto<ProductListItemDto>> {
    const { page, limit, sortBy, sortOrder, categoryId, brand } = query;

    const where: Prisma.ProductWhereInput = {
      storeId,
      activeStatus: 'active',

      // nếu có giá trị thì thêm, undefined thì thôi
      ...(categoryId && { categoryId }),
      ...(brand && {
        brand: {
          equals: brand,
          mode: 'insensitive', // không phân biệt hoa thường
        },
      }),
    };

    // INFO: $transaction - chạy nhiều query trong 1 transaction
    const [items, totalItems] = await this.db.$transaction([
      this.db.product.findMany({
        where,
        orderBy: {
          [sortBy]: sortOrder,
        },
        skip: getPaginationSkip({ page, limit }),
        take: limit,
        select: {
          productId: true,
          name: true,
          imageUrl: true,
          brand: true,
          activeStatus: true,
          createdAt: true,
          updatedAt: true,
          storeId: true,
          category: {
            select: {
              categoryId: true,
              name: true,
            },
          },
        },
      }),
      this.db.product.count({
        where,
      }),
    ]);

    return {
      items,
      totalItems,
    };
  }

  async findOne(
    storeId: string,
    productId: string,
  ): Promise<ProductSimpleResponseDto | null> {
    return await this.db.product.findUnique({
      where: {
        productId,
        storeId,
        activeStatus: 'active',
      },
      select: {
        productId: true,
        name: true,
        imageUrl: true,
        brand: true,
        storeId: true,
        categoryId: true,
      },
    });
  }

  async findDetailOne(
    storeId: string,
    productId: string,
  ): Promise<DetailProductResponseDto | null> {
    const detailProduct = await this.db.product.findUnique({
      where: {
        productId,
        storeId,
        activeStatus: 'active',
      },
      select: {
        productId: true,
        name: true,
        imageUrl: true,
        brand: true,
        activeStatus: true,
        createdAt: true,
        updatedAt: true,
        storeId: true,
        category: {
          select: {
            categoryId: true,
            name: true,
          },
        },
        productPackages: {
          where: {
            activeStatus: 'active',
          },
          orderBy: {
            displayName: 'asc',
          },
          select: {
            productPackageId: true,
            displayName: true,
            variant: true,
            importPrice: true,
            sellingPrice: true,
            unit: {
              select: {
                unitId: true,
                name: true,
              },
            },
            inventory: {
              select: {
                inventoryId: true,
                quantity: true,
                reorderThreshold: true,
              },
            },
          },
        },
      },
    });

    // convert importPrice, sellingPrice từ Prisma Decimal sang number | null
    return detailProduct
      ? {
          ...detailProduct,
          productPackages: detailProduct.productPackages.map((packageItem) => ({
            ...packageItem,
            importPrice: packageItem.importPrice?.toNumber() ?? null,
            sellingPrice: packageItem.sellingPrice?.toNumber() ?? null,
          })),
        }
      : null;
  }

  async createOne(data: CreateProductData): Promise<ProductResponseDto> {
    return await this.db.product.create({
      data,
      select: {
        productId: true,
        name: true,
        imageUrl: true,
        brand: true,
        activeStatus: true,
        createdAt: true,
        updatedAt: true,
        storeId: true,
        category: {
          select: {
            categoryId: true,
            name: true,
          },
        },
      },
    });
  }

  async updateOne(
    productId: string,
    data: UpdateProductDto,
  ): Promise<ProductResponseDto> {
    return await this.db.product.update({
      where: { productId },
      data,
      select: {
        productId: true,
        name: true,
        imageUrl: true,
        brand: true,
        activeStatus: true,
        createdAt: true,
        updatedAt: true,
        storeId: true,
        category: {
          select: {
            categoryId: true,
            name: true,
          },
        },
      },
    });
  }

  async findProductsByCategoryId(
    categoryId: string,
  ): Promise<ProductsByCategoryDto> {
    const products = await this.db.product.findMany({
      where: { categoryId },
      select: {
        productId: true,
        name: true,
        imageUrl: true,
        brand: true,
        storeId: true,
        categoryId: true,
      },
    });

    return {
      count: products.length,
      products,
    };
  }

  async findManyActiveByIds(
    storeId: string,
    productIds: string[],
  ): Promise<{ productId: string; name: string }[]> {
    if (productIds.length === 0) {
      return [];
    }

    return await this.db.product.findMany({
      where: {
        productId: {
          in: productIds,
        },
        storeId,
        activeStatus: 'active',
      },
      select: {
        productId: true,
        name: true,
      },
    });
  }

  async uncategorizeMany(
    storeId: string,
    oldCategoryId: string,
    uncategorizedId: string,
  ): Promise<number> {
    const uncategorized = await this.db.product.updateMany({
      where: {
        categoryId: oldCategoryId,
        storeId,
      },
      data: {
        categoryId: uncategorizedId,
      },
    });

    return uncategorized.count;
  }

  async softDeleteOne(productId: string): Promise<{ productId: string }> {
    return await this.db.product.update({
      where: {
        productId,
      },
      data: {
        activeStatus: 'inactive',
      },
      select: {
        productId: true,
      },
    });
  }
}
